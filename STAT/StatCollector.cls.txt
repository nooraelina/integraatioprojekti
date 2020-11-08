Class AMK.DEV1.STAT.StatCollector Extends (Ens.InboundAdapter, %Persistent, %JSON.Adaptor)
{

Property Adapter As Ens.InboundAdapter;

Parameter ADAPTER = "Ens.InboundAdapter";

Property IntegrationNro As %String;

/// ProcessInput should be called based to CallInterval setting (from Ens.InboundAdapter)
ClassMethod ProcessInput(pInput As %RegisteredObject, pOutput As %RegisteredObject) As %Status
{
    #Dim count
    #Dim tJSON
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
    Set tStatus = CreateJSON(count)
    WRITE tStatus
}

ClassMethod CreateJSON(entryCount, Output Something) As %Status
{
    // i is number of objects we need to go through
    // doneCount is number of objects we have gone through
    Set i = entryCount
    Set doneCount = 0

    // TODO Create JSON object
    Set jsonObject = ##class(AMK.DEV1.STAT.StatCollector).%New()
    Set jsonObject.IntegrationNro = "AMK1.1.1."
    DO jsonObject.%JSONExport()
    Set formatter = ##class(%JSON.Formatter).%New()
    WRITE formatter

    //WHILE doneCount < i {
        // TODO Add statentries into JSON object
        

        //Set doneCount =+ 1
    //}

    // return JSON
}

ClassMethod DeleteStatEntries() As %Status
{
    // TODO This whole thing
    Return $$$ERROR($$$NotImplemented)
}

}
