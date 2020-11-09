Class AMK.DEV1.STAT.StatCollector Extends Ens.InboundAdapter
{

Property Adapter As Ens.InboundAdapter;

Parameter ADAPTER = "Ens.InboundAdapter";

/// ProcessInput should be called based to CallInterval setting (from Ens.InboundAdapter)
ClassMethod ProcessInput(pInput As %RegisteredObject, pOutput As %RegisteredObject) As %Status
{
    #Dim count
    
    // Get the number of objects from TransferDB
    Set query = "SELECT COUNT(Filename) FROM AMK_DEV1.TransferDB" // Muuta Filename ja Transferdb !!!
    Set tStatement = ##class(%SQL.Statement).%New()
    Set qStatus = tStatement.%Prepare(query)
    If qStatus '= 1 {WRITE "Failed" DO $System.Status.DisplayError(qStatus) QUIT}
    Set rset = tStatement.%Execute()
    //DO rset.%Display() <- Jos haluu testaa mitä sql komennosta tulee, käytä tätä.
    WHILE rset.%Next(){
        Set count = rset.%GetData(1)
    }
    If count = 0 {WRITE "No entries waiting to be processed. Quitting." QUIT}
    Set jsonMessage = ##class(AMK.DEV1.STAT.StatCollector).CreateJSON(3)
    // TODO Call StatSender with jsonMessage
    // TODO Call DeleteStatEntries with StatSender response
}

ClassMethod CreateJSON(entryCount, Output Something) As %Status
{
    // i is number of objects we need to go through
    // doneCount is number of objects we have gone through
    Set i = entryCount
    #Dim doneCount As %Integer
    Set doneCount = 0

    // Create JSON object
    Set jsonObject = ##class(AMK.DEV1.STAT.JSONMessage).%New()

    WRITE "before loop doneCount is: ", doneCount, !

    FOR var = doneCount:1:entryCount {
        // Add statentries into JSON object
        Set jsonObject.IntegrationName = "INT-nnn"
        Set jsonObject.Hostname = "jee"
        Set jsonObject.ProductionName = "jee"
        Set jsonObject.Status = "jee"
        Set jsonObject.Filename = "jee"
        Set jsonObject.TimeStamp = "jee"
        Set jsonObject.MessageID = doneCount
        Do jsonObject.%JSONExport()

        Set doneCount = doneCount + 1

        WRITE !, "doneCount inside loop: ", doneCount," entryCount inside loop: ", entryCount, !
        
        }

    WRITE !, "moi"
    return jsonObject
}

ClassMethod DeleteStatEntries() As %Status
{
    // TODO This whole thing
    Return $$$ERROR($$$NotImplemented)
}

}
