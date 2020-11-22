Class AMK.DEV1.STAT.StatEntryDB Extends %Persistent
{

Property IntegrationNro As %String;

Property HostName As %String;

Property ProductionName As %String;

Property TimeStamp As %TimeStamp;

Property Status As %Boolean;

Property MessageID As %Integer;

ClassMethod AddToEntryDB(TransferDB As AMK.DEV1.TransferDB) As AMK.DEV1.STAT.StatEntryDB
{
    #Dim Data As AMK.DEV1.STAT.StatEntryDB

    Set Data = ##class(AMK.DEV1.STAT.StatEntryDB).%New()
    Set Data.TimeStamp = TransferDB.TimeStamp
    Set Data.MessageID = TransferDB.%Id()
    Set Data.IntegrationNro = TransferDB.IntegrationNro
    Set Data.HostName = $SYSTEM.INetInfo.LocalHostName()
    Set Data.ProductionName = TransferDB.ProductionName
    Set Data.Status = 1

    Do Data.%Save()

    Return 1
}

Storage Default
{
<Data name="StatEntryDBDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>IntegrationNro</Value>
</Value>
<Value name="3">
<Value>HostName</Value>
</Value>
<Value name="4">
<Value>ProductionName</Value>
</Value>
<Value name="5">
<Value>TimeStamp</Value>
</Value>
<Value name="6">
<Value>Status</Value>
</Value>
<Value name="7">
<Value>MessageID</Value>
</Value>
<Value name="8">
<Value>Filename</Value>
</Value>
</Data>
<DataLocation>^AMK.DEV1.STAT.StatEntryDBD</DataLocation>
<DefaultData>StatEntryDBDefaultData</DefaultData>
<IdLocation>^AMK.DEV1.STAT.StatEntryDBD</IdLocation>
<IndexLocation>^AMK.DEV1.STAT.StatEntryDBI</IndexLocation>
<StreamLocation>^AMK.DEV1.STAT.StatEntryDBS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
