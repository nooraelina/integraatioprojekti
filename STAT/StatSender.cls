Class AMK.DEV1.STAT.StatSender Extends %Persistent
{

Property Adapter As EnsLib.HTTP.OutboundAdapter;

Parameter ADAPTER = "EnsLib.HTTP.OutboundAdapter";

ClassMethod OnMessage(pRequestlastMessageID, pResponse) As %Status
{
	
	
	Set Request= ##class(%Net.HttpRequest).%New()
	Set Request.Server = "serveri"
	Set Request.Location = "location"
	Set Request.Https = 1
	Set Request.SSLConfiguration = "SSLConfig"
	Set Status = Request.Get(LastMessageID)
	
	///Set Status = Request.Get(LastMessageID)
}

ClassMethod PostJSON()
{
	
	///Tänne se JSON kai
	
	///Wrappaa JSONin sisällön []
	set List = ##class(%ListOfObjects).%New()
	Do List.Insert(Body)
	
	///Tekee HTTP pyynnön ja post() JSON
	Set Request= ##class(%Net.HttpRequest).%New()
	Set Request.Server = "serveri"
	Set Request.Location = "location"
	Set Request.Https = 1
	Set Request.SSLConfiguration = "SSLConfig"
	Set Request.ContentType = "application/json"
	Set Status = ##class(%ZEN.Auxiliary.jsonProvider).%WriteJSONStreamFromObject(Request.EntityBody,  Body)	
	Set Status = Request.Post()
}

/* Käytössä vaan testausta varten*/
ClassMethod GetLastMessageID() As %Integer
{
    Set LastMessageID = 108
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
