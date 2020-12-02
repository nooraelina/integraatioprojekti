Class AMK.STAT.RESTServer Extends (%CSP.REST, %Persistent, Ens.BusinessService)
{

Parameter HandleCorsRequest = 1;

XData UrlMap [ XMLNamespace = "http://www.intersystems.com/urlmap" ]
{
<Routes>
	<Route Url="/test" Method="GET" Call="Test"/>
	<Route Url="/getlastmessageid/:id" Method="GET" Call="GetLastMessageID" />
	<Route Url="/addtodb/:id" Method="POST" Call="AddtoDB" />
</Routes>
}

ClassMethod Test() As %Status
{
	Set result={}
	do result.%Set("Status", "Jees")
	write result.%ToJSON()
	Quit $$$OK
}

ClassMethod GetLastMessageID(id As %String) As %Status
{
	Set result={}

	/*Koitettu asettaa if ehto joka asettaa ^LastMessageID:n olemaan DB1 lasMessageID:n mukainen
	mikäli kyseiselle globaalille ei ole vielä annettu arvoa (tiedä sitten mikä on globaalin lähtöarvo) 
	Alla olevalla kommentoidulla haulla (ilman if ehtoa) saa tarvittaessa ainakin alkuun LastMessageID:n*/

	
	Set TableName = $GET(^Ens.LookupTable("GetTable",id))
	set query = "SELECT TOP 1 MessageID FROM AMK_STAT_StatDB."_TableName_" ORDER By MessageID DESC"
	set tStatement = ##Class(%SQL.Statement).%New()
	set qStatus = tStatement.%Prepare(query)
	set rset = tStatement.%Execute()
	do rset.%Next()
	set MessageID = rset.%GetData(1)
	if MessageID = "" {
		set ^LastMessageID = 1
	}
	

	do result.%Set("LastMessageID", ^LastMessageID)
	write result.%ToJSON()
	Quit result
}

ClassMethod AddtoDB(id As %String) As %Status
{
	Set result = {}
	Set i = 1
	/// Haetaan lookuptablesta oikea Database IntegrationNro:lla (esim. INT-1234), johon tiedot tallennetaan
	Set TableName = $GET(^Ens.LookupTable("GetTable",id))
	Set dynObj = {}.%FromJSON(%request.Content)
	set iter = dynObj.%GetIterator() 
	while iter.%GetNext(.key , .value) {
		try {
		Set cm = $CLASSMETHOD("AMK.STAT.StatDB."_TableName, "%New")
		Set cm.IntegrationNro = value.IntegrationNro
		Set cm.HostName = value.HostName
		Set cm.ProductionName = value.ProductionName
		Set cm.Status = value.Status
		Set cm.TimeStamp = value.TimeStamp
		Set cm.MessageID = value.MessageID

		Do cm.%Save()

		//asetetaa globaali ^LastMessageID olemaan viimeisin tallennettun olion ID
		Set ^LastMessageID = value.MessageID

		do result.%Set("SavedID"_i, value.MessageID)
		}
		catch err {
			write !, "Error name: ", ?20, err.Name,
			!, "Error code: ", ?20, err.Code,
			!, "Error locatio: ", ?20, err.Location,
			!, "Additional data: ", ?20, err.Data, !
		}

		set i=i+1
	}

	write result.%ToJSON()
	Quit result
}

}
