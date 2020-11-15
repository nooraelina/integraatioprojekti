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

ClassMethod PostJSON()
{
	// Kutsutaan StatCollectorista JSONin kanssa, ja odottaa vastauksena listaa tms messageideistä
	// TODO laita palauttamaan listOfLastMessageID joka tulee vastauksena Post()
	
	Set Body =  ##Class(AMK.DEV1.StatCollector).CreateJSON()
	
	///Wrappaa JSONin sisällön [] sisään, löyty foorumipostista en tiedä onko hyödyllinen/välttämätön
	set List = ##class(%ListOfObjects).%New()
	Do List.Insert(Body)
	
	///Tekee HTTP pyynnön ja post() JSON
	Set RequestJSON= ##class(%Net.HttpRequest).%New()
	Set RequestJSON.Server = "serveri"
	Set RequestJSON.Location = "location"
	Set RequestJSON.Https = 1
	Set RequestJSON.SSLConfiguration = "SSLConfig"
	Set RequestJSON.ContentType = "application/json"
	Set Status = ##class(%ZEN.Auxiliary.jsonProvider).%WriteJSONStreamFromObject(Request.EntityBody,  Body)	
	Set Status = RequestJSON.Post()
	
	Return ListMessageID
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
