/// Class for sending a push notification to iphone
Class AMK.DEV1.APNS.APNSender Extends (Ens.BusinessOperation, Ens.OutboundAdapter, %Net.PushNotifications.APNS, Ens.Adapter)
{

/// This is the ID name of the set of credentials values to be used to access the pushover server
Property Credentials As %String;

Parameter ADAPTER = "EnsLib.HTTP.OutboundAdapter";

Property Adapter As EnsLib.HTTP.OutboundAdapter;

Property Devices As %String;

Parameter INVOCATION = "Queue";

Parameter SETTINGS As %String = "Devices";

// Legacy ClassMethod, not in use. Left alone for now.

ClassMethod RequestPushNotification(Filename, IntegrationName) As AMK.DEV1.APNS.APNSender
{
	#Dim SendPush As AMK.DEV1.APNS.APNSender
	Set pRequest = ##class(EnsLib.PushNotifications.NotificationRequest).%New()
	Set pRequest.Service = "APNS"
	Set pRequest.Identifiers = "ipad1"
	Set pResponse = ##class(EnsLib.PushNotifications.NotificationResponse).%New()

	Set SendPush = ##class(AMK.DEV1.APNS.APNSender).%New()
	Do SendPush.SendPushNotification(pRequest, pResponse, Filename, IntegrationName)

	Return SendPush
}

// Recieves a push request and sends it according to the production settings

Method OnMessage(pRequest As AMK.DEV1.SuccessChecker, Output pResponse As Ens.Response) As %Status
{
	Set tStatus = $$$OK

	#Dim tDevice As %String
	#Dim tToken As %String
	#Dim tUser As %String

	Set httpsrequest = ##class(%Net.HttpRequest).%New()
	
 	Set httpsrequest.Server=..Adapter.HTTPServer
 	Set httpsrequest.Https=$$$YES
 	Set httpsrequest.SSLConfiguration=..Adapter.SSLConfig

	If '$IsObject(..%CredentialsObj) Do ..CredentialsSet(..Credentials) If '$IsObject(..Adapter.%CredentialsObj) { Set tStatus=$$$EnsError($$$EnsErrNoCredentials,..Credentials) Quit }
	Set tToken = ..Adapter.%CredentialsObj.Password
	Set tUser = ..Adapter.%CredentialsObj.Username

	Set tDevice = ..Devices

 	Do httpsrequest.SetParam("device", tDevice)
	Do httpsrequest.SetParam("token", tToken)
	Do httpsrequest.SetParam("user", tUser)
 	Do httpsrequest.SetParam("title", ""_pRequest.IntegrationName_" Aineisto siirretty")
 	Do httpsrequest.SetParam("message", "Tiedosto "_pRequest.Filename_" siirretty")
 	
 	Set status = httpsrequest.Post(..Adapter.URL)
 	
 	Set pResponse = httpsrequest.HttpResponse
 	
 	// Remember when we actually delivered it
	// Set pRresponse.DeliveredAtUTC = $ZDT($system.Util.LocalWithZTIMEZONEtoUTC($H),3)
	Quit tStatus
}

// Legacy ClassMethod, not in use. Left alone for now.

Method CredentialsSet(pInVal As %String) As %Status
{
	
	//Set tSC=##super(pInVal)  Quit:$$$ISERR(tSC) tSC

	// Set the authenticator to be used to connect on demand
	Set tHasUsername=$IsObject(..%CredentialsObj)&&(""'=..%CredentialsObj.Username)
	// Set user and token as given in credentials
	Set:tHasUsername user = ..%CredentialsObj.Username, token = ..%CredentialsObj.Password
	
	Quit tHasUsername
}

}
