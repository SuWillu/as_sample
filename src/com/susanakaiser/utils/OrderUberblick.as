/*****************************************************
 * 2010 Guesken, Krefeld
 * Actionscript 3 für Flash 10 Susanne Kaiser 2010
 * Shows the thumbnails of photos ordered for 1 format, in a popup scrollbox
 * 
 ****************************************************/ 

package com.susanakaiser.utils
{	
	
	import com.susanakaiser.model.MotivOrder;
	import com.susanakaiser.model.SubOrder;
	import flash.display.MovieClip;
	import flash.display.Shape;	
	import flash.display.BitmapData;
	import flash.events.*;	
	import flash.text.TextField;
	import flash.text.TextFormat;	
	import com.susanakaiser.controls.ScrollBox;
	import com.susanakaiser.controls.ScrollBar;
	import com.leebrimelow.ui.ScrollBarEvent;
	import flash.filters.DropShadowFilter;
	import com.susanakaiser.view.FotoView;
	import com.susanakaiser.view.OrderView;	
	import com.susanakaiser.view.OrderItemLocation;
	import com.susanakaiser.events.ModifyOrderEvent;
	
   public class OrderUberblick extends MovieClip
   {	  
	   private var _fTotals:TextFormat = new TextFormat();	  
	   private var _scrollbox:ScrollBox;
	   private var _scrollbar:ScrollBar;	  
	   private var _strProduct:String;
	   private var startX:Number = 0;
	   private var startY:Number = 0;
	   private var _mainView:OrderView;
	   public var arrLocations:Array; //array of ItemLocations
	   
	   private var testTextField:TextField;
 
      public function OrderUberblick(view:OrderView)
      {
		_mainView = view;
		initMenu();
		
	/*	//FOR TESTING ONLY
		testTextField = new TextField();
		testTextField.x = 0;
		testTextField.y = 0;
		testTextField.background = false;
		testTextField.multiline = true;
		testTextField.width = 200;
		testTextField.height = 200;
		testTextField.text= "product content";
		addChild(testTextField); */
      }
	  
	  private function initMenu():void
	  {
		  
		 /*******************************************
		 * Scrollbox setup
		 * ******************************************/			 
		 var thumbWidth:int = 20;	
		 var howManyToShow:int = 2;
		
		//scrollbox
		//set up the thumbnailHolder						
		var spacing:Number = 10;
		var scrollWide:int = 565;
		var itemHeight:int = 100;
		var limit:int = 100; //the number of rows that can be in the OrderUberblick
		var fillColor:uint = 0xffffff;
		var strokeColor:uint = 0xd6d6d6;		
		_scrollbox = new ScrollBox(scrollWide, itemHeight, limit, howManyToShow, fillColor, strokeColor);					
		_scrollbox.x = 0;
		_scrollbox.y = 0;
		_scrollbox.name = "scrollbox";		
		this.addChild(_scrollbox);
		
		//scrollbar		
		_scrollbar = new ScrollBar(stage, thumbWidth, itemHeight * howManyToShow);		
		_scrollbar.x = _scrollbox.x + scrollWide+2;
		_scrollbar.y = _scrollbox.y;
		_scrollbar.name = "scrollbar";
		_scrollbar.visible = false;
		this.addChild(_scrollbar);
		try{
			_scrollbar.addEventListener(ScrollBarEvent.VALUE_CHANGED, onScroll, false, 0, true);	
		}catch (e:Error) { trace("error" + e); }		
	  }
	  
	  public function fillScrollbox(arrResults:Array):void
	  {	
		  arrLocations = new Array();
		  var arrMotivOrders:Array = arrResults;	
		  var objMotivOrder:MotivOrder = new MotivOrder();		  		
		  var firstX:Number = 3;
		  var firstY:Number = 5;
		  var nextX:Number = firstX;
		  var nextY:Number = firstY;		  
		  var suborder:SubOrder;
		  
		  for (var i:int = 0; i < arrMotivOrders.length; ++i)
			{	
				if (arrMotivOrders[i] != null) 
				{
					objMotivOrder = MotivOrder(arrMotivOrders[i]);					
					var itemLoc:OrderItemLocation = new OrderItemLocation();
					var itemW:int = 560;
					var itemH:int = 100;
					var fillColor:uint = 0xffffff;				
					itemLoc.createItemLocation(i, itemW, itemH, fillColor);
					itemLoc.x = firstX;
					itemLoc.y = nextY;		
					itemLoc.attachItem(i, objMotivOrder);
					nextY = nextY + 105;
								
					if (i === 2)
					{
						_scrollbar.visible = true;
						_scrollbar.activate();
					}	
					var ds:DropShadowFilter = new DropShadowFilter(4, 45, 0, 1, 4, 4, 1, 1, false, false, false);
					itemLoc.filters = [ds];
					_scrollbox.addImage(itemLoc);
					this.arrLocations.push(itemLoc);
				}
			} 
			//this.addEventListener(OrderItemLocation.DELETE, onDeleteMotivorder, false, 0, true);
	  }
	  
	/* for testing only 
	  private function onDeleteMotivorder(e:ModifyOrderEvent):void
		{
	testTextField.text = "delete bubbled";
		} */
	  
	/*  private function openFotoeditor(e:MouseEvent):void
	  {
		  testTextField.text = "open";
		  var fotoview:FotoView = e.target as FotoView;
		  _mainView.openFotoeditor(fotoview, fotoview.strProduct);
	  } 	  
	 */	  
	 
	  //scroll the scrollbox with photos, edit and delete buttons
		private function onScroll(e:ScrollBarEvent):void
		{
			
			_scrollbox.sbChange(e.scrollPercent);
		}
		
		public function emptyScrollbox():void
		{
			if (_scrollbar.visible)
			{
				_scrollbar.moveThumbHome();				
			}
			_scrollbar.visible = false;				
			//clean out the box
			_scrollbox.removeImages();
			for (var i:int = 0; i < arrLocations.length; ++i)
			{
				arrLocations[i].deleteItemLocation();				
				arrLocations[i] = null;
			} 
			arrLocations = null; 
		}
    }	  
}