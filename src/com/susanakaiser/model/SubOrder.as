/**
 * Copyright (c) 2010 Guesken, Krefeld
 * Actionscript 3 für Flash 10 Susanne Kaiser 2010
 *
 * This class holds 1 suborder for 1 Foto. The Foto holds the order.
 * All the Fotos are in an array in main, therefore accessible to go through and add up all the orders for the Bestellung.
 */
 package com.susanakaiser.model  
 {
	 
   public class SubOrder //extends MovieClip
   {
	  //about Rahmen
	  public var strMotiv:String = "";
	  public var intArrayPosition:int = -1; //first order, second order for specific Product  
	  public var intAusschnittPosition:int = -1; //
	  public var imgPos:int = -1; //the foto position in the thumbnails raster.
	  public var preis:String = "0.00";
	  public var blnChosen:Boolean = false;
	  
	 
	 //in ImageMagick fotoRotation has to happen before crop and resize
	  public var fotoRotation:int = 0;
	  //in ImageMagick frameRotation has to happen after fotoRotation, crop and resize and before making the Produktionsbild.
	  public var frameRotation:int = 0;
	  
	  //----for ImageMagick----
	  public var realX:Number = -1;
	  public var realY:Number = -1;	
	  //the width and height that need to be cut out from the origW and origH (before resizing)
	  public var cropW:Number = -1;
	  public var cropH:Number = -1;
	 
	  //after cropping and resizing - pixel size of actual format
	  public var finalW:Number = 0;
	  public var finalH:Number = 0;
	  
	  //FOR PRODUKTIONSBILD - INCLUDES EDGE		  
	  //for positioning Ausschnitt in produktionsbild for image magick
	  public var topleftX:int = 0;
	  public var topleftY:int = 0;
	  
	  
	  //--for showing Ausschnitt in Flash (for reediting foto)-----
	  public var flashX:Number = -1;
	  public var flashY:Number = -1;
	  public var newFormatW:Number = -1;
	  public var newFormatH:Number = -1;
	  
	   //--for showing Ausschnitt in big Rahmen in Flash-----
	  public var showX:Number = -1;
	  public var showY:Number = -1;
	  public var showW:Number = -1;
	  public var showH:Number = -1;
	  
	  //snapshot of Ausschnitt for use in Flash
	//  public var bmp:Bitmap;
	   
       function SubOrder():void 
	   {
	   }
	   
	   public function addOrder(iPos:int, sProd:String):void  
	   {
		   this.imgPos = iPos;
		   this.strMotiv = sProd;		  
	   }
    }
 }
