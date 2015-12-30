package com.susanakaiser.view
{		
	import flash.display.*;
	import flash.geom.*;
		
	public class Progressbar extends MovieClip
	{
		private var _imgH:Number;
		private var numbLoaded:Number;
		private var numbTotal:Number;
		private var bar:Sprite;
		private var box:Shape;
		//total times barUnit gives the width of the progressbar
		private var barUnit:Number;
		
		public function Progressbar():void
		{
			box = new Shape();
			bar = new Sprite();	
		}

		public function createProgressbar(barX:Number, barY:Number, height:Number, total:Number, unit:Number):void
		{	
			this._imgH = height;
			this.x = barX;
			this.y = barY;
			this.numbTotal = total;	
			this.barUnit = unit;			
			
			box.graphics.lineStyle(1, 0xeb7209);
			box.graphics.beginFill(0xffffff);			
			box.graphics.drawRect(this.x, this.y, this.barUnit, this._imgH);			
			box.graphics.endFill();
			this.addChild(box);			

			//progressbar			
			bar.x = this.x;
			bar.y = this.y;
			drawColorRect(bar, 0xeb7209, 1, 3, this._imgH);
			//bar.scaleX = 0;
			this.addChild(bar);				
		}
		
		//draw a colored rectangle in the _in sprite
		private function drawColorRect(_in:Sprite,color:Number, opacity:Number, nW:Number,nH:Number):void {			
			_in.graphics.beginFill(color, opacity);
			try{
				_in.graphics.drawRect(0, 0, nW, nH);
			} catch (e:Error) {}
			_in.graphics.endFill();
		}
		
		public function showProgress(files_left_to_save:int):Number
		{
			this.numbLoaded= this.numbTotal - files_left_to_save;
			bar.width = Math.round(this.numbLoaded / this.numbTotal * this.barUnit);
			return this.numbLoaded;
		}
		
		public function complete():void
		{
			
			bar.width = this.barUnit;
		}
		
	}
}