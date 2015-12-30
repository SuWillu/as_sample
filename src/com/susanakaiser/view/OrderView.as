/*****************************************************
 * Copyright (c) 2010 Guesken, Krefeld
 * Actionscript 3 für Flash 10 Susanne Kaiser 2010
 *
 * OrderView holds 1 Foto Menu filled with the default values and the format bilder.
 * OrderView calls model to addSubOrders, when the user drags clicks confirm in the foto editor.
 * OrderView calls model to removeSubOrders, when the user clicks on "löschen/stornieren".
 * 
 * OrderView responds to the update call from OrderModel by calling getSubOrders from Model and 
 * then refreshing all the menus. 
 ****************************************************/ 
package com.susanakaiser.view
{	
	import com.adobe.protocols.dict.Dict;
	import com.susanakaiser.controls.FakePopup;
	import com.susanakaiser.controls.FakePopup_noClose;
	import com.susanakaiser.controls.ScrollBar;
	import com.susanakaiser.controls.SimplePopup;
	import com.stevensacks.preloaders.CircleSlicePreloader;
	import com.susanakaiser.events.PopupEvent;
	import com.susanakaiser.events.ModifyOrderEvent;
	import com.susanakaiser.utils.Menu;
	import com.susanakaiser.utils.SpecialAlertBox;
    import flash.display.*;
    import flash.events.*;
	import flash.filters.BlurFilter;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.*;
	import com.susanakaiser.utils.DropDownMenu;
	import com.susanakaiser.utils.OrderUberblick;
	import com.susanakaiser.view.CustomButton;
	import com.susanakaiser.model.OrderModel;
	import com.susanakaiser.controller.OrderController;	
	import com.susanakaiser.events.DropDownSelectEvent;
	import com.susanakaiser.view.TextMsg;
	import caurina.transitions.*;
	import com.susanakaiser.model.SubOrder;
	import com.susanakaiser.view.Tooltip;	
	import com.susanakaiser.view.LoadedImage;	
	import com.susanakaiser.view.Progressbar;
	import flash.filters.GlowFilter;
	import flash.filters.DropShadowFilter;
	import com.susanakaiser.view.DropdownButton;
	import flash.geom.Rectangle;
	import com.susanakaiser.utils.AlertBox;	
	import flash.net.URLRequest;
	import com.susanakaiser.view.Arrow;
	import flash.utils.Dictionary;
	import com.susanakaiser.events.CancelFormatEvent;	
	import com.susanakaiser.utils.GalerieFotoEditor;	
	import com.susanakaiser.view.AusschnittDropbox;	
	import com.leebrimelow.ui.ScrollBarEvent;
	
	//for galerierahmen
	import com.susanakaiser.model.MotivModel;
	import com.susanakaiser.model.MotivOrder;
	import com.susanakaiser.controls.ScrollBox;
	import com.susanakaiser.model.BildModel;
	
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	
    public class OrderView extends MovieClip
    {	
		private const ALLE_MATERIALIEN:String = "alle Rahmen - alle Materialien";
		private const ALLE_BILDER:String = "alle Rahmen - alle Versionen";
		private var _arrAusschnittBoxes:Array = []; //holds the AusschnittDropboxes	
				
		//private var ds:DropShadowFilter;	
		//says, if all Formate are ready and the load of photos can start
		private var _isLoaded:Boolean;	
		private var _content:OrderUberblick;	
		private var blnShowing:Boolean = false;				
		private var _blnShowView:Boolean = false;
		private var tooltip:Tooltip;		
		
		private var orderModel:Object;
		private var orderController:Object;
		
		private var _blnHasOrdered:Boolean = false;			
		private var _arrCurrMotivOrders:Array = []; //the current orders for wk Ubersicht	
		private var _currObjMotivOrder:MotivOrder;
		private var errorFormat:TextFormat;		
		private var formatTotalcount:TextFormat;
		private var _tfGesamtAnzahl:TextField;
		private var _tfGesamtWarenkorb:TextField;			
		
		//Bestellung
		private var btnSave:CustomButton;
		private var black:Sprite = new Sprite();
		private var progressbar:Progressbar;
		private var files_left_to_save:int = -1;
		private var formatWaiting:TextFormat;
		private var tfWaiting:TextField;
		private var tfMessage:TextField;
		private var fileUploadComplete:Boolean = true;
		public static var LIST_COMPLETE:String = "listComplete";
		public static var PROGRESS:String = "listProgress";
		private var blnFirstOrder:Boolean = true;
		private var imgBestell:LoadedImage;
		private var total:int = 0;
		private var blnGotTotal:Boolean = false;
		private var progressPopup:SimplePopup;
		private var formatDauer:TextFormat;
		private var tfDauer:TextField;
		private var progressCircle:CircleSlicePreloader;
		private var formatBest:TextFormat;
		private var tfBestell:TextField;
		
		private var tfFarbe:TextField;
		private var tfMaterial:TextField;
		private var tfBilder:TextField;		
		private var tfPasspartout:TextField;
		private var tfArtikelnr:TextField;
		private var tfPreis:TextField;		
		private var tfAdd:TextField;
		//private var blnActivated:Boolean = false;		
		
		//variables for fotoeditor
		public var fotoeditor:GalerieFotoEditor;
		private var currentImgPos:int;
		private var _strCurrentProduct:String;		
				
		//variables for Galerie
		private var bgFormat:Sprite;
		private var fValue:TextFormat;
		private var fPreis:TextFormat;
		private var fTotalpreis:TextFormat;
		private var _motiveScrollbox:ScrollBox;		
		private var _scrollbar:ScrollBar;
		
		private var _dictMotive:Dictionary = new Dictionary(true);
		private var _arrChoices:Array;
		
		private var _bilderMenu:Menu; 
		private var _chosenBilderanzahl:String = "alle";
	/*	private var _rahmenDD:DropDownMenu; 
		private var _chosenRahmen:String = "alle";
		private var _passartoutDD:DropDownMenu; 
		private var _chosenPasspartout:String = "alle"; */
		
		private var _materialMenu:Menu;
		private var _strCurrentMaterial:String = "";
		
		private var _arrMotivButtons:Array = [];
		private var _dctMotivButtons:Dictionary;
		private var _square_holder:MovieClip= new MovieClip();
		private var liMotiv:LoadedImage;
		private var currMotiv:MotivModel;
		private var _arrCurrFotos:Array = [];
		
		private var infoPopup:FakePopup_noClose;
		private var imgInfotop:LoadedImage;
		private var infoFormat:TextFormat;		
		private var txtInfotitle:TextField;
		//private var txtInfoprice:TextField;
		private var infoImage:InfoImage;
		
		private var _intMotivsLoaded:int = 0;
		
		//warenkorb ubersicht
		private var ubersichtPopup:SimplePopup;
		private var imgUberblick:LoadedImage;
		private var btnBestell:CustomButton;
		private var btnZurueck:CustomButton;
		private var pWidth:int = 0;
		private var pHeight:int = 0;
		
		public var scrollingErrMsg:HorizontalScrollingText;
		private var sMask:Sprite;
		
	//	public var errorTextField :TextField;

        public function OrderView(model:Object, controller:Object):void 
        {			
			try{
				_blnHasOrdered = false;				
				_arrChoices = [];
				
				this.orderModel = model;
				this.orderController = controller;
				this.orderModel.registerView(this);	
				
				
				/********************
				 * workarea
				 * *****************/
				var bgWidth:int = 480;
						
				 //background
				bgFormat = new Sprite();	
				var bgHeight:int = 520;
				var yPadding:int = 5;	
				bgFormat.graphics.lineStyle(2, 0xd6d6d6)
				bgFormat.graphics.beginFill(0xfefefe);
				bgFormat.graphics.drawRoundRect(0, 0, 350, bgHeight, 10, 10);
				bgFormat.x = 0;
				bgFormat.y = 0;
				var df:DropShadowFilter = new DropShadowFilter(4, 45, 0x000000,0.5,4, 4,1, 1, false,false,false);		
				bgFormat.filters = [df];
				this.addChild(bgFormat);			
				
				var fLabel:TextFormat = new TextFormat("Arial, Helvetica, sans-serif", 10, 0x000000, false);
				fValue = new TextFormat("Arial, Helvetica, sans-serif",11,0x000000,true);
				
				var tfFarbeLbl:TextField = new TextField();
				tfFarbeLbl.background = false;
				tfFarbeLbl.autoSize = TextFieldAutoSize.LEFT;
				tfFarbeLbl.multiline = false;
				tfFarbeLbl.x = 10;
				tfFarbeLbl.y = 50;
				tfFarbeLbl.text = "Farbe: ";	
				try{
					tfFarbeLbl.setTextFormat(fLabel);
				}catch(e:Error){trace("error"+e);}
				this.addChild(tfFarbeLbl);			
				
				tfFarbe = new TextField();
				tfFarbe.background = false;
				tfFarbe.autoSize = TextFieldAutoSize.LEFT;
				tfFarbe.multiline = false;
				tfFarbe.x = tfFarbeLbl.x + 35;
				tfFarbe.y = 50;
				tfFarbe.text = "white";	
				try{
					tfFarbe.setTextFormat(fValue);
				}catch(e:Error){trace("error"+e);}
				this.addChild(tfFarbe);	
				
				var tfMaterialLbl:TextField = new TextField();
				tfMaterialLbl.background = false;
				tfMaterialLbl.autoSize = TextFieldAutoSize.LEFT;
				tfMaterialLbl.multiline = false;
				tfMaterialLbl.x = tfFarbe.x + 50;
				tfMaterialLbl.y = 50;
				tfMaterialLbl.text = "Material: ";	
				try{
					tfMaterialLbl.setTextFormat(fLabel);
				}catch(e:Error){trace("error"+e);}
				this.addChild(tfMaterialLbl);		
					
				tfMaterial = new TextField();
				tfMaterial.background = false;
				tfMaterial.autoSize = TextFieldAutoSize.LEFT;
				tfMaterial.multiline = false;
				tfMaterial.x = tfMaterialLbl.x + 45;
				tfMaterial.y = 50;
				tfMaterial.text = "black";	
				try{
					tfMaterial.setTextFormat(fValue);
				}catch(e:Error){trace("error"+e);}
				this.addChild(tfMaterial);	
				
				var tfBilderLbl:TextField = new TextField();
				tfBilderLbl.background = false;
				tfBilderLbl.autoSize = TextFieldAutoSize.LEFT;
				tfBilderLbl.multiline = false;
				tfBilderLbl.x = tfMaterial.x + 70;
				tfBilderLbl.y = 50;
				tfBilderLbl.text = "Bilder: ";	
				try{
					tfBilderLbl.setTextFormat(fLabel);
				}catch(e:Error){trace("error"+e);}
				this.addChild(tfBilderLbl);	
				
				tfBilder = new TextField();
				tfBilder.background = false;
				tfBilder.autoSize = TextFieldAutoSize.LEFT;
				tfBilder.multiline = false;
				tfBilder.x = tfBilderLbl.x + 35;
				tfBilder.y = 50;
				tfBilder.text = "2";	
				try{
					tfBilder.setTextFormat(fValue);
				}catch(e:Error){trace("error"+e);}
				this.addChild(tfBilder);	
				
				var tfPasspartoutLbl:TextField = new TextField();
				tfPasspartoutLbl.background = false;
				tfPasspartoutLbl.autoSize = TextFieldAutoSize.LEFT;
				tfPasspartoutLbl.multiline = false;
				tfPasspartoutLbl.x = tfBilder.x + 10;
				tfPasspartoutLbl.y = 50;
				tfPasspartoutLbl.text = "Passpartout: ";	
				try{
					tfPasspartoutLbl.setTextFormat(fLabel);
				}catch(e:Error){trace("error"+e);}
				this.addChild(tfPasspartoutLbl);
					
				tfPasspartout = new TextField();
				tfPasspartout.background = false;
				tfPasspartout.autoSize = TextFieldAutoSize.LEFT;
				tfPasspartout.multiline = false;
				tfPasspartout.x = tfPasspartoutLbl.x + 60;
				tfPasspartout.y = 50;
				tfPasspartout.text = "white";	
				try{
					tfPasspartout.setTextFormat(fValue);
				}catch(e:Error){trace("error"+e);}
				this.addChild(tfPasspartout);	
				
				this.addChild(_square_holder);			
				
				var tfArtikelnrLbl:TextField = new TextField();
				tfArtikelnrLbl.background = false;
				tfArtikelnrLbl.autoSize = TextFieldAutoSize.LEFT;
				tfArtikelnrLbl.multiline = false;
				tfArtikelnrLbl.x = tfFarbeLbl.x;
				tfArtikelnrLbl.y = 470;
				tfArtikelnrLbl.text = "Artikelnummer: ";	
				try{
					tfArtikelnrLbl.setTextFormat(fLabel);
				}catch(e:Error){trace("error"+e);}
				this.addChild(tfArtikelnrLbl);	
				
					tfArtikelnr = new TextField();
				tfArtikelnr.background = false;
				tfArtikelnr.autoSize = TextFieldAutoSize.LEFT;
				tfArtikelnr.multiline = false;
				tfArtikelnr.x = tfArtikelnrLbl.x + 75;
				tfArtikelnr.y = 470;
				tfArtikelnr.text = "123456 ";	
				try{
					tfArtikelnr.setTextFormat(fValue);
				}catch(e:Error){trace("error"+e);}
				this.addChild(tfArtikelnr);	
				
				var tfPreisLbl:TextField = new TextField();
				tfPreisLbl.background = false;
				tfPreisLbl.autoSize = TextFieldAutoSize.LEFT;
				tfPreisLbl.multiline = false;
				tfPreisLbl.x = tfArtikelnr.x + 55;
				tfPreisLbl.y = 470;
				tfPreisLbl.text = "Preis: ";	
				try{
					tfPreisLbl.setTextFormat(fLabel);
				}catch(e:Error){trace("error"+e);}
				this.addChild(tfPreisLbl);	
				
				fPreis = new TextFormat("Arial, Helvetica, sans-serif",18,0x000000,true);
				tfPreis = new TextField();
				tfPreis.background = false;
				tfPreis.autoSize = TextFieldAutoSize.LEFT;
				tfPreis.multiline = false;
				tfPreis.x = tfPreisLbl.x + 30;
				tfPreis.y = 465;
				tfPreis.text = "Preis: ";	
				try{
					tfPreis.setTextFormat(fPreis);
				}catch(e:Error){trace("error"+e);}
				this.addChild(tfPreis);					
				
				
				
				//-----------Add to order button-------						
				var addW:Number=47;
				var addH:Number = 44;			
				var strAddUrl:String = "images/addWK.png";				
				var btnAdd_to_wk:CustomButton = new CustomButton(strAddUrl, addW, addH);
				btnAdd_to_wk.x = tfPreis.x + 55;
				btnAdd_to_wk.y = 460;
				btnAdd_to_wk.mouseChildren=false;
				btnAdd_to_wk.buttonMode = true;
				btnAdd_to_wk.useHandCursor = true;			
				addChild(btnAdd_to_wk);
				btnAdd_to_wk.addEventListener(MouseEvent.CLICK, addClicked);  
				
				tfAdd = new TextField();
				tfAdd.background = false;
				tfAdd.autoSize = TextFieldAutoSize.LEFT;
				tfAdd.multiline = true;
				tfAdd.wordWrap = true;
				tfAdd.width = 100;
				tfAdd.x = 270;
				tfAdd.y = 470;
				tfAdd.text = "Zum Warenkorb hinzufügen";	
				try{
					tfAdd.setTextFormat(fLabel);
				}catch(e:Error){trace("error"+e);}
				this.addChild(tfAdd);	
								
			/*	//for Error messages
				errorFormat = new TextFormat("Arial, Helvetica, sans-serif", 12, 0xff0000);
				errorTextField = new TextField();
				errorTextField.x = -200;
				errorTextField.y = 520;
				errorTextField.background = false;
				errorTextField.autoSize = TextFieldAutoSize.NONE;
				errorTextField.multiline = true;
				errorTextField.wordWrap = true;
				errorTextField.width = 160;
				errorTextField.text = "test view";
				errorTextField.setTextFormat(errorFormat);
				addChild(errorTextField); 
				errorTextField.name = "errormsg"; */
				
				//********************************
				//              MOTIVE
				//********************************
				//***SCROLLBOX
				var numRows:int;
				numRows = 10;
				var scrollboxW:int = 160;
				var howManyToShow:int = 1;			
				var fillColor:uint = 0xffffff;
				var strokeColor:uint = 0xd6d6d6;
				var scrollboxHeight:int = bgFormat.height - 36;
				_motiveScrollbox = new ScrollBox(scrollboxW, scrollboxHeight, numRows, howManyToShow, fillColor, strokeColor);
				_motiveScrollbox.x = bgFormat.x + bgFormat.width + 10;
				_motiveScrollbox.y = bgFormat.y + 36;
				_motiveScrollbox.name = "scrollbox";		
				this.addChild(_motiveScrollbox);
				
				//scrollbar
				var iHeight:int = scrollboxHeight * howManyToShow + 1;
				var thumbWidth:int = 20;
				_scrollbar = new ScrollBar(this.stage, thumbWidth, iHeight);		
				_scrollbar.x = _motiveScrollbox.x + scrollboxW;
				_scrollbar.y = _motiveScrollbox.y;
				_scrollbar.name = "scrollbar";
				_scrollbar.visible = true;
				_scrollbar.activate();
				this.addChild(_scrollbar);				
				try{
					_scrollbar.addEventListener(ScrollBarEvent.VALUE_CHANGED, onScroll, false, 0, true);	
				}catch (e:Error) { trace("error" + e); }
				
				var line:Shape = new Shape();
				with (line)
					{
						graphics.lineStyle(1, strokeColor);
						graphics.moveTo(_motiveScrollbox.x, _motiveScrollbox.y + iHeight);
						graphics.lineTo(_motiveScrollbox.x + scrollboxW + thumbWidth, _motiveScrollbox.y + iHeight);
					}
				this.addChild(line);
			
				//*** Material SCROLLBOX				
				var sFormat:TextFormat = new TextFormat("Arial, Helvetica, sans-serif", 10, 0x000000, false);
				var widthSerien:int = 170;
				var heightSerien:int = 17;								
				_materialMenu = new Menu(sFormat, widthSerien, heightSerien);
				_materialMenu.x = bgFormat.x + 170;;
				_materialMenu.y = bgFormat.y - 71;	
				
				//*** Bilder scrollbox
				var o_f:TextFormat = new TextFormat("Arial, Helvetica, sans-serif", 10, 0x000000, false);				
				_bilderMenu = new Menu(o_f, widthSerien, heightSerien);
				_bilderMenu.x = _motiveScrollbox.x;
				_bilderMenu.y = bgFormat.y - 71;				
				
				//der Bestellbutton muß vor den dropdowns dasein, damit sie darüber gehen
				//-----------Bestell button-------
				var strText:String = "";			
				var nWidth:Number=177;
				var nHeight:Number = 40;			
				var strUrl:String = "images/jetztBestellen.png";
				var saveFormat:TextFormat = new TextFormat();
				btnSave = new CustomButton(strUrl, nWidth, nHeight, strText, saveFormat);
				btnSave.x = _motiveScrollbox.x;
				btnSave.y = 575;
				btnSave.mouseChildren=false;
				btnSave.buttonMode = true;
				btnSave.useHandCursor = true;			
				addChild(btnSave);
				btnSave.addEventListener(MouseEvent.CLICK, saveClicked);  
				
				
				//***DROPDOWNMENUS
			/*	var formatDDTitle:TextFormat = new TextFormat("Arial, Helvetica, sans-serif", 11, 0x000000, true);
				//formatDDTitle.align = TextFormatAlign.CENTER;
				var tfBilderTitel:TextField = new TextField();				
				tfBilderTitel.background = false; 
				//tfBilderTitel.backgroundColor = 0xee7f00; //orange bg
				tfBilderTitel.multiline = false;
				tfBilderTitel.width = 150;
				tfBilderTitel.height = 20;
				tfBilderTitel.text = "Anzahl der Bilder";
				tfBilderTitel.x = bgFormat.x + bgFormat.width + 10;
				tfBilderTitel.y = bgFormat.y + bgFormat.height + 5;
				tfBilderTitel.setTextFormat(formatDDTitle);
				this.addChild(tfBilderTitel); 
				
				var o_f:TextFormat = new TextFormat("Arial, Helvetica, sans-serif", 11, 0x000000, false);			
				var strDefault:String = "alle";
				_chosenBilderanzahl = strDefault;
				_bilderMenu = new DropDownMenu(["alle", "1", "2", "3", "4", "5"], strDefault, o_f, 50, 16);
				_bilderMenu.x = tfBilderTitel.x + 15;
				_bilderMenu.y = tfBilderTitel.y + 20;	
				//_bilderMenu.activate();
				_bilderMenu.addEventListener(DropDownSelectEvent.VALUE_CHANGED, loadChosenMotive);	
				this.addChild(_bilderMenu);
				
				//Dropdown button
				//var url:String = "images/btnDropdown.png";
				var cWidth:Number = 15;
				var cHeight:Number = 15;			
				var btnBilderanzahl:DropdownButton = new DropdownButton(cWidth, cHeight);
				btnBilderanzahl.x = _bilderMenu.x + 50;
				btnBilderanzahl.y = _bilderMenu.y;	
				btnBilderanzahl.mouseChildren=false;
				btnBilderanzahl.buttonMode = true;
				btnBilderanzahl.useHandCursor = true;	
				btnBilderanzahl.addEventListener(MouseEvent.CLICK, onClickBilderanzahlHandler);	
				this.addChild(btnBilderanzahl);	*/
				
			/*	var tfRahmen:TextField = new TextField();				
				tfRahmen.background = false; 
				//tfRahmen.backgroundColor = 0xee7f00; //orange bg
				tfRahmen.multiline = false;
				tfRahmen.width = 50;
				tfRahmen.height = 20;
				tfRahmen.text = "Rahmen";
				tfRahmen.x = btnBilderanzahl.x + 20;
				tfRahmen.y = tfBilderTitel.y;
				tfRahmen.setTextFormat(formatDDTitle);
				this.addChild(tfRahmen);
				
				_chosenRahmen = strDefault;
				_rahmenDD = new DropDownMenu(["alle", "Buche", "Meranti", "Birke"], strDefault, o_f, 50, 16);
				_rahmenDD.x = btnBilderanzahl.x + 20;
				_rahmenDD.y = _bilderMenu.y;	
				_rahmenDD.activate();
				_rahmenDD.addEventListener(DropDownSelectEvent.VALUE_CHANGED, loadChosenMotive);	
				this.addChild(_rahmenDD);
			
				//Dropdown button
				//var url:String = "images/btnDropdown.png";
				var btnRahmen:DropdownButton = new DropdownButton(cWidth, cHeight);
				btnRahmen.x = _rahmenDD.x + 50;
				btnRahmen.y = _bilderMenu.y;	
				btnRahmen.mouseChildren=false;
				btnRahmen.buttonMode = true;
				btnRahmen.useHandCursor = true;	
				btnRahmen.addEventListener(MouseEvent.CLICK, onClickRahmenHandler);	
				this.addChild(btnRahmen); */
				
			/*	var tfPasspartoutTitel:TextField = new TextField();				
				tfPasspartoutTitel.background = false; 
				//tfPasspartoutTitel.backgroundColor = 0xee7f00; //orange bg
				tfPasspartoutTitel.multiline = false;
				tfPasspartoutTitel.width = 75;
				tfPasspartoutTitel.height = 20;
				tfPasspartoutTitel.text = "Passpartout";
				tfPasspartoutTitel.x = btnRahmen.x + 20;
				tfPasspartoutTitel.y = tfRahmen.y;
				tfPasspartoutTitel.setTextFormat(formatDDTitle);
				this.addChild(tfPasspartoutTitel);
				
				_chosenPasspartout = strDefault;
				_passartoutDD = new DropDownMenu(["alle", "weiss", "schwarz", "ecru"], strDefault, o_f, 50, 16);
				_passartoutDD.x = btnRahmen.x + 20;
				_passartoutDD.y = _bilderMenu.y;	
				_passartoutDD.activate();
				_passartoutDD.addEventListener(DropDownSelectEvent.VALUE_CHANGED, loadChosenMotive);	
				this.addChild(_passartoutDD); 
			
				//Dropdown button
				//var url:String = "images/btnDropdown.png";						
				var btnPasspartout:DropdownButton = new DropdownButton(cWidth, cHeight);
				btnPasspartout.x = _passartoutDD.x + 50;
				btnPasspartout.y = _bilderMenu.y;	
				btnPasspartout.mouseChildren=false;
				btnPasspartout.buttonMode = true;
				btnPasspartout.useHandCursor = true;	
				btnPasspartout.addEventListener(MouseEvent.CLICK, onClickPasspartoutHandler);	
				this.addChild(btnPasspartout);	*/
				
			/*	var rraRahmen:RoundRectArrow = new RoundRectArrow();
				rraRahmen.init (rectArrowW, 30, 0xfbf4ec, 0xdf721f, 10, 10, "Rahmen wählen");
				rraRahmen.x = _motiveScrollbox.x + (_motiveScrollbox.width/2) - rectArrowW/2;
				rraRahmen.y = -35;
				this.addChild(rraRahmen); */
				
				/***********************
				* Error Messages
				* ********************/
				//horizontal scrcolling error messages
				//the mask
				sMask =new Sprite();			
				//then draw it
				drawColorRect(sMask,0xff0000, 1, 370, 30);
				sMask.x = 250;
				sMask.y = 340;
				
				scrollingErrMsg = new HorizontalScrollingText( -1, sMask.x, sMask.y);
				scrollingErrMsg.mask = sMask;	
				//this.addChild(scrollingErrMsg);	
				
			}catch(e:Error){}
		}
		
	/*	private function turnClockwise(e:MouseEvent):void
		{	
			_square_holder.rotation += 90;			
		}
		
		private function turnCounterClockwise(e:MouseEvent):void
		{	
			_square_holder.rotation -= 90;				
		} */
		
	/*	private function onClickBilderanzahlHandler(e:MouseEvent):void
		{		
			_bilderMenu.rollMenu();			
		}
		
		private function onClickRahmenHandler(e:MouseEvent):void
		{		
			_rahmenDD.rollMenu();			
		} */
		
	/*	private function onClickPasspartoutHandler(e:MouseEvent):void
		{		
			_passartoutDD.rollMenu();			
		} */
		
		private function onScroll(e:ScrollBarEvent):void
		{			
			_motiveScrollbox.sbChange(e.scrollPercent);
		}
		
		//called from update the 1st time it runs
		public function showMenu():void
		{
			//errorTextField.text = "showMenu";
			try{			
				
				/*************************************
				 * Totals
				 * **********************************/
								
			/*	var urlW:String = "images/warenkorb.png";
				var wkW:Number = 37;
				var wkH:Number = 37;			
				var imgKorb:LoadedImage = new LoadedImage(urlW, wkW, wkH);				
				imgKorb.x = 50;
				imgKorb.y = 575;
				this.addChild(imgKorb); */
				
				var wkW:Number=37;
				var wkH:Number = 37;			
				var strwkUrl:String = "images/warenkorb.png";				
				var btnWK:CustomButton = new CustomButton(strwkUrl, wkW, wkH);
				btnWK.x = 50;
				btnWK.y = 565;
				btnWK.mouseChildren=false;
				btnWK.buttonMode = true;
				btnWK.useHandCursor = true;			
				addChild(btnWK);
				btnWK.addEventListener(MouseEvent.CLICK, showUbersicht);  
				
				//Gesamtanzahl von Kopien
				//label
				var formatTotal_lbl:TextFormat = new TextFormat("Arial, Helvetica, sans-serif", 12, 0x000000, false);
				var _tfGesamtAnzahl_lbl:TextField = new TextField();
				_tfGesamtAnzahl_lbl.x = 86;
				_tfGesamtAnzahl_lbl.y = 565;
				_tfGesamtAnzahl_lbl.autoSize = TextFieldAutoSize.LEFT;
				_tfGesamtAnzahl_lbl.background = false;           
				_tfGesamtAnzahl_lbl.multiline = false;
				_tfGesamtAnzahl_lbl.width = 70;
				_tfGesamtAnzahl_lbl.text= "Ihr Warenkorb enthält ";
				addChild(_tfGesamtAnzahl_lbl);
				_tfGesamtAnzahl_lbl.setTextFormat(formatTotal_lbl);
				
				//Gesamtanzahl von Kopien
				//amount
				formatTotalcount = new TextFormat("Arial, Helvetica, sans-serif", 12, 0x000000, false);
				_tfGesamtAnzahl = new TextField();
				_tfGesamtAnzahl.x = _tfGesamtAnzahl_lbl.x + 10;
				_tfGesamtAnzahl.y = _tfGesamtAnzahl_lbl.y;
				_tfGesamtAnzahl.autoSize = TextFieldAutoSize.RIGHT;
				_tfGesamtAnzahl.background = false;           
				_tfGesamtAnzahl.multiline = false;
				_tfGesamtAnzahl.width = 70;
				_tfGesamtAnzahl.text= "0 Artikel";
				addChild(_tfGesamtAnzahl);
				_tfGesamtAnzahl.setTextFormat(formatTotalcount);			
				
				
				//-----Gesamtwarenkorb-----
				fTotalpreis = new TextFormat("Arial, Helvetica, sans-serif", 12, 0x000000, true);
				//label		
				var _tfGesamtWarenkorb_lbl:TextField = new TextField();
				_tfGesamtWarenkorb_lbl.x = _tfGesamtAnzahl_lbl.x + 50;
				_tfGesamtWarenkorb_lbl.y = _tfGesamtAnzahl_lbl.y + 20;
				_tfGesamtWarenkorb_lbl.autoSize = TextFieldAutoSize.LEFT;
				_tfGesamtWarenkorb_lbl.background = false;           
				_tfGesamtWarenkorb_lbl.multiline = true;
				_tfGesamtWarenkorb_lbl.height = 30;
				_tfGesamtWarenkorb_lbl.width = 70;
				_tfGesamtWarenkorb_lbl.text = "Gesamtwert:";
				addChild(_tfGesamtWarenkorb_lbl);
				_tfGesamtWarenkorb_lbl.setTextFormat(fTotalpreis);	
								
				//Gesamtwarenkorb
				//amount			
				_tfGesamtWarenkorb = new TextField();
				_tfGesamtWarenkorb.x = _tfGesamtWarenkorb_lbl.x - 40;
				_tfGesamtWarenkorb.y = _tfGesamtWarenkorb_lbl.y;
				_tfGesamtWarenkorb.autoSize = TextFieldAutoSize.RIGHT;
				_tfGesamtWarenkorb.background = false;           
				_tfGesamtWarenkorb.multiline = false;
				_tfGesamtWarenkorb.width = 70;
				_tfGesamtWarenkorb.text= "0,00 €";
				addChild(_tfGesamtWarenkorb);
				_tfGesamtWarenkorb.setTextFormat(fTotalpreis);					
				
				var tfLbl:TextFormat = new TextFormat("Arial, Helvetica, sans-serif", 11, 0x000000, false);		
				var tfGesamt_Lieferkosten:TextField = new TextField();
				tfGesamt_Lieferkosten.x = _tfGesamtAnzahl_lbl.x;
				tfGesamt_Lieferkosten.y = _tfGesamtAnzahl_lbl.y + 35;
				tfGesamt_Lieferkosten.autoSize = TextFieldAutoSize.LEFT;
				tfGesamt_Lieferkosten.background = false;           
				tfGesamt_Lieferkosten.multiline = true;
				tfGesamt_Lieferkosten.height = 30;
				tfGesamt_Lieferkosten.width = 70;
				tfGesamt_Lieferkosten.text = "(zzgl. Lieferkosten & Verpackungspauschale)";
				addChild(tfGesamt_Lieferkosten);
				tfGesamt_Lieferkosten.setTextFormat(tfLbl);	
				
				//setting up for Fotoeditor and Bestellung
				drawColorRect(black, 0x000000, 0.6, stage.stageWidth, stage.stageHeight);
				black.name = "black";
				
				fotoeditor = new GalerieFotoEditor(this);			
				fotoeditor.x = 150;
				fotoeditor.y = 50;	
				
				/*************Info***************/
				var iWidth:int = 600;
				var iHeight:int = 540;
				//var roundI:int = 20;
				infoPopup = new FakePopup_noClose(iWidth, iHeight);	
				infoPopup.x = stage.stageWidth/2 - iWidth / 2 - 70;
				infoPopup.y = stage.stageHeight / 2 - iHeight / 2;
				infoPopup.visible = false;
				stage.addChild(infoPopup);
				
				var urlI:String = "images/topInfoPopup.png";
				var infoPopW:Number = 598;
				var infoPopH:Number = 98;			
				imgInfotop = new LoadedImage(urlI, infoPopW, infoPopH);	
				imgInfotop.name = "topInfoPopup";
				imgInfotop.x = 1;
				imgInfotop.y = -17;	
				
				txtInfotitle = new TextField();
				infoFormat = new TextFormat("Arial, Helvetica, sans-serif", 12, 0x000000);				
				txtInfotitle.x = 460;
				txtInfotitle.y = 58;
				txtInfotitle.background = false;				
				txtInfotitle.multiline = true;
				txtInfotitle.wordWrap = false;
				txtInfotitle.width = 160;
				txtInfotitle.text = "Artikel";
				txtInfotitle.setTextFormat(infoFormat);				
				txtInfotitle.name = "infoTitle"; 
				
			/*	txtInfoprice = new TextField();
				infoFormat = new TextFormat("Arial, Helvetica, sans-serif", 12, 0x000000);				
				txtInfoprice.x = 500;
				txtInfoprice.y = 140;
				txtInfoprice.background = false;				
				txtInfoprice.multiline = false;
				txtInfoprice.width = 100;
				txtInfoprice.text = "Preis: ";
				txtInfoprice.setTextFormat(infoFormat);				
				txtInfoprice.name = "infoPrice"; */
				
				infoImage = new InfoImage();				
				
				//****************Progress********************´/							
				var urlB:String = "images/BestellungFortschritt.png";
				var bestW:Number = 454;
				var bestH:Number = 165;			
				imgBestell = new LoadedImage(urlB, bestW, bestH);				
				imgBestell.x = 2;
				imgBestell.y = -14;			
				//stage.addChild(imgBestell);				
				
				//btnSave.addEventListener(MouseEvent.CLICK, saveClicked); 
				
				pWidth = 456;
				pHeight = 460;
				var roundP:int = 20;
				progressPopup = new SimplePopup(pWidth, pHeight, roundP);
				progressPopup.x = stage.stageWidth/2 - pWidth / 2;
				progressPopup.y = 200;
				
				/*************WarenkorbUbersicht***************/
				var ubersichtW:int = 600;
				var roundU:int = 40;
				ubersichtPopup = new SimplePopup(ubersichtW, pHeight, roundU);
				ubersichtPopup.name = "ubersichtPopup";
				ubersichtPopup.x = stage.stageWidth/2 - ubersichtW / 2;
				ubersichtPopup.y = stage.stageHeight/2 - pHeight / 2;;
				
				var urlU:String = "images/warenkorbUberblick.png";
				var uberW:Number = 598;
				var uberH:Number = 162;			
				imgUberblick = new LoadedImage(urlU, uberW, uberH);		
				imgUberblick.name = "warenkorbUberblick";
				imgUberblick.x = 2;
				imgUberblick.y = -14;	
				
				//der Zurueckbutton in der Warenkorbubersicht
				//-----------close Ubersicht button-------					
				var zWidth:Number=175;
				var zHeight:Number = 39;			
				var strUrlZ:String = "images/btnZurueck.png"; 				
				btnZurueck = new CustomButton(strUrlZ, zWidth, zHeight);
				btnZurueck.x = 25;
				btnZurueck.y = ubersichtPopup.height - 70;
				btnZurueck.name = "zurueck";
				btnZurueck.mouseChildren=false;
				btnZurueck.buttonMode = true;
				btnZurueck.useHandCursor = true;		
				
				//der Bestellbutton in der Warenkorbubersicht
				//-----------Bestell button-------					
				var bWidth:Number=177;
				var bHeight:Number = 40;			
				var strUrlB:String = "images/jetztBestellen.png"; 				
				btnBestell = new CustomButton(strUrlB, bWidth, bHeight);
				btnBestell.x = ubersichtPopup.width - 200;
				btnBestell.y = ubersichtPopup.height - 70;
				btnBestell.name = "bestell";
				btnBestell.mouseChildren=false;
				btnBestell.buttonMode = true;
				btnBestell.useHandCursor = true;		
				
				_content = new OrderUberblick(this);
				_content.name = "warenkorb";
				_content.x = 8;
				_content.y = 145; 
			}catch (e:Error) { //errorTextField.appendText ("error:" + e); 
				}	
		}
		
		private function loadMenus():void
		{	
			//***Material Menu***
			var dictMaterial:Dictionary = orderModel.dictMaterial;
			var arrMaterial:Array = [];
			arrMaterial.push(ALLE_MATERIALIEN);
			//convert to array
			for (var key:String in dictMaterial)
			{
				arrMaterial.push(dictMaterial[key]);
			}

			_materialMenu.fillMenu(arrMaterial, ALLE_MATERIALIEN);		
			_materialMenu.addEventListener(DropDownSelectEvent.VALUE_CHANGED, loadChosenMotive);	
			_strCurrentMaterial = ALLE_MATERIALIEN;
			//this.addChild(_materialMenu);
			
			//***Bilder Menu***
			var arrBilderAnzahl:Array = orderModel.arrBilderAnzahl;
			arrBilderAnzahl[0]= ALLE_BILDER;
						
			_bilderMenu.fillMenu(arrBilderAnzahl, ALLE_BILDER);		
			_bilderMenu.addEventListener(DropDownSelectEvent.VALUE_CHANGED, loadChosenMotive);	
			_chosenBilderanzahl = ALLE_BILDER;
			//this.addChild(_bilderMenu);			
		}
		
		/******************************************************************
		 * Functions for the Motive for adding new suborders
		 * **************************************************************/
		
		 //***remove current motiv
		 //if the current motiv has fotos attached, they need to be loaded into the new motiv !!!
		  private function removeCurrentMotiv():void
		{
	
			_square_holder.removeChild(liMotiv);
			liMotiv.deleteImage();
		 		
		    for (var i:int = 0; i < currMotiv.arrBilder.length; ++i)
		    {//remove the dropboxes(Bilderausschnitte) 
			   var dropBox:AusschnittDropbox = new AusschnittDropbox();
			   dropBox = _arrAusschnittBoxes.pop();				  
			   dropBox.removeEventListener(MouseEvent.CLICK, reEditFoto);
			   liMotiv.removeChild(dropBox);
			   dropBox.deleteImage();
			   dropBox = null;
		    }	
		}
		
		  //***************************
		  //      load current motiv - called, when first loading, when switching motivs, and when coming from 
		  //      OrderUeberblick to edit something
		  //***************************
		 private function loadCurrentMotiv():void
		{		  
		  currMotiv = this.orderModel.currentMotiv;
		  
		  //load the correct image
		  var imgPath:String = currMotiv.motivpath;
		/*  if (currMotiv.orientation != "a")
		  {		
			  imgPath = imgPath.replace(".jpg", "_" + currMotiv.orientation + ".jpg");
		  } */
		  
		  //clear the memory first
		  if (liMotiv)
		  {
			  liMotiv.deleteImage();
		  }
		  
		  liMotiv = new LoadedImage(imgPath, currMotiv.rahmenWidth_in_pxl, currMotiv.rahmenHeight_in_pxl );
		  _square_holder.x = bgFormat.x + (bgFormat.width / 2);
		  _square_holder.y = bgFormat.y + (bgFormat.height / 2);
		  
		  //USE THE VISIBLE OBJECTS DIMESIONS TO "CENTER" IT ON THE HOLDER 
		  liMotiv.x = - currMotiv.rahmenWidth_in_pxl/2;
		  liMotiv.y = - currMotiv.rahmenHeight_in_pxl / 2;		
		  
		  _square_holder.addChild(liMotiv);
		  var centerX:int = liMotiv.x + Math.floor(currMotiv.rahmenWidth_in_pxl / 2);
		  var centerY:int = liMotiv.y + Math.floor(currMotiv.rahmenHeight_in_pxl / 2);
		  
		//  liMotiv.transform.matrix = new Matrix(1, 0, 0, 1, centerX, centerY);
		  		  
		  tfFarbe.text = currMotiv.Farbe;
		  tfFarbe.setTextFormat(fValue);
		  tfMaterial.text = currMotiv.Material;
		  tfMaterial.setTextFormat(fValue);
		  tfBilder.text = String(currMotiv.intBilder);
		  tfBilder.setTextFormat(fValue);
		  tfPasspartout.text = currMotiv.Passpartout;
		  tfPasspartout.setTextFormat(fValue);
		  tfArtikelnr.text = String(currMotiv.Artikelnummer);
		  tfArtikelnr.setTextFormat(fValue);
		  tfPreis.text = String(currMotiv.nmbPrice.toFixed(2));
		  tfPreis.setTextFormat(fPreis);
		
	//errorTextField.appendText("bilder:" + String(currMotiv.arrBilder.length));
		
		  for (var i:int = 0; i < currMotiv.arrBilder.length; ++i)
		  {//show the dropboxes(Bilderausschnitte) 
			  var dropBox:AusschnittDropbox = new AusschnittDropbox();
			  var intRounding:int = 0;
	//errorTextField.appendText(BildModel(currMotiv.arrBilder[i]).pixelBreit + " " + BildModel(currMotiv.arrBilder[i]).pixelHoch + "edge:" + currMotiv.halbeBreite_PLUS_in_pxl);
			  dropBox.createDropbox(BildModel(currMotiv.arrBilder[i]).pixelBreit, BildModel(currMotiv.arrBilder[i]).pixelHoch, " ", currMotiv.motivID, intRounding, i, 20);
			  dropBox.intIndx = i;
			//  dropBox.alpha = .5;
			  liMotiv.addChild(dropBox);
			  dropBox.x = BildModel(currMotiv.arrBilder[i]).posX + currMotiv.halbeBreite_PLUS_in_pxl;
			  dropBox.y = BildModel(currMotiv.arrBilder[i]).posY + currMotiv.halbeHoehe_PLUS_in_pxl; 			  
			  _arrAusschnittBoxes.push(dropBox);
			 
			//if they are editing an already saved order or just filling an Ausschnitt, which already had a foto
			if (_arrCurrFotos[i] != null)
			  {
		//errorTextField.appendText("not null: " + i);
				var fotoview:FotoView = _arrCurrFotos[i] ;
				var matrix: Matrix = new Matrix();	
			    var beginX:Number; // top left x position  
			    var beginY:Number; // top left y position 
			    var croppedWidth:Number;
			    var croppedHeight:Number;			  
			    var objSuborder:SubOrder;
				
				//show the new ausschnitt instead of the dropdownbox.				
				objSuborder = fotoview.objSuborder;
				var newFotoview:FotoView = null;		
					//errorTextField.appendText("\nold w:" + String(fotoview.objSuborder.showW) + "h" + String(fotoview.objSuborder.showH) );	
				fotoview.objSuborder.strMotiv = _strCurrentProduct;
				newFotoview = fotoeditor.adeptAusschnitt(fotoview, _strCurrentProduct, currMotiv, i, objSuborder); 
				//make sure old suborder gets deleted and the new suborder gets put in its place				
				var done:String = this.orderController.addSubOrder(newFotoview.objSuborder);				
			//errorTextField.appendText(done + "\nnew w:" + String(newFotoview.objSuborder.finalW) + "h" + String(newFotoview.objSuborder.finalH) );	
	
				var newSuborder:SubOrder = newFotoview.objSuborder;
				//and show it
				beginX = newSuborder.showX;
				beginY = newSuborder.showY;
				croppedWidth = newSuborder.showW;
				croppedHeight = newSuborder.showH;
				var bmpData:BitmapData = new BitmapData(croppedWidth, croppedHeight);			
				
				bmpData.copyPixels(fotoview.bmp.bitmapData, new Rectangle(beginX, beginY, croppedWidth, croppedHeight), new Point(0, 0)); 
				dropBox.setImageData(bmpData, fotoview);
				
				dropBox.addEventListener(MouseEvent.CLICK, reEditFoto, false, 0, true); 
			    }
		    }	
		}
	
		
		private function loadMotive():void
		{
			_dictMotive = orderModel.dictMotive;
			_dctMotivButtons = new Dictionary(true);
			
			var arrChoices:Array = new Array();
			var objMotivModel:MotivModel = new MotivModel();
			
			//reset array
			_arrMotivButtons = [];
			_intMotivsLoaded = 0;			
			
		//	_chosenBilderanzahl = _bilderMenu.getSelection();
		//	_chosenRahmen = _rahmenDD.getSelection();
		//	_chosenPasspartout = _passartoutDD.getSelection();
			
			var blnShow:Boolean = true;
			//iterate through dictMotive and find out, which ones should be shown now
			for (var keyMotivID:String in _dictMotive) 
			{	
				objMotivModel = _dictMotive[keyMotivID];
				
			//errorTextField.appendText(objMotivModel.Motivname + "--");
				blnShow = true;
				if (_chosenBilderanzahl != ALLE_BILDER)
				{
					if (String(objMotivModel.strBilder) != _chosenBilderanzahl)
					{
						blnShow = false;
					}
				} 
				if (blnShow && _strCurrentMaterial != ALLE_MATERIALIEN)
				{
					if (objMotivModel.Materialname != _strCurrentMaterial)
					{
						blnShow = false;
					}
				}
			/*	if (blnShow && _chosenRahmen != "alle")
				{
					if (objMotivModel.Farbe != _chosenRahmen)
					{
						blnShow = false;
					}
				}
				if (blnShow && _chosenPasspartout != "alle")
				{
					if (objMotivModel.Passpartout != _chosenPasspartout)
					{
						blnShow = false;
					}
				} */
				if (blnShow)
				{
					arrChoices.push(objMotivModel);
				}
			}
			var newY:int = 30;
			//show them
			for (var i:int = 0; i < arrChoices.length; ++i)			
			{					
				var strBtnUrl:String = arrChoices[i].motivpath;		
				
			//	if (arrChoices[i].orientation == "a")
			//	{
					strBtnUrl = strBtnUrl.replace(".jpg", "_sm.jpg");
			/*	}else {
					strBtnUrl = strBtnUrl.replace(".jpg", "_" + arrChoices[i].orientation + "_sm.jpg");
				} */
				
				var strMotiv:String = arrChoices[i].motivID;
				
				var btnMotiv:MotivButton = new MotivButton(strBtnUrl, strMotiv, arrChoices[i].motivpath);
				btnMotiv.x = (150 - arrChoices[i].smRahmenWidth_in_pxl)/2;
				btnMotiv.y = newY;
				btnMotiv.mouseChildren=false;
				btnMotiv.buttonMode = true;
				btnMotiv.useHandCursor = true;	
				btnMotiv.name = arrChoices[i].motivID;
				btnMotiv.infoscreen = arrChoices[i].infoscreen;
				
				btnMotiv.addEventListener(MouseEvent.CLICK, switchMotiv); 
				btnMotiv.addEventListener(Event.COMPLETE, onMotivLoaded); 
								
				_arrMotivButtons.push(btnMotiv.name);
				_dctMotivButtons[btnMotiv.name] = btnMotiv;				
			
				newY = newY + arrChoices[i].smRahmenHeight_in_pxl + 20;
			}
			stage.addChild(infoPopup);
		}
		
		private function onMotivLoaded(e:Event):void
		{	
			_intMotivsLoaded ++;
			var motivButton:MotivButton = e.target as MotivButton;
			
			var motivModel:MotivModel = _dictMotive[motivButton.name];
				//errorTextField.appendText("motivButton.name " + motivButton.name);		
			var blnAddScrollbar:Boolean = _motiveScrollbox.addImage(e.target as MotivButton);	
			
			if (blnAddScrollbar)
			{
				_scrollbar.visible = true;
			}else {
				_scrollbar.visible = false;
			}
		
			if (motivModel.infoscreen != "")
			{				
				/*var infoW:Number=47;
				var infoH:Number = 44;			
				var strInfoUrl:String = "images/info.png";				
				var btnInfo:InfoButton = new InfoButton(strInfoUrl, infoW, infoH);				
				btnInfo.mouseChildren=false;
				btnInfo.buttonMode = true;
				btnInfo.useHandCursor = true;			
				
				btnInfo.name = motivModel.motivID; 
				btnInfo.x = motivButton.x + motivButton.width - 5;
				btnInfo.y = motivButton.y -10;
				_motiveScrollbox.addInfobutton(btnInfo);
				btnInfo.addEventListener(MouseEvent.CLICK, showInfo); */
				motivButton.addEventListener(MouseEvent.MOUSE_OVER, showInfo);
			}
			
			if (_intMotivsLoaded == _arrMotivButtons.length - 1)
			{
				this.addChild(_materialMenu);
				this.addChild(_bilderMenu);		
			}			
		}		
	
		private function loadChosenMotive(e:DropDownSelectEvent):void
		{	
			_intMotivsLoaded = 0;
			var arrChoices:Array = new Array();
			
			//get rid off all Motive in scrollbox and clear them from memory
			var arrBtnMotivs:Array = [];
			if ( _arrMotivButtons.length > 0)
			{
				if (_scrollbar.visible)
				{
					_scrollbar.moveThumbHome();
				}
				_motiveScrollbox.removeImages();
				_scrollbar.visible = false;
			}
			
			//reset array
			_arrMotivButtons = [];			
			
		/*	while (arrBtnMotivs.length > 0)
			{
				var oldBtnMotiv:MotivButton = arrBtnMotivs.pop();
				oldBtnMotiv.deleteButton();				
			} */
			
			var objMotivModel:MotivModel = new MotivModel();
			_strCurrentMaterial = _materialMenu.getSelection();
			_chosenBilderanzahl = _bilderMenu.getSelection();
		//	_chosenRahmen = _rahmenDD.getSelection();
		//	_chosenPasspartout = _passartoutDD.getSelection();
			
			var blnShow:Boolean = true;
			//iterate through dictMotive and find out, which ones should be shown now
			for (var keyMotivID:String in _dictMotive) 
			{		
				objMotivModel = _dictMotive[keyMotivID];
			
				blnShow = true;
				if (_chosenBilderanzahl != ALLE_BILDER)
				{
					if (String(objMotivModel.strBilder) != _chosenBilderanzahl)
					{
						blnShow = false;
					}
				} 
				if (blnShow && _strCurrentMaterial != ALLE_MATERIALIEN)
				{
					if (objMotivModel.Materialname != _strCurrentMaterial)
					{
						blnShow = false;
					}
				}
			/*	if (blnShow && _chosenPasspartout != "alle")
				{
					if (objMotivModel.Passpartout != _chosenPasspartout)
					{
						blnShow = false;
					}
				} */
		
				if (blnShow)
				{
					arrChoices.push(objMotivModel);			
				}
			}
			var newY:int = 30;
			//show them
			for (var i:int = 0; i < arrChoices.length; ++i)			
			{	
				var strMotiv:String = arrChoices[i].motivID;
				var btnMotiv:MotivButton = _dctMotivButtons[strMotiv];
				btnMotiv.x = (150 - arrChoices[i].smRahmenWidth_in_pxl)/2;
				btnMotiv.y = newY;								
				
				var blnAddScrollbar:Boolean = _motiveScrollbox.addImage(btnMotiv);
			
				if (blnAddScrollbar)
				{
					_scrollbar.visible = true;
				}else {
					_scrollbar.visible = false;
				}
				
				if (btnMotiv.infoscreen != "")
				{
				/*	var infoW:Number=47;
					var infoH:Number = 44;			
					var strInfoUrl:String = "images/info.png";				
					var btnInfo:InfoButton = new InfoButton(strInfoUrl, infoW, infoH);				
					btnInfo.mouseChildren=false;
					btnInfo.buttonMode = true;
					btnInfo.useHandCursor = true;
					btnInfo.name = objMotivModel.motivID;
					btnInfo.x = btnMotiv.x + btnMotiv.width - 5;
					btnInfo.y = btnMotiv.y -10;
					_motiveScrollbox.addInfobutton(btnInfo);
					btnInfo.addEventListener(MouseEvent.CLICK, showInfo); */
					btnMotiv.addEventListener(MouseEvent.MOUSE_OVER, showInfo);
				}				
				
				_arrMotivButtons.push(btnMotiv.name);
				
				newY = newY + arrChoices[i].smRahmenHeight_in_pxl + 20; 
			} 
			
			stage.addChild(infoPopup);
		}
		
		//move out the last motiv, switch images to new motiv, show new motiv with images 
		private function switchMotiv(e:MouseEvent):void
		{
				//errorTextField.appendText(MotivButton(e.target).strMotiv);			
			_strCurrentProduct = MotivButton(e.target).strMotiv;			
			this.removeCurrentMotiv();
			this.orderModel.setCurrentMotiv(_strCurrentProduct);
			this.loadCurrentMotiv();
			hideInfoPopup(MotivButton(e.target));
		}
		
		private function showInfo(e:MouseEvent):void
		{	
			MotivButton(e.target).removeEventListener(MouseEvent.MOUSE_OVER, showInfo);
			MotivButton(e.target).addEventListener(MouseEvent.MOUSE_OUT, hideInfo, false, 0, true);
			//dispatch custom event, which will be caught by controller 
			if (blnShowing)
			{
				closeUbersicht();
			} 
			
			var motivModel:MotivModel = _dictMotive[e.target.name];
			
		//	stage.addChild(black); 
			infoPopup.visible = true;
			infoPopup.addChild(imgInfotop);
			txtInfotitle.text = "Artikel " + motivModel.Artikelnummer + " | " + motivModel.Preis;
			txtInfotitle.setTextFormat(infoFormat);	
			infoPopup.addChild(txtInfotitle);	
	//errorTextField.appendText("\n" + motivModel.infoscreen + " "); //???
			infoImage.loadImage(motivModel.infoscreen);
			infoImage.name = "info";
			infoImage.x = 32;
			infoImage.y = 82;
			infoPopup.addChild(infoImage);
			
			//txtInfoprice.text = "Preis: " + motivModel.Preis;
			//infoPopup.addChild(txtInfoprice);			
		}
		
		private function hideInfo(e:MouseEvent):void
		{		
			MotivButton(e.target).removeEventListener(MouseEvent.MOUSE_OUT, hideInfo);
			MotivButton(e.target).addEventListener(MouseEvent.MOUSE_OVER, showInfo);
		/*	if (infoPopup.getChildByName("infoPrice"))
			{
				infoPopup.removeChild(txtInfoprice);
			} */
			if (infoPopup.getChildByName("info"))
			{
				infoPopup.removeChild(infoImage);
			}
			if (infoPopup.getChildByName("infoTitle"))
			{
				infoPopup.removeChild(txtInfotitle);	
			}
			if (infoPopup.getChildByName("topInfoPopup"))
			{
				infoPopup.removeChild(imgInfotop);
			}
			infoPopup.visible = false;
		//	stage.removeChild(black); 			
		}
		
		private function hideInfoPopup(btnMotiv:MotivButton):void
		{		
			btnMotiv.removeEventListener(MouseEvent.MOUSE_OUT, hideInfo);
			btnMotiv.addEventListener(MouseEvent.MOUSE_OVER, showInfo);
		/*	if (infoPopup.getChildByName("infoPrice"))
			{
				infoPopup.removeChild(txtInfoprice);
			}*/
			if (infoPopup.getChildByName("info"))
			{
				infoPopup.removeChild(infoImage);
			}
			if (infoPopup.getChildByName("infoTitle"))
			{
				infoPopup.removeChild(txtInfotitle);	
			}
			if (infoPopup.getChildByName("topInfoPopup"))
			{
				infoPopup.removeChild(imgInfotop);
			}
			infoPopup.visible = false;
		//	stage.removeChild(black); 			
		}
		
		private function showUbersicht(e:MouseEvent=null):void
		{				
			//when box is open and clicking on format, hide fires and then showContents
			//I wanted to remove the listeners, but I can´t add the, if they click the close button
			//I´d have to add an event that bubbles to be able to add them again. It still wouldn´t work,
			//because hide would fire and add them back.
			black.removeEventListener(MouseEvent.CLICK, onBlackClicked);
			if (!blnShowing)
			{	
				//get the array of imgPos for the fotos	
				_arrCurrMotivOrders = null;
				_arrCurrMotivOrders = [];
				_arrCurrMotivOrders = this.orderController.getOrders();	
				if (_arrCurrMotivOrders.length > 0)
				{
					stage.addChild(black); 					
					stage.addChild(ubersichtPopup);
					ubersichtPopup.addChild(imgUberblick);	
					ubersichtPopup.addChild(_content);
					ubersichtPopup.addChild(btnZurueck);
					btnZurueck.addEventListener(MouseEvent.CLICK, closeUbersicht, false, 0, true);
					ubersichtPopup.addChild(btnBestell);
					btnBestell.addEventListener(MouseEvent.CLICK, onOrder, false, 0, true);
			
					_content.fillScrollbox(_arrCurrMotivOrders); 
					stage.addEventListener(MouseEvent.MOUSE_UP, hidePopup, false, 0, true);
					stage.addEventListener(OrderItemLocation.DELETE, onDeleteMotivorder, false, 0, true);
					stage.addEventListener(OrderItemLocation.EDIT, onEditMotivorder, false, 0, true);
					blnShowing = true; 
				}				
			}			
		} 
		
		//called from OrderItemLocation, when user clicks on edit button in Warenkorbubersicht
		private function onEditMotivorder(e:ModifyOrderEvent):void
		{	
			this.closeUbersicht();
			
			this.removeCurrentMotiv();
			
			//make the order to be edited the current, and delete the order
			_currObjMotivOrder = new MotivOrder();
			_currObjMotivOrder = MotivOrder(_arrCurrMotivOrders[e.indx]);
			_strCurrentProduct = _currObjMotivOrder.motivID;	
			this.orderController.setOrderToEdit(_currObjMotivOrder);			
			_arrCurrFotos = new Array();
			var arrImgPos:Array = [];
			var arrOrder:Array = [];
			arrOrder = _currObjMotivOrder.arrOrder;
			//if there is a foto in the Ausschnitt, then get the original fotoviews from ordercontroller
			for (var i:int = 0; i < arrOrder.length; ++i)
			{
				if ((arrOrder[i]!=null) &&(SubOrder(arrOrder[i]).imgPos > -1))
				{
					arrImgPos[i] = SubOrder(arrOrder[i]).imgPos;
			//errorTextField.appendText("added:" + i + " imgPos:" + SubOrder(arrOrder[i]).imgPos);
				}
			}
			_arrCurrFotos = this.orderController.getFotos_forOrder( arrImgPos);
		//errorTextField.appendText("_arrCurrFotos.length: " + _arrCurrFotos.length);
			//_arrCurrFotos = copyArray(arrFotoViews);
			for (var k:int = 0; k < _arrCurrFotos.length; ++k)
			{
				if ((_arrCurrFotos[k] != null) && (arrOrder[k] != null))
				{			
					FotoView(_arrCurrFotos[k]).objSuborder = SubOrder(arrOrder[k]);	
					//errorTextField.appendText("\nwidth:" +SubOrder(arrOrder[k]).showW + "height:" + SubOrder(arrOrder[k]).showH);
				}
			}
			//	_square_holder.rotation = _currObjMotivOrder.frameRotation;
			this.loadCurrentMotiv();			
		}
		
		private function onDeleteMotivorder(e:ModifyOrderEvent):void
		{	
			this.orderController.deleteMotivOrder(_arrCurrMotivOrders[e.indx]);
			_arrCurrMotivOrders[e.indx] = null;	
		}
			
		private function closeUbersicht(e:MouseEvent=null):void
		{	
			if (blnShowing)
			{
				blnShowing = false;		
				if (btnZurueck.hasEventListener(MouseEvent.CLICK))
				{
					btnZurueck.removeEventListener(MouseEvent.CLICK, closeUbersicht);
				}
				if (btnBestell.hasEventListener(MouseEvent.CLICK))
				{
					btnBestell.removeEventListener(MouseEvent.CLICK, onOrder);
				}
				_content.emptyScrollbox();	
				if (ubersichtPopup.getChildByName("warenkorb"))
				{
					ubersichtPopup.removeChild(_content);
				}
				if (ubersichtPopup.getChildByName("zurueck"))
				{
					ubersichtPopup.removeChild(btnZurueck);
				}				
				if (ubersichtPopup.getChildByName("warenkorbUberblick"))
				{
					ubersichtPopup.removeChild(imgUberblick);
				}				
				if (ubersichtPopup.getChildByName("bestell"))
				{
					ubersichtPopup.removeChild(btnBestell);
				}				
				if (stage.getChildByName("ubersichtPopup"))
				{
					stage.removeChild(ubersichtPopup);
				}				
				if (stage.getChildByName("black"))
				{
					stage.removeChild(black); 	
				}
			}
		}
		
		private function onOrder(e:MouseEvent):void
		{
			this.closeUbersicht();
			this.goBestellen();
		}
		
	  public function hidePopup(e:MouseEvent):void
	  {
		  if (blnShowing)
		  {
			//  errorTextField.appendText(" isopen "+String (e.target));
			//if they clicked outside the popup, close it
			  if (!ubersichtPopup.hitTestPoint(stage.mouseX, stage.mouseY, true)) 
			  {		
				 // errorTextField.appendText( " close ");
				  stage.removeEventListener(MouseEvent.CLICK, hidePopup);
				 this.closeUbersicht();
				// this.removeEventListener(CancelFormatEvent.CANCEL_FORMAT, onCancelProduct);				 			
			  }			 
		  }	  
	  } 
		
		public function get arrAusschnittBoxes():Array
		{
			return _arrAusschnittBoxes;
		}
		
		//on load change size of the large images according to template size
		private function fixSize(loader:Loader, newWidth:Number, newHeight:Number):void {

			var sw:Number=1;
			var sh:Number=1;

			loader.scaleX=1;
			loader.scaleY=1;
			//depending on the stageW and stageH and without loosing the ratio
			//the loaded is resized
			if (loader.width>newWidth) {
				sw=newWidth/loader.width;
			}
			/*if (loader.height>newHeight) {
				sh=newHeight/loader.height;
			}*/
			var s:Number=Math.min(sw,sh);
			//resizing of the large image
			loader.width*=s;
			loader.height*=s;
		}
		
		//user can click on an Ausschnitt again, to reedit the foto
		private function reEditFoto(e:MouseEvent):void
		{		
			stage.addChild(black);
		
			var currFotoview:FotoView = e.target.parent.fotoview;
			var objSuborder:SubOrder = currFotoview.objSuborder;
			var intIndx:int = e.target.parent.intIndx;
			
			//get Formate list						
			fotoeditor.reopenFotoEditor(currFotoview, _strCurrentProduct, this._dictMotive[_strCurrentProduct], intIndx, objSuborder);
			
			stage.addChild (fotoeditor);
			black.addEventListener(MouseEvent.CLICK, onBlackClicked, false, 0, true);
			fotoeditor.addEventListener(PopupEvent.CLOSE_BOX, onCloseFotoEditor, false, 0, true);			
		} 		
		
		//attaches a photo to a Format; called from main when foto is dropped on product
		public function openFotoeditor(mini:FotoView, strMotiv:String, intAusschnittIndx:int ):void
		{		
			stage.addChild(black);		
						
			//show the new image in the fotoeditor
			currentImgPos = mini.iPos;
			//open up fotoeditor with the list of formats for _arrAusschnittBoxes[intProduct].product;
			_strCurrentProduct = strMotiv;
			//get Formate list						
			fotoeditor.openFotoEditor(mini, _strCurrentProduct, this._dictMotive[_strCurrentProduct], intAusschnittIndx);
			stage.addChild (fotoeditor);
			black.addEventListener(MouseEvent.CLICK, onBlackClicked, false, 0, true);
			fotoeditor.addEventListener(PopupEvent.CLOSE_BOX, onCloseFotoEditor, false, 0, true);			
		} 		
		
		//called from galerieFotoEditor
		public function confirmPicture(copyofFoto:FotoView):void
		{	
			var objSuborder:SubOrder = copyofFoto.objSuborder;
			
			//check, if ausschnitt already had an image, if so get rid off it first
			if ((_arrCurrFotos[objSuborder.intAusschnittPosition]!=null)&&(_arrCurrFotos[objSuborder.intAusschnittPosition]is FotoView))
			{
				//if there was a different foto before...
				if (FotoView(_arrCurrFotos[objSuborder.intAusschnittPosition]).objSuborder.imgPos != copyofFoto.objSuborder.imgPos)
				{
					FotoView(_arrCurrFotos[objSuborder.intAusschnittPosition]).onReplace();
					//errorTextField.appendText("removed last foto");
				}
			} 			
	
			var done:String = this.orderController.addSubOrder(objSuborder);
			var adAusschnitt:AusschnittDropbox = _arrAusschnittBoxes[objSuborder.intAusschnittPosition];
			
			//reset the current foto for the Ausschnitt position
			_arrCurrFotos[objSuborder.intAusschnittPosition] = copyofFoto;
				//errorTextField.appendText(adAusschnitt.motiv + " and " + objSuborder.strMotiv );	
			if (adAusschnitt.motiv === objSuborder.strMotiv)
			{	
					//errorTextField.appendText("yes");
				var matrix: Matrix = new Matrix();	
			    var beginX:Number; // top left x position  
			    var beginY:Number; // top left y position 
			    var croppedWidth:Number;
			    var croppedHeight:Number;			  
			    var suborder:SubOrder;
				//show the new ausschnitt instead of the dropdownbox.
				var origfotoview:FotoView = copyofFoto;				
				suborder = objSuborder;										
				beginX = suborder.showX;
				beginY = suborder.showY;
				croppedWidth = suborder.showW;
				croppedHeight = suborder.showH;				
				
				//turn the foto inside the Rahmen, if fotoRotation or if frameRotation? I don´t remember ???
				var degrees:int=suborder.fotoRotation;
                var angle_in_radians:Number = Math.PI * 2 * (degrees / 360);
                var rotationMatrix:Matrix = new Matrix();
                rotationMatrix.translate(-origfotoview.bmp.width/2,-origfotoview.bmp.height/2);
                rotationMatrix.rotate(angle_in_radians);
                rotationMatrix.translate(origfotoview.bmp.width/2,origfotoview.bmp.height/2);
                var matrixImage:BitmapData = new BitmapData(origfotoview.bmp.width, origfotoview.bmp.height, true, 0x00000000);
                matrixImage.draw(origfotoview.bmp.bitmapData, rotationMatrix);
                //adAusschnitt.setImageData(matrixImage, origfotoview);

				var bmpData:BitmapData = new BitmapData(croppedWidth, croppedHeight);
				bmpData.copyPixels(matrixImage, new Rectangle(beginX, beginY, croppedWidth, croppedHeight), new Point(0, 0)); 
				var bmp:Bitmap = new Bitmap();
				bmp.bitmapData = bmpData;
				//this.addChild(bmp);
				
				//bmpData.copyPixels(origfotoview.bmp.bitmapData, new Rectangle(beginX, beginY, croppedWidth, croppedHeight), new Point(0, 0)); 
				adAusschnitt.setImageData(bmpData, origfotoview);				
				
				adAusschnitt.addEventListener(MouseEvent.CLICK, reEditFoto, false, 0, true);
			}
		}
		
		//Kunde clicked to add to Warenkorb
		private function addClicked(e:MouseEvent):void
		{
			//check if all Ausschnitte are filled, if not give alert
			var blnAllFilled:Boolean = true;			
			blnAllFilled = check_if_allAusschnitte_filled();
			
			//if one or more Ausschnitte are not filled, show alert, otherwise add order
			if (!blnAllFilled)
			{
				var fillColor:uint = 0xefefef;
				//var sizeRect:Rectangle = new Rectangle( -50, 50, 255, 220);
				var sizeRect:Rectangle = new Rectangle(0, 0, 255, 194);
				var strMsg:String = "Sie haben noch nicht alle Ausschnitte gefüllt. Wollen Sie dennoch fortfahren?";
				var alertBx:AlertBox = new AlertBox(this, sizeRect, strMsg, "Achtung", ["Ja", "Nein"], fillColor, 0x000000, 0x626262, onAlertAusschnitte);
				alertBx.x = stage.stageWidth / 2 - 254 / 2;
				alertBx.y = stage.stageHeight / 2 - 194 / 2;
				stage.addChild(black);
				stage.addChild(alertBx);	
			} else {					
				this.addOrder_andshow();				
			}			
		}
		
		//answers true, if all; false, if not all
		private function check_if_allAusschnitte_filled():Boolean
		{
			//check if all Ausschnitte are filled, if not give alert
			var blnAllFilled:Boolean = true;
			
			for (var i:int = 0; i < _arrAusschnittBoxes.length; ++i)
			{
				if (_arrAusschnittBoxes[i].blnFilled == false)
				{
					blnAllFilled = false;
				}
			}
			return blnAllFilled;
		}
		
		//answers true if any; false if none
		private function check_if_anyAusschnitte_filled():Boolean
		{
			//check if all Ausschnitte are filled, if not give alert
			var blnSomeFilled:Boolean = false;
			
			for (var i:int = 0; i < _arrAusschnittBoxes.length; ++i)
			{
				if (_arrAusschnittBoxes[i].blnFilled == true)
				{
					blnSomeFilled = true;
				}
			}
			return blnSomeFilled;
		}
		
		//Kunde clicked to add to Warenkorb
		private function onAlertAusschnitte(buttonNumber:int, abox:AlertBox):void 
		{
			stage.removeChild(black);
			switch (buttonNumber)
			{
				case 0: //ja
				this.addOrder_andshow();
					break;				
				case 1: //nein
					//do nothing
					break;
				default:
			}
		}
		
		private function addOrder_andshow():void
		{
			this.addOrderToWarenkorb();		
			
			//alert to make it obvious, the order was saved
			var fillColor:uint = 0xefefef;			
			var sizeRect:Rectangle = new Rectangle(0, 0, 440, 194);
			var strMsg:String = "Was möchten Sie jetzt tun?";
			var alertBx:SpecialAlertBox = new SpecialAlertBox(this, sizeRect, strMsg, "Sie haben Ihren Galerie-Rahmen erfolgreich in den Warenkorb gelegt!", ["zurück", "zum Warenkorb", "JETZT bestellen"], fillColor, 0x000000, 0x626262, onAlertAddedOrder);
			alertBx.x = stage.stageWidth / 2 - 440 / 2;
			alertBx.y = stage.stageHeight / 2 - 194 / 2;
			stage.addChild(black);
			stage.addChild(alertBx);	
		}
		
		private function addOrderToWarenkorb():void
		{
			var bmpSnapshot:Bitmap = new Bitmap();	
			try
				{					
					var snapshot:BitmapData = new BitmapData (liMotiv.width, liMotiv.height);
					snapshot.draw(liMotiv);
				}catch (e:ArgumentError) { 
					//trace (e);
				}catch (e:SecurityError) { 
					//trace (e);
				}
			bmpSnapshot.bitmapData = snapshot;
			//this.addChild(bmpSnapshot);				
	
			var done:String = this.orderController.addOrder(bmpSnapshot);		
			
			for (var i:int = 0; i < _arrAusschnittBoxes.length; ++i)
			{
				_arrAusschnittBoxes[i].clearImage();
			}
			
			//clear the array of current Ausschnitt Fotos
			_arrCurrFotos = new Array();
			_currObjMotivOrder = null;
			
			if (done != "0")
			{				
				if (blnFirstOrder)
				{
					blnFirstOrder = false;					
					activateBestellen();
				}
			}
		}
		
		private function onAlertAddedOrder(buttonNumber:int, abox:SpecialAlertBox):void 
		{
			stage.removeChild(black);
			switch (buttonNumber)
			{
				case 0: //zurück, do nothing				
					break;				
				case 1: //zum Warenkorb				
					this.showUbersicht();
					break;
				case 2: //jetzt bestellen				
					this.saveClicked();
					break;
				default:
			}
		}

		
		public function onCloseFotoEditor(e:PopupEvent = null):void
		{
			black.removeEventListener(MouseEvent.CLICK, onBlackClicked);
			fotoeditor.empty();
			stage.removeChild(black);
			stage.removeChild(fotoeditor);
		}
		
		private function onBlackClicked(e:MouseEvent):void
		{
			black.removeEventListener(MouseEvent.CLICK, onBlackClicked);
			this.onCloseFotoEditor();
		}		
		
		public function get isLoaded():Boolean
		{
			return _isLoaded;			
		}
		
		public function set isLoaded(isItLoaded:Boolean):void
		{
			_isLoaded = isItLoaded;
		}	
				
		/*****************************************************
		 * Bestellung
		 * **************************************************/
		
		 private function activateBestellen():void
		{
		/*	if (!btnSave.hasEventListener(MouseEvent.CLICK))
			{
				btnSave.addEventListener(MouseEvent.CLICK, saveClicked, false, 0, true);
			} */
			_blnHasOrdered = true;
		}
		
		private function deactivateBestellen():void
		{
		/*	if (btnSave.hasEventListener(MouseEvent.CLICK))
			{
				btnSave.removeEventListener(MouseEvent.CLICK, saveClicked);
			} */
			_blnHasOrdered = false;
		}
		
		/* 1)	Wenn der Kunde auf Bestellen klickt, checkt es, ob schon etwas im Warenkorb ist.
			2)	Dann checkt es, ob im Rahmen in der Mitte alle Ausschnitte voll sind.
			a.	Wenn schon etwas im Warenkorb ist: 
			i.	Wenn noch kein Ausschnitt gefüllt ist, dann geht es ohne den Rahmen in der Mitte mit der Bestellung weiter.
			ii.	Wenn mindestens 1 Ausschnitt gefüllt ist oder auch alle, dann kommt ein alert „"Ak-tuelle Konfiguration verwerfen und mit der Bestellung fortfahren?" "JA zum Wa-renkorb" "NEIN zurück zum Konfigurator"
			b.	Wenn noch nichts im Warenkorb ist:
			i.	Wenn noch nicht alle Ausschnitte voll sind oder keiner voll ist, gibt es die Nachricht "Sie haben noch nicht alle Ausschnitte gefüllt. ...“
			ii.	Wenn alle Ausschnitte voll sind, gibt es den Rahmen zum Warenkorb und fährt gleich mit der Bestellung fort. */
		private function saveClicked(e:MouseEvent=null):void
		{	
			//???this.update();
			
			//Kunde hasn´t ordered anything to warenkorb yet
			if (!_blnHasOrdered)
			{
				//check if all Ausschnitte are filled, if not give alert
				var blnAllFilled:Boolean = true;			
				blnAllFilled = check_if_allAusschnitte_filled();
				if (blnAllFilled)
				{
					this.addOrderToWarenkorb();
					this.goBestellen();
				}else {
					var fillColor:uint = 0xefefef;
					var sizeRect:Rectangle = new Rectangle(0, 0, 254, 194);
					var strMsg:String = "Sie haben noch nicht alle Ausschnitte gefüllt. Wollen Sie dennoch fortfahren?";
					var alertBx:AlertBox = new AlertBox(this, sizeRect, strMsg, "Achtung", ["Ja", "Nein"], fillColor, 0x000000, 0x626262, onAlertAusschnitte_bestell);
					alertBx.x = stage.stageWidth / 2 - 254 / 2;
					alertBx.y = stage.stageHeight / 2 - 194 / 2;
					stage.addChild(black);
					stage.addChild(alertBx);	
				}
			}else { //Kunde has added something to Warenkorb
				var blnSomeFilled:Boolean = check_if_anyAusschnitte_filled();
				if (blnSomeFilled)
				{
					var fillColor2:uint = 0xefefef;
					var alertW:int = 380;
					var alertH:int = 180;
					var sizeRect2:Rectangle = new Rectangle(0, 0, alertW, alertH);
					var strMsg2:String = "Aktuelle Konfiguration verwerfen und mit der Bestellung fortfahren?";
					var alertBx2:AlertBox = new AlertBox(this, sizeRect2, strMsg2, "Achtung", ["JA", "NEIN zurück zum Konfigurator"], fillColor2, 0x000000, 0x626262, onAlert_cancel_startedOrder);
					alertBx2.x = stage.stageWidth / 2 - alertW / 2;
					alertBx2.y = stage.stageHeight / 2 - alertH / 2;
					stage.addChild(black);
					stage.addChild(alertBx2);
					
				}else {
					this.goBestellen();					
				}				
			}			
		}
		
		//Kunde clicked on Bestellen
		private function onAlertAusschnitte_bestell(buttonNumber:int, abox:AlertBox):void 
		{
			stage.removeChild(black);
			switch (buttonNumber)
			{
				case 0: //ja
				this.addOrderToWarenkorb();
				this.goBestellen();
					break;				
				case 1: //nein
					//do nothing
					break;
				default:
			}
		}
		
		//Kunde clicked on Bestellen
		private function onAlert_cancel_startedOrder(buttonNumber:int, abox:AlertBox):void 
		{
			stage.removeChild(black);
			switch (buttonNumber)
			{
				case 0: //ja
				this.goBestellen(); 
					break;				
				case 1: //nein
					//do nothing
					break;
				default:
			}
		}
		
		private function goBestellen():void
		{
			orderController.savePhotos();
		
			//cover everything with a rect and show progressbar				
			stage.addChild(black);  
			
			stage.addChild(progressPopup);
			progressPopup.addChild(imgBestell);	
			
			formatBest= new TextFormat("Arial, Helvetica, sans-serif", 15, 0x4c4a4a);
			tfBestell = new TextField();
			tfBestell.width = 100;
			tfBestell.background = false;
			tfBestell.border = false;
			tfBestell.autoSize = TextFieldAutoSize.LEFT;
			tfBestell.multiline = false;
			tfBestell.x = progressPopup.width/2 - 110;
			tfBestell.y = pHeight / 2 - 70;
			tfBestell.text = "Ihre Bestellung wird verarbeitet...";
			tfBestell.setTextFormat(formatBest);
			progressPopup.addChild(tfBestell);	
			
			progressCircle = new CircleSlicePreloader(12, 6);
			progressCircle.x = pWidth / 2;
			progressCircle.y = pHeight / 2 - 6;
			progressPopup.addChild(progressCircle);
			
			formatDauer = new TextFormat("Arial, Helvetica, sans-serif", 9, 0x4c4a4a);
			tfDauer = new TextField();
			tfDauer.width = 100;
			tfDauer.background = false;
			tfDauer.border = false;
			tfDauer.autoSize = TextFieldAutoSize.LEFT;
			tfDauer.multiline = false;
			tfDauer.x = 100;
			tfDauer.y = 240;
			tfDauer.text = "Die Dauer ist abhängig von Ihrer Verbindungsgeschwindigkeit!"
			tfDauer.setTextFormat(formatDauer);
			progressPopup.addChild(tfDauer);				
			
			progressbar = new Progressbar();
			
			//waiting msg
			formatWaiting = new TextFormat();
			formatWaiting.color = 0x1c1a1a; 
			formatWaiting.font="Arial, Helvetica, sans-serif"; 
			formatWaiting.bold = true;
			formatWaiting.size = 10;
			tfWaiting = new TextField();
			tfWaiting.width = 100;
			tfWaiting.background = true;
			tfWaiting.border = false;
			//tfWaiting.borderColor = 0xff6600;
			tfWaiting.autoSize = TextFieldAutoSize.LEFT;
			tfWaiting.multiline = true;
			tfWaiting.x = progressPopup.width/2 - 110;
			tfWaiting.y = pHeight/2 + 60;
			
			formatWaiting.color = 0x000000;				
			tfWaiting.text = "waiting";				
			progressPopup.addChild(tfWaiting);
			
			//add error messages textbox to stage
			stage.addChild(sMask);	
			stage.addChild(scrollingErrMsg);	
			
			if (!this.fileUploadComplete)
			{					
				//wait for upload of files to the server to be done				
				this.addEventListener(OrderView.PROGRESS, list_progress_handler, false, 0, true);				
				
				this.addEventListener(OrderView.LIST_COMPLETE, list_complete_handler, false, 0, true);				
				tfWaiting.text = "Dieser Vorgang kann mehrere Minuten dauern.\nVielen Dank für Ihre Geduld. \nWir speichern noch Ihre Bilder.";
				tfWaiting.setTextFormat(formatWaiting);
				return;
			}else {				
				//progressbar.createProgressbar(40, 130, 20, 1, 300);
				//progressPopup.addChild(progressbar);
				//this.bestellen(); 
				this.list_complete_handler();
			} 
		}
		
		private function list_progress_handler(e:Event):void
		{
			if (!blnGotTotal)
			{
				total = this.files_left_to_save + 1;
				blnGotTotal = true;
				
				var prWidth:int = 300;
				progressbar.createProgressbar(40, 130, 20, total, prWidth);
				progressPopup.addChild(progressbar);
			}
			//errorTextField.appendText("Total: "+ total);
			//errorTextField.appendText("progress" + this.files_left_to_save);
			var numb:Number = progressbar.showProgress(this.files_left_to_save + 1);
			//errorTextField.appendText("loaded" + numb);
			if (this.files_left_to_save === 1)
			{
				tfWaiting.text = "Dieser Vorgang kann mehrere Minuten dauern.\nVielen Dank für Ihre Geduld. \nWir speichern noch Ihre Bilder.\n Noch " + this.files_left_to_save + " Bild";
				tfWaiting.setTextFormat(formatWaiting);
			}else {
				tfWaiting.text = "Dieser Vorgang kann mehrere Minuten dauern.\nVielen Dank für Ihre Geduld. \nWir speichern noch Ihre Bilder.\n Noch " + this.files_left_to_save + " Bilder";
				tfWaiting.setTextFormat(formatWaiting);				
			}
			
		}
		
		private function list_complete_handler(e:Event= null):void
		{
			//progressPopup.removeChild(progressbar);	
			this.orderController.checkSavedFotos();
		}
		
		private function bestellen():void
		{			
			tfWaiting.text = "Dieser Vorgang kann mehrere Minuten dauern.\nVielen Dank für Ihre Geduld. \nSpeichern der Daten.";
			tfWaiting.setTextFormat(formatWaiting);
			
			this.orderController.bestellen();			
		}
		
		/****************************************************
		 * functions called from main to update the progress
		 * *************************************************/			
		
		//true, when all uploaded files are done saving to the server
		public function uploadComplete():void
		{
			this.fileUploadComplete = true;
			var event:Event = new Event(OrderView.LIST_COMPLETE);
			dispatchEvent(event);			
		}
		
		public function progress(queued_uploads:int):void
		{
			this.files_left_to_save = queued_uploads;
			var e:Event = new Event(OrderView.PROGRESS);
			dispatchEvent(e);
			//errorTextField.appendText("queued:"+this.files_left_to_save);
		}
		
		//true, when starting to upload files to the server
		public function uploadStarted():void
		{
			//errorTextField.appendText("uploadStarted");
			this.fileUploadComplete = false;
		}
		
		/****************************************************************
		 * Functions for dealing with suborders
		 * **************************************************************/
		
		 //called from OrderModel. The view needs to refresh with the appropriate suborders
		public function update():void
		{	
			//errorTextField.appendText ( "\nupdate");
			
			var intSavedFotosSuccessfully:int = orderModel.intSavedFotosSuccessfully;
			
			//the first time, we need to check, if the formate are loaded first 
			if (_blnShowView === false)
			{
				//errorTextField.appendText ("update: show =false");
				var blnReady:Boolean = this.orderModel.blnFormateReady;
				if (blnReady==true)
				{					
					_blnShowView = true;					
					this.showMenu();				
					this.loadCurrentMotiv();
					this.loadMenus();
					this.loadMotive();					
					 _isLoaded = true;	
					// _content = new OrderUberblick(this);	
				}
			}else {
				
				switch (intSavedFotosSuccessfully)
				{
					case -1: //not saved yet									
						//show total count and total price							
						var arrTotals:Array = this.orderModel.getTotals();			
						
						_tfGesamtAnzahl.text = String(arrTotals[0]) + " Artikel"; 
						_tfGesamtAnzahl.setTextFormat(formatTotalcount);
						_tfGesamtWarenkorb.text = arrTotals[1] + " €";
						_tfGesamtWarenkorb.setTextFormat(fTotalpreis);	
						if (int(arrTotals[0]) > 0)
						{
							this.activateBestellen();
						}else {
							this.deactivateBestellen();
						}
						break;
					case 0://some fotos did not get saved
						this.showFotosNotSaved();
						break;
					case 1://successful				
						this.bestellen();
					//	errorTextField.appendText ("bestellt");
						break;
				}
			}//end else	
				//errorTextField.appendText ("updated");
		}
		
		private function showFotosNotSaved ():void
		{			
			var fillColor:uint = 0xefefef;
			//var sizeRect:Rectangle = new Rectangle( -50, 50, 255, 220);
			var sizeRect:Rectangle = new Rectangle(0, 0, 255, 194);
			var strMsg:String = orderController.strFotos_not_saved;
			var alertBx:AlertBox = new AlertBox(this, sizeRect, strMsg, "Achtung", ["ok"], fillColor, 0x000000, 0x626262, onAlertFotosNotSaved);
			alertBx.x = stage.stageWidth / 2 - 254 / 2;
			alertBx.y = stage.stageHeight / 2 - 194 / 2;
			stage.addChild(black);
			stage.addChild(alertBx);				
		}
		
		//Kunde clicked to add to Warenkorb
		private function onAlertFotosNotSaved(buttonNumber:int, abox:AlertBox):void 
		{
			this.bestellen();
			//bring it back to the top, since black is currently on top of it
			stage.addChild(progressPopup);
			
			//if we allow the Kunde to go back, I´ll have to add more code, so it shows that all fotos from first upload 
			//got saved, new ones not yet...
		/*	stage.removeChild(black);
			switch (buttonNumber)
			{
				case 0: //abbrechen
					//remove Bestellen popup
					this.removeEventListener(OrderView.LIST_COMPLETE, list_complete_handler);		
					this.addEventListener(OrderView.PROGRESS, list_progress_handler);
					//remove error messages textbox to stage
					stage.removeChild(scrollingErrMsg);	
					stage.removeChild(sMask);
					progressPopup.removeChild(tfWaiting);
					formatWaiting = null;
					tfWaiting = null;
					progressbar = null;
					progressPopup.removeChild(tfDauer);	
					formatDauer = null;
					tfDauer = null;
					progressPopup.removeChild(progressCircle);
					progressCircle = null;
					progressPopup.removeChild(tfBestell);
					formatBest = null;
					tfBestell = null;
					progressPopup.removeChild(imgBestell);
					stage.removeChild(progressPopup);
					
					//all fotos that didn´t get saved have been taken out; reset, so Kunde can continue
					orderModel.intSavedFotosSuccessfully = 1; 
				
					break;				
				case 1: //weiter
					this.bestellen();
					break;
				default:
			} */
		}
				 
		/************************************
		 * Utility functions
		 * *********************************/
		//draw a colored rectangle in the _in sprite
		private function drawColorRect(_in:Sprite,color:Number, opacity:Number, nW:Number,nH:Number):void {			
			_in.graphics.beginFill(color, opacity);
			try{
				_in.graphics.drawRect(0, 0, nW, nH);
			} catch (e:Error) {}
			_in.graphics.endFill();
		}
		
	/*	private function isChildOf(displayObjectContainer:DisplayObjectContainer, displayObject:DisplayObject):Boolean 
		{   
			try{
				for (var i:uint = 0; i < displayObjectContainer.numChildren; i++)   
				{     
					if (displayObjectContainer.getChildAt(i) == displayObject) return true;   
				}  
			} catch (e:Error) { trace("error"+e);}
			return false; 
		} */
		
		public static function f_trim($s_base:String):String
		{
			///* remove whitespace
			return($s_base.replace(/^\s+|\s+$/g, ""));
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
	}
}