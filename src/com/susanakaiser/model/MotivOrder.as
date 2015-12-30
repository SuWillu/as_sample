/******************************************
 * holds 1 order each for a given Motiv, 
 * it is stored in the arrMotivorders of the objMotivModel
 * ****************************************/

package com.susanakaiser.model
{		
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.utils.Dictionary; 
	
	public class MotivOrder extends MovieClip
	{				
		public var intArrayPosition:int = -1;
		//each arrOrder holds intBilder * objSuborder:SubOrder. Each suborder knows it´s strMotiv, intOrderPosition and intBildausschnittPosition.
		public var arrOrder:Array = []; 		
		public var frameRotation:Number = 0;
		public var blnAllFilled:Boolean = false;
		
		//it needs to know from the motivmodel data
		public var Farbe:String = "";
		public var Material:String = "";
		public var Materialname:String = "";
		public var intBilder:int = 0;
		public var strBilder:String = "";
		public var Passpartout:String = "";
		public var Artikelnummer:String = "";
		public var orientation:String = "";
		public var Preis:String = "";
		public var Motivname:String = "";	
		public var motivID:String = "";	
		public var passpartoutBreite_in_mm:Number = 0;
		public var passpartoutHoehe_in_mm:Number = 0;	
		
		public var passpartoutW_in_pxl:int = 0; //in pixels
		public var passpartoutH_in_pxl:int = 0; //in pixels	
		public var bmp:Bitmap;
		
		public function MotivOrder():void
		{
			
		bmp=new Bitmap();				
			//and add it to the image container
			this.addChild(bmp);			
		}
		
		//setter for the bitmap data
		public function set imageData(value:BitmapData):void {
			try{
				//if the old value is not null dispose the data
				if (bmp.bitmapData!=null) {
					bmp.bitmapData.dispose();
				}
				//set the new data
				bmp.bitmapData=value;
		
				//force the smoothing
				bmp.smoothing=true;		  
				bmp.alpha = 1;
				this.scaleX=1;
				this.scaleY = 1;
			} catch (e:Error) {}
		}
		
		public function empty():void
		{
			try{
				if (bmp.bitmapData!=null) {
					bmp.bitmapData.dispose();
				}
			} catch (e:Error) {}	
		}
	}
}