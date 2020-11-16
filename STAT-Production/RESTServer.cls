Class AMK.STAT.RESTServer Extends (%CSP.REST, %Persistent)
{

Parameter HandleCorsRequest = 1;

XData UrlMap [ XMLNamespace = "http://www.intersystems.com/urlmap" ]
{
<Routes>
	<Route Url="/test" Method="GET" Call="Test"/>
	<Route Url="/getlastmessageid/:id" Method="GET" Call="GetLastMessageID" />
	<Route Url="/addtodb/:integration" Method="POST" Call="AddtoDB" />
</Routes>
}

ClassMethod Test() As %Status
{
	Set result={}
	do result.%Set("Status", "Jees")
	write result.%ToJSON()
	Quit $$$OK
}

ClassMethod GetLastMessageID(id As %String) As %Status
{
	Set result={}
	Set TableName = $GET(^Ens.LookupTable("GetTable",id))
	set query = "SELECT TOP 1 MessageID FROM AMK_STAT_StatDB."_TableName_" ORDER By MessageID DESC"
	set tStatement = ##Class(%SQL.Statement).%New()
	set qStatus = tStatement.%Prepare(query)
	set rset = tStatement.%Execute()
	do rset.%Next()
	set LastMessageID = rset.%GetData(1)
	do result.%Set("LastMessageID", LastMessageID)
	write result.%ToJSON()
	Quit result
}

}
