/// Class for sending a push notification to iphone
Class AMK.DEV1.APNS.APNSender Extends (Ens.BusinessOperation, Ens.OutboundAdapter, %Net.PushNotifications.APNS)
{

/// This is the ID name of the set of credentials values to be used to access the pushover server
Property Credentials As %String;

/// Choose alert or success APN, if needed both, do another operation
Property NotificationProtocol As %String(DISPLAYLIST = ",SuccessMsg,Alert", VALUELIST = ",success,alert") [ Required ];

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

ClassMethod SendPushNotification(pRequest As EnsLib.PushNotifications.NotificationRequest, ByRef pResponse As EnsLib.PushNotifications.NotificationResponse, Filename As %String, IntegrationName)
{
	Set httpsrequest = ##class(%Net.HttpRequest).%New()
	
 	Set httpsrequest.Server="api.pushover.net"
 	Set httpsrequest.Https=$$$YES
 	Set httpsrequest.SSLConfiguration="TEST"
 	
 	// TODO call credentialsset and add that to httpsreq
 	
 	// Send other info; device, title, message
 	Set msg("device") = pRequest.Identifiers.GetAt(1)
 	Set msg("title") = ""_IntegrationName_" Aineisto siirretty"
 	Set msg("message") = "Tiedosto "_Filename_" siirretty"
 	/*
 	Set title1 = title("TITLE")
 	Set msg = message("MESSAGE")
 	Set deviceInfo = device("DEVICE")
 	*/
 	Set httpsrequest.Params = msg
 	
 	Set status = httpsrequest.Get("/1/messages.json")
 	
 	Set response = httpsrequest.HttpResponse
 	
 	// Remember when we actually delivered it
	Set response.DeliveredAtUTC = $ZDT($system.Util.LocalWithZTIMEZONEtoUTC($H),3)
	//TODO response / request classes
}

Method SendAlertPushNotification(pRequest As EnsLib.PushNotifications.NotificationRequest, ByRef pResponse As EnsLib.PushNotifications.NotificationResponse, Filename As %String, IntegrationName)
{
	Quit $$$ERROR($$$NotImplemented)
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
