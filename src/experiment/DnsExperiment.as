package experiment 
{
	import flash.events.*;
	import flash.net.dns.*;
	import flash.utils.getTimer;
	/**
	 * ...
	 * @author ...
	 */
	public class DnsExperiment 
	{
		public static const EXP_ID:String = "DNS IPv4";
		public static const EXP_VER:String = "1.0";
		
		private var callback:Function;
		private var ongoing:Boolean;
		
		private var domainname:String;
		private var timed:int;
		
		public function DnsExperiment() 
		{
			
		}
	
		public function doExperiment(domain:String):void
		{
			if (ongoing)
			{
				throw new Error("an experiment is ongoing");
			}
			if (callback==null)
			{
				throw new ArgumentError("did not set callback method");
			}
			this.domainname = domain;
			var resolver:DNSResolver = new DNSResolver();
			resolver.addEventListener(DNSResolverEvent.LOOKUP, dnsLookupHandler);
			resolver.addEventListener(ErrorEvent.ERROR, dnsErrorHandler);
			timed = getTimer();
			try
			{
				resolver.lookup(domain, ARecord);
			}
			catch (error:Error)
			{
				//status_label.text = "Error: please check your input!\n";
				var result:ExperimentResult = new ExperimentResult(EXP_ID, EXP_VER, this.domainname, "FAILURE", "", "input error", "", "");
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

		private function dnsLookupHandler(event:DNSResolverEvent):void
		{
			var time_diff:int = getTimer() - timed;
			//status_label.text = "DNS Time: " + time_diff + " ms";
			//var extrainfo:String = "Time:"+String(time_diff);
			var dnsResult:String = "";
			dnsResult +=  "Query string: " + event.host + "\n";
			for each (var record:* in event.resourceRecords)
			{
				if (record is ARecord)
				{
					dnsResult += "    " + (record.name + " : " + record.address) + "; ";
				}
				if (record is AAAARecord)
				{
					dnsResult += "    " + (record.name + " : " + record.address) + "; ";
				}
				if (record is MXRecord)
				{
					dnsResult += "    " + (record.name + " : " + record.exchange + ", " 
					+ record.preference) + ";";
				}
				if (record is PTRRecord)
				{
					dnsResult += "    " + (record.name + " : " + record.ptrdName) + "; ";
				}
				if (record is SRVRecord)
				{
					dnsResult += "    " + (record.name + " : " + record.target + ", " 
					+ record.port + ", " + record.priority + ", " 
					+ record.weight) + "; ";
				}
			}//end of for each loop
			//output_text.text +=  dnsResult;
			var result:ExperimentResult = new ExperimentResult(EXP_ID, EXP_VER, this.domainname, "SUCCESS", "", dnsResult, "", String(time_diff));
			this.ongoing = false;
			this.callback(result);
		}

		private function dnsErrorHandler(event:DNSResolverEvent):void
		{
			//status_label.text = "Error: " + event.toString() + "\n";
			var result:ExperimentResult = new ExperimentResult(EXP_ID, EXP_VER, this.domainname, "FAILURE", "", event.toString(), "", "");
			this.ongoing = false;
			this.callback(result);
		}
	}
}