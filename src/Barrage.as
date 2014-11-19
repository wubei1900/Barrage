package
{
	import com.greensock.TweenLite;
	
	import flash.events.Event;
	import flash.external.ExternalInterface;
	import flash.utils.setInterval;
	
	import org.flexlite.domCore.Injector;
	import org.flexlite.domUI.components.Alert;
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
			
			setInterval(testInterval,100);
		}
			
		private function testInterval():void
		{
			dispatchMsg({
				cnt:'这是一个测试' + Math.ceil(Math.random()*100000000),
				nickname:'姓名'+Math.ceil(Math.random()*100),
				style:{
				}
			});
		}
		
		private var defaultStyle:Object = {
			fontsize:{
				small: 14,
				medium: 24,
				large:32,
				llarge:42
			},
			color:'DDDDDD'
		};
		
		private function dispatchMsg(msg):void
		{
			l('MSG:',msg);
			
			//cid: "Test2"
			//cnt: "我"
			//code: "broadcast"
			//gid: "CCTV1"
			//headimg: ""
			//nickname: "游客"
			//style: "
			//{
				//"fontsize":"llarge",
				//"color":"blue",
				//"flyspeed":"quickly",
				//"animation":"normal"
			//}
			//"tm: 1415931995444
			
			//消息对象
			var msgSprite:Label = new Label();
			
			//消息内容
			msgSprite.text = msg['nickname'] ? (msg['nickname'] + " : " + msg.cnt) : "" + msg.cnt;
			
			//消息样式
			msgSprite.size = msg['style'] && msg['style']['fontsize'] ? defaultStyle['fontsize'][msg['style']['fontsize']] : defaultStyle['fontsize']['small'];
			msgSprite.textColor = parseInt(msg['style'] && msg['style']['color'] ? msg['style']['color'] : defaultStyle['color'],16);
			
			//消息初始定位
			msgSprite.x = screen.width;
			msgSprite.y = Math.random() * screen.height;
			
			//消息动画
			TweenLite.to(msgSprite,60,{x:-500,onComplete:function(tr:Label):void
			{
				tr.text = 'done';
				
				screen.removeElement(tr);
				
			},onCompleteParams:[msgSprite]});
			
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
			screen.x = screen.y = 0;
			screen.percentWidth = screen.percentHeight = 100;
		
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
		
		private function a(...args):void
		{
			Alert.show(JSON.stringify(args),'DEBUG');	
		}
	}
}