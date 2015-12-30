package com.susanakaiser.controls
{
	import flash.display.*;
	import flash.events.*;
	import flash.filters.DropShadowFilter;
	import flash.filters.GradientBevelFilter;
	import flash.filters.GradientGlowFilter;
	import flash.filters.GlowFilter;
	import com.leebrimelow.ui.ScrollBarEvent;
	
	
	public class ScrollBar extends MovieClip
	{
		private var yOffset:Number;
		private var yMin:Number;
		private var yMax:Number;
		private var _thumb:Sprite;
		private var track:Sprite;
		private var _thumbThickness:Number;
		private var _trackThickness:Number;
		private var _thumbGrip:Sprite;
		private var _thumbArrow1:Sprite;
		private var _thumbArrow2:Sprite;
		private var _gripColor:uint;
		private var _thumbHeight:Number;
		//private var testTextField:TextField;
		
		public function ScrollBar(stage:Stage, iWidth:int, iHeight:int):void
		{
		/*	//FOR TESTING ONLY
			testTextField = new TextField();
			testTextField.x = 400;
            testTextField.y = 10;
            testTextField.background = true;
          	testTextField.multiline = true;
			testTextField.width = 200;
			testTextField.text= "scrollbar";
			addChild(testTextField); */
			_trackThickness = iWidth;
			_thumbThickness = iWidth;
			
			//scrolling track
			track = new Sprite();
			track.x=0;
			track.y = 0;						
			drawColorRect(track, 0xcccccc, 1, _trackThickness, iHeight);
			try{
				var gg:GradientGlowFilter = new GradientGlowFilter(4, 320, [0xcccccc, 0xe8e3e3],[1,1], [0, 255], 4, 4, 1, 1, "inner", false);
				var df:DropShadowFilter = new DropShadowFilter(1, 225, 0xe8e3e3, 1, 5, 5, 1, 1, false,false,false);		
				track.filters = [gg, df];
			} catch (e:Error) {}
			this.addChild(track);
			
			_gripColor = 0x898b8f;
			_thumbHeight = 50;
			//scroll thumb
			createThumb();			
			createGrips();
			positionGrips();
							
			yMin = 0+track.y ;
			yMax = track.height - _thumb.height + track.y;
			try{				
				_thumb.addEventListener(MouseEvent.MOUSE_OVER, thumbOver, false, 0, true);
				_thumb.addEventListener(MouseEvent.MOUSE_OUT, thumbOut, false, 0, true);
			} catch (e:Error) {}
		}
		
		public function activate():void
		{
			try{
				_thumb.addEventListener(MouseEvent.MOUSE_DOWN, thumbDown, false, 0, true);
			} catch (e:Error) {}
		}
		
		private function thumbDown(e:MouseEvent):void
		{
			try{
				_thumb.addEventListener(MouseEvent.MOUSE_MOVE, thumbMove, false, 0, true);
				stage.addEventListener(MouseEvent.MOUSE_MOVE, thumbMove, false, 0, true);
				stage.addEventListener(MouseEvent.MOUSE_UP, thumbUp, false, 0, true);
				_thumb.addEventListener(MouseEvent.MOUSE_UP, thumbUp, false, 0, true);
			} catch (e:Error) {}
			yOffset = mouseY - _thumb.y;
		}

		private function thumbUp(e:MouseEvent):void
		{
			try{
				_thumb.removeEventListener(MouseEvent.MOUSE_MOVE, thumbMove);
				stage.removeEventListener(MouseEvent.MOUSE_MOVE, thumbMove);
				stage.removeEventListener(MouseEvent.MOUSE_UP, thumbUp);
				_thumb.removeEventListener(MouseEvent.MOUSE_UP, thumbUp);
			} catch (e:Error) {}
		}

		private function thumbMove(e:MouseEvent):void
		{
			_thumb.y = mouseY - yOffset;
			if(_thumb.y <= yMin)
				_thumb.y = yMin;
			if(_thumb.y >= yMax)
				_thumb.y = yMax;
			try{
				dispatchEvent(new ScrollBarEvent((_thumb.y - track.y) / (yMax - track.y)));
			} catch (e:Error) {}
			
			e.updateAfterEvent();
		}
		
		//put thumb back into default position
		public function moveThumbHome():void
		{
			_thumb.y = 0;
			try{
				dispatchEvent(new ScrollBarEvent((_thumb.y - track.y) / (yMax - track.y)));
			} catch (e:Error) {}
		}
		
		private function thumbOver(e:MouseEvent):void
		{
			var gf:GlowFilter = new GlowFilter(0xffffff,0.5,4,4,4,3,true);	
			_thumb.filters = [gf]; 			
		}
		
		private function thumbOut(e:MouseEvent):void
		{
			_thumb.filters = []; 
		}
		
			//draw a colored rectangle in the _in sprite
		private function drawColorRect(_in:Sprite,color:Number, opacity:Number, nW:Number,nH:Number):void {			
			_in.graphics.beginFill(color, opacity);
			try{
				_in.graphics.drawRect(0, 0, nW, nH);
			} catch (e:Error) {}
			_in.graphics.endFill();
		}
		
		//	from FullScreenScrollBar.as from
		// http://www.warmforestflash.com/blog/2009/04/free-as3-scrollbar-fullscreen-and-resizable/
		//============================================================================================================================
		private function createThumb():void
		//============================================================================================================================
		{
			_thumb = new Sprite();
			var t:Sprite = new Sprite();
			t.graphics.beginFill(0x596991); 
			t.graphics.drawRect(0, 0, _thumbThickness, _thumbHeight);
			t.graphics.endFill();			
			t.graphics.beginFill(0xbdcadb); 
			t.graphics.drawRect(1, 1, _thumbThickness - 2, _thumbHeight - 2);
			t.graphics.endFill();
			t.name = "bg";				
			_thumb.addChild(t);			
						
			//if(_hasShine)
			//{
				var shine:Sprite = new Sprite();
				var sg:Graphics = shine.graphics;
				sg.beginFill(0xffffff, 0.3);
				sg.drawRect(0, 0, Math.ceil(_thumbThickness/2), _thumbHeight);
				sg.endFill();
				shine.x = 0;
				shine.name = "shine";
				_thumb.addChild(shine);
			//}
			
			addChild(_thumb);
		}
		
		//============================================================================================================================
		private function createGrips():void
		//============================================================================================================================
		{
			_thumbGrip = createGrabberGrip();
			_thumb.addChild(_thumbGrip);
			
			_thumbArrow1 = createPixelArrow();
			_thumb.addChild(_thumbArrow1);
			
			_thumbArrow2 = createPixelArrow();
			_thumb.addChild(_thumbArrow2);
			
			_thumbArrow1.rotation = -90;
			_thumbArrow1.x = ((_thumbThickness - 7) / 2) + 1;
			_thumbArrow2.rotation = 90;
			_thumbArrow2.x = ((_thumbThickness - 7) / 2) + 6;
		}
		
		//============================================================================================================================
		private function createGrabberGrip():Sprite
		//============================================================================================================================
		{
			var w:int = 7;
			var xp:int = (_thumbThickness - w) / 2;
			var t:Sprite = new Sprite();
			t.graphics.beginFill(_gripColor, 1);
			t.graphics.drawRect(xp, 0, w, 1);
			t.graphics.drawRect(xp, 0 + 2, w, 1);
			t.graphics.drawRect(xp, 0 + 4, w, 1);
			t.graphics.drawRect(xp, 0 + 6, w, 1);
			t.graphics.drawRect(xp, 0 + 8, w, 1);
			t.graphics.endFill();
			return t;
		}
		
		//============================================================================================================================
		private function createPixelArrow():Sprite
		//============================================================================================================================
		{
			var t:Sprite = new Sprite();			
			t.graphics.beginFill(_gripColor, 1);
			t.graphics.drawRect(0, 0, 1, 1);
			t.graphics.drawRect(1, 1, 1, 1);
			t.graphics.drawRect(2, 2, 1, 1);
			t.graphics.drawRect(1, 3, 1, 1);
			t.graphics.drawRect(0, 4, 1, 1);
			t.graphics.endFill();
			return t;
		}
		
		//============================================================================================================================
		private function positionGrips():void
		//============================================================================================================================
		{
			_thumbGrip.y = Math.ceil(_thumb.getChildByName("bg").y + (_thumb.getChildByName("bg").height / 2) - (_thumbGrip.height / 2));
			_thumbArrow1.y = _thumb.getChildByName("bg").y + 8;
			_thumbArrow2.y = _thumb.getChildByName("bg").height - 8;
		}
		
		public function discardScrollbar():void
		{
			
		}
		
		public function showTrackwithoutThumb():void
		{
			_thumb.visible = false;
		}
	}
}
