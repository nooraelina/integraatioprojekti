Class AMK.DEV1.STAT.StatCollector Extends Ens.BusinessService
{

Property Adapter As Ens.InboundAdapter;

Parameter ADAPTER = "Ens.InboundAdapter";

/// Max amount of messages processed per Interval
Property MessageProcessLimit As %Integer;

Property SourceConfigName As %String;

Parameter SETTINGS = "MessageProcessLimit:Basic, SourceConfigName:Basic:selector?multiSelect=1&context={Ens.ContextSearch/ProductionItems?sources=1&productionName=@productionId}";

Method OnProcessInput(pInput As %RegisteredObject, pOutput As %RegisteredObject) As %Status
{
    #Dim count
    
    // Get the number of objects from StatEntryDB to check if there is any new statentries (Not sure if needed but left it here anyways)
    Set query = "SELECT COUNT(MessageID) FROM AMK_DEV1_STAT.StatEntryDB WHERE IntegrationNro = '"_$GET(^Ens.LookupTable("IntegrationNro",..SourceConfigName))_"'"
    Set tStatement = ##class(%SQL.Statement).%New()
    Set qStatus = tStatement.%Prepare(query)
    If qStatus '= 1 {WRITE "Failed" DO $System.Status.DisplayError(qStatus) QUIT}
    Set rset = tStatement.%Execute()
    WHILE rset.%Next(){
        Set count = rset.%GetData(1)
    }
    If count = 0 {
        $$$TRACE("No entries waiting to be processed. Quitting.") 
        DO $System.Status.DisplayError(qStatus)
        set returnvalue = 1
        QUIT returnvalue
        }

    // Get the user-defined message process limit from settings
    set tMsgProcessLimit = ..MessageProcessLimit
    set integrationNro = $GET(^Ens.LookupTable("IntegrationNro",..SourceConfigName))

    //set tMsgProcessLimit = 10
    $$$TRACE("Entries found. Creating JSON for sending")
    Set jsonMessage = ..CreateJSON(tMsgProcessLimit)

    // Call StatSender with jsonMessage
    Set listOfMessageIds = ##class(AMK.DEV1.STAT.StatSender).PostJSON(jsonMessage, integrationNro)

    // Call DeleteStatEntries with StatSender response
    Set tStatus = ##class(AMK.DEV1.STAT.StatCollector).DeleteStatEntries(listOfMessageIds)

    Return tStatus
}

Method CreateJSON(tMsgProcessLimit) As %String
{
    // get every MessageID and add that to a list
    Set tGetMsgID = "SELECT TOP "
    Set tGetMsgID2 = " MessageID FROM AMK_DEV1_STAT.StatEntryDB WHERE IntegrationNro = '"_$GET(^Ens.LookupTable("IntegrationNro",..SourceConfigName))_"'"
    Set tGetMsgIDquery = tGetMsgID_tMsgProcessLimit_tGetMsgID2
    Set tStatement = ##class(%SQL.Statement).%New()
    Set qStatus = tStatement.%Prepare(tGetMsgIDquery)
    If qStatus '= 1 {WRITE "Failed1" DO $System.Status.DisplayError(qStatus) QUIT}
    Set rset = tStatement.%Execute()
    Set a = "SELECT * FROM AMK_DEV1_STAT.StatEntryDB WHERE MessageID = '"
    Set c = "' AND IntegrationNro = '"_$GET(^Ens.LookupTable("IntegrationNro",..SourceConfigName))_"'"
    Set tArr = []

    WHILE rset.%Next() {
        Set messageId = rset.%GetData(1)
        
        // SQL haku messageidllä muiden tietojen saamiseksi
        Set b = messageId
        Set query2 = a_b_c
        Set tStatement = ##class(%SQL.Statement).%New()
        Set qStatus2 = tStatement.%Prepare(query2)
        If qStatus2 '= 1 {WRITE "Failed2" DO $System.Status.DisplayError(qStatus) QUIT}
        Set rset2 = tStatement.%Execute()
        do rset2.%Next()

        Do tArr.%Push({
            "IntegrationNro":      (rset2.%Get("IntegrationNro")),
            "HostName":             (rset2.%Get("HostName")),
            "ProductionName":       (rset2.%Get("ProductionName")),
            "Status":               (rset2.%Get("Status")),
            "TimeStamp":            (rset2.%Get("TimeStamp")),
            "MessageID":            (rset2.%Get("MessageID"))
        })
        
    }

    Set jsonMessage = tArr.%ToJSON()
    
    return jsonMessage
}

ClassMethod DeleteStatEntries(listOfMessageIds) As %Status
{
    // Create SQL statement, ? = list
    SET myquery="DELETE FROM AMK_DEV1_STAT.StatEntryDB "_
                "WHERE MessageID %INLIST ?"
    SET tStatement = ##class(%SQL.Statement).%New()
    SET qStatus = tStatement.%Prepare(myquery)
        IF qStatus'=1 {WRITE "%Prepare failed:" DO $System.Status.DisplayError(qStatus) QUIT}
    SET rset = tStatement.%Execute(listOfMessageIds)

    return $$$OK
}

Storage Default
{
<Data name="StatCollectorDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Adapter</Value>
</Value>
<Value name="3">
<Value>MessageProcessLimit</Value>
</Value>
<Value name="4">
<Value>SourceConfigName</Value>
</Value>
<Value name="5">
<Value>%WaitForNextCallInterval</Value>
</Value>
<Value name="6">
<Value>ThrottleDelay</Value>
</Value>
<Value name="7">
<Value>%PreserveSession</Value>
</Value>
<Value name="8">
<Value>%RequestHeader</Value>
</Value>
<Value name="9">
<Value>%AlertStartTime</Value>
</Value>
<Value name="10">
<Value>%ProcessError</Value>
</Value>
<Value name="11">
<Value>AlertGracePeriod</Value>
</Value>
<Value name="12">
<Value>%OutsideCreated</Value>
</Value>
<Value name="13">
<Value>%SessionId</Value>
</Value>
<Value name="14">
<Value>%SuperSessionCreatedBeforeSession</Value>
</Value>
<Value name="15">
<Value>%SuperSession</Value>
</Value>
<Value name="16">
<Value>%ConfigQueueName</Value>
</Value>
<Value name="17">
<Value>%ConfigName</Value>
</Value>
<Value name="18">
<Value>%QuitTask</Value>
</Value>
<Value name="19">
<Value>AlertGroups</Value>
</Value>
<Value name="20">
<Value>AlertOnError</Value>
</Value>
<Value name="21">
<Value>ArchiveIO</Value>
</Value>
<Value name="22">
<Value>BusinessPartner</Value>
</Value>
<Value name="23">
<Value>GenerateSuperSessionID</Value>
</Value>
<Value name="24">
<Value>IOLogEntry</Value>
</Value>
<Value name="25">
<Value>InactivityTimeout</Value>
</Value>
</Data>
<DataLocation>^AMK.DEV1.STAT.StatCollectorD</DataLocation>
<DefaultData>StatCollectorDefaultData</DefaultData>
<IdLocation>^AMK.DEV1.STAT.StatCollectorD</IdLocation>
<IndexLocation>^AMK.DEV1.STAT.StatCollectorI</IndexLocation>
<StreamLocation>^AMK.DEV1.STAT.StatCollectorS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
