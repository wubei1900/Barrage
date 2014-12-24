package Component
{
	import flash.display.MovieClip;
	import flash.events.Event;
	
	import org.flexlite.domUI.components.Group;
	import org.flexlite.domUI.components.UIAsset;
	import org.flexlite.domUI.events.UIEvent;
	
	public class EmoteContainer extends Group
	{
		private const markEmoteUrl:String = "http://58.215.50.188/micromessager/swf";
		
		private  var _arrName:Array;
		private  var _arrId:Array;
		private var _xmlLength:int;
		
		private var _msg:Object;
		private var _callBack:Function;
		private var _parent:Group;
		private var emoteList:Vector.<UIAsset>;//魔法表情容器列表
		public function EmoteContainer(callBack:Function)
		{
			_callBack = callBack;
			super();
		}
		
		/**
		 *	增加一个魔法表情 
		 */
		public function addMsg(msg:Object, parent:Group, arrName:Array, arrId:Array, xmlLength:int ):void
		{
			_msg = msg;
			_parent = parent;
			_arrName = arrName;
			_arrId = arrId;
			_xmlLength = xmlLength;
			
			parseMark();
		}
		
		/**
		 *	解析魔法表情函数 
		 */
		protected function parseMark(ts:String=''):String
		{
			//空的字符串和接收到的消息
			var s:String = ts || _msg.cnt;//图文混排
			
			//字符串有内容才能解析
			if (s.length > 0)
			{
				var lefte:int = s.indexOf("{");
				var righte:int = s.indexOf("}");
				if(lefte >= 0 && righte >= 0)
				{
					var mark:String = s.substring(lefte, righte + 1);
					var remain:String = s.substring(righte+1);
					parseMessage(mark);
					
					return parseMark(remain);
				}
				else
				{
					parseMessage('{献花献花}');
					return "";
				}
			}
			else
			{
				return "";
			}
		}
		
		/**
		 *		表情是否合法 
		 */
		private function emoteExit(emote:String):String
		{
			for(var i:int=0;i<_xmlLength;i++)
			{
				if(emote == String(_arrName[i]))
				{
					return _arrId[i];
				}
			}
			
			return "";
		}
		
		private function parseMessage(emote:String):void
		{
			if(emote)
			{
				var id:String = emoteExit(emote);
				if(id != "")
				{
					var emoteUI:UIAsset = new UIAsset();
					var url:String = this.markEmoteUrl+"/"+id+".swf";
					emoteUI.skinName = url;
					_parent.addElement(emoteUI);
					emoteUI.addEventListener(UIEvent.SKIN_CHANGED,  skinChanged);
					
					if(emoteList == null)
						emoteList = new Vector.<UIAsset>();
					emoteList.push(emoteUI);
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
			if(!IsAdd)
			{
				IsAdd = true;
				start();
			}
		}
		
		private function start():void
		{
			this.addEventListener(Event.ENTER_FRAME, enterFrame);
		}
		
		private function stop():void
		{
			this.removeEventListener(Event.ENTER_FRAME, enterFrame);
		}
		/**
		 *	播放完了进行删除 
		 */
		private function enterFrame(e:Event):void
		{
			for each(var emote:UIAsset in emoteList)
			{
				var swfEmote:MovieClip = emote.skin as MovieClip;
				if(swfEmote == null)continue;
				if(_parent.width < swfEmote.width)
					swfEmote.x = 0;
				else
					swfEmote.x = (_parent.width-swfEmote.width)/2;
				
				if(_parent.height < swfEmote.height)
					swfEmote.y = 0;
				else
					swfEmote.y = (_parent.height-swfEmote.height)/2;
				
				if(swfEmote.currentFrame == swfEmote.totalFrames)
				{
					swfEmote.stop();
					_parent.removeElement(emote);
					emoteList.splice(emoteList.indexOf(emote), 1);
				}
			}
			
			if(emoteList && emoteList.length == 0)
			{
				if(_callBack != null)
					_callBack(this);
				stop();
				
				emoteList.length = 0;
			}
		}
		
		public function destory():void
		{
			if(emoteList != null)
			{
				for each(var emoteUI:UIAsset in emoteList)
				{
					var swfEmote:MovieClip = emoteUI.skin as MovieClip;
					swfEmote && swfEmote.stop();
					
					if(_parent.getElementIndex(emoteUI) > -1)
						_parent.removeElement(emoteUI);
				}
				
				emoteList.length = 0;
			}
			
			stop();
		}
	}
}