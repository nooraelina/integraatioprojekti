Class AMK.DEV1.STAT.StatSender Extends %Persistent
{

ClassMethod GetLastMessageID() As %Integer
{
    Set LastMessageID = 108
    Return LastMessageID
}

Storage Default
{
<Data name="StatSenderDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
</Data>
<DataLocation>^AMK.DEV1.STAT.StatSenderD</DataLocation>
<DefaultData>StatSenderDefaultData</DefaultData>
<IdLocation>^AMK.DEV1.STAT.StatSenderD</IdLocation>
<IndexLocation>^AMK.DEV1.STAT.StatSenderI</IndexLocation>
<StreamLocation>^AMK.DEV1.STAT.StatSenderS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
