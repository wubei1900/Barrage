package
{
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import org.flexlite.domUI.components.Group;
	
	public class Common_Expression extends Group
	{
		
		private var ud:URLLoader;
		private var xml:XML;
		private var xmlLength:int;
		public var arrName:Array;
		public var arrId:Array;
		public var strUrl:String;
		public function Common_Expression()
		{
			super();
			loadXml();
		}
		
		private function loadXml():void
		{
			// TODO Auto Generated method stub
			arrName=new Array();
			arrId=new Array();
			ud=new URLLoader();
			ud.load(new URLRequest("assest/c_comm.xml"));
			ud.addEventListener(Event.COMPLETE,onCom);
		}
		
		protected function onCom(event:Event):void
		{
			// TODO Auto-generated method stub
			xml=new XML(event.target.data);
			xmlLength=int(xml.SubTexture.length());
			
			strUrl=String(xml.SubTexture[0].@url);
			trace(strUrl,22222222);
			for(var i:int=0;i<xmlLength;i++)
			{
				arrName.push(xml.SubTexture[i].@name);
				arrId.push(xml.SubTexture[i].@id);
				//trace(xml.SubTexture[i].@name,xml.SubTexture[i].@id);
				
			}
			//for(var j:String in arrId)
			//{
				//trace(arrId[j],333333333);
			//}
			
		}
	}
}