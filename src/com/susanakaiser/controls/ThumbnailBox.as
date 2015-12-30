/**
 * Copyright (c) 2010 Guesken, Krefeld
 * Actionscript 3 für Flash 10 Susanne Kaiser 2010
 *
 * This class is a scrollbox used for "Fotos and Posters". 
 * It creates a raster of thumbnail locations 
 */
package com.susanakaiser.controls
{	
	import flash.display.*;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import com.susanakaiser.view.ThumbnailLocation;
	import flash.text.TextField;
	import caurina.transitions.*;
	import com.susanakaiser.view.FotoView;	
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.text.TextFormat;
	
	public class ThumbnailBox extends MovieClip
	{
		public var arrLocations:Array; //array of ThumbnailLocations
		private var _thumbnailSize:Number;
		public var bg:Sprite;
		private var sMask:Sprite;
		private var startY:Number;
		//private var testTextField:TextField;	
		private var intLastImage:int = 0;
		
		public function ThumbnailBox(spacing:Number, sizeXY:Number, countWide:int, limit:int, height:Number):void
		{
		/*	//FOR TESTING ONLY
			testTextField = new TextField();
			testTextField.x = 300;
            testTextField.y = -50;
            testTextField.background = true;
          	testTextField.multiline = true;
			testTextField.width = 200;
			//testTextField.text= "menuHolder";
			addChild(testTextField); */			
			
			bg = new Sprite();
			bg.x = 0;
			startY = 0;
			bg.y = startY;
			var numRows:int;
			if (limit % countWide > 0)
			{
				numRows = int(limit / countWide) + 1;
			}else {
				numRows = int(limit / countWide);
			}
			//testTextField.text = String(numRows);	
			var iWidth:int = (countWide * sizeXY) + ((countWide) * spacing);
			//var iHeight:int = (numRows * sizeXY) + ((numRows+1) * spacing);
			drawColorRect(bg, 0xe1e1e1, 1, 280, height);
			
			/********************
			 * Arrow
			 * *****************/
			var arrowW:int = 30;
			var arrowH:int = height;
			var arrowColor:uint = 0xe1e1e1;
			var rightArrow:Shape = new Shape();
			with (rightArrow) {
				//graphics.lineStyle(1 ,0xc8ad90 ,1 );
				graphics.beginFill(arrowColor);
				graphics.moveTo(0, 0);
				graphics.lineTo(arrowW, arrowH/2);
				graphics.lineTo(0, arrowH);
				graphics.lineTo(0, 0);
				graphics.endFill();
			}
			rightArrow.x = bg.x + bg.width;
			rightArrow.y = bg.y;						
			bg.addChild(rightArrow);
			var gf:GlowFilter = new GlowFilter(0x000000, .5, 2, 2, 2, 2, true, false);						
			bg.filters = [gf];
			
			var tfLabel:TextFormat = new TextFormat("Arial, Helvetica, sans-serif", 11, 0x4c4c4c, false);		
			var tfAdvice:TextField = new TextField();
			tfAdvice.x = 227;
			tfAdvice.y = 225;
			tfAdvice.background = false; 
			//tfAdvice.backgroundColor = 0xff9900;				
			tfAdvice.width = 75;
			tfAdvice.height = 60;	
			tfAdvice.multiline = true; 				
			tfAdvice.text= "Ziehen Sie\nIhr Foto auf\nden Platzhalter\nim Rahmen";
			bg.addChild(tfAdvice);
			tfAdvice.setTextFormat(tfLabel);
			
			this.addChild(bg);	
			
			//add thumbnail backgrounds
			this.arrLocations = [];	
			_thumbnailSize = sizeXY;
			var firstX:Number = bg.x+3;
			var firstY:Number = 5;
			var nextX:Number = firstX;
			var nextY:Number = firstY;
		
			for (var i:int = 1; i <= limit; i++)
			{
				var thumbLoc:ThumbnailLocation = new ThumbnailLocation();
				var fillColor:uint = 0xffffff;
				if (i == 1)
				{
					thumbLoc.createThumbnailLocation(_thumbnailSize, fillColor);
					thumbLoc.x = firstX;
					thumbLoc.y = firstY;
				}
				else if (i % countWide == 1)
				{
					nextY += _thumbnailSize +spacing + 15;
					nextX = firstX;
					thumbLoc.createThumbnailLocation(_thumbnailSize, fillColor);
					thumbLoc.x = nextX;
					thumbLoc.y = nextY;
					
				}else { 
					nextX += _thumbnailSize +spacing;
					thumbLoc.createThumbnailLocation(_thumbnailSize, fillColor);
					thumbLoc.x = nextX;
					thumbLoc.y = nextY;
				}
				var ds:DropShadowFilter = new DropShadowFilter(4, 45, 0, 1, 4, 4, 1, 1, false, false, false);
				thumbLoc.filters = [ds];
				bg.addChild(thumbLoc);
				this.arrLocations.push(thumbLoc);				
			}
		}
				
		public function addImage(photo:FotoView):int
		{	
			var index:int = -1;
			for (var i:int = 0; i < arrLocations.length; i++)
			{
				if (this.arrLocations[i].hasPhoto()===false)
				{
					var msg:String = arrLocations[i].attachImage(photo);
					
					//keep track of how far we have images, so it can scroll only that far
					if (i > intLastImage)
					{
						intLastImage = i;
					}
					//testTextField.appendText ("length:"+arrLocations.length+"i:"+i+"\n");
					index = i;
					return index;
				}
			}
			return index;
		}
		
		public function removeImage(photo:FotoView):void
		{				
			var thumbLoc:ThumbnailLocation = new ThumbnailLocation();
			//if the photo is a thumbnail...
			if (arrLocations.indexOf(photo.parent) > -1)
			{
				thumbLoc = photo.parent as ThumbnailLocation;
				thumbLoc.removeImage();
			}
		}
		
		//draw a colored rectangle in the _in sprite
		private function drawColorRect(_in:Sprite,color:Number, opacity:Number, nW:Number,nH:Number):void {			
			_in.graphics.beginFill(color, opacity);
			try{
				_in.graphics.drawRect(0, 0, nW, nH);
			} catch (e:Error) {}
			_in.graphics.endFill();
		}
		
		public function addHighlight(sp:Sprite, intPos:int):void
		{
			arrLocations[intPos].addChild(sp);
		}
		
		public function removeHighlight(intPos:int):void
		{
			var sp:Sprite = arrLocations[intPos].getChildByName("frame-" + intPos) as Sprite;
			if (arrLocations[intPos].contains(sp))
			{
				arrLocations[intPos].removeChild(sp);
			}
		}
		
		public function removeAllImages():void
		{	
			//var strResult:String = "hello";
			for (var i:int=0; i < arrLocations.length; ++i) 
			{			
				arrLocations[i].clearImage();
			}			
		}
	}
}
