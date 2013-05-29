package com.nudoru.lms.aicc
{
	import com.nudoru.debug.Debugger;
	import flash.utils.Dictionary;
	/**
	 * Deserializes data returned from the LMS and stored it in a dictionary object for easy retrieval
	 * 
	 * Sample data:
	 * [core]
	 * time=00:00:0
	 * lesson_status=incomplete
	 * lesson_location=matchingtext
	 * score=80
	 * [core_lesson]
	 * ...
	 * 
	 * @author Matt Perkins
	 */
	public class AICCGetParamDeserializer
	{

		private var _CRLF:String = unescape("%0D"); // "\r"

		private var _deserializedData:Dictionary = new Dictionary();
		
		// list of all of the valid AICC elements
		private var _ElementsList:Array = ["error","error_text","student_id","student_name","lesson_location","score","credit","lesson_status","time","mastery_score","lesson_mode","max_time_allowed","time_limit_action","audio","speed","language","text","course_id","core_vendor","core_lesson","comments","objectives_status"];
		
		private static const GROUP_ID_CORE:String = "[core]";
		private static const GROUP_ID_CORE_LESSON:String = "[core_lesson]";
		
		// below are unsupported at this time, MBP 2-18-11
		private static const GROUP_ID_CORE_VENDOR:String = "[core_vendor]";
		private static const GROUP_ID_COMMENTS:String = "[comments]";
		private static const GROUP_ID_EVALUATION:String = "[evaluation]";
		private static const GROUP_ID_OBJECTIVE_STATUS:String = "[objectives_status]";
		private static const GROUP_ID_STUDENT_DATA:String = "[student_data]";
		private static const GROUP_ID_STUDENT_DEMOGRAPHICS:String = "[student_demographics]";
		private static const GROUP_ID_STUDENT_PREFERENCES:String = "[student_preferences]";


		public function AICCGetParamDeserializer():void
		{
		}

		public function getElementData(element:String):String
		{
			if(hasElementData(element)) return _deserializedData[element];
			return "";
		}

		private function setElementData(element:String, data:String):void
		{
			Debugger.instance.add("AICC, "+element+" = "+data, this);
			_deserializedData[element] = data;
		}

		public function hasElementData(element:String):Boolean
		{
			if(_deserializedData[element]) return true;
			return false;
		}

		public function process(dataResult:String):void
		{
			var dataElements:Array = unescape(dataResult).split(_CRLF);
			for(var i:int,len:int=dataElements.length;i<len;i++)
			{
				var currentElement:String = dataElements[i];
				// is it a [group_id] element?
				if(isGroupIDString(currentElement))
				{
					var groupID:String = currentElement.toLowerCase();
					// really just looking for this one to get the suspend data
					if(groupID == GROUP_ID_CORE_LESSON) 
					{
						// test to see if there is anther line, if so that the suspend data
						if(i != (len-1)) setElementData(GROUP_ID_CORE_LESSON, dataElements[i+1]);
					}
				}
				else
				{
					// split the "element=data" pair
					var elementDataPair:Array = currentElement.split("=");
					var elementIndex:int = getElementIndexInElementList(elementDataPair[0]);
					if(elementIndex >= 0) setElementData(_ElementsList[elementIndex], elementDataPair[1]);
				}
				
			}
		}

		// determines if the line passed is "[whatever]"
		private function isGroupIDString(line:String):Boolean
		{
			line = line.replace(/^\s*/, "");
			var bracketPos:int = line.search(/\[[\w]+\]/);
			if(bracketPos == 0) return true;
			return false;
		}

		private function getElementIndexInElementList(element:String):int
		{
			for(var i:int, len:int = _ElementsList.length; i<len;i++)
			{
				if(_ElementsList[i] == element.toLowerCase()) return i;	
			}
			return -1;
		}


	}
}
