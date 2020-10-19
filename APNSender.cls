/// Class for sending a push notification to iphone
Class AMK.DEV1.APNS.APNSender Extends (Ens.BusinessOperation, Ens.OutboundAdapter, %Net.PushNotifications.APNS)
{

/// This is the ID name of the set of credentials values to be used to access the pushover server
Property Credentials As %String;

/// Choose alert or success APN, if needed both, do another operation
Property NotificationProtocol As %String(DISPLAYLIST = ",SuccessMsg,Alert", VALUELIST = ",success,alert") [ Required ];

Property SSLConfiguration As %String;

Property SSLCheckServerIdentity As %Boolean [ InitialExpression = 0 ];

Parameter SERVICETYPE As %String = "APNS";

Parameter INVOCATION = "Queue";

Parameter DEVICETOKENLENGTH As %Integer = 32;

Parameter SETTINGS As %String = "Credentials:Basic:credentialsSelector,NotificationProtocol:Basic,SSLConfig:Connection:sslConfigSelector,SSLCheckServerIdentity:Connection";

/// First, checking what kind of msg we are going to send
Method PushNotification(pRequest As EnsLib.PushNotifications.NotificationRequest, ByRef pResponse As EnsLib.PushNotifications.NotificationResponse) As %Status
{
	If pRequest.Service'=..#SERVICETYPE {
		Quit $$$ERROR("error",pRequest.Service)
	} Else {
		Quit $CASE(..NotificationProtocol,
					 "success":..SendPushNotification(pRequest,.pResponse),
					   "alert":..SendAlertPushNotification(pRequest,.pResponse),
					          :$$$ERROR("EnsPushNotificationsErrNotificationProtocolNotSupported",..NotificationProtocol))
	}
}

ClassMethod RequestPushNotification(Filename, IntegrationName)
{
	Set pRequest = ##class(EnsLib.PushNotifications.NotificationRequest).%New()
	Set pRequest.Service = "APNS"
	Set pRequest.Identifiers = "ipad1"
	Set pResponse = ##class(EnsLib.PushNotifications.NotificationResponse).%New()

	Set SendPush = ##class(AMK.DEV1.APNS.APNSender).SendPushNotification(pRequest, pResponse, Filename, IntegrationName)

	Return SendPush
}

ClassMethod SendPushNotification(pRequest As EnsLib.PushNotifications.NotificationRequest, ByRef pResponse As EnsLib.PushNotifications.NotificationResponse, Filename As %String, IntegrationName)
{
	Set httpsrequest = ##class(%Net.HttpRequest).%New()
	
 	Set httpsrequest.Server="api.pushover.net"
 	Set httpsrequest.Https=$$$YES
 	Set httpsrequest.SSLConfiguration="ClientConfig"
 	
 	// TODO call credentialsset and add that to httpsreq
 	
 	// Send other info; device, title, message

 	Do httpsrequest.SetParam("device", "ipad1")
	Do httpsrequest.SetParam("token", "anafhq3uf6r686vbhpgs1zvnic5b18")
	Do httpsrequest.SetParam("user", "u5d2491xhnesvkq7bjpagm5nqshd6s")
 	Do httpsrequest.SetParam("title", ""_IntegrationName_" Aineisto siirretty")
 	Do httpsrequest.SetParam("message", "Tiedosto "_Filename_" siirretty")
 	
 	Set status = httpsrequest.Post("/1/messages.json") // Tämän pitäisi lähettää https request, toinen vaihtoehto käyttää Post() jos tää ei toimi
 	
 	Set pResponse = httpsrequest.HttpResponse
 	
 	// Remember when we actually delivered it
	// Set pRresponse.DeliveredAtUTC = $ZDT($system.Util.LocalWithZTIMEZONEtoUTC($H),3)
	//TODO response / request classes
	Return pResponse
}

Method SendAlertPushNotification(pRequest As EnsLib.PushNotifications.NotificationRequest, ByRef pResponse As EnsLib.PushNotifications.NotificationResponse, Filename As %String, IntegrationName)
{
	
	Set httpsrequest = ##class(%Net.HttpRequest).%New()
	
 	Set httpsrequest.Server="api.pushover.net"
 	Set httpsrequest.Https=$$$YES
 	Set httpsrequest.SSLConfiguration="TEST"
 	
	Set msg("device") = "iphoneWhite"
	Set msg("title") = ""_IntegrationName_" hälytys"
 	Set msg("message") = SourceConfigName_", Session: "_session_number  
 	// Vaihda oikeisiin nimiin ^
}

Method CredentialsSet(pInVal As %String) As %Status
{
	
	//Set tSC=##super(pInVal)  Quit:$$$ISERR(tSC) tSC

	// Set the authenticator to be used to connect on demand
	Set tHasUsername=$IsObject(..%CredentialsObj)&&(""'=..%CredentialsObj.Username)
	// Set user and token as given in credentials
	Set:tHasUsername user = ..%CredentialsObj.Username, token = ..%CredentialsObj.Password
	
	Quit tHasUsername
}

XData MessageMap
{
<MapItems>
	<MapItem MessageType="EnsLib.PushNotifications.NotificationRequest"> 
		<Method>PushNotification</Method>
	</MapItem>
</MapItems>
}

}
