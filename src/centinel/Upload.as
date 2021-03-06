﻿package centinel
{
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import flash.events.*;
	import flash.net.URLVariables;
	import mx.formatters.DateFormatter;
	
	public class Upload 
	{
		private var serverUrl:String;
		private var currentMethod:String;
		private var userName:String;
		private var passWord:String;
		
		//(error:int,data:string) - error 0 for success, <0 for failure
		private var callback:Function;
		
		public function Upload(url:String,username:String,password:String)
		{
			this.serverUrl = url;
			this.userName = username;
			this.passWord = password;
		}
		
		public function getVersion():void
		{
			this.currentMethod = APIMethod.GETVERSION;
			sendGetRequest(this.serverUrl+"version",false);
		}
		
		public function getResults():void
		{
			this.currentMethod = APIMethod.GETRESULTS;
			sendGetRequest(this.serverUrl+"results",true);
		}
		
		public function postResults(result:String,done:Function):void
		{
			this.currentMethod = APIMethod.POSTRESULTS;
			this.callback = done;
			//var variables:URLVariables = new URLVariables("files='{\"result\": {\"status\": \"success\"}}'");
			/*var mystr:String;
			mystr = "{\"result\": {\"status\": \"success\"}}";*/
			sendFileUpload(this.serverUrl+"results",result,true);
		}
		
		private function sendGetRequest(url:String,auth:Boolean=false):void
		{
			trace(url);
			var header:URLRequestHeader;
			var request:URLRequest = new URLRequest(url);
			if(auth)
			{
				//header = new URLRequestHeader("Authorization", "Basic " + Base64.encode(this.userName+":"+this.passWord));
				header = new URLRequestHeader("Authorization", "Basic " + "Zm9vOmJhcg=="); //foo:bar base64
				request.requestHeaders.push(header);
			}
			request.contentType = "text/html";
			request.method = URLRequestMethod.GET;
			var loader:URLLoader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.TEXT;
			loader.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, httpStatusHandler);
			loader.addEventListener(IOErrorEvent.IO_ERROR, httpLoaderIOErrorHandler);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			loader.addEventListener(Event.COMPLETE, httpCompleteHandler);
			try
			{
				loader.load(request);
			}
			catch (error:Error)
			{
				trace("load:" + error);
			}
		}
		
		/*private function sendPostRequest(url:String,data:String,auth:Boolean):void
		{
			trace(url);
			var header:URLRequestHeader;
			var request:URLRequest = new URLRequest(url);
			if(auth)
			{
				//header = new URLRequestHeader("Authorization", "Basic " + Base64.encode(this.userName+":"+this.passWord));
				header = new URLRequestHeader("Authorization", "Basic " + "Zm9vOmJhcg=="); //foo:bar base64
				request.requestHeaders.push(header);
			}
			request.contentType = "text/html";
			//request.contentType = "application/x-www-form-urlencoded";
			request.method = URLRequestMethod.POST;
			request.data = data;
			var loader:URLLoader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.TEXT;
			loader.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, httpStatusHandler);
			loader.addEventListener(IOErrorEvent.IO_ERROR, httpLoaderIOErrorHandler);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			loader.addEventListener(Event.COMPLETE, httpCompleteHandler);
			try
			{
				loader.load(request);
			}
			catch (error:Error)
			{
				trace("load:" + error);
			}
		}*/
		
		private function sendFileUpload(url:String,data:String,auth:Boolean):void
		{
			var paddeddata:String;
			var boundary:String;
			var currentdate:Date = new Date();
			var dateformatter:DateFormatter = new DateFormatter('YYYYMMDD-HHNNSS');
			boundary = "02v049fe0f9";
			paddeddata = "--" + boundary + "\r\n";
			paddeddata += 'Content-Disposition: form-data; name="result"; filename="' + dateformatter.format(currentdate) + '.txt"' + "\r\n";
			//paddeddata += 'Content-Type: application/json' + "\r\n";
			paddeddata += 'Content-Type: text/plain' + "\r\n";
			paddeddata += "\r\n";
			paddeddata += data + "\r\n";
			paddeddata += "--" + boundary + "--\r\n";
			//trace(paddeddata);
			sendPostMultipartFormRequest(url,paddeddata,boundary,auth);
		}
		
		private function sendPostMultipartFormRequest(url:String,data:String,boundary:String,auth:Boolean):void
		{
			//trace(url);
			//trace(data);
			var header:URLRequestHeader;
			var request:URLRequest = new URLRequest(url);
			if(auth)
			{
				//header = new URLRequestHeader("Authorization", "Basic " + Base64.encode(this.userName+":"+this.passWord));
				header = new URLRequestHeader("Authorization", "Basic " + "Zm9vOmJhcg=="); //foo:bar base64
				request.requestHeaders.push(header);
			}
			//request.contentType = "multipart/form-data; boundary=---kjoijohohfc";
			request.contentType = "multipart/form-data" + "; boundary=" + boundary;
			request.method = URLRequestMethod.POST;
			request.data = data;
			var loader:URLLoader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.TEXT;
			loader.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, httpStatusHandler);
			loader.addEventListener(IOErrorEvent.IO_ERROR, httpLoaderIOErrorHandler);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			loader.addEventListener(Event.COMPLETE, httpCompleteHandler);
			try
			{
				loader.load(request);
			}
			catch (error:Error)
			{
				trace("load:" + error);
			}
		}
		
		private function httpStatusHandler(event:HTTPStatusEvent):void
		{
			trace("httpStatusHandler: " + event + " !");
			switch(currentMethod)
			{
				case APIMethod.GETVERSION:
					break;
				case APIMethod.GETRESULTS:
					break;
				case APIMethod.POSTRESULTS:
					var done:Function = this.callback;
					this.callback = null;
					if (event.status == 201)
					{
						done(0, String(event.status));
					}
					else
					{
						done(-2, String(event.status));
					}
					break;
				default:
					break; 
			}
		}

		private function httpLoaderIOErrorHandler(event:IOErrorEvent):void
		{
			//trace("httpLoaderIOErrorHandler: " + event + " !");
			switch(currentMethod)
			{
				case APIMethod.GETVERSION:
					trace("httpLoaderIOErrorHandler: " + event + " !");
					break;
				case APIMethod.GETRESULTS:
					trace("httpLoaderIOErrorHandler: " + event + " !");
					break;
				case APIMethod.POSTRESULTS:
					trace("httpLoaderIOErrorHandler: " + event + " !");
					var done:Function = this.callback;
					this.callback = null;
					done(-1,"httpLoaderIOErrorHandler: " + event + " !");
					break;
				default: 
					trace("httpLoaderIOErrorHandler: Out of range"); 
					break; 
			}
		}
		
		private function securityErrorHandler(event:SecurityErrorEvent):void
		{
			trace("securityErrorHandler: " + event + " !");
		}

		private function httpCompleteHandler(event:Event):void
		{
			var loader:URLLoader = URLLoader(event.target);
			switch(currentMethod)
			{
				case APIMethod.GETVERSION:
					trace(loader.data);
					break;
				case APIMethod.GETRESULTS:
					trace(loader.data);
					break;
				case APIMethod.POSTRESULTS:
					trace("uploadCompleteHandler: " + loader.data);
					break;
				default: 
					trace("uploadCompleteHandler: Out of range"); 
					break; 
			}
		}
	}
}