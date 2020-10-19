/// Recieves Information about the transferred file and compiles and sends an E-Mail notification
Class AMK.DEV1.Mailer Extends Ens.BusinessOperation
{

Property SMTPServer As %String;

Property SMTPPort As %Integer;

Property SSLConfiguration As %String;

Property AuthUserName As %String;

Property AuthPassword As %String;

Parameter SETTINGS = "SMTPServer, SMTPPort, SSLConfiguration, AuthUserName, AuthPassword";

/*Sets up different setting, in order to send the mail to the correct address. I relly tried to make this work with the properties above (so that you could
	configure all the email setting directly from the production management portal), but I think in order for that to work this method should be an instance method
	not a class method. Changing this to an instance Method and getting everything to work just wasn't something i was able to wrap my head around :( 
	So yeah atleast for now the mail setting have to be changed within this method and won't work in the management portal */
ClassMethod GMailSMTP() As %Net.SMTP
{
  Set SetData = ##class(AMK.DEV1.Mailer).%New()
		
  Set server=##class(%Net.SMTP).%New()
  Set server.smtpserver="smtp.gmail.com"
  Set server.port="465"
  Set server.SSLConfiguration="ClientConfig"
  
  //Create object to carry authentication
  Set auth=##class(%Net.Authenticator).%New()
  Set auth.UserName="testienska@gmail.com"
  Set auth.Password="GenPy1ts"
  
  Set server.authenticator=auth
  Set server.AuthFrom=auth.UserName
  Quit server
}

// Recieves the information about the SMTP server, Filename and IntegrationName and creates and sends a success Email

ClassMethod SendSimpleMessage(server As %Net.SMTP, Filename As %String, IntegrationName) As %List
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

ClassMethod SendCopyNotification(server As %Net.SMTP, Filename As %String, IntegrationName, TimeStamp) As %List
{
  Set msg = ##class(%Net.MailMessage).%New()
  Set From=server.authenticator.UserName
  Set:From="" From="EnsmebleAlert@gmail.com"
  Set msg.From = From
  
  Do msg.To.Insert("testienska@gmail.com")
  Set msg.Subject="File Name Changed During transfer For "_Filename
  Set msg.IsBinary=0
  Set msg.IsHTML=0
  Do msg.TextData.Write("Filename "_Filename_" already exists for "_IntegrationName_" Filename Changed to "_Filename_"-"_TimeStamp)
  
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
</Data>
<DataLocation>^AMK.DEV1.MailerD</DataLocation>
<DefaultData>MailerDefaultData</DefaultData>
<IdLocation>^AMK.DEV1.MailerD</IdLocation>
<IndexLocation>^AMK.DEV1.MailerI</IndexLocation>
<StreamLocation>^AMK.DEV1.MailerS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
