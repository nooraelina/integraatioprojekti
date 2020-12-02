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

/* tämä tarkoitus muuttaa vielä ClassMetodista Methodiksi, mutta jostain syystä toiminta ei 
vaan skulannut vaikka lähes täysin identtisellä toiminnolla varustettu GetLastMessageID pelittää */
ClassMethod PostJSON(jsonMessage As %String, integrationNro As %String) As %Status
{
	// Kutsutaan StatCollectorista JSONin kanssa, ja odottaa vastauksena listaa tms messageideistä
	
	///Tekee HTTP pyynnön ja post() JSON
	Set RequestJSON= ##class(%Net.HttpRequest).%New()
	Set RequestJSON.Server = ##class(Ens.Director).GetItemSettingValue("StatSender", "Adapter", "HTTPServer", .status)
	Set RequestJSON.Port = ##class(Ens.Director).GetItemSettingValue("StatSender", "Adapter", "HTTPPort", .status)
	Set URL = ##class(Ens.Director).GetItemSettingValue("StatSender", "Adapter", "URL", .status)
	Do RequestJSON.EntityBody.Write(jsonMessage)
	Do RequestJSON.Post(URL_"/addtodb/"_integrationNro)
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
