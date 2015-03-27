package code {
	import flash.display.MovieClip;
	import flash.display.Sprite; 
	import flash.events.*; 
	import flash.net.URLLoader; 
	import flash.net.URLLoaderDataFormat; 
	import flash.net.URLRequest;
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
		   HttpLoad(input_text.text);
		}
		
		function HttpLoad(url:String) 
		{ 
			var request:URLRequest = new URLRequest(url); 
			request.contentType = "text/html"; 
			request.method = URLRequestMethod.GET; 
			var loader:URLLoader = new URLLoader(); 
			loader.addEventListener(IOErrorEvent.IO_ERROR, httpLoaderIOErrorHandler);
			loader.dataFormat = URLLoaderDataFormat.TEXT; 
			loader.addEventListener(Event.COMPLETE, completeHandler); 
			try 
			{ 
				status_label.text = "Sending request to: "+input_text.text+"\n";
				timed = getTimer();
				loader.load(request); 
			}  
			catch (error:Error) 
			{ 
				status_label.text = "Error: "+error+"\n";
				trace("Unable to load URL: " + error); 
			} 
		} 
		
		function completeHandler(event:Event):void 
		{ 
			var loader:URLLoader = URLLoader(event.target); 
			//trace(loader.data); 
			output_text.text = loader.data;
			status_label.text = "Time: " + (getTimer() - timed) + " ms";
		} 
		
		function httpLoaderIOErrorHandler(event:Event):void 
		{ 
			status_label.text = "Error: "+event+"\n";
		} 
	}
}