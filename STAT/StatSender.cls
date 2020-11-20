Class AMK.DEV1.STAT.StatSender Extends %Persistent
{

Parameter ADAPTER = "EnsLib.HTTP.OutboundAdapter";

ClassMethod OnMessage(pRequestlastMessageID, pResponse) As %Status
{
	
	///Lähettää pyynnöt HTTP avulla RESTille
	Set Request= ##class(%Net.HttpRequest).%New()
	Set Request.Server = "serveri"
	Set Request.Location = "location"
	Set Request.Https = 1
	Set Request.SSLConfiguration = "SSLConfig"
	Set Status = Request.Get(LastMessageID) ///LastMessageID:n sisältävä page
	
	///Do Request.Get(LastMessageID)???
	
	///Set Status = Request.Get(..Location,0) Quit:$$$ISERR(tSC) Jotain mitä netistä löyty ,0 ,1 ,2 on testimetodeja
	///Set LastMessageID = SaatuJutska
	Return LastMessageID
}

ClassMethod PostJSON(jsonMessage As %String) As %Status
{
	// Kutsutaan StatCollectorista JSONin kanssa, ja odottaa vastauksena listaa tms messageideistä
	// TODO laita palauttamaan listOfLastMessageID joka tulee vastauksena Post()
	
	///Wrappaa JSONin sisällön [] sisään, löyty foorumipostista en tiedä onko hyödyllinen/välttämätön
	
	///Tekee HTTP pyynnön ja post() JSON
	Set RequestJSON= ##class(%Net.HttpRequest).%New()
	Set RequestJSON.Server = "localhost"
	Set RequestJSON.Port = 52773
	//Set RequestJSON.ContentType = "application/json"
	Do RequestJSON.EntityBody.Write(jsonMessage)
	//Set Status = ##class(%ZEN.Auxiliary.jsonProvider).%WriteJSONStreamFromObject(RequestJSON.EntityBody, jsonMessage)
	Do RequestJSON.Post("/rest/statdataupdater/addtodb/"_$GET(^Ens.LookupTable("IntegrationNro","From_Src_File")),2)
	set response = RequestJSON.HttpResponse
	
	Return response
}

/* Toimii niinku pitää ja StatFinder kutsuu tätä oikein*/
ClassMethod GetLastMessageID() As %Integer
{
    set IDrequest = ##class(%Net.HttpRequest).%New()
	set IDrequest.Server = "localhost"
	set IDrequest.Port = 52773
	Do IDrequest.Get("/rest/statdataupdater/getlastmessageid/"_$GET(^Ens.LookupTable("IntegrationNro","From_Src_File")))
	set response = IDrequest.HttpResponse
	set dynObj = {}.%FromJSON(response.Data)
	set LastMessageID = dynObj.%Get("LastMessageID")
    Return LastMessageID
}

Storage Default
{
<Data name="StatSenderDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Adapter</Value>
</Value>
</Data>
<DataLocation>^AMK.DEV1.STAT.StatSenderD</DataLocation>
<DefaultData>StatSenderDefaultData</DefaultData>
<IdLocation>^AMK.DEV1.STAT.StatSenderD</IdLocation>
<IndexLocation>^AMK.DEV1.STAT.StatSenderI</IndexLocation>
<StreamLocation>^AMK.DEV1.STAT.StatSenderS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
