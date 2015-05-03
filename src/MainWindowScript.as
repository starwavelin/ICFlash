import experiment.DnsExperiment;
import experiment.ExperimentResult;
import experiment.HttpExperiment;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.*;
import mx.collections.ArrayList;
import spark.events.GridEvent;
import spark.events.GridSelectionEvent;

import centinel.*;


private var debug:Boolean = true;
private var timed:int = 0;
private var uploadobject:Upload;
private var stopped:Boolean = false;
//private var lastresult:ExperimentResult;

private var experiment_queue:ArrayList;
private var results_list:ArrayList = new ArrayList();
private var upload_index:int = 0; // index of next item to upload

private function windows_initialized():void
{
	status_label.text = "Status";
	//test_button.addEventListener(MouseEvent.CLICK, onClick);
	//upload_button.addEventListener(MouseEvent.CLICK, upLoad);
	trace("Application starts");
	
	uploadobject = new Upload("https://130.245.64.107:8082/","foo","bar");
	//uploadobject = new Upload("http://130.245.64.107:1234/","foo","bar");

	// tab index
	//input_text.tabIndex = 1;
	//method_dropdown.tabIndex = 2;
	//test_button.tabIndex = 3;
	//output_text.tabIndex = 4;
	
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
private function test2_button_onclick(event:MouseEvent):void
{
	if(test2_button.label=="Test") {
		input_tab_tab2.enabled = false;
		test2_button.label = "Stop";
		method2_dropdown.enabled = false;
		status_label.text = "doing bulk experiment";
		experiment_queue = new ArrayList();
		stopped = false;
		if (method2_dropdown.selectedIndex == 0)
		{
			var exp:HttpExperiment = new HttpExperiment();
			exp.registerNotification(bulk_result_handler);
			for (var i:int = 0; i < url_list_data.length; i++)
			{
				var url:* = url_list_data.getItemAt(i);
				experiment_queue.addItem([exp, url]);
				//output_text.text += url;
			}
		}
		else if (method2_dropdown.selectedIndex == 1)
		{
			var exp2:DnsExperiment = new DnsExperiment();
			exp2.registerNotification(bulk_result_handler);
			for (var j:int = 0; j < url_list_data.length; j++)
			{
				var domain:* = url_list_data.getItemAt(j);
				experiment_queue.addItem([exp2, domain]);
			}
		}
		bulk_result_handler(null);
	}
	else if (test2_button.label == "Stop")
	{
		stopped = true;
	}
}

//event handler
private function test_button_onclick(event:MouseEvent):void
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
private function upload_button_onclick(event:MouseEvent):void
{
	if (results_list.length>upload_index)
	{
		//uploadobject.postResults(lastresult.json());
		upload_button.enabled = false;
		clearresult_button.enabled = false;
		var arr:Array = new Array(results_list.length - upload_index);
		for (var i:int = upload_index; i < result_grid_data.length; i++)
		{
			var result_item:* = result_grid_data.getItemAt(i);
			arr[i - upload_index] = result_item;
			result_grid_data.getItemAt(i).uploaded = "uploading";
		}
		upload_index = url_list_data.length;
		var json_string:String = JSON.stringify(arr);
		uploadobject.postResults(json_string, upload_finish_handler);
	}
	else
	{
		status_label.text = "No item to upload";
	}
}

//clear result button event handler
private function clearresult_button_onclick(event:MouseEvent):void
{
	results_list = new ArrayList();
	result_grid_data = new ArrayList();
	upload_index = 0;
}

private function bulk_result_handler(result:ExperimentResult):void
{
	if (result != null)
	{
		status_label.text = result.error;
		//output_text.text = result.json();
		add_result_to_list(result);
	}
	if (stopped)
	{
		experiment_queue.removeAll();
	}
	if (experiment_queue.length != 0)
	{
		var item:* = experiment_queue.getItemAt(0);
		experiment_queue.removeItemAt(0);
		item[0].doExperiment(item[1]);
	}
	else {
		input_tab_tab2.enabled = true;
		test2_button.label = "Test";
		method2_dropdown.enabled = true;
		experiment_queue = null;
		status_label.text = "completed";
	}
}

private function http_result_handler(result:ExperimentResult):void
{
	status_label.text = result.error;
	//output_text.text = result.json();
	add_result_to_list(result);
}

private function dns_result_handler(result:ExperimentResult):void
{
	status_label.text = result.status;
	//output_text.text = result.json();
	add_result_to_list(result);
}

private function add_result_to_list(result:ExperimentResult):void
{
	results_list.addItem(result);
	result_grid_data.addItem( { input:result.args, status:result.error, time:result.time, uploaded:"no", result_object:result } );
}

private function display_result_detail(event:GridSelectionEvent):void
{
	output_text.text = result_grid.selectedItem.result_object.body;
}

private function upload_finish_handler(error:int, data:String):void
{
	if (error == 0)
	{
		for (var i:int = upload_index-1; i >= 0; i--)
		{
			if (result_grid_data.getItemAt(i).uploaded == "uploading")
			{
				result_grid_data.getItemAt(i).uploaded = "yes";
			}
			else if (result_grid_data.getItemAt(i).uploaded == "yes")
			{
				break;
			}
		}
	}
	else if (error < 0)
	{
		for (var j:int = upload_index-1; j >= 0; j--)
		{
			if (result_grid_data.getItemAt(j).uploaded == "uploading")
			{
				result_grid_data.getItemAt(j).uploaded = "error";
				upload_index = j;
			}
			else if (result_grid_data.getItemAt(j).uploaded == "yes")
			{
				break;
			}
		}
	}
	upload_button.enabled = true;
	clearresult_button.enabled = true;
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
