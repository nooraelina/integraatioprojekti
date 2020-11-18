Class AMK.DEV1.STAT.StatCollector Extends (Ens.InboundAdapter, Ens.BusinessService)
{

Property Adapter As Ens.InboundAdapter;

Parameter ADAPTER = "Ens.InboundAdapter";

/// ProcessInput should be called based to CallInterval setting (from Ens.InboundAdapter)
Method OnProcessInput(pInput As %RegisteredObject, pOutput As %RegisteredObject) As %Status
{
    #Dim count
    
    // Get the number of objects from StatEntryDB to check if there is any new statentries (Not sure if needed but left it here anyways)
    Set query = "SELECT COUNT(MessageID) FROM AMK_DEV1_STAT.StatEntryDB"
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

    // get every MessageID and add that to a list
    Set tGetMsgID = "SELECT MessageID FROM AMK_DEV1_STAT.StatEntryDB"
    Set tStatement = ##class(%SQL.Statement).%New()
    Set qStatus = tStatement.%Prepare(tGetMsgID)
    If qStatus '= 1 {WRITE "Failed1" DO $System.Status.DisplayError(qStatus) QUIT}
    Set rset = tStatement.%Execute()
    Set a = "SELECT * FROM AMK_DEV1_STAT.StatEntryDB WHERE MessageID = '"
    Set c = "'"
    set List = ##class(%ListOfObjects).%New()

    WHILE rset.%Next() {
        Set jsonObject = ##class(AMK.DEV1.STAT.JSONMessage).%New()
        Set messageId = rset.%GetData(1)

        // SQL haku messageidllä muiden tietojen saamiseksi
        Set b = messageId
        Set query2 = a_b_c
        Set tStatement = ##class(%SQL.Statement).%New()
        Set qStatus2 = tStatement.%Prepare(query2)
        If qStatus2 '= 1 {WRITE "Failed2" DO $System.Status.DisplayError(qStatus) QUIT}
        Set rset2 = tStatement.%Execute()
        do rset2.%Next()

        // TODO lisää oikeat numerot getdatoihin
        Set jsonObject.IntegrationName = rset2.%GetData(3)
        Set jsonObject.Hostname = rset2.%GetData(2)
        Set jsonObject.ProductionName = rset2.%GetData(5)
        Set jsonObject.Status = rset2.%GetData(6)
        Set jsonObject.TimeStamp = rset2.%GetData(7)
        Set jsonObject.MessageID = rset2.%GetData(4)

        Do List.Insert(jsonObject)

    }
    
    // Show in terminal the jsonobject
    Do jsonObject.%JSONExport()        
    
    return List
}

ClassMethod DeleteStatEntries(listOfMessageIds) As %Status
{
    // Väliaikainen lista testaukseen, tää lista tarkotus saada toisesta produktiosta
    SET listOfMessageIds=$LISTBUILD(2,4)

    // Create SQL statement, ? = list
    SET myquery="DELETE FROM AMK_DEV1.TransferDB "_ // "DELETE FROM AMK_DEV1_STAT.StatEntryDB "
                "WHERE ID %INLIST ?" // WHERE MessageID = "
    SET tStatement = ##class(%SQL.Statement).%New()
    SET qStatus = tStatement.%Prepare(myquery)
        IF qStatus'=1 {WRITE "%Prepare failed:" DO $System.Status.DisplayError(qStatus) QUIT}
    SET rset = tStatement.%Execute(listOfMessageIds)

    // Tämäkin testauksen ajaksi, poista kun redi
    DO rset.%Display()

    return $$$OK
}

}
