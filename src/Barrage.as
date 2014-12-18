package
{
	import com.greensock.TweenLite;
	import com.greensock.easing.Linear;
	
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.external.ExternalInterface;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.setInterval;
	
	import mx.events.FlexEvent;
	
	import org.flexlite.domCore.Injector;
	import org.flexlite.domUI.components.Alert;
	import org.flexlite.domUI.components.Group;
	import org.flexlite.domUI.components.Label;
	import org.flexlite.domUI.components.UIAsset;
	import org.flexlite.domUI.components.UIMovieClip;
	import org.flexlite.domUI.core.Theme;
	import org.flexlite.domUI.core.UIComponent;
	import org.flexlite.domUI.effects.Resize;
	import org.flexlite.domUI.events.ResizeEvent;
	import org.flexlite.domUI.events.UIEvent;
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
		
		private var groupList:Vector.<Group>;//图文混排列表
		private var emoteList:Vector.<UIAsset>;//魔法表情容器列表
		public function Barrage()
		{
			Injector.mapClass(Theme,VectorTheme);
			
			
			/*
			var swf:UIAsset = new UIAsset();
			swf.skinName = "http://58.215.50.188/micromessager/swf/Rose_realse.swf";
			addElement(swf);
			*/
			
			/*
			var loader:Loader = new Loader();
			loader.load(new URLRequest('http://58.215.50.188/micromessager/swf/Rose_realse.swf'));
			
			var swf:UIComponent = new UIComponent()
			swf.addChild(loader);
			
			addElement(swf);
			
			*/
			
			//this.addEventListener(Event.ADDED_TO_STAGE,addStageHandler);
			
			//抛消息的，管多少
			setInterval(testInterval,1000);
			
			//配置图标库URl
			//this.markUrl = this.loaderInfo.parameters['markUrl'] || this.markUrl;
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
			
			dispatchMsg({"tm":"1417169321307","nickname":"游客","id":24,"headimg":"","style":{"color":"59bb51","fontsize":"large","animation":"waves","flyspeed":"general"},"gid":null,"cid":"Test1","cnt":"来咯"});
		}
		
		private var defaultStyle:Object = {
			fontsize:{
				small: 14,
				medium: 24,
				large:32,
				llarge:42
			},
			fontfamily:'黑体',
			color:'BBBBBB'
		};
		
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
					for each(var msgGroup:Group in groupList)
					{
						msgGroup.parent && Group(msgGroup.parent).removeElement(msgGroup);
					}
					
					groupList.length = 0;
				}
				
				if(emoteList != null)
				{
					for each(var emote:UIAsset in emoteList)
					{
						var emoteMC:MovieClip = emote.skin as MovieClip;
						emoteMC.stop();
						this.removeElement(emote);
					}
					
					emoteList.length = 0;
				}
			}
		}
		
		/**
		 *	显示图文混排 
		 */
		private function dispatchMsg(msg):void
		{
			l('MSG:',msg);
			
			//ParseMessage -- step1 -- nickname/imgheader
			if(msg['nickname'])
			{
				//MessageBody
				var msgContainer:Group = new Group();
				msgContainer.visible = false;
				if(groupList == null)
					groupList = new Vector.<Group>();
				groupList.push(msgContainer);
				//Position & Animation 
				msgContainer.addEventListener(ResizeEvent.RESIZE,msgShow2Stage);
				
				//HeadImg
				if(msg['headimg'])
				{
					var headImg:UIAsset = new UIAsset();
					headImg.width = headImg.height = 28;
					headImg.skinName = msg['headimg'];
					msgContainer.addElement(headImg);
				}else
				{
					//Nickname
					var namenick:Label = new Label();
					namenick.text = msg['nickname'] + ":";
					namenick.size = msg['style'] && msg['style']['fontsize'] ? defaultStyle['fontsize'][msg['style']['fontsize']] : defaultStyle['fontsize']['small'];
					namenick.textColor = parseInt(msg['style'] && msg['style']['color'] ? msg['style']['color'] : defaultStyle['color'],16);
					namenick.fontFamily = msg['style'] && msg['style']['fontfamily'] ? msg['style']['fontfamily'] : defaultStyle['fontfamily'];
					msgContainer.addElement(namenick);
				}
				
				//Compontent's Layout
				var msglayout:HorizontalLayout = new HorizontalLayout();
				msglayout.verticalAlign = 'middle';
				msglayout.gap = 0;
				msgContainer.layout = msglayout;
				
				parseMark(msgContainer,msg);
				parseEmoteMark(msg);
				
				//AddToStage
				screen.addElement(msgContainer);
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
			
			TweenLite.fromTo(msgContainer,25,
			{
				x : msgContainer.parent.width,
				y : msgContainer.height * Math.floor(Math.random() * Math.floor(screen.height / msgContainer.height)),
				ease : Linear.easeNone,
				onStartParams:[msgContainer],
				onStart : function(msgC:Group):void
				{
					msgC.visible = true;
				}
			},
			{
				x : - msgContainer.width,
				ease : Linear.easeNone,
				onCompleteParams : [msgContainer,msgContainer.parent],
				onComplete:function(msgC:Group,msgParent:Group):void
				{
					msgParent.removeElement(msgC);
				}
			});
		}
		//解析图片和文本的函数
		protected function parseMark(container:Group,msg:Object,ts:String=''):String
		{
			//空的字符串和接收到的消息
			var s:String = ts || msg.cnt;//图文混排
			
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
					parseMessage(container,msg,leftText,mark, '');
					
					return parseMark(container,msg,remain);
				}
				else
				{
					parseMessage(container,msg,msg.cnt,'[微笑]', '');
					
					return "";
				}
			}else
			{
				return "";
			}
		}
		
		/**
		 *	解析魔法表情函数 
		 */
		protected function parseEmoteMark(msg:Object,ts:String=''):String
		{
			//空的字符串和接收到的消息
			var s:String = ts || msg.cnt;//图文混排
			
			//字符串有内容才能解析
			if (s.length > 0)
			{
				var lefte:int = s.indexOf("{");
				var righte:int = s.indexOf("}");
				if(lefte >= 0 && righte >= 0)
				{
					var mark:String = s.substring(lefte, righte + 1);
					var remain:String = s.substring(righte+1);
					parseMessage(null,msg,'','', mark);
					
					return parseEmoteMark(msg, remain);
				}
				else
				{
					parseMessage(null, msg ,'', '', '{献花献花}');
					return "";
				}
			}
			else
			{
				return "";
			}
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
		
		private var markUrl:String="http://58.215.50.188/micromessager/imgs/";
		private var markEmoteUrl:String = "http://58.215.50.188/micromessager/swf"
		private function parseMessage(container:Group, msg:Object, text:String, mark:String, emote:String):void
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
				msgSprite.fontFamily = msg['style'] && msg['style']['fontfamily'] ? msg['style']['fontfamily'] : defaultStyle['fontfamily'];
				
				container && container.addElement(msgSprite);
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
//						imgExpress.skinName = "assest/hard/"+arrId[i]
//						trace(imgExpress.skinName);
					}
					
				}
				
				container && container.addElement(imgExpress);
			}
			
			if(emote)
			{
				for(var j:int=0;j<xmlLength;j++)
				{
					if(String(emote) == String(arrName[j]))
					{
						var url:String = this.markEmoteUrl+"/"+arrId[j]+".swf";
						var swfEmote:UIAsset = new UIAsset();
						swfEmote.skinName = url;
						this.addElement(swfEmote);
						swfEmote.addEventListener(UIEvent.SKIN_CHANGED,  skinChanged);
					}
				}
			}
		}
		
		private var IsAdd:Boolean = false;//是否注册帧事件
		/**
		 *		资源加载完成事件 
		 */
		private function skinChanged(e:UIEvent):void
		{
			var swfEmote:UIAsset = e.target as UIAsset;
			
			if(emoteList == null)
				emoteList = new Vector.<UIAsset>();
			
			emoteList.push(swfEmote);
			
			if(!IsAdd)
			{
				IsAdd = true;
				this.addEventListener(Event.ENTER_FRAME, enterFrame);
			}
		}
		
		/**
		 *	播放完了进行删除 
		 */
		private function enterFrame(e:Event):void
		{
			for each(var emote:UIAsset in emoteList)
			{
				var swfEmote:MovieClip = emote.skin as MovieClip;
				if(this.width < swfEmote.width)
					swfEmote.x = 0;
				else
					swfEmote.x = (this.width-swfEmote.width)/2;
				
				if(this.height < swfEmote.height)
					swfEmote.y = 0;
				else
					swfEmote.y = (this.height-swfEmote.height)/2;
				
				if(swfEmote.currentFrame == swfEmote.totalFrames)
				{
					swfEmote.stop();
					this.removeElement(emote);
					emoteList.splice(emoteList.indexOf(emote), 1);
				}
			}
			
			if(emoteList && emoteList.length == 0)
				this.removeEventListener(Event.ENTER_FRAME, enterFrame);
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