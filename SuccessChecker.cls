Class AMK.DEV1.SuccessChecker Extends %Persistent
{

Property Filename As %String;

Property IntegrationName As %String;

Property Mailtype As %Integer;

Property TimeStamp As %String;

Parameter ADAPTER = "Ens.BusinessOperation";

Property Adapter As Ens.BusinessOperation;

Method CheckFileOut(tFilename As %String)
{
	/* if the file transferred and saved by PassthroughOperation2 is found in the Outbound folder, the transfer data is adde to the database
	and an Email notification is send notifying of a succesfull transfer*/
	If ##class(%File).Exists(tFilename){
		
		Set ..IntegrationName = "AMK1.1"
		Set ..Mailtype = 1
		
		//Creating a new instance of %File class in order to check the creation date of the file later
		Set File = ##class(%File).%New(tFilename)
		
		//Getting only the filename from the passed tFilename, that included the whole path
		Set ..Filename = ##class(%File).GetFilename(tFilename)
		
		//Passing required information to the TransferDB class for information storing to database
		Set DB = ##Class(AMK.DEV1.TransferDB).AddToData(..Filename, ..TimeStamp, ..IntegrationName)
		
		//Setting up a SMTP server and sending notification message of a succesfull file transfer
		//Set tEmail = ..Adapter.SendRequestAsync("AMK.Email", SuccessCheck)
		//Set Push = ##class(AMK.DEV1.APNS.APNSender).RequestPushNotification(..Filename, ..IntegrationName)
		Quit
	}Else{
	/* This Method does(and returns) nothing if the file does not exist, If the file does not exist the problem has happened 
	in some other class and that class handles alerting / Error handling */
	Set ..Mailtype = 2
	Quit
	}
}

Method PreCheck(pFilename, pFile) As %String
{
	/*Notification and timestamp adding in case the filename already exists in the outbound location.
	Done by using pFilename(cPath) passed from PassthroughOperation2's OnMessage method*/
	If ##class(%File).Exists(pFilename){
		
		Set IntegrationName = "AMK1.1"
		Set ..Mailtype = 2
		
		//Calling .GMailSMTP method that creates the SMTP server configuration for the pEmail
		//Set pServer = ##class(AMK.DEV1.Mailer).GMailSMTP()
		
		Set ..TimeStamp = $ZDATETIME($HOROLOG, 3)
		
		//Passing SMTP server configuration (pServer), Filename (pFile), IntegrationName and created TimeStamp to use constructing the notification Email
		//Set pEmail = ##class(AMK.DEV1.Mailer).SendCopyNotification(pServer, pFile, IntegrationName, ..TimeStamp)
		
		//Adding the Timestamp to the files name and returning it
		Set NewFileName = pFilename_"-"_..TimeStamp
		Set ..Filename = ##class(%File).GetFilename(NewFileName)
		Return NewFileName
	}Else{
		Set ..TimeStamp = $ZDATETIME($HOROLOG, 3)
		//Returning the filename as it came in, as there was no duplicate found
		Return pFilename
	}
}

Storage Default
{
<Data name="SuccessCheckerDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Filename</Value>
</Value>
<Value name="3">
<Value>IntegrationName</Value>
</Value>
<Value name="4">
<Value>Mailtype</Value>
</Value>
<Value name="5">
<Value>TimeStamp</Value>
</Value>
<Value name="6">
<Value>Adapter</Value>
</Value>
</Data>
<DataLocation>^AMK.DEV1.SuccessCheckerD</DataLocation>
<DefaultData>SuccessCheckerDefaultData</DefaultData>
<IdLocation>^AMK.DEV1.SuccessCheckerD</IdLocation>
<IndexLocation>^AMK.DEV1.SuccessCheckerI</IndexLocation>
<StreamLocation>^AMK.DEV1.SuccessCheckerS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
