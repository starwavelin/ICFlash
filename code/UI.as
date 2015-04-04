package code {
	import flash.display.MovieClip;
	import flash.display.Sprite; 
	import flash.events.*; 
	import flash.net.URLLoader; 
	import flash.net.URLLoaderDataFormat; 
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import flash.utils.getTimer;
	
	public class UI extends MovieClip
	{
		var debug:Boolean = true;
		var timed:int = 0;
		
		public function UI() 
		{
			status_label.text = "Status";
			test_button.addEventListener(MouseEvent.CLICK, onClick);
			trace("Application start");
		}
		
		//event handler
		function onClick(event:MouseEvent):void
		{
		   doHttpLoad(input_text.text);
		}
		
		function doHttpLoad(url:String) 
		{ 
			var request:URLRequest = new URLRequest(url); 
			request.contentType = "text/html"; 
			request.method = URLRequestMethod.GET; 
			var loader:URLLoader = new URLLoader(); 
			loader.dataFormat = URLLoaderDataFormat.TEXT; 
			loader.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, httpStatusHandler);
			loader.addEventListener(IOErrorEvent.IO_ERROR, httpLoaderIOErrorHandler);
			loader.addEventListener(Event.COMPLETE, completeHandler); 
			try 
			{ 
				status_label.text = "Sending request to: "+input_text.text+"\n";
				output_text.text = "";
				timed = getTimer();
				loader.load(request); 
			}  
			catch (error:Error) 
			{ 
				status_label.text = "Error: "+error+"\n";
				trace("Unable to load URL: " + error); 
			} 
		} 
		
		function httpStatusHandler(event:HTTPStatusEvent):void
		{
			var httpStatus:String = "";
			//status
			httpStatus += "Status code: " + String(event.status) + "\n";
			//responseURL
			httpStatus += "Response URL: " + event.responseURL + "\n";
			//URLRequestHeader 
			httpStatus += "Headers:\n";
			var headers:Array = event.responseHeaders;
			for(var i:uint = 0; i<headers.length; i++)
			{
				httpStatus += "    " + headers[i].name + ": " + headers[i].value + "\n";
			}
			httpStatus += "\n";
			output_text.text = httpStatus;
			
		}
		
		function completeHandler(event:Event):void 
		{ 
			var loader:URLLoader = URLLoader(event.target); 
			//trace(loader.data); 
			output_text.text += loader.data;
			status_label.text = "Time: " + (getTimer() - timed) + " ms";
		} 
		
		function httpLoaderIOErrorHandler(event:Event):void 
		{ 
			status_label.text = "Error: "+event+"\n";
		} 
	}
}