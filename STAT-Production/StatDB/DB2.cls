Class AMK.STAT.StatDB.DB2 Extends %Persistent
{

Property MessageID As %Integer;

Property IntegrationNro As %String;

Property ProductionName As %String;

Property TimeStamp As %TimeStamp;

Property HostName As %String;

Property Status As %Boolean;

Storage Default
{
<Data name="DB2DefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>MessageID</Value>
</Value>
<Value name="3">
<Value>IntegrationNro</Value>
</Value>
<Value name="4">
<Value>ProductionName</Value>
</Value>
<Value name="5">
<Value>TimeStamp</Value>
</Value>
<Value name="6">
<Value>HostName</Value>
</Value>
<Value name="7">
<Value>Status</Value>
</Value>
</Data>
<DataLocation>^AMK.STAT.StatDB.DB2D</DataLocation>
<DefaultData>DB2DefaultData</DefaultData>
<IdLocation>^AMK.STAT.StatDB.DB2D</IdLocation>
<IndexLocation>^AMK.STAT.StatDB.DB2I</IndexLocation>
<StreamLocation>^AMK.STAT.StatDB.DB2S</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
