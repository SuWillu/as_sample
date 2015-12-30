/*****************************************************
 * 2010 Guesken, Krefeld
 * Actionscript 3 für Flash 10 Susanne Kaiser 2010
 *
 * adapted from the tutorial at 
 * http://blog.sugarpillfactory.com/?p=171 (also see DropDownMenu.as)
 ****************************************************/ 

package com.susanakaiser.utils
{
    import flash.display.*;
    import flash.events.*;
    import flash.text.*;

    public class LinkBox extends MovieClip
    {
        private var _selected:String;
		private var tField:TextField;
		private var tFieldFormat:TextFormat;
		private var _origColor:uint;

        public function LinkBox(strSelected:String, tformat:TextFormat, width:Number, height:Number, borderColor:uint, bgColor:uint=0xffffff)
        {
            _selected = strSelected;   
			_origColor = bgColor;

			tFieldFormat = new TextFormat();
			tFieldFormat = tformat;				
			tField = new TextField();
			tField.text = _selected;
			//tField.autoSize = TextFieldAutoSize.LEFT;
			tField.width = width;
			tField.height = height;
			if (bgColor == 0xffffff)
			{
				tField.border = true;
				tField.borderColor = borderColor;
			}else {
				tField.border = false;
			}
			tField.background = true;
			tField.backgroundColor = bgColor;
			tField.wordWrap = false;
			try{
				tField.setTextFormat(tFieldFormat);
			}catch (e:Error) {}	
			this.addChild(tField);
			this.mouseChildren = false;
			tField.x = width/2 - tField.width/2;
			tField.y = height/2 - tField.height/2;
		}
		
		public function select(newTitle:String):void
		{
			_selected = newTitle;
			tField.text = _selected;
			try{
				tField.setTextFormat(tFieldFormat);
			}catch (e:Error) {}	
		}
		
		public function get selected():String
		{
			return tField.text;
		}
		
		public function changeColor(color:uint):void
		{
			tField.backgroundColor = color;
			tFieldFormat.color = 0xffffff;
			tField.setTextFormat(tFieldFormat);
		}
		
		public function changeColorBack():void
		{
			tField.backgroundColor = _origColor;
			tFieldFormat.color = 0x000000;
			tField.setTextFormat(tFieldFormat);
		}
		
		public function changeBorder(color:uint):void
		{
			tField.borderColor = color;
		}
		
		public function discardMenu():void
		{
			this.removeChild(tField);			
			tFieldFormat = null;				
			tField = null;
		}
    }
}

