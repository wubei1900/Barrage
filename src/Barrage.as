package
{
	import com.greensock.easing.Linear;
	
	import flash.events.Event;
	import flash.external.ExternalInterface;
	import flash.filters.GlowFilter;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.system.System;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	
	import mx.events.FlexEvent;
	
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
	
	[SWF(backgroundColor="#000000")]
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
	
		private var testSpeed:Array = [2, 3, 4];
		private var testMove:Array = [1, 2, 3];
		public function Barrage()
		{
			Injector.mapClass(Theme,VectorTheme);
			
			this.addEventListener(Event.ADDED_TO_STAGE,addStageHandler);
			this.addEventListener(ResizeEvent.RESIZE, stageResize);
			//抛消息的，管多少
			testWork = false;
			
			//测试开关按钮
			testOpenAndClose();
			
			this.addEventListener(Event.ENTER_FRAME, priftHandler);
			//配置图标库URl
			//this.markUrl = this.loaderInfo.parameters['markUrl'] || this.markUrl;
		}
		
		private var priftTxt:Label;
		private function priftHandler(e:Event):void
		{
			if(priftTxt == null)
			 	priftTxt = new Label();
			priftTxt.textColor = 0xffffff;
			this.addElement(priftTxt);
			
			var onScreen:int = 0
			if(groupList != null)
			{
				for each(var msg:MsgContainer in groupList)
				{
					if(msg.IsMove)
						onScreen++;
				}
			}
			priftTxt.text = "Memory:"+System.freeMemory+"		CPU"+System.processCPUUsage+"			MSGNUM"+(groupList ? groupList.length : 0)+
			"		EMOTENUM"+(emoteList ? emoteList.length : 0)+"			repeatCount"+repeatCount+"		newCount"+newCount+"		onScreen"+onScreen;
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
			if(e.target == left)
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
			var cnts:Array = ["来咯","路过","顶一个","节目真给力","北京欢迎你!!!","都是美女啊"];
			var colors:Array = [0x000000, 0xff8a2c, 0x0ca713, 0x1647d3, 0x9b0bed];
			var sizes:Array = ["small", "medium", "large", "llarge"];
			dispatchMsg({"tm":"1417169321307","nickname":nicknames[int(Math.random()*nicknames.length)],"id":24,"headimg":"","style":{"color":colors[int(Math.random()*colors.length)],
				"fontsize":sizes[int(Math.random()*sizes.length)],"animation":"waves","flyspeed":"general"},"gid":null,"cid":"Test1","cnt":cnts[int(Math.random()*cnts.length)]});
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
		/**
		 *	显示图文混排 
		 */
		private function dispatchMsg(msg:*):void
		{
			l('MSG:',msg);
			
			//ParseMessage -- step1 -- nickname/imgheader
			if(msg['nickname'])
			{
				//MessageBody
				msg.speed = testSpeed[int(Math.random()*testSpeed.length)];
				msg.move = testMove[int(Math.random()*testMove.length)];
				var msgContainer:MsgContainer = getMsgContainer();
				msgContainer.visible = false;
				msgContainer.addMsg(msg, screen, arrName, arrId, xmlLength)
				//Position & Animation 
//				msgContainer.addEventListener(ResizeEvent.RESIZE,msgShow2Stage);
				
				if(groupList == null)
					groupList = new Vector.<MsgContainer>();
				
				if(groupList.indexOf(msgContainer) < 0)
					groupList.push(msgContainer);
				
				var emoteContainer:EmoteContainer = new EmoteContainer(clearEmoteContainer);
				emoteContainer.addMsg(msg, this, arrName, arrId, xmlLength);
				
				if(emoteList == null)
					emoteList = new Vector.<EmoteContainer>();
				emoteList.push(emoteContainer);
			}else
			{
				l('Nickname is missing!');	
			}
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
		
		
		protected function addStageHandler(event:Event):void
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
			ud=new URLLoader();
			ud.load(new URLRequest("assest/smiles.xml"));
			ud.addEventListener(Event.COMPLETE,onCom);
		}
		protected function onCom(event:Event):void
		{
			xml=new XML(event.target.data);
			xmlLength=int(xml.SubTexture.length());
			strUrl=String(xml.SubTexture[0].@url);
			for(var i:int=0;i<xmlLength;i++)
			{
				arrName.push(xml.SubTexture[i].@name);
				arrId.push(xml.SubTexture[i].@id);
			}
			
			trace(xml.attribute("[回头]"));
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