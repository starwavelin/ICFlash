package experiment 
{
	import flash.events.*;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import flash.utils.getTimer;
	import flash.utils.Timer;
	/**
	 * ...
	 * @author ...
	 */
	public class HttpExperiment 
	{
		public static const EXP_ID:String = "HTTP GET";
		public static const EXP_VER:String = "1.0";
		
		private var callback:Function;
		private var ongoing:Boolean;
		
		private var currenturl:String;
		private var responseheader:Array;
		private var httpstatuscode:String;
		private var timed:int;
		
		private var loader:URLLoader;
		private var timer:Timer;
		
		public function HttpExperiment() 
		{
			
		}
		
		/*--- Part I: Do HTTP Load ---*/
		public function doExperiment(url:String):void
		{
			if (ongoing)
			{
				throw new Error("an experiment is ongoing");
			}
			if (callback==null)
			{
				throw new ArgumentError("did not set callback method");
			}
			this.ongoing = true;
			this.currenturl = "";
			this.responseheader = [];
			this.httpstatuscode = "";
			var url_fullform:String = url;
			if (url.indexOf("://") < 0)
			{
				url_fullform = "http://" + url_fullform;
			}
			this.currenturl = url_fullform;
			var request:URLRequest = new URLRequest(url_fullform);
			request.contentType = "text/html";
			request.method = URLRequestMethod.GET;
			loader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.TEXT;
			loader.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, httpStatusHandler);
			loader.addEventListener(IOErrorEvent.IO_ERROR, httpLoaderIOErrorHandler);
			loader.addEventListener(Event.COMPLETE, httpCompleteHandler);
			timer = new Timer(5000, 1);
			timer.addEventListener(TimerEvent.TIMER_COMPLETE, timerExpireHandler);
			try
			{
				this.timed = getTimer();
				loader.load(request);
			}
			catch (error:Error)
			{
				//status_label.text = "Error: please check your input!\n";
				//trace("Unable to load URL:" + error);
				var result:ExperimentResult = new ExperimentResult(EXP_ID, EXP_VER, [currenturl], "FAILURE", "", "input error", [], "");
				this.ongoing = false;
				this.callback(result);
			}
		}
		
		public function registerNotification(func:Function):void
		{
			if (ongoing)
			{
				throw new Error("an experiment is ongoing");
			}
			this.callback = func;
		}

		private function httpStatusHandler(event:HTTPStatusEvent):void
		{
			if (!ongoing)
			{
				return;
			}
			timer.stop();
			var httpStatus:String = "";
			//status
			//httpStatus +=  "Status Code: " + String(event.status) + "\n";
			this.httpstatuscode = String(event.status);
			//responseURL
			//httpStatus +=  "Response URL: " + event.responseURL + "\n";
			this.responseheader.push("ResponseURL:" + event.responseURL);
			//URLRequestHeader
			//httpStatus +=  "Headers: \n";
			var headers:Array = event.responseHeaders;
			for (var i:uint = 0; i < headers.length; i++)
			{
				//httpStatus +=  "    " + headers[i].name + ": " + headers[i].value + "\n";
				this.responseheader.push(headers[i].name + ":" + headers[i].value);
			}
			//httpStatus +=  "\n";
			//output_text.text = httpStatus;
		}

		private function httpLoaderIOErrorHandler(event:IOErrorEvent):void
		{
			if (!ongoing)
			{
				return;
			}
			timer.stop();
			//status_label.text = "Error: " + event.toString() + "\n";
			var result:ExperimentResult = new ExperimentResult(EXP_ID, EXP_VER, [currenturl], "FAILURE", "", event.toString(), [], "");
			this.ongoing = false;
			this.callback(result);
		}

		private function httpCompleteHandler(event:Event):void
		{
			if (!ongoing)
			{
				return;
			}
			timer.stop();
			var loader:URLLoader = URLLoader(event.target);
			var time_diff:int = getTimer() - this.timed;
			//status_label.text = "Http time: " + time_diff + " ms";
			//trace(loader.data);
			//output_text.text +=  loader.data;
			//this.responseheader += "ResponseTime:" + String(time_diff) + ",";
			var result:ExperimentResult = new ExperimentResult(EXP_ID, EXP_VER, [currenturl], "SUCCESS", this.httpstatuscode, loader.data, this.responseheader, String(time_diff));
			this.ongoing = false;
			this.callback(result);
		}
		
		private function timerExpireHandler(event:TimerEvent):void
		{
			if (!ongoing)
			{
				return;
			}
			var result:ExperimentResult = new ExperimentResult(EXP_ID, EXP_VER, [currenturl], "FAILURE", "", "Timeout", [], "5000");
			this.ongoing = false;
			this.callback(result);
		}
	}
}