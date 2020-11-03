/// Recieves Information about the transferred file and compiles and sends an E-Mail notification
Class AMK.DEV1.Mailer Extends (Ens.BusinessOperation, Ens.Adapter)
{

Property SMTPServer As %String;

Property SMTPPort As %Integer;

Property SSLConfiguration As %String;

Property Credentials As %String;

Parameter SETTINGS = "SMTPServer, SMTPPort, Credentials:Basic:credentialsSelector, SSLConfiguration:Connection:sslConfigSelector";

/*Sets up different setting, in order to send the mail to the correct address. I relly tried to make this work with the properties above (so that you could
	configure all the email setting directly from the production management portal), but I think in order for that to work this method should be an instance method
	not a class method. Changing this to an instance Method and getting everything to work just wasn't something i was able to wrap my head around :( 
	So yeah atleast for now the mail setting have to be changed within this method and won't work in the management portal */
Method OnMessage(pRequest As AMK.DEV1.SuccessChecker, Output pResponse As %Persistent) As %Status
{
  if pRequest.Mailtype = 1 {
    Set server = ..GMailSMTP()
    Set message = ..SendSimpleMessage(server, pRequest.Filename, pRequest.IntegrationName)
  }
  ElseIf pRequest.Mailtype = 2 {
    Set server = ..GMailSMTP()
    Set message = ..SendCopyNotification(server, pRequest.Filename, pRequest.IntegrationName, pRequest.TimeStamp, pRequest.OriginalFileName)
  }	Else{
    Quit 
  }
  Quit message
}

Method GMailSMTP() As %Net.SMTP
{
		
  Set server=##class(%Net.SMTP).%New()
  Set server.smtpserver=..SMTPServer
  Set server.port=..SMTPPort
  Set server.SSLConfiguration=..SSLConfiguration
  
  //Create object to carry authentication
  Set auth=##class(%Net.Authenticator).%New()
  If '$IsObject(..%CredentialsObj) Do ..CredentialsSet(..Credentials) If '$IsObject(..%CredentialsObj) { Set tStatus=$$$EnsError($$$EnsErrNoCredentials,..Credentials) Quit }
  Set auth.UserName= ..%CredentialsObj.Username
  Set auth.Password= ..%CredentialsObj.Password
  
  Set server.authenticator=auth
  Set server.AuthFrom=auth.UserName
  Quit server
}

// Recieves the information about the SMTP server, Filename and IntegrationName and creates and sends a success Email

Method SendSimpleMessage(server As %Net.SMTP, Filename As %String, IntegrationName, Output pResponse As %Persistent) As %Status
{
  Set msg = ##class(%Net.MailMessage).%New()
  Set From=server.authenticator.UserName
  Set:From="" From="EnsmebleAlert@gmail.com"
  Set msg.From = From
  
  Do msg.To.Insert("testienska@gmail.com")
  Set msg.Subject="File Transfer Successfull For "_Filename
  Set msg.IsBinary=0
  Set msg.IsHTML=0
  Do msg.TextData.Write("File Transfer Successfull: "_Filename_" on "_IntegrationName)
  
  Set status=server.Send(msg)
  If $$$ISERR(status) {
    Do $System.Status.DisplayError(status)
    Write server.Error
    Quit ""
  }
  Quit server.FailedSend
}

// Recieves the information about the SMTP server and other file relaterd stuff and send a notification Email that the filename was changed during the integration because of a duplicate

Method SendCopyNotification(server As %Net.SMTP, Filename As %String, IntegrationName, TimeStamp, OriginalFileName) As %List
{
  Set msg = ##class(%Net.MailMessage).%New()
  Set From=server.authenticator.UserName
  Set:From="" From="EnsmebleAlert@gmail.com"
  Set msg.From = From
  
  Do msg.To.Insert("testienska@gmail.com")
  Set msg.Subject="File Name Changed During transfer For "_OriginalFileName
  Set msg.IsBinary=0
  Set msg.IsHTML=0
  Do msg.TextData.Write("Filename "_OriginalFileName_" already exists for "_IntegrationName_" Filename Changed to "_Filename)
  
  Set status=server.Send(msg)
  If $$$ISERR(status) {
    Do $System.Status.DisplayError(status)
    Write server.Error
    Quit ""
  }
  Quit server.FailedSend
}

Storage Default
{
<Data name="MailerDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>SMTPServer</Value>
</Value>
<Value name="3">
<Value>SMTPPort</Value>
</Value>
<Value name="4">
<Value>SSLConfiguration</Value>
</Value>
<Value name="5">
<Value>AuthUserName</Value>
</Value>
<Value name="6">
<Value>AuthPassword</Value>
</Value>
<Value name="7">
<Value>%RequestHeader</Value>
</Value>
<Value name="8">
<Value>ReplyCodeActions</Value>
</Value>
<Value name="9">
<Value>AlertOnError</Value>
</Value>
<Value name="10">
<Value>AlertRetryGracePeriod</Value>
</Value>
<Value name="11">
<Value>BusinessPartner</Value>
</Value>
<Value name="12">
<Value>AlertGroups</Value>
</Value>
<Value name="13">
<Value>QueueWaitAlert</Value>
</Value>
<Value name="14">
<Value>%QuitTask</Value>
</Value>
<Value name="15">
<Value>%SessionId</Value>
</Value>
<Value name="16">
<Value>NoFailWhileDisconnected</Value>
</Value>
<Value name="17">
<Value>Retry</Value>
</Value>
<Value name="18">
<Value>SuspendMessage</Value>
</Value>
<Value name="19">
<Value>DeferResponse</Value>
</Value>
<Value name="20">
<Value>%AlertStartTime</Value>
</Value>
<Value name="21">
<Value>RetryCount</Value>
</Value>
<Value name="22">
<Value>Adapter</Value>
</Value>
<Value name="23">
<Value>%ConfigQueueName</Value>
</Value>
<Value name="24">
<Value>%ConfigName</Value>
</Value>
<Value name="25">
<Value>%SuperSession</Value>
</Value>
<Value name="26">
<Value>ArchiveIO</Value>
</Value>
<Value name="27">
<Value>FailureTimeout</Value>
</Value>
<Value name="28">
<Value>IOLogEntry</Value>
</Value>
<Value name="29">
<Value>InactivityTimeout</Value>
</Value>
<Value name="30">
<Value>QueueCountAlert</Value>
</Value>
<Value name="31">
<Value>RetryInterval</Value>
</Value>
<Value name="32">
<Value>SendSuperSession</Value>
</Value>
<Value name="33">
<Value>ThrottleDelay</Value>
</Value>
</Data>
<DataLocation>^AMK.DEV1.MailerD</DataLocation>
<DefaultData>MailerDefaultData</DefaultData>
<IdLocation>^AMK.DEV1.MailerD</IdLocation>
<IndexLocation>^AMK.DEV1.MailerI</IndexLocation>
<StreamLocation>^AMK.DEV1.MailerS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
