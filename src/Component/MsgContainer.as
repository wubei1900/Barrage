package Component
{
	import com.greensock.TweenLite;
	
	import flash.events.Event;
	import flash.external.ExternalInterface;
	
	import filter.FilterLib;
	
	import org.flexlite.domUI.components.Group;
	import org.flexlite.domUI.components.Label;
	import org.flexlite.domUI.components.UIAsset;
	import org.flexlite.domUI.events.ResizeEvent;
	import org.flexlite.domUI.layouts.HorizontalLayout;
	
	public class MsgContainer extends Group
	{
		private var headImg:UIAsset;//头像
		private var namenick:Label;//名字
		private var msgSprite:Label;//文本内容
		private var msglayout:HorizontalLayout;//文本布局
		
		private var imgExpress:UIAsset;//表情图片
		private var _parent:Group;
		
		private var _callBack:Function;
		private var _msg:Object;
		
		private var _alpha:Number = 0.1;
		private var _size:int;//字体大小
		private var _font:String;//字体
		private var _animation:String;
		private var _flyspeed:int;
		private var _filters:Array=[FilterLib.glow_white];
		private var _color:Number = 0x000000;
		private var _compareColor:Number;
		private var IsAdd:Boolean = true;
		
		private var _xmlLength:int;
		private  var _arrName:Array;
		private  var _arrId:Array;
		
		private var _IsMove:Boolean=false;
		
		/**移动类型**/
		private const MOVE_TYPE_ONE:String				= 'normal';
		private const MOVE_TYPE_SECOND:String		= 'waves';
		private const MOVE_TYPE_THREE:String			= 'flicker';
		private const markUrl:String="http://58.215.50.188/micromessager/imgs";
		private const headUrl:String="http://58.215.50.188/micromessager/imgs";
//		private const headUrl:String="assest";
		
		private var colors:Array = ['000000', 'ff722c', '59bb51', '1787d5', 'c33de0'];
		private var compareColors:Array = ['ffffff', '0099FF', 'CC00CC', 'FFCC00', '009900'];
		public function MsgContainer()
		{
//			_callBack = callBack;
			super();
		}
		
		public function get IsMove():Boolean
		{
			return _IsMove;
		}
		
		public function set IsMove(value:Boolean):void
		{
			if(!value)
				trace(value);
			_IsMove = value;
		}
		
		private var defaultStyle:Object = {
			fontsize:{
				small: 24,
				medium: 32,
				large:42,
				llarge:50
			},
			
			flyspeed:{
				slow:4,
				general:6,
				fast:8,
				quickly:15
			},
			
			fontfamily:'雅黑',
			color:'000000',
			speed:1
		};
		
		/**
		 *	增加一个弹幕单元 
		 */
		public function addMsg(msg:Object, screen:Group, arrName, arrId, xmlLength):void
		{
			IsMove = true;
			
			_msg = msg;
			_parent = screen;
			_arrName = arrName;
			_arrId = arrId;
			_xmlLength = xmlLength;
			
			if(headImg == null)
				headImg = new UIAsset();
			headImg.width = headImg.height = 32;
			this.addElement(headImg);
			//HeadImg
			if(msg['headimg'])
			{
				headImg.skinName = msg['headimg'];
			}
			else
			{
				headImg.skinName =this.headUrl +"/defaultHeadImg.jpg" ;
			}
				
			//Nickname
			if(namenick == null)
				namenick = new Label();
			namenick.text = msg['nickname'] + ":";
			
			_size = msg['style'] && msg['style']['fontsize'] ? defaultStyle['fontsize'][msg['style']['fontsize']] : defaultStyle['fontsize']['small'];
			var colorString:String =  msg['style'] && msg['style']['color'] ? msg['style']['color'] : defaultStyle['color']//颜色字符串
			_animation = msg['style'] && msg['style']['animation'] ? msg['style']['animation'] : 'normal';
			_flyspeed = msg['style'] && msg['style']['flyspeed'] ? defaultStyle['flyspeed'][msg['style']['flyspeed']] : defaultStyle['flyspeed']['slow'];
			
			var indexColor:int = colors.indexOf(colorString);
			if(indexColor < 0 || indexColor > 4)
				indexColor = 0;
			
			_color = parseInt(colorString, 16);
			_compareColor = parseInt(compareColors[indexColor], 16);
			
			_font = msg['style'] && msg['style']['fontfamily'] ? msg['style']['fontfamily'] : defaultStyle['fontfamily'];
			namenick.size = _size;
			namenick.textColor =_color;
			namenick.fontFamily = _font;
			namenick.filters = _filters;
			this.addElement(namenick);
			
			//Compontent's Layout
			if(msglayout == null)
					msglayout = new HorizontalLayout();
			msglayout.verticalAlign = 'middle';
			msglayout.gap = 0;
			this.layout = msglayout;
			
			parseMark();
			
			screen.addElement(this);
			
			
			this.addEventListener(ResizeEvent.RESIZE, showStage);
//			showStage();
////			this.addEventListener(ElementExistenceEvent.ELEMENT_ADD, showStage);
//			tweenLite = TweenLite.delayedCall(1, showStage);
		}
		
		private var tweenLite:TweenLite;
		private function showStage(e:Event=null):void
		{
			if( ! (this.width && this.height && this.parent) ) return;
			
			tweenLite && tweenLite.kill();
			this.removeEventListener(ResizeEvent.RESIZE, showStage);
//			this.removeEventListener(ElementExistenceEvent.ELEMENT_ADD, showStage);
			
			this.x = this.parent.width;
			this.y = this.height * Math.floor(Math.random() * Math.floor(this.parent.height / this.height));
			
			this.visible = true;
//			start();
		}
		//解析图片和文本的函数
		protected function parseMark(ts:String=''):String
		{
			//空的字符串和接收到的消息
			var s:String = ts || _msg.cnt;//图文混排
			
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
					parseMessage(_msg, leftText, mark, '');
					
					if(remain != "")
						return parseMark(remain);
					else
						return "";
				}
				else
				{
					parseMessage(_msg, s, '', '');
					
					return "";
				}
			}else
			{
				return "";
			}
		}
		
		private function parseMessage(msg:Object, text:String, mark:String, emote:String):void
		{
			if(text)
			{
				//消息对象
				if(msgSprite == null)
					msgSprite = new Label();
				
				//消息内容
				msgSprite.text = text;
				
				//消息样式
				msgSprite.size = _size;
				msgSprite.textColor = _color;
				msgSprite.fontFamily = _font;
				msgSprite.filters = _filters;
				
				this.addElement(msgSprite);
			}
			
			if(mark)
			{
				//暂时代替url
				//mark --> url
				if(imgExpress == null)
						imgExpress = new UIAsset();
				imgExpress.width = imgExpress.height = 28;
				
				for(var i:int=0;i<_xmlLength;i++)
				{
					if(String(mark)==String(_arrName[i]))
					{
						//imgExpress.skinName = "assest/2.png";
						
						//服务器
						imgExpress.skinName = this.markUrl +"/"+_arrId[i]+".gif";
						break;
						//测试
						//						imgExpress.skinName = "assest/hard/"+arrId[i]
						//						trace(imgExpress.skinName);
					}
					
				}
				
				this.addElement(imgExpress);
			}
		}
		
		private function start():void
		{
			this.addEventListener(Event.ENTER_FRAME, enterFrame, false, 0, true);
		}
		
		private function stop():void
		{
			this.removeEventListener(Event.ENTER_FRAME, enterFrame);
			
			if(_callBack != null)
				_callBack(this);
		}
		
		private var _count:int;
		private var _angle:Number = 0;
		private const FLICKERSPEED:int = 5;
		private const WAVESANGLE:int = 5;
		public function enterFrame(e:Event=null):void
		{
			if(this.x <= -this.width)
			{
				IsMove = false;
				destory();
				if(_parent && _parent.getElementIndex(this))
					_parent.removeElement(this);
				return;
			}
			
			this.x -= _flyspeed; 
			
			if(_animation == MOVE_TYPE_ONE)
			{
			}
			else if(_animation == MOVE_TYPE_SECOND)
			{
				_angle += 2;
				this.y += Math.sin(_angle)*WAVESANGLE; 
			}
			else if(_animation == MOVE_TYPE_THREE)
			{
//				if(alpha >= 1)
//					IsAdd = false;
//				if(alpha <= 0.1)
//					IsAdd = true;
//				
//				if(IsAdd)
//					_alpha += 0.1;
//				else
//					_alpha -= 0.1;
				_count++;
				if(_count <= FLICKERSPEED)
					return;
				
				_count = 0;
				
				var color:Number=0xffffff;
				if(IsAdd)
				{
					IsAdd = false;
					color = _compareColor;
				}
				else
				{
					IsAdd = true;
					color = _color;
				}
				
				if(namenick)
					namenick.textColor = color;
				if(msgSprite)
					msgSprite.textColor = color;
				
//				this.alpha = _alpha;
			}
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
		
		public function destory():void
		{
//			stop();
			
			if(headImg != null)
			{
				if(this.getElementIndex(headImg) > -1)
					this.removeElement(headImg);
				
				headImg = null;
			}
			
			if(namenick != null)
			{
				
				if(this.getElementIndex(namenick) > -1)
					this.removeElement(namenick);
				namenick = null;
			}
			
			if(msgSprite != null)
			{
				if(this.getElementIndex(msgSprite) > -1)
					this.removeElement(msgSprite);
				msgSprite = null;
			}
			
			if(msglayout != null)
			{
				msglayout = null;
			}
			
			if(imgExpress != null)
			{
				if(this.getElementIndex(imgExpress) > -1)
					this.removeElement(imgExpress);
				imgExpress = null;
			}
			
			_angle = 0;
			_alpha = 0.1;
			
			if(_callBack != null)
				_callBack = null;
			
			if(_arrName != null)
				_arrName = null;
			
			if(_arrId != null)
				_arrId = null;
		}
	}
}