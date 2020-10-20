Class AMK.DEV1.SuccessChecker Extends Ens.BusinessOperation
{

ClassMethod CheckFileOut(tFilename)
{
	/* if the file transferred and saved by PassthroughOperation2 is found in the Outbound folder, the transfer data is adde to the database
	and an Email notification is send notifying of a succesfull transfer*/
	If ##class(%File).Exists(tFilename){
		
		Set IntegrationName = "AMK1.1"
		
		//Creating a new instance of %File class in order to check the creation date of the file later
		Set File = ##class(%File).%New(tFilename)
		
		//Getting only the filename from the passed tFilename, that included the whole path
		Set OnlyFileName = ##class(%File).GetFilename(tFilename)
		
		//Passing required information to the TransferDB class for information storing to database
		$$$TRACE("Saving file information to Database by calling AMK.DEV1.TransferDB")
		Set DB = ##Class(AMK.DEV1.TransferDB).AddToData(OnlyFileName, File.DateCreatedGet(), IntegrationName)
		
		//Setting up a SMTP server and sending notification message of a succesfull file transfer
		Set tServer = ##class(AMK.DEV1.Mailer).GMailSMTP()
		Set tEmail = ##class(AMK.DEV1.Mailer).SendSimpleMessage(tServer, OnlyFileName, IntegrationName)
		Set Push = ##class(AMK.DEV1.APNS.APNSender).RequestPushNotification(OnlyFileName, IntegrationName)
		$$$TRACE("Email notification sent of succesfull file transmission, returning")
		Quit
}Else{
	/* This Method does(and returns) nothing if the file does not exist, If the file does not exist the problem has happened 
	in some other class and that class handles alerting / Error handling */
	Quit
}
}

ClassMethod PreCheck(pFilename, pFile) As %String
{
	/*Notification and timestamp adding in case the filename already exists in the outbound location.
	Done by using pFilename(cPath) passed from PassthroughOperation2's OnMessage method*/
	If ##class(%File).Exists(pFilename){
		
		Set IntegrationName = "AMK1.1"
		
		//Calling .GMailSMTP method that creates the SMTP server configuration for the pEmail
		Set pServer = ##class(AMK.DEV1.Mailer).GMailSMTP()
		
		Set TimeStamp = $ZDATETIME($HOROLOG, 3)
		
		//Passing SMTP server configuration (pServer), Filename (pFile), IntegrationName and created TimeStamp to use constructing the notification Email
		$$$TRACE("Duplicate Filename already in the Folder. Sending Email notification")
		Set pEmail = ##class(AMK.DEV1.Mailer).SendCopyNotification(pServer, pFile, IntegrationName, TimeStamp)
		
		//Adding the Timestamp to the files name and returning it
		Set NewFileName = pFilename_"-"_TimeStamp
		$$$TRACE("Added Timestamp to Filename, returning")
		Return NewFileName
	}Else{
		//Returning the filename as it came in, as there was no duplicate found
		$$$TRACE("No Duplicate Filename found, returning.")
		Return pFilename
}
}

Storage Default
{
<Data name="SuccessCheckerDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
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
