package
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.external.ExternalInterface;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.system.System;
	import flash.text.Font;
	import flash.utils.clearInterval;
	import flash.utils.getTimer;
	import flash.utils.setInterval;
	
	import Component.EmoteContainer;
	import Component.MsgContainer;
	
	import org.flexlite.domCore.Injector;
	import org.flexlite.domUI.components.Alert;
	import org.flexlite.domUI.components.Button;
	import org.flexlite.domUI.components.Group;
	import org.flexlite.domUI.components.Label;
	import org.flexlite.domUI.core.Theme;
	import org.flexlite.domUI.events.ResizeEvent;
	import org.flexlite.domUI.events.UIEvent;
	import org.flexlite.domUI.managers.SystemManager;
	import org.flexlite.domUI.skins.themes.VectorTheme;
	
	[SWF(backgroundColor="#000000", frameRate="24")]
//	[Embed(source="C:/Windows/Fonts/MSYH.ttf", fontName="微软雅黑", mimeType="application/x-font-truetype")]
	public class Barrage extends SystemManager
	{
		private var ud:URLLoader;
		private var xml:XML;
		private var xmlLength:int;
		private  var arrName:Array;
		private  var arrId:Array;
		private  var strUrl:String;
		
		private var groupList:Vector.<MsgContainer>;//图文混排列表
		private var emoteList:Vector.<EmoteContainer>;//魔法表情容器列表
	
		private var testSpeed:Array = ['slow', 'general', 'fast', 'quickly'];
		private var testMove:Array = ['normal', 'waves', 'flicker'];
		
		private var cacheMsgList:Array;
		private var ONSCREENMAX:int = 500;
		public function Barrage()
		{
			Injector.mapClass(Theme,VectorTheme);
			
			this.addEventListener(Event.ADDED_TO_STAGE,addStageHandler);
			addStageHandler();
//			this.addEventListener(ResizeEvent.RESIZE, stageResize);
			//抛消息的，管多少
//			testWork = true;
			
			//测试开关按钮
//			testOpenAndClose();
			
//			this.addEventListener(Event.ENTER_FRAME, priftHandler);
			//配置图标库URl
			//this.markUrl = this.loaderInfo.parameters['markUrl'] || this.markUrl;
//			fscommand("allowscale", 'false');
		}
		
		private function checkFontFamily(fontName:String):Boolean
		{
			var hasFont:Boolean = false;
			var localFonts:Array = Font.enumerateFonts(true);
			var f:Font;
			var fName:String;
			for(var i:int=0, len:int=localFonts.length; i<len; i++)
			{
				f = localFonts[i] as Font;
				fName = f.fontName;
				if(fName == fontName)
				{
					hasFont = true;
					return hasFont;
				}
			}
			return hasFont;
		}
		
		private var priftTxt:Label;
		private function priftHandler(e:Event):void
		{
			if(priftTxt == null)
			 	priftTxt = new Label();
			priftTxt.textColor = 0xffffff;
			this.addElement(priftTxt);
			
			priftTxt.text = "Memory:"+System.freeMemory+"		CPU"+System.processCPUUsage+"			MSGNUM"+(groupList ? groupList.length : 0)+
			"		EMOTENUM"+(emoteList ? emoteList.length : 0)+"			repeatCount"+repeatCount+"		newCount"+newCount+"		onScreen"+getOnScreenCount();
		}
		
		private var workTime:uint;
		private function set testWork(value:Boolean):void
		{
			if(value)
				workTime = setInterval(testInterval,1000);
			else
				clearInterval(workTime);
		}
			
		private function stageResize(e:ResizeEvent):void
		{
			if(left == null || right == null)return;
			
			if(this.width > left.width)
				left.x = this.width-left.width;
			else
				left.x = 0;
			
			if(this.width > right.width)
				right.x = this.width-right.width;
			else
				right.x = 0;
		}
		
		private var left:Button;
		private var right:Button;
		private function testOpenAndClose():void
		{
			left = new Button();
			left.label = "关闭";
			this.addElement(left);
			
			right = new Button();
			right.label = "开始";
			right.name = "right";
			this.addElement(right);
			
			left.addEventListener(UIEvent.BUTTON_DOWN, downHandler);
			right.addEventListener(UIEvent.BUTTON_DOWN, downHandler);
		}
		
		private function downHandler(e:UIEvent):void
		{
			if(e.target.name == 'left')
			{
				Visible = true;
				testWork = false;
				dispatchMsgControl({open:false})
			}
			else
			{
				Visible = false;
				testWork = true;
				dispatchMsgControl({open:true});
			}
		}
		
		private function set Visible(value:Boolean):void
		{
			left.visible = !(right.visible = value);
		}
		
		private function testInterval():void
		{
			/*
			dispatchMsg({
				cnt:'这是个[微笑][惊讶]小拇指',
				nickname:'姓名'+Math.ceil(Math.random()*100),
				headimg:'http://wx.qlogo.cn/mmopen/PiajxSqBRaEJD2x1ibOse16lY3zjBIep9GOCPon4jCQmh4hpIeYpjjQY9pn4hBqH4cRl0P7DRIfaGRNQQyRMWyvg/96',
				style:{
					color:'000000'
				}
			});*/
			
			var nicknames:Array = ["游客","过客","王强","李刚"];
			var cnts:Array = ["来咯","路过","顶一感动流泪个","节目真给力","北京欢迎你!!!","都是献花献花美女啊", '中国智造,惠及全球', '{感动流泪}', '{献花献花}','{感动流泪}','{笑死我了}','{吓死我了}','{扔鸡蛋}','{困死了}'];
			var colors:Array = ['000000', 'ff722c', '59bb51', '1787d5', 'c33de0'];
			var sizes:Array = ["small", "medium", "large", "llarge"];
			dispatchMsg({"tm":"1417169321307","nickname":nicknames[int(Math.random()*nicknames.length)],"id":24,"headimg":"","style":{"color":colors[int(Math.random()*colors.length)],
				"fontsize":sizes[int(Math.random()*sizes.length)],"animation":testMove[int(Math.random()*testMove.length)],"flyspeed":testSpeed[int(Math.random()*testSpeed.length)]},"gid":null,"cid":"Test1","cnt":cnts[int(Math.random()*cnts.length)]});
//			dispatchMsg({nickname:'游客', gid:'CCTV1', id:4, style:{color:000000, flyspeed:'general', fontsize:'small', animation:'normal'}, heading:'', tm:'1419583882247',
//			cid:'oHsekt2JyfIMp6bMR2R75sE68MqU', cnt:'[呲牙]'});
//			var cnts:Array = ['[月亮][月亮]','[再见][再见]','[坏笑][坏笑]']
//			dispatchMsg({"gid":"cctv2","style":{"fontsize":"small","flyspeed":"slow","color":"00ff00","animation":"normal"},"cid":"test2","cnt":cnts[int(Math.random()*cnts.length)],"headimg":"imgs/general/avatar-admin.png","code":"broadcast","tm":1419837465032,"nickname":"管理员"});
		}
		
		private var repeatCount:int=0;
		private var newCount:int=0;
		private function getMsgContainer():MsgContainer
		{
			for each(var msg:MsgContainer in groupList)
			{
				if(!msg.IsMove)
				{
					repeatCount++;
					return msg;
				}
			}
			
			newCount++;
			return new MsgContainer();
		}
		/**
		 *	是否显示表情 
		 */
		private function dispatchMsgControl(control):void
		{
			l('CONTROL:', control);
			
			if(control['open'])
			{
				
			}
			else
			{
				if(groupList != null)
				{
					for each(var msgContainer:MsgContainer in groupList)
					{
						msgContainer.destory();
						msgContainer.parent && Group(msgContainer.parent).removeElement(msgContainer);
					}
					groupList.length = 0;
				}
				
				if(emoteList != null)
				{
					for each(var emote:EmoteContainer in emoteList)
					{
						emote.destory();
					}
					emoteList.length = 0;
				}
			}
		}
		
		private function clearMsgContainer(msgContainer:MsgContainer):void
		{
				var index:int = groupList.indexOf(msgContainer);
				if(index > -1)
					groupList.splice(index, 1);
		}
		
		private function clearEmoteContainer(emoteContainer:EmoteContainer):void
		{
			var index:int = emoteList.indexOf(emoteContainer);
			if(index > -1)
				emoteList.splice(index, 1);
		}
		
		private function enterFrame(e:Event):void
		{
			if(cacheMsgList.length > 0)
				dispatchMsg(cacheMsgList.shift());
			else
				this.removeEventListener(Event.ENTER_FRAME, enterFrame);
		}
		
		/**
		 *	缓存处理(数据多不显示、卡)  
		 */
		private function cacheHandler(msg:*):void
		{
			if(cacheMsgList == null)
				cacheMsgList = new Array();
			cacheMsgList.push(msg);
			this.addEventListener(Event.ENTER_FRAME, enterFrame);
		}
		/**
		 *	显示图文混排 
		 */
		private var count:int=0;
		private var lastTimer:int;
		private function dispatchMsg(msg:*):void
		{
			if(msg == null)return;
			
			if(getTimer() - lastTimer < 45 || getOnScreenCount() >= ONSCREENMAX)
			{
				cacheHandler(msg);
				return;
			}
			
			l('MSG:',msg+"条数:"+count++);
			lastTimer = getTimer();
			
			//ParseMessage -- step1 -- nickname/imgheader
			if(msg['nickname'])
			{
				//Position & Animation 
//				msgContainer.addEventListener(ResizeEvent.RESIZE,msgShow2Stage);
				if(emoteExit(msg))
				{
					l('魔法表情已通过！！！');
					var emoteContainer:EmoteContainer = new EmoteContainer();
					emoteContainer.addMsg(msg, this, arrName, arrId, xmlLength)
					
					if(emoteList == null)
						emoteList = new Vector.<EmoteContainer>();
					emoteList.push(emoteContainer);
				}
				else
				{
					//MessageBody
					var msgContainer:MsgContainer = getMsgContainer();
					msgContainer.visible = false;
					msgContainer.addMsg(msg, screen, arrName, arrId, xmlLength);
					
					if(groupList == null)
						groupList = new Vector.<MsgContainer>();
					
					if(groupList.indexOf(msgContainer) < 0)
						groupList.push(msgContainer);
				}
				
				if(getOnScreenCount() > 0 || getEmoteCount() > 0)
				{
					start();
				}
			}
			else
			{
				l('Nickname is missing!');	
			}
		}
		
		private function start():void
		{
			this.addEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
		
		private function stop():void
		{
			this.removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
		
		private function enterFrameHandler(e:Event):void
		{
			if(getOnScreenCount() <= 0 && getEmoteCount() <= 0)
			{
				stop();
			}
			
			if(getOnScreenCount() > 0)
			{
				for each(var msg:MsgContainer in groupList)
				{
					if(msg.IsMove)
						msg.enterFrame();
				}
			}
			
			if(getEmoteCount() > 0)
			{
				for each( var emote:EmoteContainer in emoteList)
				{
					if(emote.getOnSceneCount() > 0)
						emote.enterFrame();
					else
						clearEmoteContainer(emote);
				}
			}
		}
		
		private function emoteExit(msg:Object):Boolean
		{
			var s:String = msg.cnt;
			var left:int = s.indexOf('{');
			var right:int = s.indexOf('}');
			var mark:String = s.substring(left, right+1);
			
			for(var i:int=0;i<xmlLength;i++)
			{
				if(mark == String(arrName[i]))
				{
					return true;
				}
			}
			
			return false;
		}
		
		/**
		 *	当前屏显示数量(图文混排) 
		 */
		private function getOnScreenCount():int
		{
			var onScreen:int = 0;
			if(groupList != null)
			{
				for each(var msg:MsgContainer in groupList)
				{
					if(msg.IsMove)
						onScreen++;
				}
			}
			
			return onScreen;
		}
		
		/**
		 *	当前屏幕魔法表情 
		 */
		private function getEmoteCount():int
		{
			var onScreen:int=0;
			if(emoteList != null)
				for each(var emote:EmoteContainer in emoteList)
				{
					if(emote.getOnSceneCount() > 0)
						onScreen++;
				}
			
			return onScreen;
		}
		/**
		 *	根据舞台摆位置 
		 */
		protected function msgShow2Stage(event:ResizeEvent):void
		{
			var msgContainer:Group = event.target as Group;
			
			if( ! (msgContainer.width && msgContainer.height)) return;
			
			msgContainer.width = msgContainer.width;
			msgContainer.height = msgContainer.height;
			
			msgContainer.removeEventListener(ResizeEvent.RESIZE,msgShow2Stage);
			
//			var msg:Object = getMsgByGroup(msgContainer);
			
//			TweenLite.fromTo(msgContainer,msg.speed ? (msgContainer.parent.width+msgContainer.width-msgContainer.x)/msg.speed : defaultStyle.speed,
//			{
//				x : msgContainer.parent.width,
//				y : msgContainer.height * Math.floor(Math.random() * Math.floor(screen.height / msgContainer.height)),
//				ease : Linear.easeNone,
//				onStartParams:[msgContainer],
//				onStart : function(msgC:Group):void
//				{
//					msgC.visible = true;
//				}
//			},
//			{
//				x : - msgContainer.width,
//				ease : Linear.easeNone,
//				onCompleteParams : [msgContainer,msgContainer.parent],
//				onComplete:function(msgC:Group,msgParent:Group):void
//				{
//					if(msgParent.getElementIndex(msgC) > -1)
//						msgParent.removeElement(msgC);
//				}
//			});
		}
		
		
		protected function addStageHandler(event:Event=null):void
		{  
			//CallBack
			if(ExternalInterface.available)
			{
				ExternalInterface.addCallback('dispatchMsg',dispatchMsg);
				ExternalInterface.addCallback('dispatchMsgControl',dispatchMsgControl);
			}
			
			//Notify
			if(ExternalInterface.available)
			{
				ExternalInterface.call('barrageReady');
			}
			
			loadXml();
		}
		
		private function loadXml():void
		{
			arrName=new Array();
			arrId=new Array();
			var url:String='';
			/**线上**/
//			url = "http://58.215.50.188/suntv/public/swf/assest/smiles.xml";
			/**测试**/
			url = 'assest/smiles.xml';
			ud=new URLLoader();
			ud.load(new URLRequest(url));
			ud.addEventListener(Event.COMPLETE,onCom);
			ud.addEventListener(IOErrorEvent.IO_ERROR, error);
		}
		
		protected function error(event:IOErrorEvent):void
		{
			l('加载失败XML'+'噢噢噢噢');
		}
		
		protected function onCom(event:Event):void
		{
			xml=new XML(event.target.data);
			l('加载完成XML'+xml);
			xmlLength=int(xml.SubTexture.length());
			strUrl=String(xml.SubTexture[0].@url);
			for(var i:int=0;i<xmlLength;i++)
			{
				arrName.push(xml.SubTexture[i].@name);
				arrId.push(xml.SubTexture[i].@id);
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