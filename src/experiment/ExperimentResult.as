package experiment 
{
	/**
	 * ...
	 * @author ...
	 */
	public class ExperimentResult 
	{
		private var description:String;
		private var version:String;
		private var parameter:String;
		private var shortstatus:String;
		private var returncode:String;
		private var resultbody:String;
		private var extrainfo:String;
		private var finishtime:String;
		
		public function ExperimentResult(id:String,ver:String,args:String,status:String,error:String,body:String,extra:String,time:String) 
		{
			this.description = id;
			this.version = ver;
			this.parameter = args;
			this.shortstatus = status;
			this.returncode = error;
			this.resultbody = body;
			this.extrainfo = extra;
			this.finishtime = time;
		}
		
		/* Experiment identification */
		public function get id():String
		{
			return this.description;
		}
		
		/* Experiment version */
		public function get ver():String
		{
			return this.version;
		}
		
		/* Argument used in the experiment */
		public function get args():String
		{
			return this.parameter;
		}
		
		/* Human readable status */
		public function get status():String
		{
			return this.shortstatus;
		}
		
		/* Error code or return code of the experiment */
		public function get error():String
		{
			return this.returncode;
		}
		
		/* Body of the response */
		public function get body():String
		{
			return this.resultbody;
		}
		
		/* extra info in the experiment */
		public function get extra():String
		{
			return this.extrainfo;
		}
		
		public function get time():String
		{
			return this.finishtime;
		}
		
		/* Json representation */
		public function json():String
		{
			return JSON.stringify(this);
		}
	}

}