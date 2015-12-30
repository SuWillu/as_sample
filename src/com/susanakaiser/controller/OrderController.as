/*****************************************************
 * Copyright (c) 2010 Guesken, Krefeld
 * Actionscript 3 für Flash 10 Susanne Kaiser 2010
 *
 * This class separates OrderView from OrderModel.
 ****************************************************/ 
package com.susanakaiser.controller
{	
	import com.susanakaiser.model.OrderModel;
	import com.susanakaiser.model.SubOrder;
	import com.susanakaiser.view.FotoView;
	import flash.display.DisplayObject;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.navigateToURL;
	import flash.events.*;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	//for Bestellung
	import com.susanakaiser.model.Snapshot;	
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;	
	import flash.net.URLLoaderDataFormat;
	import flash.net.navigateToURL;
	//import com.susanakaiser.model.FotoFormat;
	import flash.utils.Dictionary; 
	import Main;
	
	import com.susanakaiser.model.MotivModel;
	import com.susanakaiser.model.MotivOrder;	
	
	//for testing
	import flash.display.*;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
    public class OrderController extends MovieClip
    {
		private var model:Object;
		
		//-----------For Bestellung------------
		private var _sessionID:String;
		private var _WKPos:String;
		//the user´s folder, where everything for that session is stored
		private var strFolder:String;
		//filename of the preview screenshot
		private var strPreviewname:String;
		private var snapshot:Snapshot;	
		private var arrFotos:Array; //fotoviews ordered by position in scrollbox, given by main
		private var arrFotoswithorders:Array = []; //only the fotoviews, which have orders at the time of bestellen
			//the xml text for the file to reload the user´s choices
		private var xmlSettings:String;
		//the xml for the Bestellung minus the produktionsbilder
		private var xmlOrder:String;
		private var xmlSendLoad:URLLoader;
		private var xmlLoader:URLLoader;
		
		private var _strFlashversion:String = "";
		private var _main:Main;	
		
		//private var _arrFotos_not_saved:Array = [];
		private var _strFotos_not_saved:String = ""
		
		//to allow for using more than 1 .xml file as input
		private var _paket:String = "1";
		
		//private var testTextField:TextField;
		
        public function OrderController(main:Main, model:Object, arrFotosInScrollbox:Array, paket:String):void
        {
			this.model = model;	
			arrFotos = arrFotosInScrollbox;
			_main = main;
			_paket = paket;
			init();	
			
			
		/*	//FOR TESTING ONLY
			testTextField = new TextField();
			testTextField.x = 300;
			testTextField.y = 10;
			testTextField.background = true;
			testTextField.backgroundColor = 0xed223a;
			testTextField.autoSize = TextFieldAutoSize.LEFT;
			testTextField.multiline = true;			
			testTextField.text= "testing controller";
			addChild(testTextField);	*/
		}	
		
		private function init():void
		{
			//Load the templates XML file
			xmlLoader =new URLLoader();
			//assign the Complete loading event
			xmlLoader.addEventListener(Event.COMPLETE, parseXML, false, 0, true);
			xmlLoader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler, false, 0, true);
			
			 try {
                //load the file
				//Modified 2012/Jan/06
				//xmlLoader.load(new URLRequest("rahmen/rahmen.xml"));				
				var urlF:String = "rahmen/rahmen" + String(_paket) + ".xml";
				xmlLoader.load(new URLRequest(urlF));	
            }
            catch (error:SecurityError)
            {
               //  testTextField.appendText("OrderController - SecurityError:"+error);
            }
		}
		
		private function ioErrorHandler( e:IOErrorEvent ):void
		{
			// testTextField.appendText( "OrderController - Error: " + e );
		} 
		
		//parses motivrahmen.xml and turns them over to ordermodel
		private function parseXML(e:Event):void {
			xmlLoader.removeEventListener(Event.COMPLETE, parseXML);
			xmlLoader.removeEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			
			  try {
                   	//generate the xml object
					var xml:XML = new XML(e.target.data); 	
					
					//ignore the white spaces
					xml.ignoreWhitespace=true;
					//generate the xmlList object
					var xmlProdukteList:XMLList = xml.rahmenmotive.motivserie;
					//this.model.parseXML(xmlProdukteList);
                } catch (e:TypeError) {
                   // testTextField.appendText("Could not parse the Format XML file.");
                }	
			xmlLoader = null;
		}
	
		/***********************************************************
		 * functions called by orderView
		 * ********************************************************/		
				
		 public function addSubOrder(objSuborder:SubOrder):String
		{
			var response:String = "none"; 			
			response = this.model.addSubOrder(objSuborder);			
			return response;
		}
		
		public function addOrder(bmp:Bitmap):void
		{
			this.model.confirmMotivOrder(bmp);
		}
		
		public function setOrderToEdit(objMotivOrder:MotivOrder):void
		{
			this.model.setOrderToEdit(objMotivOrder);
		}
		
		public function deleteMotivOrder(objMotivOrder:MotivOrder):void {
			this.model.deleteMotivOrder(objMotivOrder);
		} 
		
		public function cancelAll():void {
			this.model.cancelAll();
		}
		
		public function getOrders():Array
		{ 
		//-----------------to get orders by Motiv-----------------------
			var arrMotivOrders:Array = [];
			arrMotivOrders = model.getMotivOrders();
			
			return arrMotivOrders;
		} 
		
		public function getFotos_forOrder(arrImgPos:Array):Array
		{
			var arrFotoviews:Array = [];
			for (var i:int = 0; i < arrImgPos.length; ++i)
			{
				//they may not have an Ausschnitt filled
				if ((arrImgPos[i]!=null) && (arrImgPos[i] > -1))
				{
					//copy Fotoview
					var photo:FotoView = new FotoView();
					photo = arrFotos[arrImgPos[i]] as FotoView;
					
					try{
						var myBitmapData:BitmapData = new BitmapData(photo.bmp.width, photo.bmp.height);
					}catch (e:ArgumentError)
					{
						//testTextField.appendText("dragPhoto ArgumentError");
					}
					
					var bounds: Rectangle = photo.getBounds(photo.bmp);	
					//testTextField.appendText("firstx:" + bounds.x+" y:"+ bounds.y);
					// create translation matrix
					var matrix: Matrix = new Matrix();
					matrix.translate(-bounds.x, -bounds.y);
					// make copy
					myBitmapData.draw(photo.bmp, matrix); 		
					
					var copyOfFoto:FotoView = new FotoView();
					copyOfFoto.name = photo.name;
					copyOfFoto.iPos = photo.iPos;
					copyOfFoto.origWidth = photo.origWidth;
					copyOfFoto.origHeight = photo.origHeight;
					copyOfFoto.resizeFactor = photo.resizeFactor;
					copyOfFoto.imageData = myBitmapData;	
					arrFotoviews[i] = copyOfFoto;
				}
			}
			return arrFotoviews;
		}
		
		/***************************************************************************
		* functions related to Bestellung
		* ************************************************************************/
		
		public function savePhotos():void  
		{
				var arrImgPos_WithOrders:Array = model.getFotos_withOrders();
				var arrOrigNames_fotoswithorders:Array = [];
				for (var i:int = 0; i < arrImgPos_WithOrders.length; ++i)
				{
					arrOrigNames_fotoswithorders.push (arrFotos[arrImgPos_WithOrders[i]].origFileName);
					//for Bestellung .xml
					arrFotoswithorders.push (arrFotos[arrImgPos_WithOrders[i]]);
				}
				//have to call saveImages, so it´ll complete			
				_main.saveImages(arrOrigNames_fotoswithorders);
		}
		
		public function checkSavedFotos():void
		{
			var querystring:String = "";
			for (var i:int = 0; i < arrFotoswithorders.length; ++i)
			{
				querystring = querystring + "|" + arrFotoswithorders[i].filePath;
			}
			
			var variables:URLVariables = new URLVariables();
			variables.querystring = querystring;
				//testTextField.appendText(querystring + "\n");
			this.sendData_checkFotos("checkImages.php", variables);
		}
		
		public function sendData_checkFotos(url:String, _vars:URLVariables):void 
		{
			var request:URLRequest = new URLRequest(url);
			var loader:URLLoader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.VARIABLES;
		
			request.data = _vars;
			request.method = URLRequestMethod.POST;
			loader.addEventListener(Event.COMPLETE, handleComplete_checkFotos);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onIOError_checkFotos);	
			loader.load(request);	
		}
		
		private function handleComplete_checkFotos(event:Event):void 
		{	
			var loader:URLLoader = URLLoader(event.target);
				//testTextField.appendText(loader.data.error);
			if (loader.data.error == 0)
			{
				//continue with bestellen
				model.intSavedFotosSuccessfully = 1;
					//testTextField.appendText("success");
			}else if (loader.data.errorfiles)
			{					
				var arrResults:Array = loader.data.errorfiles.split("|");
				var tmpfile:String = "";
				for (var k:int = 0; k < arrResults.length; ++k)
				{	
					tmpfile = arrResults[k];				
						//testTextField.appendText("tmpfile:" + tmpfile);
					if (tmpfile != "")
					{
						// find the errored files in the array, delete them from scrollbox and orders.
						for (var i:int = 0; i < arrFotoswithorders.length; ++i)
						{				
							if (arrFotoswithorders[i].filePath === tmpfile)
							{
									//testTextField.appendText("tmpfile:" + tmpfile + "i:" + 2);
								//_arrFotos_not_saved.push(FotoView(arrFotoswithorders[i]).origFileName);
								if (k == 0)
								{
									_strFotos_not_saved = (FotoView(arrFotoswithorders[i]).origFileName);
								}else{
									_strFotos_not_saved = _strFotos_not_saved + ", " + (FotoView(arrFotoswithorders[i]).origFileName);
								}
								//delete foto from scrollbox and orders
								_main.deleteFoto_not_saved(arrFotoswithorders[i]);
								arrFotoswithorders.splice(i, 1); 
							} 
						} 
					}
				}
				//get the error msg from the php file, so it can easily be changed by Güsken
				_strFotos_not_saved = loader.data.error + _strFotos_not_saved;
				model.intSavedFotosSuccessfully = 0;				
			}		
		}
		
		private function onIOError_checkFotos(event:IOErrorEvent):void 
		{
			//trace("Error loading URL.");
		}
		
		public function bestellen():Array
		{		
			//-----------------to get orders by Motiv-----------------------
			var arrMotivOrders:Array = [];
			arrMotivOrders = model.getMotivOrders();	
		
			if ((arrMotivOrders != null) && (arrMotivOrders.length > 0))
			{
				createSettingsXML(arrMotivOrders);
			}
			
			return arrMotivOrders;
		}
		
		//creates the thumbnails
		private function createSnapshot(motivOrder:MotivOrder):String
		{
			var strServerpath:String;
			var strFiletype:String;			
			strServerpath = "";
			strFolder = "tmp/" +this._sessionID+"_"+this._WKPos;
			strPreviewname = strFolder+"/sp";
			strPreviewname = getUniqueFileName(strPreviewname);
			strFiletype = ".jpg";			
			snapshot = new Snapshot(MovieClip(motivOrder), strServerpath, strPreviewname, strFiletype, strFolder );				
			var strResult:String;
			strResult = snapshot.saveSnapshot();
			return strPreviewname + strFiletype;
		}
		
		private function createSettingsXML(arrMotivOrders:Array):void
		{
			var xmlStart:String = "";
			//save all data in settings.xml, in case the kunde wants to come back and edit the foto order		
			xmlStart= "<?xml version='1.0' encoding='utf-8'?>\n";
			xmlStart = xmlStart + "<artido-order>\n<stats flashversion='" + _strFlashversion + "' />";						
			var xmlItems:String = "";
			var xmlThumb:String = "";	
			var xmlOrigBild:String = "";
			var strPreview:String = "";
			
			//for reloading the fotos, if Kunde comes back
			xmlItems = xmlItems + "<Fotos_byImgPos>";
			var foto:FotoView = new FotoView();
			for (var k:int = 0; k < arrFotoswithorders.length; ++k)
			{
				foto = arrFotoswithorders[k];							
				
				if (!foto.filePath == "")						
				{
					xmlItems = xmlItems + "<foto origName='" + foto.origFileName + "' origWidth='" + foto.origWidth;
					xmlItems = xmlItems + "' origHeight='" + foto.origHeight + "' >";
					xmlItems = xmlItems +  foto.filePath;
					xmlItems = xmlItems + "</foto>\n";
				}					
			}
			xmlItems = xmlItems + "</Fotos_byImgPos>";		
						
			for (var i:int = 0; i < arrMotivOrders.length; ++i )
			{	
				var objMotivOrder:MotivOrder = arrMotivOrders[i];
				//var arrFormat:Array = arrMotivOrders[i];
				var arrOrders:Array =  objMotivOrder.arrOrder;
				
				xmlItems = xmlItems + "<item>\n";
				//Total number of pictures per format
				xmlItems = xmlItems + "<menge>1</menge>\n";
				
				xmlItems = xmlItems + "<artikel-nr>galerierahmen</artikel-nr>\n";				
			
				xmlItems = xmlItems + "<Format type='" + objMotivOrder.Artikelnummer + "' dpi='300' breite_cm='" + (objMotivOrder.passpartoutBreite_in_mm/10) +"' hoehe_cm='" + (objMotivOrder.passpartoutHoehe_in_mm/10) +"' pixelBreit='";
				xmlItems = xmlItems + objMotivOrder.passpartoutW_in_pxl + "' pixelHoch='"+ objMotivOrder.passpartoutH_in_pxl + "' Preis='"+(objMotivOrder.Preis.replace(" €", "")) + "' >\n ";
				xmlItems = xmlItems + "<beschreibung >galerierahmen " +  objMotivOrder.Motivname + " </beschreibung>\n";
				
				strPreview=createSnapshot(objMotivOrder);	
				xmlThumb = xmlThumb + "<bild width='"+objMotivOrder.bmp.width+"' height='"+objMotivOrder.bmp.height+"' >" + strPreview + "</bild>";
			
				//store all fotos for 1 format at a time				
				for (var j:int = 0; j < objMotivOrder.intBilder; ++j )
				{
					var objSuborder:SubOrder = arrOrders[j];
			
					if (objSuborder!=null)
					{
						var fotoview:FotoView = arrFotos[objSuborder.imgPos];
										
						xmlOrigBild = xmlOrigBild + "<bild passepartout_topleftX='" + objSuborder.topleftX + "' passepartout_topleftY='" + objSuborder.topleftY + "' ";
						xmlOrigBild = xmlOrigBild + "orientation = '" +  objMotivOrder.orientation + "'  ";
						xmlOrigBild = xmlOrigBild + "imgPos = '" + objSuborder.imgPos + "' origName = '" + fotoview.origFileName + "' origWidth = '" + fotoview.origWidth;
						xmlOrigBild = xmlOrigBild + "' origHeight='" + fotoview.origHeight + "'";
						
						xmlOrigBild = xmlOrigBild + " crop='" + String(objSuborder.cropW) + "x" + String(objSuborder.cropH) + "+" + objSuborder.realX + "+" + objSuborder.realY + "' ";
						xmlOrigBild = xmlOrigBild + "resize='" + String(objSuborder.finalW) + "x" + String(objSuborder.finalH) + "' >";  
						if(!fotoview.filePath==""){
							xmlOrigBild = xmlOrigBild + fotoview.filePath; 
						}
						xmlOrigBild = xmlOrigBild + "</bild>\n";
					}else { //??? for testing only
						xmlOrigBild = xmlOrigBild + "<Fehler Meldung='Bild info nicht vorhanden' />";
					}
				} 
				xmlItems = xmlItems + "<thumb>"+xmlThumb+"</thumb>\n";				
				xmlItems = xmlItems + "<produktionsbilder"+ i +"/>\n"; 	
				xmlItems = xmlItems + "<originalbilder passepartout_breite_mm='" + objMotivOrder.passpartoutBreite_in_mm +"' passepartout_hoehe_mm='" + objMotivOrder.passpartoutHoehe_in_mm +"' >";
				xmlItems = xmlItems + xmlOrigBild;	
				xmlItems = xmlItems + "</originalbilder>\n"; 		
				xmlItems = xmlItems + "</Format>\n"; 
				xmlItems = xmlItems + "</item>\n";
				
				xmlThumb = "";
				xmlOrigBild = "";				
			}		
			
			xmlSettings = xmlStart + xmlItems + "</artido-order>";
				//testTextField.appendText(xmlSettings); 
			storeUsersSettings(); 			
		}
		
		private function storeUsersSettings():void
		{	
			//save xml file
			XML.ignoreWhitespace = true;
			try{
			var xmlBestellung:XML = new XML(xmlSettings);
			}catch (e:Error) {
				//testTextField.appendText("error creating xml object" + e.message);
			}
			
			var xmlURLReq:URLRequest = new URLRequest("saveXML.php?SessionID="+this._sessionID+"&WKPos="+this._WKPos);
			xmlURLReq.data = xmlBestellung;
			xmlURLReq.contentType = "text/xml";
			xmlURLReq.method = URLRequestMethod.POST;
			xmlSendLoad = new URLLoader();
			xmlSendLoad.addEventListener(Event.COMPLETE, onCompleteSaveSettings, false, 0, true);
			xmlSendLoad.addEventListener(IOErrorEvent.IO_ERROR, onIOErrorSettings, false, 0, true);			
			xmlSendLoad.load(xmlURLReq);	
		}
		
		private function onIOErrorSettings(evt:IOErrorEvent):void {
			xmlSendLoad.removeEventListener(Event.COMPLETE, onCompleteSaveSettings);
			xmlSendLoad.removeEventListener(IOErrorEvent.IO_ERROR, onIOErrorSettings);			
		}		
		
		private function onCompleteSaveSettings(evt:Event):void {
			try {
				var xmlResponse:XML = new XML(evt.target.data);
				xmlSendLoad.removeEventListener(Event.COMPLETE, onCompleteSaveSettings);
				xmlSendLoad.removeEventListener(IOErrorEvent.IO_ERROR, onIOErrorSettings);					
			
			} catch (err:TypeError) {
				//testTextField.appendText("An error occurred when communicating with server:\n" + err.message);
			}
			//---call calendar.php with sessionid and wkpos---			
			var myRequest:URLRequest = new URLRequest();  
			
			myRequest.url = "http://order.artido.de/manager/tools/bestellannahme-galerierahmen.php?SessionID="+this._sessionID+"&WKPos="+this._WKPos;
			
			try { 
				navigateToURL(myRequest, '_self'); // second argument is target
			} catch (e:Error) {
			  //trace("Error occurred!");
			}	
		}
			
		public function get sessionID():String
		{
			return _sessionID;
		}
		
		public function set sessionID(value:String):void
		{
			_sessionID = value;
		}
		
		public function get WKPos():String
		{
			return _WKPos;
		}
		
		public function set WKPos(value:String):void
		{
			_WKPos = value;
		}
		
		public function get strFlashversion():String
		{
			return _strFlashversion;
		}
		
		public function set strFlashversion(value:String):void
		{
			_strFlashversion = value;
		}
		
			private function getUniqueFileName(fileName:String):String
		{
			var date:Date = new Date();
			return fileName+date.getTime();
		}
		
		public function get strFotos_not_saved():String
		{
			return _strFotos_not_saved;
		}
	}
}