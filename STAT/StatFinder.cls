Class AMK.DEV1.STAT.StatFinder Extends (Ens.BusinessService, %Persistent)
{

Property LastMessageID As %Integer;

Property LatestMessageID As %Integer;

Property TransferDBID As %Integer;

Property Adapter As Ens.InboundAdapter;

Parameter ADAPTER = "Ens.InboundAdapter";

Method OnProcessInput(pInput As %RegisteredObject, pOutput As %RegisteredObject) As %Status
{
    //Getting the ID of the latest message saved in STAT Database. Asking LastMessageID through StatSender process
    set ..LastMessageID = ##Class(AMK.DEV1.STAT.StatSender).GetLastMessageID()

    //Getting the ID of the latest message saved to local Database
    set query = "SELECT TOP 1 ID FROM AMK_DEV1.TransferDB ORDER By ID DESC"
    set tStatement = ##Class(%SQL.Statement).%New()
    set qStatus = tStatement.%Prepare(query)
    set rset = tStatement.%Execute()
    do rset.%Next()
    Set ..TransferDBID = rset.%GetData(1)

    if ..LastMessageID '= ..LatestMessageID {
        Set task = ..UpdateStatEntryDB()
        Set ..LatestMessageID = ..LastMessageID
    } else{
        Set task = 1
        Quit task
    }
    Quit task
}

Method UpdateStatEntryDB() As %Status
{
    Set status = $$$OK
    Set x = ..LastMessageID + 1
    Set y = ..TransferDBID
    For {
        Set TransferDBObj = ##class(AMK.DEV1.TransferDB).%OpenId(x)
        Set AddToDB = ##class(AMK.DEV1.STAT.StatEntryDB).AddToEntryDB(TransferDBObj)
        Set x=x+1
        Quit:x>y
    }
    return status
}

Storage Default
{
<Data name="StatFinderDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>LastMessageID</Value>
</Value>
<Value name="3">
<Value>LatestMessageID</Value>
</Value>
<Value name="4">
<Value>TransferDBID</Value>
</Value>
<Value name="5">
<Value>Adapter</Value>
</Value>
</Data>
<DataLocation>^AMK.DEV1.STAT.StatFinderD</DataLocation>
<DefaultData>StatFinderDefaultData</DefaultData>
<IdLocation>^AMK.DEV1.STAT.StatFinderD</IdLocation>
<IndexLocation>^AMK.DEV1.STAT.StatFinderI</IndexLocation>
<StreamLocation>^AMK.DEV1.STAT.StatFinderS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
