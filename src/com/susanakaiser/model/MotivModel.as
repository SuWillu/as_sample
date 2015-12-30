/******************************************
 * holds all the details for 1 Motiv
 * ****************************************/

package com.susanakaiser.model
{	
	import com.susanakaiser.view.MotivButton;
	import Object;
	import flash.utils.Dictionary; 
	
	public class MotivModel extends Object
	{
		public var strSerie:String = "";
		public var Farbe:String = "";
		public var Material:String = "";
		//for the select Menu
		public var Materialname:String = "";
		public var intBilder:int = 0;
		public var strBilder:String = "";
		public var Passpartout:String = "";
		public var Artikelnummer:String = "";
		public var nmbPrice:Number = 0;
		public var Preis:String = "";
		public var passpartoutBreite_in_mm:Number = 0;
		public var passpartoutHoehe_in_mm:Number = 0;
		//for settings.xml
		public var passpartoutW_in_pxl:int = 0; 
		public var passpartoutH_in_pxl:int = 0; 
		
		public var Motivname:String = "";
		//used in Flash to find the correct items to go together - sm and lg rahmen and info
		public var motivID:String = ""; //in the form artikelnummer + "_" + orientation
		public var motivpath:String = "";
		public var smRahmenWidth_in_pxl:int = 0;
		public var smRahmenHeight_in_pxl:int = 0;
		public var rahmenWidth_in_pxl:int = 0; //in pixels
		public var rahmenHeight_in_pxl:int = 0; //in pixels	
		//needs to be added to the passpartout size and to each imgPos for the frame, to get the place to put the dropboxes.
		public var halbeBreite_PLUS_in_pxl:Number = 0;
		public var halbeHoehe_PLUS_in_pxl:Number = 0;
		public var infoscreen:String = "";
		public var orientation:String = "";
		
		public var arrBilder:Array = []; //arrBilder holds the info for each Bildausschnitt as BildModel.
		public var objMotivButton:MotivButton;
		
		//arrMotivorders holds the orders for this motiv: arrMotivorders = [objMotivOrder, objMotivOrder, objMotivOrder, ...].
		//each objMotivorder holds an arrOrder, which holds intBilder * objSuborder:SubOrder. Each suborder knows it´s strMotiv, intOrderPosition and intBildausschnittPosition.
		public var arrMotivorders:Array = []; 
		
		public var intCurrOrder:int = -1;
		
		public function MotivModel():void
		{
			
		}
	}
}