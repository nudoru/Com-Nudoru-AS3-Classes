package com.nudoru.lms.aicc
{
	import com.nudoru.debug.Debugger;
	import com.nudoru.lms.AbstractLMSProtocolFacade;
	import com.nudoru.lms.ILMSProtocolFacade;
	import com.nudoru.lms.scorm.SCOStatus;
	import com.nudoru.utilities.HTMLContainerUtils;

	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;

	/**
	 * Standard facade interface AND services to talk to the LMS for AICC
	 * 
	 * TODO separate server calls to a service
	 * 
	 * @author Matt Perkins
	 */
	public class AICCFacade extends AbstractLMSProtocolFacade implements ILMSProtocolFacade
	{
		//---------------------------------------------------------------------
		//
		//	VARIABLES
		//
		//---------------------------------------------------------------------

		private var  _LaunchURL:String;
		private var  _AICCSID:String;
		private var  _AICCURL:String;
		private var  _AICCVersion:String = "3.5";
		
		private var  _isRequestPendingResponse:Boolean = false;
		private var  _pendingRequestType:String;
		
		private var _Deserializer:AICCGetParamDeserializer;
		
		//---------------------------------------------------------------------
		//
		//	GETTER/SETTERS
		//
		//---------------------------------------------------------------------
		
		// aicc getter/setters only work on the cache vaules and do not communicate to the server or API like scorm
		// no changes from Abstract implementation
		
		//---------------------------------------------------------------------
		//
		//	INITIALIZATION
		//
		//---------------------------------------------------------------------

		/**
		 * Constructor
		 */
		
		public function AICCFacade():void {}
		
		/**
		 * Version param should be the launch string
		 * 
		 * Sample launch URL from Docent 6.5
		 * https://sub.domain.com/wb_content/coursecode/lmsdefault.htm?aicc_sid=3032659%2CA001&aicc_url=sub.domain.com%2Fns-bin%2Fdocentnsapi%2Flms%2Capp1%2C2151%2FSQN%3D-76165634%2CCMD%3DGET%2Cfile%3Daicc_catcher.jsm%2CSVR%3Dpldd005.csm.fub.com%3A48673%2CSID%3DPLDD005.CSM.FUB.COM%3A48673-A9CA-2-B1FD32EA-00BDB3E0%2F
		 */
		override public function initialize(data:String = undefined):void
		{
			Debugger.instance.add("AICC LMS initializing", this);
			Debugger.instance.add("AICC launch url: "+_LaunchURL, data);
			
			super.initialize(data);
			
			_LaunchURL = unescape(data);

			_Deserializer = new AICCGetParamDeserializer();

			initializeLMS();
		}

		//---------------------------------------------------------------------
		//
		//	API SPECIFIC FUNCTIONS
		//
		//---------------------------------------------------------------------

		override protected function initializeLMS():void
		{
			_AICCURL = getAICCURL();
			_AICCSID = getAICCSID();

			Debugger.instance.add("AICC url: "+_AICCURL, this);
			Debugger.instance.add("AICC sid: "+_AICCSID, this);
			
			// If there is an error sending the GetParam request, the lmsCannotConnectSignal will dispatch
			sendGetParamRequest();
		}

		private function get AICCURL():String 
		{
			return _AICCURL;
		}
		private function get AICCSID():String
		{
			return _AICCSID;
		}
		
		/**
		 * Convert SCORM lesson status to AICC lesson status
		 */
		private function convertSCORMLessonStatusToAICCLessonStatus(status:String):String
		{
			if(status == SCOStatus.INCOMPLETE) return AUStatus.INCOMPLETE;
			if(status == SCOStatus.COMPLETE) return AUStatus.COMPLETE;
			if(status == SCOStatus.PASS) return AUStatus.PASS;
			if(status == SCOStatus.FAIL) return AUStatus.FAIL;
			return status;
		}
		
		/**
		 * Gets the data string for a put param post
		 */
		private function getPutParamData():String {
			// if the course is complete or incomplete, don't pass a score
			var auScore:String = (lessonStatus == AUStatus.COMPLETE || lessonStatus == AUStatus.INCOMPLETE) ? "" : String(score); 
			
			var data:String = "[core]\r";
			data += "lesson_location="+lastLocation+"\r";
			data += "lesson_status="+lessonStatus+"\r";
			data += "score="+ auScore +"\r";
			data += "time="+ getSessionTime() +"\r";
			data += "[core_lesson]\r";
			data += suspendData;
			return data;
		}
		
		private function sendGetParamRequest():void 
		{
			//DEBUG
			sendRequest(AICCCommands.GET_PARAM, URLRequestMethod.GET, "");
			//handleGetParamResult(DEBUGinprogressAICCGetParamData);
		}
		
		private function handleGetParamResult(dataResult:*):void 
		{
			Debugger.instance.add("Handle GET param: "+dataResult, this);
			
			_Deserializer.process(dataResult);
			
			_CacheLessonStatus = _Deserializer.getElementData("lesson_status");
			_CacheLastLocation = _Deserializer.getElementData("lesson_location");
			_CacheSuspendData = _Deserializer.getElementData("[core_lesson]");
			_CacheScore = int(_Deserializer.getElementData("score"));
			_CacheSessionTime = _Deserializer.getElementData("time");
			_RetrievedStudentName = _Deserializer.getElementData("student_name");
			_RetrievedStudentID = _Deserializer.getElementData("student_id");
			
			_LMSConnectionActive = true;
			_SuspendLMSCommunication = false;
			
			lmsConnectSignal.dispatch();
		}
		
		private function sendPutParamRequest():void 
		{
			sendRequest(AICCCommands.PUT_PARAM, URLRequestMethod.POST, getPutParamData());
		}
		
		private function handlePutParamResult(dataResult:*):void 
		{
			Debugger.instance.add("Handle PUT param: "+dataResult, this);
			
			sendExitAURequest();
		}
		
		/**
		 * NOT IMPLEMENTED
		 */
		private function sendPutInteractionsRequest():void
		{
			sendRequest(AICCCommands.PUT_INTERACTIONS, URLRequestMethod.POST, "");

			/* SAMPLE DATA
			var t:String = '"course_id","student_id","lesson_id","date","time","interaction_id","objective_id","type_interaction","correct_response","student_response","result","weighting","latency"'
			t += '"'+o.courseid+'","'+o.studentid+'","'+o.lessonid+'","'+o.date+'","'+o.time+'","'+o.id+'","'+o.objectiveid+'","'+o.type+'","'+o.correct_response+'","'+o.student_response+'","'+o.result+'","'+o.weighting+'","'+o.latency+'"'
			*/
		}
		
		private function handlePutInteractionsResult(dataResult:*):void 
		{
			Debugger.instance.add("Handle PUT interactions: "+dataResult, this);
		}
		
		private function sendExitAURequest():void 
		{
			sendRequest(AICCCommands.EXITAU, URLRequestMethod.POST, "");
		}
		
		private function handleExitAUResult(dataResult:*):void 
		{
			Debugger.instance.add("Handle EXIT au: "+dataResult, this);
			lmsDisconnectSignal.dispatch();
			
			/*recvParamData = recLvObj
			var datatemp:String = "Data from LMS (exitau):\n"+recLvObj+"\n\n"
			_root.aiccdebug_txt.text += datatemp
			if(s) fscommand("CloseWindows")*/
		}

		//---------------------------------------------------------------------
		//
		//	SERVER FUNCTIONS
		//
		//---------------------------------------------------------------------

		/**
		 * Sends the request to the server 
		 * 
		 * Based on
		 * http://snipplr.com/view/4487/as3-sending-data-using-post/
		 */
		private function sendRequest(requestType:String, requestMethod:String, aiccData:String):void
		{
			Debugger.instance.add("AICC REQUEST type: "+requestType+", method: "+requestMethod+", data: "+aiccData, this);

			if(_isRequestPendingResponse)
			{
				Debugger.instance.add("Warning, request pending: "+_pendingRequestType, this);
			}

			_isRequestPendingResponse = true;
			_pendingRequestType = requestType;
			
			var request:URLRequest = new URLRequest(_AICCURL);
			request.contentType = "text/xml"; // don't know if this is the correct type
			request.data = createURLVariableInstance(aiccData, requestType);
			request.method = requestMethod;
			
			var loader:URLLoader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.VARIABLES; // should this be text or variables?
			
			loader.addEventListener(Event.COMPLETE, onRequestComplete, false, 0, true);
			loader.addEventListener(HTTPStatusEvent.HTTP_STATUS, onRequestHTTPStatus, false, 0, true);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onRequestSecurityError, false, 0, true);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onRequestIOError, false, 0, true);
			
			try
			{
			   loader.load(request);
			}
			catch (error:ArgumentError)
			{
			   Debugger.instance.add("ArgumentError occurred when sending the request.", this);
			   clearRequestQueueDispatchFailure();
			}
			catch (error:SecurityError)
			{
			   Debugger.instance.add("SecurityError occurred when sending the request.", this);
			   clearRequestQueueDispatchFailure();
			}
		}

		/**
		 * Creates the URLVariable instance to use for sending all of the server requests
		 */
		private function createURLVariableInstance(aiccData:String, aiccCommand:String):URLVariables
		{
			var variables:URLVariables = new URLVariables();
			variables.session_id = HTMLContainerUtils.URLEncodeString(_AICCSID);
			variables.version = _AICCVersion;
			variables.command = HTMLContainerUtils.URLEncodeString(aiccCommand);
			variables.aicc_data = HTMLContainerUtils.URLEncodeString(aiccData);
			return variables;
		}

		private function onRequestHTTPStatus(event:HTTPStatusEvent):void
		{
			Debugger.instance.add("Request HTTP Status event type: "+event.type+", status: "+event.status, this);
		}

		private function onRequestIOError(event:IOErrorEvent):void
		{
			Debugger.instance.add("IO Error occurred when sending the request.", this);
			clearRequestQueueDispatchFailure();
		}

		private function onRequestSecurityError(event:SecurityErrorEvent):void
		{
			 Debugger.instance.add("SecurityError(2) occurred when sending the request.", this);
			 clearRequestQueueDispatchFailure();
		}

		/**
		 * Data returned from the request
		 */
		private function onRequestComplete(event:Event):void
		{
			Debugger.instance.add("Request completed", this);
			
			var loader:URLLoader = URLLoader(event.target);
			
			if(_pendingRequestType == AICCCommands.GET_PARAM) handleGetParamResult(loader.data);
			if(_pendingRequestType == AICCCommands.PUT_PARAM) handlePutParamResult(loader.data);
			if(_pendingRequestType == AICCCommands.PUT_INTERACTIONS) handlePutInteractionsResult(loader.data);
			if(_pendingRequestType == AICCCommands.EXITAU) handleExitAUResult(loader.data);
			
			clearRequestQueueDispatchSuccess();
		}

		private function clearRequestQueueDispatchSuccess():void
		{
			var theRequestWas:String = _pendingRequestType;
			clearRequestPendingVars();
			_lmsSuccessSignal.dispatch(theRequestWas);
		}

		private function clearRequestQueueDispatchFailure():void
		{
			var theRequestWas:String = _pendingRequestType;
			clearRequestPendingVars();
			
			// If there was a failure initializing the connection to the LMS then continue with the course
			if(theRequestWas == AICCCommands.GET_PARAM)
			{
				lmsCannotConnectSignal.dispatch();
			}
			
			_lmsFailureSignal.dispatch(theRequestWas);
		}

		private function clearRequestPendingVars():void
		{
			_isRequestPendingResponse = false;
			_pendingRequestType = "";
		}
		
		private function processServerErrorCode(serverResult:String):void
		{
			//var hacp_buffer:String = unescape(String(recLvObj)).toUpperCase()
			//var hacp_error:int = int(hacp_buffer.substr(hacp_buffer.indexOf("ERROR=")+6, 1))
		}
		
		//---------------------------------------------------------------------
		//
		//	TIMER METHODS
		//
		//---------------------------------------------------------------------

		/**
		 * Get the session time in proper format
		 * @return
		 */
		override public function getSessionTime():String
		{
			return _SessionTimer.elapsedTimeFormattedHHMMSS();
		}

		//---------------------------------------------------------------------
		//
		//	STATUS
		//
		//---------------------------------------------------------------------

		/**
		 * Set the lesson status to incomplete
		 * @param	f	If true, stop the time
		 */
		override public function setStatusIncomplete():void
		{
			lessonStatus = AUStatus.INCOMPLETE;
		}

		/**
		 * Set the lesson status to completed
		 */
		override public function setStatusComplete():void
		{
			stopSessionTimer();
			lessonStatus = AUStatus.COMPLETE;
		}

		/**
		 * Set the lesson status to pass
		 */
		override public function setStatusPass():void
		{
			stopSessionTimer();
			lessonStatus = AUStatus.PASS;
		}

		/**
		 * Set the lesson status to fail
		 */
		override public function setStatusFail():void
		{
			stopSessionTimer();
			lessonStatus = AUStatus.FAIL;
		}

		//---------------------------------------------------------------------
		//
		//	COMMIT/DISCONNECT
		//
		//---------------------------------------------------------------------

		/**
		 * Disconnect from the LMS and end the session. 
		 */
		override public function disconnect():void
		{
			//if (!_LMSConnectionActive) return;
			
			Debugger.instance.add("scorm facade, disconnecting");
			
			//sendExitAURequest();
			sendPutParamRequest();
		}

		
		//---------------------------------------------------------------------
		//
		//	UTILITY
		//
		//---------------------------------------------------------------------

		/**
		 * Gets the AICC SID from the launch URL
		 */
		private function getAICCSID():String
		{
			return HTMLContainerUtils.getQueryStringValue("aicc_sid", _LaunchURL.toLowerCase());
		}

		/**
		 * Gets the AICC URL from the launch URL
		 * Fix for some LMS' - if the protocol is NOT passed as part of the AICC_URL, add it based on the launch URL
		 */
		private function getAICCURL():String
		{
			var aiccurl:String = HTMLContainerUtils.getQueryStringValue("aicc_url", _LaunchURL);
			if(aiccurl.toLowerCase().indexOf("http") == 0) return aiccurl;
			return getAICCProtocolFromLaunchURL() + aiccurl;
		}

		/**
		 * Determines what the communication protocol should be based on the AICC url or launch url
		 */
		private function getAICCProtocolFromLaunchURL():String
		{
			return HTMLContainerUtils.getURLProtocol(_LaunchURL.toLowerCase());
		}

		/**
		 * Start a timer to trap server timeouts to prevent app from locking up
		 */
		/*protected function startServerWaitTimer():void
		{
			if(!_ServerWaitTimer)
			{
				_ServerWaitTimer = new TimeKeeper("_aicc_server_wait_timer", _ServerWaitTimeMS);
			}
			
			stopServerWaitTimer();
			
			_ServerWaitTimer.addEventListener(TimeKeeper.TIMEUP, onServerWaitTimeOut, false, 0, true);
			_ServerWaitTimer.start();
		}*/

		/**
		 * Handled a time out event
		 */
		/*protected function onServerWaitTimeOut(event:TimeKeeper):void
		{
			stopServerWaitTimer();
			
			Debugger.instance.add("AICC Server TIME OUT!", this);
		}*/

		/**
		 * Stop the timer
		 */
		/*protected function stopServerWaitTimer():void
		{
			_ServerWaitTimer.stop();
			_ServerWaitTimer.removeEventListener(TimeKeeper.TIMEUP, onServerWaitTimeOut);
		}*/
		
	}
}
