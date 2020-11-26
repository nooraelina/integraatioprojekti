Class AMK.DEV1.STAT.JSONMessage Extends (%Persistent, %JSON.Adaptor)
{

/* This class kind of missed it's original purpose as it was decided to change on to
using JSON Arrays/Strings as a means of transferring database information */
/// Currently used as a message body for getting LasMessageID
Property MessageID As %Integer;

Property RequestType As %Integer;

Property Message As %String;

Property Result As %String;

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
<Value name="10">
<Value>Message</Value>
</Value>
<Value name="11">
<Value>Result</Value>
</Value>
<Value name="12">
<Value>RequestType</Value>
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
