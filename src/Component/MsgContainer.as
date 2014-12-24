package Component
{
	import flash.events.Event;
	
	import filter.FilterLib;
	
	import org.flexlite.domUI.components.Group;
	import org.flexlite.domUI.components.Label;
	import org.flexlite.domUI.components.UIAsset;
	import org.flexlite.domUI.effects.Resize;
	import org.flexlite.domUI.events.ResizeEvent;
	import org.flexlite.domUI.layouts.HorizontalLayout;
	
	public class MsgContainer extends Group
	{
		private var headImg:UIAsset;//头像
		private var namenick:Label;//名字
		private var msgSprite:Label;//文本内容
		private var msglayout:HorizontalLayout;//文本布局
		
		private var imgExpress:UIAsset;//表情图片
		
		private var _callBack:Function;
		private var _msg:Object;
		
		private var _angle:Number = 0;
		private var _alpha:Number = 0.1;
		private var _size:int;
		private var _font:String;
		private var _filters:Array=[FilterLib.glow_white];
		private var _color:Number = 0x000000;
		private var _compareColor:Number;
		private var IsAdd:Boolean = true;
		
		private var _xmlLength:int;
		private  var _arrName:Array;
		private  var _arrId:Array;
		
		private var _IsMove:Boolean=false;
		
		/**移动类型**/
		private const MOVE_TYPE_ONE:int				= 1;
		private const MOVE_TYPE_SECOND:int			= 2;
		private const MOVE_TYPE_THREE:int			= 3;
		private const markUrl:String="http://58.215.50.188/micromessager/imgs/";
		private const headUrl:String="http://58.215.50.188/micromessager/imgs/";
		
		private var colors:Array = [0x000000, 0xff8a2c, 0x0ca713, 0x1647d3, 0x9b0bed];
		private var compareColors:Array = [0xffffff, 0xff9933, 0x00cc33, 0x0099ff, 0x0033ff];
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
				small: 14,
				medium: 24,
				large:32,
				llarge:42
			},
			fontfamily:'黑体',
			color:'BBBBBB',
			speed:1
		};
		
		/**
		 *	增加一个弹幕单元 
		 */
		public function addMsg(msg:Object, screen:Group, arrName, arrId, xmlLength):void
		{
			IsMove = true;
			
			_msg = msg;
			_arrName = arrName;
			_arrId = arrId;
			_xmlLength = xmlLength;
			
			if(headImg == null)
				headImg = new UIAsset();
			headImg.width = headImg.height = 28;
			this.addElement(headImg);
			//HeadImg
			if(msg['headimg'])
			{
				headImg.skinName = msg['headimg'];
			}
			else
			{
				headImg.skinName =this.headUrl +"/shy.gif" ;
			}
				
			//Nickname
			if(namenick == null)
				namenick = new Label();
			namenick.text = msg['nickname'] + ":";
			
			_size = msg['style'] && msg['style']['fontsize'] ? defaultStyle['fontsize'][msg['style']['fontsize']] : defaultStyle['fontsize']['small'];
			_color =  parseInt(msg['style'] && msg['style']['color'] ? msg['style']['color'] : defaultStyle['color'],16);
			var indexColor:int = colors.indexOf(_color);
			if(indexColor < 0 || indexColor > 4)
				indexColor = 0;
			_compareColor = compareColors[indexColor];
			
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
		}
		
		private function showStage(e:ResizeEvent):void
		{
			if( ! (this.width && this.height)) return;
			
			this.removeEventListener(ResizeEvent.RESIZE, showStage);
			
			this.x = this.parent.width;
			this.y = this.height * Math.floor(Math.random() * Math.floor(this.parent.height / this.height));
			
			this.visible = true;
			start();
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
					
					return parseMark(remain);
				}
				else
				{
					parseMessage(_msg, _msg.cnt,'[微笑]', '');
					
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
			this.addEventListener(Event.ENTER_FRAME, enterFrame);
		}
		
		private function stop():void
		{
			this.removeEventListener(Event.ENTER_FRAME, enterFrame);
			
			if(_callBack != null)
				_callBack(this);
		}
		
		private function enterFrame(e:Event):void
		{
			if(this.x == -this.width)
			{
				IsMove = false;
				destory();
//				Group(this.parent).removeElement(this);
			}
			
			if(_msg.move == MOVE_TYPE_ONE)
			{
				this.x -=  _msg.speed ? _msg.speed : defaultStyle.speed;
			}
			else if(_msg.move == MOVE_TYPE_SECOND)
			{
				_angle += 2;
				this.x -=  (_msg.speed ? _msg.speed : defaultStyle.speed)*1;
				this.y += Math.sin(_angle)*5; 
			}
			else if(_msg.move == MOVE_TYPE_THREE)
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
				
				this.x -= _msg.speed ? _msg.speed :defaultStyle.speed; 
//				this.alpha = _alpha;
			}
		}
		
		public function destory():void
		{
			stop();
			
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