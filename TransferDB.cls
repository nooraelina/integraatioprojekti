Class AMK.DEV1.TransferDB Extends %Persistent
{

Property Filename As %String;

Property Date As %String;

Property Time As %String;

Property IntegrationName As %String;

Method OnMessage(pRequest As AMK.DEV1.SuccessChecker, Output pResponse As %Persistent) As %Status
{
	Set DB = ..AddToData(pRequest.Filename, pRequest.TimeStamp, pRequest.IntegrationName)
}

ClassMethod AddToData(oFilename, oDateTime As %Date, oIntegrationName) As AMK.DEV1.TransferDB
{
	#Dim Data As AMK.DEV1.TransferDB
	
	// Setting the correct time for the timestamp
	Set oDateTime = $ZDateTime($ZTIMESTAMP,3,,3)
	Set Secs = $ZDATETIMEH($SYSTEM.SQL.DATEADD("hour",+2,oDateTime),3,1,3)
	Set oDateTime = $ZDATETIME(Secs,3,1,3)
	
	//Creating a new Data object and saving it to the Database. Adding all the necessary information as they were passed as to the method. Chopping the Time stamp to Date and Time.
	Set Data = ##class(AMK.DEV1.TransferDB).%New()
	Set Data.Filename = oFilename
	Set Data.IntegrationName = oIntegrationName
	Set Data.Date = $Piece(oDateTime, " ",1)
	Set Data.Time = $Piece(oDateTime, " ",2)
	
	Do Data.%Save()
	
	Return 1
}

Storage Default
{
<Data name="TransferDBDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>ID</Value>
</Value>
<Value name="3">
<Value>Filename</Value>
</Value>
<Value name="4">
<Value>Date</Value>
</Value>
<Value name="5">
<Value>Time</Value>
</Value>
<Value name="6">
<Value>RealID</Value>
</Value>
<Value name="7">
<Value>IntegrationName</Value>
</Value>
</Data>
<DataLocation>^AMK.DEV1.TransferDBD</DataLocation>
<DefaultData>TransferDBDefaultData</DefaultData>
<IdLocation>^AMK.DEV1.TransferDBD</IdLocation>
<IndexLocation>^AMK.DEV1.TransferDBI</IndexLocation>
<StreamLocation>^AMK.DEV1.TransferDBS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
