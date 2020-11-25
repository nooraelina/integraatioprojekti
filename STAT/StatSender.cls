Class AMK.DEV1.STAT.StatSender Extends (Ens.BusinessOperation, Ens.OutboundAdapter, Ens.Adapter)
{

Parameter ADAPTER = "EnsLib.HTTP.OutboundAdapter";

Property Adapter As EnsLib.HTTP.OutboundAdapter;

Method OnMessage(pRequest As %Persistent, Output pResponse As %Persistent) As %Status
{
	Set status = $$$OK
	if pRequest.RequestType = 1 {
		set result = ..GetLastMessageID()
		$$$TRACE("result = "_result)
		$$$TRACE("MessageID = "_pRequest.MessageID)
		Set JSONMessage = ##class(AMK.DEV1.STAT.JSONMessage).%New()
		Set JSONMessage.MessageID = result
		set pResponse = JSONMessage
		Return pResponse
	} ElseIf pRequest.RequestType = 2 {
		set message = pRequest.Message
		set result = ..PostJSON(message)
		Set JSONMessage = ##class(AMK.DEV1.STAT.JSONMessage).%New()
		Set JSONMessage.Result = result
		set pResponse = JSONMessage
		Return pResponse
	} Else {
		Quit status
	}
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
	Do RequestJSON.Post("/rest/statdataupdater/addtodb/"_$GET(^Ens.LookupTable("IntegrationNro","From_Src_File")))
	set response = RequestJSON.HttpResponse

	set dynObj = {}.%FromJSON(response.Data)
	set iter = dynObj.%GetIterator()
	set SavedList = $Listbuild()
	set i=1
	while iter.%GetNext(.key, .value) {
		set $LIST(SavedList, i) = value
		set i = i+1

	}
	
	Return SavedList
}

/* Toimii niinku pitää ja StatFinder kutsuu tätä oikein*/
Method GetLastMessageID() As %Integer
{
    set IDrequest = ##class(%Net.HttpRequest).%New()
	set IDrequest.Server = ..Adapter.HTTPServer
	set IDrequest.Port = ..Adapter.HTTPPort
	Do IDrequest.Get(..Adapter.URL_"/getlastmessageid/"_$GET(^Ens.LookupTable("IntegrationNro","From_Src_File")))
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
