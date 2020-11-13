Class AMK.DEV1.STAT.StatCollector Extends Ens.InboundAdapter
{

Property Adapter As Ens.InboundAdapter;

Parameter ADAPTER = "Ens.InboundAdapter";

/// ProcessInput should be called based to CallInterval setting (from Ens.InboundAdapter)
ClassMethod OnProcessInput(pInput As %RegisteredObject, pOutput As %RegisteredObject) As %Status
{
    #Dim count
    
    // Get the number of objects from StatEntryDB to check if there is any new statentries (Not sure if needed but left it here anyways)
    Set query = "SELECT COUNT(Filename) FROM AMK_DEV1.TransferDB" // "SELECT COUNT(MessageID) FROM AMK_DEV1_STAT.StatEntryDB"
    Set tStatement = ##class(%SQL.Statement).%New()
    Set qStatus = tStatement.%Prepare(query)
    If qStatus '= 1 {WRITE "Failed" DO $System.Status.DisplayError(qStatus) QUIT}
    Set rset = tStatement.%Execute()
    WHILE rset.%Next(){
        Set count = rset.%GetData(1)
    }
    If count = 0 {WRITE "No entries waiting to be processed. Quitting." QUIT}
    Set jsonMessage = ##class(AMK.DEV1.STAT.StatCollector).CreateJSON()

    // Call StatSender with jsonMessage
    Set listOfMessageIds = ##class(AMK.DEV1.STAT.StatSender).PostJSON(jsonMessage)

    // TODO Call DeleteStatEntries with StatSender response
    Set tStatus = ##class(AMK.DEV1.STAT.StatCollector).DeleteStatEntries(listOfMessageIds)

    WRITE !, tStatus
}

ClassMethod CreateJSON() As %Status
{
    Set jsonObject = ##class(AMK.DEV1.STAT.JSONMessage).%New()

    // get every MessageID and add that to a list
    Set tGetMsgID = "SELECT MessageID FROM AMK_DEV1_STAT.StatEntryDB"
    Set tStatement = ##class(%SQL.Statement).%New()
    Set qStatus = tStatement.%Prepare(tGetMsgID)
    If qStatus '= 1 {WRITE "Failed" DO $System.Status.DisplayError(qStatus) QUIT}
    Set rset = tStatement.%Execute()
    Set a = "SELECT * FROM AMK_DEV1_STAT.StatEntryDB WHERE MessageID = "
    Set c = "'"

    WHILE rset.%Next() {
        Set messageId = rset.%GetData(1)

        // SQL haku messageidllä muiden tietojen saamiseksi
        Set b = messageId
        Set query2 = a_b_c
        Set tStatement = ##class(%SQL.Statement).%New()
        Set qStatus2 = tStatement.%Prepare(query2)
        If qStatus2 '= 1 {WRITE "Failed" DO $System.Status.DisplayError(qStatus) QUIT}
        Set rset2 = tStatement.%Execute()
        do rset2.%Next()

        // TODO lisää oikeat numerot getdatoihin
        Set jsonObject.IntegrationName = rset2.%GetData(1)
        Set jsonObject.Hostname = rset2.%GetData()
        Set jsonObject.ProductionName = rset2.%GetData()
        Set jsonObject.Status = rset2.%GetData()
        Set jsonObject.Filename = rset2.%GetData()
        Set jsonObject.TimeStamp = rset2.%GetData()
        Set jsonObject.MessageID = rset2.%GetData()

    }
    
    // Show in terminal the jsonobject
    Do jsonObject.%JSONExport()        
    
    return jsonObject
}

ClassMethod DeleteStatEntries() As %Status
{
    // TODO This whole thing
    set getMessageIdQuery = "SELECT"
}

}
