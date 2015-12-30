/**
 * Copyright (c) 2010 Guesken, Krefeld
 * Actionscript 3 für Flash 10 Susanne Kaiser 2010
 *
 * This class holds a reference to all the dictionary dictProducts with the SubOrders for all the Fotos.
 * All the Fotos are in an array in main, therefore accessible to go through and add up all the orders for the Bestellung.
 * OrderModel changes and calls notifyChanges which calls update in OrderView,
 * 			when the user deletes a highlighted photo, 
 * 			when the user highlights one photo, 
 * 			when the user unhighlights one photo
 * 
 * OrderModel responds to View changes from the menu,
 * 			when the user adds a SubOrder,
 * 			when the user deletes a SubOrder,
 * 			when the user changes a SubOrder and clicks on Akzeptieren.
 * 			when the user clicks on "bestellen".
 * OrderModel implements singleton.
 */
 package com.susanakaiser.model  
 { 
	 import com.susanakaiser.utils.Observer;
	 import com.susanakaiser.model.SubOrder;
	 import com.susanakaiser.model.FotoOrdersModel;
	 import flash.utils.Dictionary; 
	 import com.susanakaiser.model.MotivModel;
	 
	  //for testing
	import flash.display.*;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;

   public class OrderModel extends Observer
   {
	    //implementing singleton, since only 1 instance of this class should be used in the whole project.
	   private static var instance:OrderModel = undefined;
	   private static var allowInstance:Boolean; 
	   
	   //arrFotoOrdersModels_for_all_photos holds the FotoOrdersModel instances, 1 for each foto.
	   private var arrFotoOrdersModels_for_all_photos:Array = [];
	   //holds only the origW and origH for each foto, currently used only in getPotentialOrder for checking the size
	   //but I will need it for the FotoEditor
	   private var arrFotoModel:Array = []; 
	   private var _limit:int = 0; //the potential number of photos
	   
	   private var _blnFormateReady:Boolean;	   
	  // private var _intGesamtAnzahl:int = 0;
	   private var _intGesamtPreis:Number = 0.00;
	   
	   //_arrHighlighted holds the index numbers of the Photos, which are highlighted.
	   //The index numbers corresponds with the index in arrFotoOrdersModels_for_all_photos.
	   private var _arrHighlighted:Array;
	   private var _blnAllHighlighted:Boolean; //whether or not all photos are highlighted
	   
	   //ordercontroller gets the formate from the xml file. 
	   private var _arrFormate:Array = []; //holds the objBildAusschnitte in the order they are in .xml file  
	   
	   //---------for Bestellung-------------
	   private var arrFotos_with_orders:Array;
	   
	   //---------for monopoly code----------
	   private var _codeResponse:String = "";
	   
	   	 	   
	   //für Galerierahmen
	   //holds all info about the motivs, the name is the key, the obj with the array of Bildausschnitten (and all orders for this motiv) the value.
	   private var _arrSerien:Array; //holds the names of all the Motivserien, used in OrderView for the selectmenu.
	   private var _dictMotive:Dictionary; 
	   private var _strCurrentMotiv:String = "";	  
	   private var _currentMotiv:MotivModel;
	   private var _objCurrMotivOrder:MotivOrder = new MotivOrder(); 
	   private var _intCurrOrder:int; //the position of the motivorder in the array of orders for that motiv
	   
	   //for editing order
	   private var _strEditMotiv:String = "";	  
	   private var _editMotiv:MotivModel = new MotivModel();
	   private var _objEditMotivOrder:MotivOrder = new MotivOrder;	 
	   
	   private var _dictMaterial:Dictionary;
	   private var _arrBilderAnzahl:Array;
	   
	   //for dealing with fotos that couldn´t get saved and didn´t give message back to flash
	   private var _intSavedFotosSuccessfully:int = -1; // -1=not saved yet, 0 = some unsuccessful, 1 = successful
	  
		private var testTextField:TextField;

	    //--------------------------
		// Singleton Implementation
		//--------------------------
       public function OrderModel():void 
	   {  
			 if (!allowInstance) 
			 { 
				throw new Error("Error: use OrderModel.getInstance() instead of new keyword");
			 }else{
				arrFotoOrdersModels_for_all_photos = [];
				_arrHighlighted = [];
				_blnAllHighlighted = false;
				_blnFormateReady = false;
				
			/*	//FOR TESTING ONLY
				testTextField = new TextField();
				testTextField.x = 50;
				testTextField.y = 500;
				testTextField.background = false;
				testTextField.autoSize = TextFieldAutoSize.LEFT;
				testTextField.multiline = true;			
				testTextField.text= "test order model:";
				addChild(testTextField); */
			 }
	   }
	   
	   public static function getInstance():OrderModel {
       if (instance == null) 
	   {
         allowInstance = true;
         instance = new OrderModel();
         trace("OrderModel instance created");
         allowInstance = false;
       } else { 
         trace("OrderModel instance already exists");
       }
       return instance;
    }
	   
		//OrderView registers here, to be updated, when the highlighting changes
		//or when a photo gets deleted
	   public function registerView(view:Object):void
	   {
		   super.addSubscriber(view);
	   }
	   
	   	public function unregisterView(view:Object):void
	   {
		   super.removeSubscriber(view);
	   }
	   
	   /***************************************************************************
		* functions called by orderController, initiated by orderView
		* ************************************************************************/
	   	   
	   //only 1 suborder at a time gets added
	   public function addSubOrder(objSuborder:SubOrder):void
	   {	
		   //remove the old suborder first, if they are switching motive or bringing a new foto, where
		   //there already was a foto
		    _strCurrentMotiv = objSuborder.strMotiv;
				//testTextField.appendText("Ausschnitt " + String(objSuborder.intAusschnittPosition));
			//check, if there already was an image in that position, if so reduce the count for that img
			if (_objCurrMotivOrder.arrOrder[objSuborder.intAusschnittPosition] != null)
			{	
				var lastObjSuborder:SubOrder = _objCurrMotivOrder.arrOrder[objSuborder.intAusschnittPosition];
					//testTextField.appendText("last imgPos " + String(lastObjSuborder.imgPos));
				
				//destroy the former order 
				lastObjSuborder = null; 
			}
		   
			//add the Ausschnitt order	
			_objCurrMotivOrder.arrOrder[objSuborder.intAusschnittPosition] = objSuborder;	
			//testTextField.appendText("addSuborders: " + objSuborder.intAusschnittPosition + "\n");	
		}
		
		//add an order with Ausschnitten, whether they are filled or not - using the already stored data
		//gets called, when Kunde has clicked on Add to Warenkorb
		public function confirmMotivOrder(bmpSnapshot:Bitmap):void
		{
			_objCurrMotivOrder.imageData = bmpSnapshot.bitmapData;
		
			if (_objCurrMotivOrder.arrOrder.length > 0)
			{
				//get whether it´s the first, second etc. order for this foto in this Motiv.
				var intArrayPosition:int = _currentMotiv.intCurrOrder;
					//testTextField.appendText("Bilder: " + _currentMotiv.intBilder);	
				
				for (var i:int = 0; i < _objCurrMotivOrder.arrOrder.length; ++i)
				{
						//testTextField.appendText("\n" + i + " confirm order at: " + _currentMotiv.intCurrOrder + String(_objCurrMotivOrder.arrOrder[i]) + "img:" + SubOrder(_objCurrMotivOrder.arrOrder[i]).imgPos);
					//not every Ausschnitt has to be filled
					if ((_objCurrMotivOrder.arrOrder[i] != null)&&(i < _currentMotiv.intBilder))
					{
						var objSuborder:SubOrder = SubOrder(_objCurrMotivOrder.arrOrder[i]);
						objSuborder.intArrayPosition = intArrayPosition;
						
						this.addOrderToFoto(objSuborder);
					}else { //discard any extra Fotos at this point (Kunde might have filled a Rahmen w/ more Bilder first and have excess Bilder now
						_objCurrMotivOrder.arrOrder[i] = null;
					}
				}
			} 
			
			_objCurrMotivOrder.intArrayPosition = _currentMotiv.intCurrOrder;
			
			
			//the order needs to know the following attributes from the motiv for the bestellung
			_objCurrMotivOrder.Artikelnummer = _currentMotiv.Artikelnummer;
			_objCurrMotivOrder.Preis = _currentMotiv.Preis;
			_objCurrMotivOrder.Motivname = _currentMotiv.Motivname;		
			_objCurrMotivOrder.motivID = _currentMotiv.motivID;		
			_objCurrMotivOrder.Farbe = _currentMotiv.Farbe;
			_objCurrMotivOrder.Material = _currentMotiv.Material;
			_objCurrMotivOrder.Materialname = _currentMotiv.Materialname;
			_objCurrMotivOrder.intBilder = _currentMotiv.intBilder;
			_objCurrMotivOrder.Passpartout = _currentMotiv.Passpartout;
			_objCurrMotivOrder.passpartoutBreite_in_mm = _currentMotiv.passpartoutBreite_in_mm;
			_objCurrMotivOrder.passpartoutHoehe_in_mm = _currentMotiv.passpartoutHoehe_in_mm;
			
			_objCurrMotivOrder.passpartoutW_in_pxl = _currentMotiv.passpartoutW_in_pxl;
			_objCurrMotivOrder.passpartoutH_in_pxl = _currentMotiv.passpartoutH_in_pxl;		
		
			//Kunde kann einen Rahmen mit oder ohne Bilder bestellen und auch, wenn ein Bild drin ist und andere fehlen				
			_currentMotiv.arrMotivorders[_currentMotiv.intCurrOrder] = _objCurrMotivOrder;
			_currentMotiv.intCurrOrder = _currentMotiv.arrMotivorders.length;
			
			//start fresh
			_objCurrMotivOrder = null;
			_objCurrMotivOrder = new MotivOrder();
		
			
			this.notifyView();	
		}
		
		//should be called, only when an rahmen order gets confirmed
	   private function addOrderToFoto(objSuborder:SubOrder):void
	   {				
			arrFotoOrdersModels_for_all_photos[objSuborder.imgPos].addSubOrder(1);
	   }
		
		public function deleteMotivOrder(objMotivOrder:MotivOrder):void
		{	
			var strMotivid:String = objMotivOrder.motivID;
			//find the MotivOrder and delete it from arrMotivOrders
			var arrMotivOrders:Array = MotivModel(_dictMotive[strMotivid]).arrMotivorders;
			//need to determine, how to delete it, if I 
			if ((arrMotivOrders != null) && (arrMotivOrders.length > 0))
			{		
				var intIndx:int = objMotivOrder.intArrayPosition;
		
				//reduce the count for the imgs in the order
				var arrOrder:Array = objMotivOrder.arrOrder;
				
				for (var k:int = 0; k < arrOrder.length; ++k)
				{
					if (arrOrder[k] != null)
					{
						var lastObjSuborder:SubOrder = arrOrder[k];
						if (lastObjSuborder.imgPos > -1)
						{
							for (var i:int = 0; i < this.arrFotoOrdersModels_for_all_photos.length; i++ )
							{
								if ((arrFotoOrdersModels_for_all_photos[i]!=null) && (arrFotoOrdersModels_for_all_photos[i].imgPos === lastObjSuborder.imgPos))
								{
										//testTextField.appendText("remove order for Foto # " + i);
									arrFotoOrdersModels_for_all_photos[i].removeSubOrder(1);			
								}
							}
						}	
						lastObjSuborder = null; //destroy the former order 
					}
				}
				
				//delete old snapshot
				objMotivOrder.empty();
				objMotivOrder = null;
				
				MotivModel(_dictMotive[strMotivid]).arrMotivorders[intIndx] = null;
			}	
			this.notifyView();
		}
			
		//for displaying totals in orderView  
		public function getTotals():Array
		{			
			//calculate total count and total price			
			var intTotalAnzahl:int = 0;
			var numbPreisInsgesamt:Number = 0.00;
			
			//check the fotoorders and add to totals
			var arrTotals:Array = [];
			var arrFormate_forProduct:Array = [];
			var intAnzahlPerProduct:int = 0;
			var numbPreisPerProduct:Number = 0.00;
			var dictProductTotals:Dictionary = new Dictionary();
			var dictOrders_forProduct:Dictionary = new Dictionary();			
			var arrSuborders:Array = [];			
			
			//go through all products
			for each (var objMotivModel:MotivModel in _dictMotive) 
			{// iterates through each value		
				
				//has to check, if there is an order in each slot of the arrMotivorders, since they will be able
				//to cancel an order, and since it stores the position, I can only set it to null, not splice() it out
				intAnzahlPerProduct = 0;
				for (var i:int = 0; i <  objMotivModel.arrMotivorders.length; ++i)
				{
					if (objMotivModel.arrMotivorders[i] != null)
					{
						intAnzahlPerProduct += 1;
					}
				}			
				numbPreisPerProduct = objMotivModel.nmbPrice * intAnzahlPerProduct;					
								
				intTotalAnzahl = intTotalAnzahl + intAnzahlPerProduct;
				numbPreisInsgesamt = numbPreisInsgesamt + numbPreisPerProduct;
			}
				
			arrTotals[0] = intTotalAnzahl;
			var strTotalPrice:String = numbPreisInsgesamt.toFixed(2);
			arrTotals[1] = strTotalPrice.replace(".", ",");				
				
			return arrTotals;
		}
		
	   
	   /*******************************************
		* For Bestellung
		* called from OrderController
		* ****************************************/
	   
	   //Called by ordercontroller, used to only save fotos with orders
	   //it collects all imgPos that have orders, then OrderController finds the origfilenames for those 
	   //and hands them to main
	   public function getFotos_withOrders():Array  
	   {
		   arrFotos_with_orders = [];
		   
		   //find out, which fotos have orders
		   for (var imgPos:int = 0; imgPos < arrFotoOrdersModels_for_all_photos.length; imgPos++)
		    {
				//check, if there is a photo in this spot...
				if (arrFotoOrdersModels_for_all_photos[imgPos]!=null)
				{
					if (arrFotoOrdersModels_for_all_photos[imgPos].iTotalQtyOrdered > 0)
					{					
						arrFotos_with_orders.push(imgPos);					
					}
				}
		    }
		   return arrFotos_with_orders;
	   }
		   
	   //the orders are sorted by Motiv.
	    //used in Bestellung, called from orderController and for WarenkorbUbersicht
	    public function getMotivOrders():Array
	   {
		   var arrOrderedMotivOrders:Array = []; 		
		  // var dpi:Number = 0;
		   
			 //go through all products
			for each (var objMotivModel:MotivModel in _dictMotive) 
			{	
		
				if ((objMotivModel.arrMotivorders !=null) &&(objMotivModel.arrMotivorders.length > 0))
				{						
					//if there is a suborder, add 1. Each suborder is only for 1.
					for (var i:int =0; i< objMotivModel.arrMotivorders.length; ++i)
					{		
						if (objMotivModel.arrMotivorders[i] != null)
						{
							arrOrderedMotivOrders.push(objMotivModel.arrMotivorders[i]); 
						}
					}			
				}//end if
		    }//end for each 
		   return arrOrderedMotivOrders;
	   } 
	  		 
	   /***************************************************************************
		* functions called from fotoView, which call orderView to update
		* ************************************************************************/
	   
	   //when the user clicks chooses a photo, notify the View - it needs to refresh and show all corresponding suborders
	    public function addHighlight(numImgPos:uint):void
	   {
		   _arrHighlighted.push(numImgPos);		  		   
		   //return _arrHighlighted.length;
	   }
	   
	   public function removeHighlight(numImgPos:int):void
	   {
		   for (var i:int = 0; i < _arrHighlighted.length; i++)
		   {
			  if (_arrHighlighted[i] === numImgPos)
			  {
				this._arrHighlighted.splice(i, 1); 
			  }
		   } 
	   }
	   
	   //creates a new FotoOrderModel, it´s called from Fotoview, gives origW and origH
	   public function addFoto(imgPos:int, arrFotoModelData:Array):FotoOrdersModel
	   {
		   arrFotoModel[imgPos] = arrFotoModelData; //the important data about a photo
		  // testTextField.appendText("addedFoto w:" + arrFotoModelData[0] + " h:" + arrFotoModelData[1]+"\n");
		   //they are in the order they are in scrollbox.
			var allOrders_for_thisPhoto:FotoOrdersModel = new FotoOrdersModel();
			arrFotoOrdersModels_for_all_photos[imgPos] = allOrders_for_thisPhoto;	
			return allOrders_for_thisPhoto;
	   }
	   
	   //deletes a FotoOrderModel with all its SubOrders, if a foto couldn´t get saved to the server
	    public function deleteFoto(imgPos:int):String
	   {
		   var objSuborder:SubOrder = new SubOrder();
		   var objMotivOrder:MotivOrder = new MotivOrder();
			//go through all products
			for each (var objMotivModel:MotivModel in _dictMotive) 
			{// iterates through each value		
				
				//has to check, if there is an order in each slot of the arrMotivorders, since they will be able
				//to cancel an order, and since it stores the position, I can only set it to null, not splice() it out
				if ((objMotivModel.arrMotivorders !=null) &&(objMotivModel.arrMotivorders.length > 0))
				{	
					for (var i:int = 0; i <  objMotivModel.arrMotivorders.length; ++i)
					{
						if (objMotivModel.arrMotivorders[i] != null)
						{
							//if there is a suborder, with the deleted foto, remove it.										
							objMotivOrder = objMotivModel.arrMotivorders[i]; 
							//reduce the count for the imgs in the order
							var arrOrder:Array = objMotivOrder.arrOrder;
							
							for (var k:int = 0; k < arrOrder.length; ++k)
							{
								if (arrOrder[k] != null)
								{
									objSuborder = arrOrder[k];
									if (objSuborder.imgPos ==imgPos)
									{
									//testTextField.appendText("remove order for Foto # " + i);
									arrFotoOrdersModels_for_all_photos[imgPos].removeSubOrder(1);			
									}	
									//destroy the former order 
									objSuborder = null;
									objMotivOrder.arrOrder[k] = null;
								}
							}
							
								
						}//end if
					}
				}		
		
			}
			arrFotoOrdersModels_for_all_photos[imgPos] = null;		 
		 
		  this.notifyView();	
		   return "a";
	   } 
	   
	   	public function get blnAllHighlighted ():Boolean
		{
			return _blnAllHighlighted;
		}
		
		public function set blnAllHighlighted( value:Boolean):void 
		{			
			_blnAllHighlighted = value;				
		}
		
		public function notifyView():void
		{
			super.notifyChanges();
		}		
		
		/***************************************************************************
		* utility functions
		* ************************************************************************/
	
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
		
			
		public function parseXML(motiveserien:XMLList):void
		{ 	
			_arrSerien = [];		
			
			_dictMotive = new Dictionary();	
			_dictMaterial = new Dictionary(true);
			_arrBilderAnzahl = [];
			
				var anzahlSerien:int = motiveserien.length();
				for (var s:int = 0; s < anzahlSerien; ++ s)
				{
					var motivSerie:XML = motiveserien[s];
			
					var strSerie:String = motivSerie.SerienName;
					_arrSerien.push(strSerie);
				
					var motive:XMLList = motivSerie.rahmen;
					var anzahlMotive:int = motive.length();						
					var strMotiv:String = "";			
					//var numbFormate:int = 0;
					
					for (var zahl:int = 0; zahl < anzahlMotive; ++zahl)
					{	
						var motiv:XML = new XML();	
						var objMotivModel:MotivModel = new MotivModel();
						var Ausschnitte:XMLList = new XMLList();			
						var xmlBildausschnitt:XML = new XML();
						var dpi:Number = 72;
						
						motiv = motive[zahl];
						objMotivModel.strSerie = strSerie;
						
						//testTextField.appendText (motiv.@name + " " + motiv.@lieferzeit + "\n");
						strMotiv = objMotivModel.motivID = motiv.@Artikelnummer + "_" + motiv.@orientation;
						objMotivModel.Motivname = motiv.@Motivname;
						
						//Farbe="schwarz" Material="Metal" Bilder= "2" Passpartout= "ecru" Artikelnummer="83" Preis
						
						objMotivModel.Farbe = motiv.@Farbe;	
						objMotivModel.Material = motiv.@Material;	
						objMotivModel.Materialname = objMotivModel.Material + "rahmen";					
						_dictMaterial[objMotivModel.Materialname] = objMotivModel.Materialname;						
						
						//get all the options of how many Fotos a Rahmen can have - each one once
						objMotivModel.intBilder = motiv.@Bilder;
						if (motiv.@Bilder =="1")
						{
							objMotivModel.strBilder = "für " + motiv.@Bilder + " Foto";	
						}else {
							objMotivModel.strBilder = "für " + motiv.@Bilder + " Fotos";	
						}
						_arrBilderAnzahl[motiv.@Bilder] = objMotivModel.strBilder;	
						
						objMotivModel.Passpartout = motiv.@Passpartout;		
						objMotivModel.Artikelnummer = motiv.@Artikelnummer;				
						var strPreis:String = motiv.@Preis;
						objMotivModel.nmbPrice = Number(strPreis.replace(",", "."));
						
						//size for the whole produktionsbild
						objMotivModel.passpartoutBreite_in_mm = motiv.@passpartoutBreite_in_mm;
						objMotivModel.passpartoutHoehe_in_mm = motiv.@passpartoutHoehe_in_mm;
						
						//for bestellung
						objMotivModel.passpartoutW_in_pxl = Math.round(objMotivModel.passpartoutBreite_in_mm / 10 / 2.54 * 300);
						objMotivModel.passpartoutH_in_pxl = Math.round(objMotivModel.passpartoutHoehe_in_mm / 10 / 2.54 * 300);
						
						objMotivModel.motivpath = motiv.@path;			
						
						//size of the motiv buttons in the scrollbox
						objMotivModel.smRahmenWidth_in_pxl = motiv.@smRahmenWidth_in_pxl;
						objMotivModel.smRahmenHeight_in_pxl = motiv.@smRahmenHeight_in_pxl;
						
						//size of the .jpg for the motiv in the center of flash
						objMotivModel.rahmenWidth_in_pxl = motiv.@rahmenWidth_in_pxl;
						objMotivModel.rahmenHeight_in_pxl = motiv.@rahmenHeight_in_pxl;
						
						if (motiv.@infoscreen != "")
						{
							objMotivModel.infoscreen = "rahmen/infoscreens/" + motiv.@infoscreen;
						}
						
					try {	
						/******************Calculations for the whole passpartout*******/
						//the thickness of the frame
						var plusW_in_cm:Number = Number(motiv.@halbeBreite_PLUS_in_mm) / 10;
						var plusH_in_cm:Number = Number(motiv.@halbeHoehe_PLUS_in_mm) / 10;	
						//all the sizes in the .xml file don´t include the frame. Since the .jpg has the frame, this adds the frame size
						var plusW:Number = plusW_in_cm / 2.54 * dpi;
						var plusH:Number = plusH_in_cm / 2.54 * dpi;
						
						var totalWidth_in_cm:Number = objMotivModel.passpartoutBreite_in_mm / 10 + (2 * plusW_in_cm);
						var actualWidth_in_pxl:Number = Math.round(totalWidth_in_cm / 2.54 * dpi); 
						
						var ratio:Number = motiv.@rahmenWidth_in_pxl / actualWidth_in_pxl;
						//trying to reduce the number of calculations for more accuracy
						//var ratio:Number = motiv.@rahmenWidth_in_pxl/(motiv.@passpartoutBreite_in_mm + motiv.@halbeBreite_PLUS_in_mm) / 25.4 * dpi;
						
						//Was außerhalb des passpartouts noch dazu kommt - es ist != die Rahmendicke und muß daher von den
						//factory Maßen errechnet werden.
						objMotivModel.halbeBreite_PLUS_in_pxl = Math.round(plusW * ratio);
						objMotivModel.halbeHoehe_PLUS_in_pxl = Math.round(plusH * ratio);	
						
							//testTextField.appendText("ratio" + ratio + " halbeBreite_PLUS_in_pxl:" + objMotivModel.halbeBreite_PLUS_in_pxl);
						
						objMotivModel.Preis = motiv.@Preis + " €";									
						Ausschnitte = motiv.Bildausschnitt;					
						
						var length:int = Ausschnitte.length();			
				
						for (var i:int = 0; i < length; ++i)
						{						
							xmlBildausschnitt = Ausschnitte[i];	
							
						//testTextField.appendText("LIST of " + formateList.length() + ": " + formateList.toString() +  "\n");						
													
							//load the data for the Model	
							var objBildAusschnitt:BildModel = new BildModel();	
							var imgX:String = xmlBildausschnitt.@imgX;
							imgX = imgX.replace(",", ".");
							var imgY:String = xmlBildausschnitt.@imgY;
							imgY = imgY.replace(",", ".");	
							var imgX_cm:Number = Number(imgX) / 10;
							var imgY_cm:Number = Number(imgY) / 10;						
											
							objBildAusschnitt.Breite_in_mm = Number(String(xmlBildausschnitt.@imgWidth).replace(",", "."));							
							objBildAusschnitt.Hoehe_in_mm = Number(String(xmlBildausschnitt.@imgHeight).replace(",", "."));
							
							//used in the workarea only
							objBildAusschnitt.posX = Math.round(imgX_cm / 2.54 * dpi * ratio);
							objBildAusschnitt.posY = Math.round(imgY_cm / 2.54 * dpi * ratio);
							
							//the size of the Ausschnitt in the Rahmen in the middle of Flash
							objBildAusschnitt.pixelBreit = Math.round(objBildAusschnitt.Breite_in_mm/ 10 /  2.54 * dpi * ratio);
							objBildAusschnitt.pixelHoch = Math.round(objBildAusschnitt.Hoehe_in_mm / 10 / 2.54 * dpi * ratio);	
								//testTextField.appendText("\nbreitmm:" + objBildAusschnitt.Breite_in_mm + " breitpx: "	+ objBildAusschnitt.pixelBreit + "hochmm:" + objBildAusschnitt.Hoehe_in_mm + " hochpx: "	+ objBildAusschnitt.pixelHoch);
							//actual width at 300dpi for the produktionsbilder
							var edge_in_pixel:int = 59;
							objBildAusschnitt.topleftX = Math.round(imgX_cm / 2.54 * 300) - edge_in_pixel; 
							objBildAusschnitt.topleftY = Math.round(imgY_cm / 2.54 * 300) - edge_in_pixel;
							//the 94px at 300dpi are 2 * 4mm for the edge, so there won´t be a white line showing, if the passpartout slides
							objBildAusschnitt.finalW = Math.round(objBildAusschnitt.Breite_in_mm/ 10 /  2.54 * 300 + 2 * edge_in_pixel); 
							objBildAusschnitt.finalH = Math.round(objBildAusschnitt.Hoehe_in_mm / 10 / 2.54 * 300 + 2 * edge_in_pixel);	
								//testTextField.appendText("finalW: " + objBildAusschnitt.finalW + "finalH:" + objBildAusschnitt.finalH);
							
							objMotivModel.arrBilder.push(objBildAusschnitt);							
											
						} //end of for Ausschnitte							
									
						_dictMotive[strMotiv] = objMotivModel;
						
						if ((motiv.@default == "y") && (!_currentMotiv))
						{				
							_currentMotiv= new MotivModel();
							_currentMotiv = objMotivModel;	
							objMotivModel.intCurrOrder = 0;  //the first order for this motiv
						}	
						} catch (e:TypeError) {
							//testTextField.appendText("Could not parse the XML.");  
						} //end try 
					}//end for motivSerie 	
				}//end for serien
				
			//take out any empty slots, but leave 0 for ALL
			for (var b:int = 1; b < _arrBilderAnzahl.length; ++b)
			{
				if (_arrBilderAnzahl[b] == null)
				_arrBilderAnzahl.splice(b, 1);
			}
				
			_blnFormateReady = true; 
			this.notifyView();
		}
		
		public function get limit ():int
		{
			return _limit;
		}
		
		//set from main - in this case it´s 100
		public function set limit( value:int ):void 
		{			
			_limit = value;		
		}
		
		public function get blnFormateReady ():Boolean
		{
			return _blnFormateReady;
		}
		
		public function set blnFormateReady( value:Boolean ):void 
		{			
			_blnFormateReady = value;		
		}
		
		public function get currentMotiv():MotivModel
		{
			return _currentMotiv;
		}
		
		//called from OrderView
		public function setCurrentMotiv(strMotiv:String):void
		{	
			_strCurrentMotiv = strMotiv;
			_currentMotiv = _dictMotive[strMotiv];			
	
			_currentMotiv.intCurrOrder = _currentMotiv.arrMotivorders.length;
		//	_objCurrMotivOrder = new MotivOrder();
		
				//testTextField.appendText("switched motiv intCurrentOrder= " + _currentMotiv.intCurrOrder);
		}
		
		//called, when Kunde clicks on Edit in Warenkorbubersicht
		public function setOrderToEdit(objMotivOrder:MotivOrder):void
		{
			//7.2.2011 From now on, the order gets deleted first. If the customer decides, he wants it, he has to click on
			//plus Warenkorb again.		
			
			//set it to current, since it is current - the current will be changed, if they switch, the edit will not
			//be changed, until they order
		//testTextField.appendText("setCurrentOrder:" + objMotivOrder.Motivname);
			_strCurrentMotiv = objMotivOrder.motivID;
			_currentMotiv = _dictMotive[_strCurrentMotiv];
			_currentMotiv.intCurrOrder = objMotivOrder.intArrayPosition;
		//testTextField.appendText("setCurrentOrder:" + objMotivOrder.intArrayPosition);
			_objCurrMotivOrder = objMotivOrder;
			
			deleteMotivOrder(objMotivOrder);
				//testTextField.appendText(" deleted ");
		}
		
		public function get dictMotive():Dictionary
		{
			return _dictMotive;
		}		
		
		public function get arrSerien():Array
		{
			return _arrSerien;
		}
		
		public function get dictMaterial():Dictionary
		{
			return _dictMaterial;
		}
		
		public function get arrBilderAnzahl():Array
		{
			return _arrBilderAnzahl;
		}
		
		public function get intSavedFotosSuccessfully ():int
		{
			return _intSavedFotosSuccessfully;
		}
		
		//set from main - in this case it´s 100
		public function set intSavedFotosSuccessfully( value:int ):void 
		{			
			_intSavedFotosSuccessfully = value;	
			this.notifyView();
		}
    }
 }
