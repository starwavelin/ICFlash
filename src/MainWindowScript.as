import experiment.DnsExperiment;
import experiment.ExperimentResult;
import experiment.HttpExperiment;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.*;
import flash.filesystem.File;
import flash.filesystem.FileStream;
import mx.collections.ArrayList;
import mx.containers.TabNavigator;
import mx.events.CollectionEvent;
import spark.components.Group;
import spark.events.GridEvent;
import spark.events.GridSelectionEvent;

import centinel.*;

private const URLXML:String = "assets/urls.xml";

private const UPLOAD_NO:String = "ready";
private const UPLOAD_UPLOADING:String = "uploading";
private const UPLOAD_ERROR:String = "error";
private const UPLOAD_DONE:String = "done";

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
	
	//uploadobject = new Upload("https://130.245.64.107:8082/","foo","bar");
	//uploadobject = new Upload("http://130.245.64.107:1234/","foo","bar");

	//this.addEventListener(Event.RESIZE, windows_resized);
}

/*private function windows_resized(event:Event):void
{
	var input_group:Group = this.input_group;
	var output_group:Group = this.output_group;
	var status_group:Group = this.status_group;
	
	input_group.width = this.stage.width;
	output_group.width = this.stage.width;
	status_group.width = this.stage.width;
	
	input_group.y = 0;
	input_group.height = (this.stage.height - 100) * 0.40;
	output_group.y = (this.stage.height - 100) * 0.40;
	output_group.height = (this.stage.height - 100) * 0.60;
	status_group.y = (this.stage.height - 100);
	status_group.height = 100;
	
	var input_tab_group:TabNavigator = this.input_tab_group;
	input_tab_group.percentWidth = 100;
	input_tab_group.percentHeight = 100;
	
	
}*/

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
		uploadobject = new Upload(uploadserver_text.text, "foo", "bar");
		var arr:Array = new Array(result_grid_data.length - upload_index);
		for (var i:int = upload_index; i < result_grid_data.length; i++)
		{
			var result_item:* = result_grid_data.getItemAt(i);
			arr[i - upload_index] = result_item;
			result_grid_data.getItemAt(i).uploaded = UPLOAD_UPLOADING;
		}
		result_grid.dataProvider.dispatchEvent( new CollectionEvent(CollectionEvent.COLLECTION_CHANGE));
		upload_index = result_grid_data.length;
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
	output_text.text = "";
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
	result_grid_data.addItem( { input:result.args, status:result.error, time:result.time, uploaded:UPLOAD_NO, result_object:result } );
	result_grid.validateNow();
	result_grid.ensureCellIsVisible(result_grid.dataProviderLength - 1);
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
			if (result_grid_data.getItemAt(i).uploaded == UPLOAD_UPLOADING)
			{
				result_grid_data.getItemAt(i).uploaded = UPLOAD_DONE;
			}
			else if (result_grid_data.getItemAt(i).uploaded == UPLOAD_DONE)
			{
				break;
			}
		}
	}
	else if (error < 0)
	{
		for (var j:int = upload_index-1; j >= 0; j--)
		{
			if (result_grid_data.getItemAt(j).uploaded == UPLOAD_UPLOADING)
			{
				result_grid_data.getItemAt(j).uploaded = UPLOAD_ERROR;
				upload_index = j;
			}
			else if (result_grid_data.getItemAt(j).uploaded == UPLOAD_DONE)
			{
				break;
			}
		}
	}
	result_grid.dataProvider.dispatchEvent( new CollectionEvent(CollectionEvent.COLLECTION_CHANGE));
	upload_button.enabled = true;
	clearresult_button.enabled = true;
}
