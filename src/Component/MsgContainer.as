package Component
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import filter.FilterLib;
	
	import org.flexlite.domUI.components.Group;
	import org.flexlite.domUI.components.Label;
	import org.flexlite.domUI.components.UIAsset;
	import org.flexlite.domUI.effects.Resize;
	import org.flexlite.domUI.events.ResizeEvent;
	import org.flexlite.domUI.layouts.HorizontalLayout;
	
	public class MsgContainer extends Group
	{
		private var _callBack:Function;
		private var _msg:Object;
		
		private var _angle:Number = 0;
		private var _alpha:Number = 0;
		private var IsAdd:Boolean = true;
		
		private var _xmlLength:int;
		private  var _arrName:Array;
		private  var _arrId:Array;
		
		/**移动类型**/
		private const MOVE_TYPE_ONE:int				= 1;
		private const MOVE_TYPE_SECOND:int			= 2;
		private const MOVE_TYPE_THREE:int			= 3;
		private const markUrl:String="http://58.215.50.188/micromessager/imgs/";
		public function MsgContainer(callBack:Function)
		{
			_callBack = callBack;
			super();
		}
		
		private var defaultStyle:Object = {
			fontsize:{
				small: 14,
				medium: 24,
				large:32,
				llarge:42
			},
			fontfamily:'黑',
			color:'BBBBBB',
			speed:1
		};
		
		/**
		 *	增加一个弹幕单元 
		 */
		public function addMsg(msg:Object, screen:Group, arrName, arrId, xmlLength):void
		{
			_msg = msg;
			_arrName = arrName;
			_arrId = arrId;
			_xmlLength = xmlLength;
			
			//HeadImg
			if(msg['headimg'])
			{
				var headImg:UIAsset = new UIAsset();
				headImg.width = headImg.height = 28;
				headImg.skinName = msg['headimg'];
				this.addElement(headImg);
			}else
			{
				//Nickname
				var namenick:Label = new Label();
				namenick.text = msg['nickname'] + ":";
				
				namenick.size = msg['style'] && msg['style']['fontsize'] ? defaultStyle['fontsize'][msg['style']['fontsize']] : defaultStyle['fontsize']['small'];
				namenick.textColor = parseInt(msg['style'] && msg['style']['color'] ? msg['style']['color'] : defaultStyle['color'],16);
				namenick.fontFamily = msg['style'] && msg['style']['fontfamily'] ? msg['style']['fontfamily'] : defaultStyle['fontfamily'];
				namenick.filters = [FilterLib.glow_white];
				this.addElement(namenick);
			}
			
			//Compontent's Layout
			var msglayout:HorizontalLayout = new HorizontalLayout();
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
				var msgSprite:Label = new Label();
				
				//消息内容
				msgSprite.text = text;
				
				//消息样式
				msgSprite.size = msg['style'] && msg['style']['fontsize'] ? defaultStyle['fontsize'][msg['style']['fontsize']] : defaultStyle['fontsize']['small'];
				msgSprite.textColor = parseInt(msg['style'] && msg['style']['color'] ? msg['style']['color'] : defaultStyle['color'],16);
				msgSprite.fontFamily = msg['style'] && msg['style']['fontfamily'] ? msg['style']['fontfamily'] : defaultStyle['fontfamily'];
				msgSprite.filters = [FilterLib.glow_white];
				
				this.addElement(msgSprite);
			}
			
			if(mark)
			{
				//暂时代替url
				//mark --> url
				var imgExpress:UIAsset = new UIAsset();
				imgExpress.width = imgExpress.height = 28;
				
				for(var i:int=0;i<_xmlLength;i++)
				{
					if(String(mark)==String(_arrName[i]))
					{
						//imgExpress.skinName = "assest/2.png";
						
						//服务器
						imgExpress.skinName = this.markUrl +"/"+_arrId[i]+".gif";
						
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
				stop();
				Group(this.parent).removeElement(this);
			}
			
			if(_msg.move == MOVE_TYPE_ONE)
			{
				this.x -=  _msg.speed ? _msg.speed : defaultStyle.speed;
			}
			else if(_msg.move == MOVE_TYPE_SECOND)
			{
				_angle += 2;
				this.x -=  (_msg.speed ? _msg.speed : defaultStyle.speed)*1;
				this.y += Math.sin(_angle)*2; 
			}
			else if(_msg.move == MOVE_TYPE_THREE)
			{
				if(alpha >= 1)
					IsAdd = false;
				if(alpha <= 0.1)
					IsAdd = true;
				
				if(IsAdd)
					_alpha += 0.1;
				else
					_alpha -= 0.1;
				
				this.x -= _msg.speed ? _msg.speed :defaultStyle.speed; 
				this.alpha = _alpha;
			}
		}
		
		public function destory():void
		{
			stop();
			_angle = 0;
		}
	}
}