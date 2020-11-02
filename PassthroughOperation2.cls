/* Copyright (c) 2020 by InterSystems Corporation.
   Cambridge, Massachusetts, U.S.A.  All rights reserved.
   Confidential property of InterSystems Corporation. */

/// Modified Version of EnsLib.File.PassthroughOperation, to call the counter and the succes Email notifier (All changes in OnMessage method)
/// Accepts objects of type Ens.StreamContainer and saves the encapsulated stream data to a file using the File OutboundAdapter.
Class AMK.DEV1.File.PassthroughOperation2 Extends Ens.BusinessOperation [ ProcedureBlock, System = 4 ]
{

Parameter ADAPTER = "EnsLib.File.OutboundAdapter";

/// Name of file to output the document(s) to. May include timestamp specifiers. The %f specifier if present will be 
/// replaced with the name of the document's original source filename (stripped of characters illegal in target filenames).<p>
/// See the method Ens.Util.File.CreateTimestamp() for documentation of timestamping options.
Property Filename As %String(MAXLEN = 1000, MINLEN = 1) [ InitialExpression = "%f_%Q%!+(_a)", Required ];

Parameter SETTINGS As %String = "Filename:Basic";

/// Method that activates as a new file is recieved as an Ens.Streamcontainer. Renames the file and saves it
Method OnMessage(pRequest As Ens.StreamContainer, Output pResponse As %Persistent) As %Status
{
	Set SuccessCheck = ##class(AMK.DEV1.SuccessChecker).%New()
	Quit:'$IsObject(pRequest.Stream) $$$ERROR($$$EnsErrGeneral,"No Stream contained in StreamContainer Request")
	If "@"'=$E(..Adapter.FilePath) {
		
		//Getting the original filename as cFileName and the Whole filepath (including the filename) as cPath
		Set cFileName = ##class(%File).GetFilename(pRequest.OriginalFilename)
		Set cPath = ..Adapter.fixPath(..Adapter.FilePath)_cFileName
		
		/*Calling PreCheck method to check if the filename already exists in the Outbound folder
		If the file already exists this adds a timestamp to the filename (and informs about it via Email) and returns the whole path (PreCheck)*/
		Set PreCheck = SuccessCheck.PreCheck(cPath, cFileName)
		If SuccessCheck.Mailtype = 2 {
			$$$TRACE("Filename already exists. Sending Email notification of filename Change")
			Set pEmail = ..SendRequestAsync("AMK.Email", SuccessCheck)
		} Else{
			Set pEmail = 0
		}
		
		//Creating a new filename based on the returnvalue of PreCheck
		Set tFilename=..Adapter.CreateFilename(##class(%File).GetFilename(PreCheck),..Filename)
		Set tSC=..Adapter.PutStream(tFilename, pRequest.Stream)
		
		/*Exctracting only the filepath part from Precheck and then combining it with tFilename
		This is done because ..Adapter.CreateFilename changes the PreCheck filename by removing : and adding _
		from the possibly added timestamp*/
		Set nPath = ##class(%File).GetDirectory(PreCheck)
		Set NewFilePathName = nPath_tFilename
		
		Do pRequest.%Save() ; re-save in case PutStream() optimization changed the Stream filename
		
		//Calling CheckFileOut Method that makes sure that the Newly saved file is found in the Outbound Folder (and saves information to DB and informs about it via Email)
		Do SuccessCheck.CheckFileOut(NewFilePathName)
		If SuccessCheck.Mailtype = 1 {
			$$$TRACE("Filetransfer successfull, Sending notifications. Transfer object saved to Database.")
			Set tEmail = ..SendRequestAsync("AMK.Email", SuccessCheck)
			Set tPush = ..SendRequestAsync("AMK.Push", SuccessCheck)
		} Else{
			set tEmail = 0
		}
	} Else {
		#; Forward to agent
		If pRequest.Stream.%Extends("%Library.FileStreamAdaptor") {
			#; copy to a global stream in a new container
			Set tStream=##class(%FileBinaryStream).%New()
			Merge tStream.Attributes=pRequest.Stream.Attributes
			Set tSC=tStream.CopyFrom(pRequest.Stream)
			Set tSC=tStream.SaveStream()  Quit:$$$ISERR(tSC) tSC
			Set tMsg=##class(Ens.StreamContainer).%New(tStream)
		} Else {
			Set tMsg=pRequest
		}
		//Same Checking methods added here as above (cFileName, cPath, PreCheck, nPath, NewFilePathName and .CheckFileOut)
		Set cFileName = ##class(%File).GetFilename(pRequest.OriginalFilename)
		Set cPath = ..Adapter.fixPath(..Adapter.FilePath)_cFileName
		Set PreCheck = SuccessCheck.PreCheck(cPath, cFileName)
		If SuccessCheck.Mailtype = 2 {
			$$$TRACE("Filename already exists. Sending Email notification of filename Change")
			Set pEmail = ..SendRequestAsync("AMK.Email", SuccessCheck)
		} Else{
			Set pEmail = 0
		}
		Set tFilename=##class(Ens.Util.File).CreateTimestamp(##class(%File).GetFilename(PreCheck),..Filename)
		Set tAgent=$P(..Adapter.FilePath,":"), tTimeout=+$P(tAgent,"(",2), tAgent=$P(tAgent,"(")  Set:'tTimeout tTimeout=-1
		Set tSC=..EnQueueToService(tAgent,tMsg,..%RequestHeader,,tFilename) ; !!! Sync(...,,tTimeout,..%RequestHeader.Description)
		Set nPath = ##class(%File).GetDirectory(PreCheck)
		Set NewFilePathName = nPath_tFilename
		Do SuccessCheck.CheckFileOut(NewFilePathName)
		If SuccessCheck.Mailtype = 1 {
			$$$TRACE("Filetransfer successfull, Sending notifications. Transfer-object saved to Database.")
			Set tEmail = ..SendRequestAsync("AMK.Email", SuccessCheck)
			Set tPush = ..SendRequestAsync("AMK.Push", SuccessCheck)
		} Else{
			set tEmail = 0
		}
	}
	Quit tSC
}

ClassMethod EnQueueToService(pTargetQueueName As %String, pRequest As %RegisteredObject, pOriginalHeader As Ens.MessageHeader, Output pNewHeader As Ens.MessageHeader, pDescription As %String = "") As %Status [ Internal ]
{
	Set tSC = ##class(Ens.MessageHeader).NewRequestMessage(.pNewHeader,pRequest,pOriginalHeader.SessionId) Quit:$$$ISERR(tSC) tSC
	Set pNewHeader.CorrespondingMessageId = pOriginalHeader.%Id()
	Set pNewHeader.SourceConfigName = pOriginalHeader.TargetConfigName
	Set pNewHeader.TargetConfigName = $P(pTargetQueueName,":")
	Set pNewHeader.SourceBusinessType = $$$eHostTypeOperation
	Set pNewHeader.TargetBusinessType = $$$eHostTypeService
	Set pNewHeader.TargetQueueName = pTargetQueueName
	Set pNewHeader.Description = pDescription
	Quit ##class(Ens.Queue).EnQueue(pNewHeader)
}

/// Return an array of connections for drawing lines on the config diagram
ClassMethod OnGetConnections(Output pArray As %String, pItem As Ens.Config.Item)
{
	Do ##super(.pArray,pItem)
	If pItem.GetModifiedSetting("FilePath",.tValue) {
		If "@"=$E(tValue) {
			Set tAgent=$E($P(tValue,":"),2,*)
			#; if agent package is installed, call it to find the appropriate agent Service connection.
			try {
				Set tSC=$classmethod("EnsLib.Agent.Interface","GetAgentService",tAgent,pItem.Name,.tAgentService)
				Set:""'=tAgentService&&$$$ISOK(tSC) pArray(tAgentService)=""
			} catch {  }
		}
	}
}

}
