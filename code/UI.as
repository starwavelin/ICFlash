package code {
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.*;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import flash.net.dns.*;
	import flash.utils.getTimer;
	
	public class UI extends MovieClip
	{
		var debug:Boolean = true;
		var timed:int = 0;
		
		public function UI()
		{
			status_label.text = "Status";
			test_button.addEventListener(MouseEvent.CLICK, onClick);
			trace("Application starts");
			
			// tab index
			input_text.tabIndex = 1;
			dropdown.tabIndex = 2;
			test_button.tabIndex = 3;
			output_text.tabIndex = 4;
		}
		
		//event handler
		function onClick(event:MouseEvent):void
		{
			output_text.text = ""; // clear text after teach test button click
			if (dropdown.selectedIndex == 0)
			{
				doHttpLoad(input_text.text);
			} 
			else 
			{
				doDnsQuery(input_text.text);
			}
		}
		
		/*--- Part I: Do HTTP Load ---*/
		function doHttpLoad(url:String)
		{
			var url_fullform = "http://" + url;
			var request:URLRequest = new URLRequest(url_fullform);
			request.contentType = "text/html";
			request.method = URLRequestMethod.GET;
			var loader:URLLoader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.TEXT;
			loader.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, httpStatusHandler);
			loader.addEventListener(IOErrorEvent.IO_ERROR, httpLoaderIOErrorHandler);
			loader.addEventListener(Event.COMPLETE, httpCompleteHandler);
			try 
			{
				status_label.text = "Sending HTTP request to: " + input_text.text + "\n";
				timed = getTimer();
				loader.load(request);
			}
			catch (error:Error)
			{
				status_label.text = "Error: please check your input!\n";
				//trace("Unable to load URL:" + error);
			}
		}
		
		function httpStatusHandler(event:HTTPStatusEvent):void
		{
			var httpStatus:String = "";
			//status
			httpStatus += "Status Code: " + String(event.status) + "\n";
			//responseURL
			httpStatus += "Response URL: " + event.responseURL + "\n";
			//URLRequestHeader
			httpStatus += "Headers: \n";
			var headers:Array = event.responseHeaders;
			for (var i:uint = 0; i < headers.length; i++)
			{
				httpStatus += "    " + headers[i].name + ": " + headers[i].value + "\n";
			}
			httpStatus += "\n";
			output_text.text = httpStatus;
		}
		
		function httpLoaderIOErrorHandler(event:IOErrorEvent):void
		{
			status_label.text = "Error: " + event.toString() + "\n";
		}
		
		function httpCompleteHandler(event:Event):void
		{	
			var loader:URLLoader = URLLoader(event.target);
			var time_diff = getTimer() - timed;
			status_label.text = "Http time: " + time_diff + " ms";
			//trace(loader.data);
			output_text.text += loader.data;
		}
		
		/*--- Part II: Do DNS Query ---*/
		function doDnsQuery(url:String):void
		{
			var resolver:DNSResolver = new DNSResolver();
			resolver.addEventListener(DNSResolverEvent.LOOKUP, dnsLookupHandler);
			resolver.addEventListener(ErrorEvent.ERROR, dnsErrorHandler);
			status_label.text = "Sending DNS request for " + input_text.text + "\n";
			timed = getTimer();
			try 
			{
				resolver.lookup(url, ARecord);
			}
			catch (error:Error)
			{
				status_label.text = "Error: please check your input!\n";
			}
		}
		
		function dnsLookupHandler(event:DNSResolverEvent):void
		{
			var time_diff = getTimer() - timed;
			status_label.text = "DNS Time: " + time_diff + " ms";
			var dnsResult:String = "";
			dnsResult += "Query string: " + event.host + "\n";
			for each (var record in event.resourceRecords)
			{
				if (record is ARecord)
				{
					dnsResult += "    " + (record.name + " : " + record.address) + "\n";
				}
				if (record is AAAARecord)
				{
					dnsResult += "    " + (record.name + " : " + record.address) + "\n";
				}
				if (record is MXRecord)
				{
					dnsResult += "    " + (record.name + " : " + record.exchange + ", " 
						+ record.preference) + "\n";
				}
				if (record is PTRRecord)
				{
					dnsResult += "    " + (record.name + " : " + record.ptrdName) + "\n";
				}
				if (record is SRVRecord)
				{
					dnsResult += "    " + (record.name + " : " + record.target + ", " 
						+ record.port + ", " + record.priority + ", " 
						+ record.weight) + "\n"
				}
			}	//end of for each loop
			output_text.text += dnsResult;			
		}
		
		function dnsErrorHandler(event:DNSResolverEvent):void
		{
			status_label.text = "Error: " + event.toString() + "\n";
		}
	}
}