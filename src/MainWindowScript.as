import experiment.DnsExperiment;
import experiment.ExperimentResult;
import experiment.HttpExperiment;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.*;

import centinel.*;


private var debug:Boolean = true;
private var timed:int = 0;
private var uploadobject:Upload;
private var lastresult:ExperimentResult;

private function windows_initialized():void
{
	status_label.text = "Status";
	test_button.addEventListener(MouseEvent.CLICK, onClick);
	upload_button.addEventListener(MouseEvent.CLICK, upLoad);
	trace("Application starts");
	
	uploadobject = new Upload("https://130.245.64.107:8082/","foo","bar");
	//uploadobject = new Upload("http://130.245.64.107:1234/","foo","bar");

	// tab index
	input_text.tabIndex = 1;
	method_dropdown.tabIndex = 2;
	test_button.tabIndex = 3;
	output_text.tabIndex = 4;
	
	//status_label.htmlText='<font face="Arial" color="#FF0000" size="20">Fill:</font>';
	/*
	// add for test
	var aLabel:Label = new Label();
	var aCp:ColorPicker = new ColorPicker();

	addChild(aLabel);
	addChild(aCp);

	aLabel.htmlText = '<font face="Arial" color="#FF0000" size="14">Fill:</font>';
	aLabel.x = 200;
	aLabel.y = 150;
	aLabel.width = 25;
	aLabel.height = 22;

	aCp.x = 230;
	aCp.y = 150;
	// end add for test
	*/
}

//event handler
private function onClick(event:MouseEvent):void
{
	output_text.text = "";// clear text after teach test button click
	if (method_dropdown.selectedIndex == 0)
	{
		status_label.text = "Sending HTTP request to: " + input_text.text + "\n";
		var exp:HttpExperiment = new HttpExperiment();
		exp.registerNotification(http_result_handler);
		exp.doExperiment(input_text.text);
	}
	else
	{
		status_label.text = "Sending DNS request for " + input_text.text + "\n";
		var exp2:DnsExperiment = new DnsExperiment();
		exp2.registerNotification(dns_result_handler);
		exp2.doExperiment(input_text.text);
	}
}

//upload button event handler
private function upLoad(event:MouseEvent):void
{
	if (lastresult != null)
	{
		uploadobject.postResults(lastresult.json());
	}
	else
	{
		status_label.text = "Please do test first";
	}
}

private function http_result_handler(result:ExperimentResult):void
{
	status_label.text = result.error;
	output_text.text = result.json();
	lastresult = result;
}

private function dns_result_handler(result:ExperimentResult):void
{
	status_label.text = result.status;
	output_text.text = result.json();
	lastresult = result;
}

/*--- Part I: Do HTTP Load ---*//*
private function doHttpLoad(url:String):void
{
	var url_fullform:String = url;
	if (url.indexOf("://") < 0)
	{
		url_fullform = "http://" + url_fullform;
	}
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

private function httpStatusHandler(event:HTTPStatusEvent):void
{
	var httpStatus:String = "";
	//status
	httpStatus +=  "Status Code: " + String(event.status) + "\n";
	//responseURL
	httpStatus +=  "Response URL: " + event.responseURL + "\n";
	//URLRequestHeader
	httpStatus +=  "Headers: \n";
	var headers:Array = event.responseHeaders;
	for (var i:uint = 0; i < headers.length; i++)
	{
		httpStatus +=  "    " + headers[i].name + ": " + headers[i].value + "\n";
	}
	httpStatus +=  "\n";
	output_text.text = httpStatus;
}

private function httpLoaderIOErrorHandler(event:IOErrorEvent):void
{
	status_label.text = "Error: " + event.toString() + "\n";
}

private function httpCompleteHandler(event:Event):void
{
	var loader:URLLoader = URLLoader(event.target);
	var time_diff:int = getTimer() - timed;
	status_label.text = "Http time: " + time_diff + " ms";
	//trace(loader.data);
	output_text.text +=  loader.data;
}

/*--- Part II: Do DNS Query ---*//*
private function doDnsQuery(url:String):void
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

private function dnsLookupHandler(event:DNSResolverEvent):void
{
	var time_diff:int = getTimer() - timed;
	status_label.text = "DNS Time: " + time_diff + " ms";
	var dnsResult:String = "";
	dnsResult +=  "Query string: " + event.host + "\n";
	for each (var record:* in event.resourceRecords)
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
			+ record.weight) + "\n";
		}
	}//end of for each loop
	output_text.text +=  dnsResult;
}

private function dnsErrorHandler(event:DNSResolverEvent):void
{
	status_label.text = "Error: " + event.toString() + "\n";
}
*/
