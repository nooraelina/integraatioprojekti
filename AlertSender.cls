Class AMK.DEV1.APNS.AlertSender Extends (Ens.BusinessOperation, Ens.Adapter)
{

Parameter ADAPTER = "EnsLib.HTTP.OutboundAdapter";

Property Adapter As EnsLib.HTTP.OutboundAdapter;

Property Devices As %String;

Parameter INVOCATION = "Queue";

Parameter SETTINGS = "Devices";

/// This is the ID name of the set of credentials values to be used to access the external system
Property Credentials As %String;

Method OnMessage(pAlertRequest As Ens.AlertRequest, Output pResponse As Ens.Response) As %Status
{
		Set tStatus = $$$OK
		
		#Dim tDevice As %String
		#Dim tToken As %String
		#Dim tUser As %String
		
		Try {
			Set tHttpsrequest = ##class(%Net.HttpRequest).%New()
			
			Set tDevice = ..Devices
			
			// Add credentials (Ens.Adapter)
			If '$IsObject(..%CredentialsObj) Do ..CredentialsSet(..Credentials) If '$IsObject(..Adapter.%CredentialsObj) { Set tStatus=$$$EnsError($$$EnsErrNoCredentials,..Credentials) Quit }
			Set tToken = ..Adapter.%CredentialsObj.Password
			Set tUser = ..Adapter.%CredentialsObj.Username

			Set tHttpsrequest.Server=..Adapter.HTTPServer
			Set tHttpsrequest.Https=$$$YES
			Set tHttpsrequest.SSLConfiguration=..Adapter.SSLConfig

			// Construct the alert msg
			Do tHttpsrequest.SetParam("device", tDevice)
			Do tHttpsrequest.SetParam("token", tToken)
			Do tHttpsrequest.SetParam("user", tUser)
 			Do tHttpsrequest.SetParam("title", "AMK1.1 hälytys")
 			Do tHttpsrequest.SetParam("message", pAlertRequest.SourceConfigName_", Session: "_pAlertRequest.SessionId) 	
 			
 			Set status = tHttpsrequest.Post(..Adapter.URL)

			Set pResponse = tHttpsrequest.HttpResponse

			Return pResponse
 			
		}
		Catch {
			Set tStatus = $$$EnsSystemError
		}
		Quit tStatus
}

}
