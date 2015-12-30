/*****************************************************
 * 2010 Guesken, Krefeld
 * Actionscript 3 für Flash 10 Susanne Kaiser 2010
 * Popup without a point or a closing button
 * used for showing the progress, after the user hits Bestellen * 
 ****************************************************/ 

package com.susanakaiser.controls
{
	import flash.display.Shape;	
	import flash.display.Sprite;	
	import flash.events.*;	
	import flash.filters.GlowFilter;	
	import flash.filters.DropShadowFilter;	
	import flash.text.TextField;
	import flash.text.TextFormat;
	//import com.susanakaiser.events.PopupEvent;
	
   public class SimplePopup extends Sprite
   { 		
		private var _width:Number;
		private var _height:Number;
		private var point:Shape;
		private var _bg:Sprite;
		public static var instanceName:String;
        public static var dragInstance:Object;
	   
	 //  private var testTextField:TextField;
 
        public function SimplePopup(width:Number, height:Number, round:int, bottomText:String = "", pointing:String ="")
        {
			_width = width;
			_height = height;
			//draw background			
			_bg = new Sprite();
			_bg.x = 0;
			_bg.y = 0;
			var bgFrame:Shape = new Shape();				
			bgFrame.graphics.beginFill(0xFFFFFF);			
			bgFrame.graphics.drawRoundRect( 0, 0, _width, _height, round, round);		
			bgFrame.graphics.endFill();
			bgFrame.x = 0;
			bgFrame.y = 0;
			bgFrame.name = "frame";
			_bg.addChild(bgFrame);
			
			var gf:GlowFilter = new GlowFilter(0x000000, .5, 6, 6, 2, 8, true, false);
			var ogf:GlowFilter = new GlowFilter(0xED8000, 1, 6, 6, 2, 1, false, false);
			//var df:DropShadowFilter = new DropShadowFilter(8, 45, 0x000000,0.5,4, 4, 1, 1, false,false,false);				
			_bg.filters = [gf, ogf];
			this.addChild(_bg);
			
			instanceName = this._bg.name;
            dragInstance = this._bg;
			//this.addEventListener(MouseEvent.MOUSE_DOWN, doStartDrag, false, 0, true);
           //this.addEventListener(MouseEvent.MOUSE_UP, doStopDrag, false, 0, true);
		}
				
		  public static function doStopDrag(event:MouseEvent) : void
        {
            if (event.target.name == SimplePopup.instanceName)
            {
                SimplePopup.dragInstance.stopDrag();
            }
            return;
        }

        public static function doStartDrag(event:MouseEvent) : void
        {
            if (event.target.name == SimplePopup.instanceName)
            {
                SimplePopup.dragInstance.startDrag();
            }
            return;
        }
		
		public function get bg():Sprite
		{
			return this._bg;
		}

	}
}