/******************************************
 * holds all the details for 1 Bildausschnitt
 * ****************************************/

package com.susanakaiser.model
{	
	import Object;
	import flash.utils.Dictionary; 
	
	public class BildModel extends Object
	{		
		public var Breite_in_mm:Number = 0;
		public var Hoehe_in_mm:Number = 0;
		
		//FOR PRODUKTIONSBILD - INCLUDES EDGE
		//size of printed produktionsbild
		public var finalW:int = 0;
		public var finalH:int = 0;
		//position of ausschnitt in produktionsbild
		public var topleftX:int = 0;
		public var topleftY:int = 0;
		
		//the size for the Rahmen Ausschnitt in workarea
		public var pixelBreit:Number = 0; 
		public var pixelHoch:Number = 0;
		public var posX:Number= 0;
		public var posY:Number = 0;
		public var orientation:String = "";
		
		public function BildModel():void
		{
			
		}
	}
}