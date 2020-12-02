/// Updates the StatEntryDB with new objects based on the latest MessageID recieved from STAT-Database
Class AMK.DEV1.STAT.StatFinder Extends Ens.BusinessService
{

Property LastMessageID As %Integer;

Property LatestMessageID As %Integer;

Property TransferDBID As %Integer;

Property Adapter As Ens.InboundAdapter;

/// Doesn't work as excpected :(
Property SyncWithCollector As %Boolean;

Parameter ADAPTER = "Ens.InboundAdapter";

Parameter SETTINGS As %String = "SyncWithCollector";

Method OnProcessInput(pInput As %RegisteredObject, pOutput As %RegisteredObject) As %Status
{
    //Getting the ID of the latest message saved in STAT Database. Asking LastMessageID through StatSender process
    Set JSONMessage = ##class(AMK.DEV1.STAT.JSONMessage).%New()
    Set JSONMessage.RequestType = 1
    Do ..SendRequestSync("StatSender", JSONMessage, .pResponse)
    Set ..LastMessageID = pResponse.MessageID
    $$$TRACE("LastMessageID is "_..LastMessageID)

    //Getting the ID of the latest message saved to local Database
    set query = "SELECT TOP 1 ID FROM AMK_DEV1.TransferDB ORDER By ID DESC"
    set tStatement = ##Class(%SQL.Statement).%New()
    set qStatus = tStatement.%Prepare(query)
    set rset = tStatement.%Execute()
    do rset.%Next()
    Set ..TransferDBID = rset.%GetData(1)

    
    $$$TRACE("Updating StatEntryDB")
    Set task = ..UpdateStatEntryDB()
    Set ..LatestMessageID = ..LastMessageID

    Quit task
}

Method UpdateStatEntryDB() As %Status
{
    Set status = $$$OK
    Set EntryDBID = ##class(AMK.DEV1.STAT.StatEntryDB).GetLargestID()
    If EntryDBID > ..LastMessageID{
        Set x = EntryDBID + 1
    } ElseIf ..LastMessageID > EntryDBID {
        Set x = ..LastMessageID +1
    } ElseIf EntryDBID = ..TransferDBID {
        $$$TRACE("No New Messages to transfer, Quitting.")
        Quit status
    } Else {
        $$$TRACE("No New Messages to transfer, Quitting.")
        Quit status
    }
    
    
    Set y = ..TransferDBID
    If x>y{
        $$$TRACE("No New Messages to transfer, Quitting.")
        Quit status
    }
    For {
        try{
        Set TransferDBObj = ##class(AMK.DEV1.TransferDB).%OpenId(x)
        Set AddToDB = ##class(AMK.DEV1.STAT.StatEntryDB).AddToEntryDB(TransferDBObj)
        }
        catch err{
            $$$TRACE("Opening the object with ID "_x_"Failed.")
        }
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
