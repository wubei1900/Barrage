package
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.external.ExternalInterface;
	import flash.utils.setInterval;
	
	import org.flexlite.domCore.Injector;
	import org.flexlite.domUI.components.Group;
	import org.flexlite.domUI.components.Label;
	import org.flexlite.domUI.core.Theme;
	import org.flexlite.domUI.managers.SystemManager;
	import org.flexlite.domUI.skins.themes.VectorTheme;
	
	public class Barrage extends SystemManager
	{
		public function Barrage()
		{
			Injector.mapClass(Theme,VectorTheme);
			
			this.addEventListener(Event.ADDED_TO_STAGE,addStageHandler);
			
			//REjectTranspote
			if(ExternalInterface.available)
			{
				ExternalInterface.addCallback('dispatchMsg',dispatchMsg);
			}
			
			setInterval(testInterval,1000);
		}
			
		private function testInterval():void
		{
			dispatchMsg({cnt:'这是一个测试' + Math.ceil(Math.random()*100000000)});
		}
		
		private function dispatchMsg(msg):void
		{
			l('MSG:',msg);
			
			var msgSprite:Label = new Label();
			msgSprite.text = msg.cnt;
			
			msgSprite.right = 0;
			
			msgSprite.x = this.width/2;
			msgSprite.y = Math.random() * this.height;
			
			screen.addElement(msgSprite);
		}
		
		protected function addStageHandler(event:Event):void
		{
			
		}
		
		private var screen:Group;
		
		override protected function createChildren():void
		{
			super.createChildren();
			
			screen = new Group();
		
			addElement(screen);
		}
		
		private function l(...args):void
		{
			var logstr:String = JSON.stringify(args);
			
			trace('LOCAL LOG:-->',logstr);
			
			if(ExternalInterface.available)
			{
				ExternalInterface.call('console.log','Barrage--->',logstr);
			}
		}
	}
}