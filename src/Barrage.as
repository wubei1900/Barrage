package
{
	import com.greensock.TweenLite;
	
	import flash.events.Event;
	import flash.external.ExternalInterface;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.setInterval;
	
	import org.flexlite.domCore.Injector;
	import org.flexlite.domUI.components.Alert;
	import org.flexlite.domUI.components.Group;
	import org.flexlite.domUI.components.Label;
	import org.flexlite.domUI.components.UIAsset;
	import org.flexlite.domUI.core.Theme;
	import org.flexlite.domUI.layouts.HorizontalLayout;
	import org.flexlite.domUI.managers.SystemManager;
	import org.flexlite.domUI.skins.themes.VectorTheme;
	
	public class Barrage extends SystemManager
	{
		private var ud:URLLoader;
		private var xml:XML;
		private var xmlLength:int;
		private  var arrName:Array;
		private  var arrId:Array;
		private  var strUrl:String;
		public function Barrage()
		{
			Injector.mapClass(Theme,VectorTheme);
			
			this.addEventListener(Event.ADDED_TO_STAGE,addStageHandler);
			
			//REjectTranspote
			if(ExternalInterface.available)
			{
				ExternalInterface.addCallback('dispatchMsg',dispatchMsg);
			}
			//抛消息的，管多少
			setInterval(testInterval,200);
			
			//配置图标库URl
			this.markUrl = this.loaderInfo.parameters['markUrl'] || this.markUrl;
		}
			
		private function testInterval():void
		{
			dispatchMsg({
				cnt:'这是个[微笑][偷笑][微笑]好[调皮]节目[撇嘴]节目[微笑]节目[傲慢]节目[微笑]节目[惊讶]小拇指',
				nickname:'姓名'+Math.ceil(Math.random()*100),
				style:{
					fontsize:'medium',
					color:'000000'
					
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
			
			
			
			//hhp  提取string里的图片名
			//var reg:RegExp=new RegExp(/\[.]|\[..]|\[...]|\[....]|\[.....]/g)
			//var arr:Array=str.match(reg);
			
			//hhp 获取string的正确顺序
			
			var msgContainer:Group = new Group();
			
			msgContainer.x = screen.width + 10;
			msgContainer.y = screen.height * Math.random();
			
			msgContainer.layout = new HorizontalLayout();
			//解析字符串，图片
			parseMark(msgContainer,msg);
			
			screen.addElement(msgContainer);
			
			TweenLite.to(msgContainer,25,{x: -500,delay:0.3});
		}
		//解析图片和文本的函数
		protected function parseMark(container:Group,msg:Object,ts:String=''):String
		{
			//空的字符串和接收到的消息
			var s:String = ts || msg.cnt;
			//字符串有内容才能解析
			if (s.length > 0)
			{
				var leftbBracket:int = s.indexOf("[");
				var rightBracket:int = s.indexOf("]");
				
				if (leftbBracket >= 0 && rightBracket >=0)
				{
					
					var leftText:String = s.substring(0,leftbBracket);
					var mark:String = s.substring(leftbBracket, rightBracket + 1);
					var remain:String = s.substring(rightBracket+1);
					//trace(leftText,5555,mark,6666,remain);
					parseMessage(container,msg,leftText,mark);
					
					return parseMark(container,msg,remain);
				}else
				{
					return  "";
				}
			}else
			{
				return "";
			}
		}
		
		protected function addStageHandler(event:Event):void
		{  
		
			loadXml();
		
		}
		
		private var markUrl:String="http://58.215.50.188/micromessager/imgs/";
		
		private function parseMessage(container:Group,msg:Object,text:String,mark:String):void
		{
			if(text)
			{
				//消息对象
				var msgSprite:Label = new Label();
				
				//消息内容
				msgSprite.text = text;
				
				//消息样式
				msgSprite.size = msg['style'] && msg['style']['fontsize'] ? defaultStyle['fontsize'][msg['style']['fontsize']] : defaultStyle['fontsize']['small'];
				msgSprite.textColor = parseInt(msg['style'] && msg['style']['color'] ? msg['style']['color'] : defaultStyle['color'],16);
				
				
				container.addElement(msgSprite);
			}
			
			if(mark)
			{
				//暂时代替url
				//mark --> url
				
				var imgExpress:UIAsset = new UIAsset();
				imgExpress.width = imgExpress.height = 28;
				
				
				for(var i:int=0;i<xmlLength;i++)
				{
					if(String(mark)==String(arrName[i]))
					{
						
						//imgExpress.skinName = "assest/2.png";
						
						//服务器
						imgExpress.skinName = this.markUrl +"/"+arrId[i]+".gif";
						
						//测试
						//imgExpress.skinName = "assest/hard/"+arrId[i]
//						trace(imgExpress.skinName);
					}
				}
				
				container.addElement(imgExpress);
			}
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
			for(var i:int=0;i<xmlLength;i++)
			{
				arrName.push(xml.SubTexture[i].@name);
				arrId.push(xml.SubTexture[i].@id);
				//trace(xml.SubTexture[i].@name,xml.SubTexture[i].@id);
				
//				trace(arrName,arrId);
				
				
			}
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