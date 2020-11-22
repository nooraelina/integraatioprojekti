Class AMK.STAT.RESTServer Extends (%CSP.REST, %Persistent)
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
	Set TableName = $GET(^Ens.LookupTable("GetTable",id))
	set query = "SELECT TOP 1 MessageID FROM AMK_STAT_StatDB."_TableName_" ORDER By MessageID DESC"
	set tStatement = ##Class(%SQL.Statement).%New()
	set qStatus = tStatement.%Prepare(query)
	set rset = tStatement.%Execute()
	do rset.%Next()
	set LastMessageID = rset.%GetData(1)
	do result.%Set("LastMessageID", LastMessageID)
	write result.%ToJSON()
	Quit result
}

ClassMethod AddtoDB(id As %String) As %Status
{
	Set result = {}
	Set i = 1
	Set TableName = $GET(^Ens.LookupTable("GetTable",id))
	Set dynObj = {}.%FromJSON(%request.Content)
	set iter = dynObj.%GetIterator() 
	while iter.%GetNext(.key , .value) {
		/// How to call a certain class? now it is just calling DB1
		try {
		Set cm = ##class(AMK.STAT.StatDB.DB1).%New()
		Set cm.IntegrationNro = value.IntegrationName
		Set cm.HostName = value.HostName
		Set cm.ProductionName = value.ProductionName
		Set cm.Status = value.Status
		Set cm.TimeStamp = value.TimeStamp
		Set cm.MessageID = value.MessageID

		Do cm.%Save()
		}
		catch err {
			do result.%Set("FailedID"_i, value.MessageID)
		}

		set i=i+1
	}

	//do result.%Set("Status",$s($$$ISERR(sc):$system.Status.GetOneErrorText(sc),1:"OK"))
	//do result.%Set("FailedID", 119)
	write result.%ToJSON()
	Quit result
}

}
