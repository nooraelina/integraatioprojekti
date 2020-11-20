Class AMK.DEV1.STAT.JSONMessage Extends (%Persistent, %JSON.Adaptor)
{

Property IntegrationName As %String(%JSONFIELDNAME = "integrationName");

Property HostName As %String(%JSONFIELDNAME = "hostName");

Property ProductionName As %String(%JSONFIELDNAME = "productionName");

Property Status As %Boolean(%JSONFIELDNAME = "status");

Property Filename As %String(%JSONFIELDNAME = "filename");

Property TimeStamp As %TimeStamp(%JSONFIELDNAME = "timeStamp");

Property MessageID As %Integer(%JSONFIELDNAME = "messageID");

Storage Default
{
<Data name="JSONMessageDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>IntegrationName</Value>
</Value>
<Value name="3">
<Value>Hostname</Value>
</Value>
<Value name="4">
<Value>ProductionName</Value>
</Value>
<Value name="5">
<Value>Status</Value>
</Value>
<Value name="6">
<Value>Filename</Value>
</Value>
<Value name="7">
<Value>TimeStamp</Value>
</Value>
<Value name="8">
<Value>MessageID</Value>
</Value>
<Value name="9">
<Value>HostName</Value>
</Value>
</Data>
<DataLocation>^AMK.DEV1.STAT.JSONMessageD</DataLocation>
<DefaultData>JSONMessageDefaultData</DefaultData>
<IdLocation>^AMK.DEV1.STAT.JSONMessageD</IdLocation>
<IndexLocation>^AMK.DEV1.STAT.JSONMessageI</IndexLocation>
<StreamLocation>^AMK.DEV1.STAT.JSONMessageS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
