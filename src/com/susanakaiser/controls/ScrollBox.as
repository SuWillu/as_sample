/**
 * Copyright (c) 2010 Guesken, Krefeld
 * Actionscript 3 für Flash 10 Susanne Kaiser 2010
 *
 * This class is a scrollbox used for "Fotos and Posters". 
 * It creates a raster of thumbnail locations 
 */
package com.susanakaiser.controls
{	
	import com.susanakaiser.view.InfoButton;
	import flash.display.*;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import com.susanakaiser.view.ThumbnailLocation;
	import flash.text.TextField;
	import caurina.transitions.*;
	
	public class ScrollBox extends MovieClip
	{
		private var sb:Sprite;
		private var sMask:Sprite;
		private var startY:Number;
		private var _stroke:uint;
		private var _arrImages:Array = [];
		private var _arrInfobuttons:Array = [];
		private var _numbScrollto:Number = 0;	
		private var _boxHeight:int = 0;
		private var _blnNeedScrollbar:Boolean = false;
		//private var testTextField:TextField;	
		
		public function ScrollBox(width:int, maskHeight:int, limit:int, howManyToShow:int, fillColor:uint = 0xf0f0f0, strokeColor:uint = 0xf0f0f0 ):void
		{
		/*	//FOR TESTING ONLY
			testTextField = new TextField();
			testTextField.x = 0;
            testTextField.y = 0;
            testTextField.background = true;
          	testTextField.multiline = true;
			testTextField.width = 200;
			testTextField.text= "sb";
			addChild(testTextField); */
			
			//scrolling box
			sb = new Sprite();
			sb.x = 0;
			startY = 0;
			sb.y = startY;
			_stroke = strokeColor;
			
			var iWidth:int = width;
			var iHeight:int = (limit * maskHeight)+1;
			drawColorRect(sb,fillColor,1,iWidth,iHeight);
			this.addChild(sb);	
			
			_boxHeight = maskHeight * howManyToShow;
			
			//the mask
			sMask=new Sprite();			
			//draw it
			drawColorRect(sMask,0xccffff,1,iWidth,_boxHeight);
			sMask.x = sb.x;
			sMask.y = sb.y;
			//add it to stage
			addChild(sMask);
			sb.mask = sMask;
		}
		
		//draw a colored rectangle in the _in sprite
		private function drawColorRect(_in:Sprite, color:Number, opacity:Number, nW:Number, nH:Number):void {	
			_in.graphics.lineStyle(1, _stroke);
			_in.graphics.beginFill(color, opacity);
			try{
				_in.graphics.drawRect(0, 0, nW, nH);
			} catch (e:Error) {}
			_in.graphics.endFill();
		}
		
		public function sbChange(scrollPercent:Number):void
		{
			try{
				Tweener.addTween(sb, { y:(startY - scrollPercent * (_numbScrollto - sMask.height)), time:1 } ); //used to be sb.height instead of numbScrollto
			} catch (e:Error) { }
			
		/*	try{
				Tweener.addTween(sb, { y:(startY - scrollPercent * (sb.height - sMask.height)), time:1 } );
			} catch (e:Error) { } */			
		}	
		
		public function addImage(mcImage:MovieClip):Boolean
		{
			sb.addChild(mcImage);
			_arrImages.push(mcImage);
			var bottomOfImg:int = mcImage.y + mcImage.height;
			if (bottomOfImg > _numbScrollto)
			{
				_numbScrollto = bottomOfImg;
			}
			if (bottomOfImg > _boxHeight)
			{
				_blnNeedScrollbar = true;
			}else {
				_blnNeedScrollbar = false;
			}
			return _blnNeedScrollbar;
		}
		
		public function removeImage(mcImage:MovieClip):void
		{
			sb.removeChild(mcImage);
		}
		
		public function addInfobutton(mcImage:MovieClip):void
		{
			sb.addChild(mcImage);
			_arrInfobuttons.push(mcImage);
		}
		
		public function removeImages():Array
		{
			_numbScrollto = 0;
			var arrMovieclips:Array = copyArray(_arrImages);
			while (_arrImages.length > 0)
			{
				var mcImage:MovieClip = _arrImages.pop();
				sb.removeChild(mcImage);
			}
			while (_arrInfobuttons.length > 0)
			{
				var infoButton:InfoButton = _arrInfobuttons.pop();
				infoButton.deleteButton();
				sb.removeChild(infoButton);
			}
			_blnNeedScrollbar = false;
			
			return arrMovieclips;
		}
		
		private function copyArray(origArray:Array):Array
		{
			var arr:Array = []; 
			if (origArray.length > 0)
			{
				while ( arr.length < origArray.length) 
				{     
					arr[arr.length] = origArray[arr.length]; 
				} 
			}
			return arr; 
		}
		
		public function get boxHeight():int
		{
			return _boxHeight;
		}
	}
}
