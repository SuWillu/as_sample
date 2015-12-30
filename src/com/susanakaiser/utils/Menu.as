/*****************************************************
 * 2010 Guesken, Krefeld
 * Actionscript 3 für Flash 10 Susanne Kaiser 2010
 * Shows format dropdown menu with popup scrollbox
 * 
 ****************************************************/ 

package com.susanakaiser.utils
{
	import com.susanakaiser.controls.ScrollBar;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Shape;	
	import flash.events.*;
	import caurina.transitions.Tweener;
	import flash.filters.GlowFilter;
	import flash.text.TextFormat;
	import com.susanakaiser.events.DropDownSelectEvent;
	import com.susanakaiser.controls.ScrollBox;
	import com.leebrimelow.ui.ScrollBarEvent;
	import flash.filters.DropShadowFilter;
	import com.susanakaiser.controls.SimplePopup;
	import com.susanakaiser.events.PopupEvent;
	import com.susanakaiser.view.CustomButton;
	
	import flash.text.TextField;
	
   public class Menu extends MovieClip
   {
	   private var _arrNames:Array;
	   private var _defaultSelected:String;
	   private var _selected:String;
	   private var _menuWidth:Number;
	   private var _menuHeight:Number;
	   private var _textFormat:TextFormat = new TextFormat();
	   private var menuTitle:LinkBox;
	   private var _arrGroupnames:Array;
	   private var _arrLinkBoxes:Array = [];
	   private var _blnFormate_expanded:Boolean = false;	   
	   private var popup:SimplePopup;
	   private var _bottomText:String;
	   private var _scrollbox:ScrollBox;
	   private var _scrollbar:ScrollBar;
	   private var btnFormat:CustomButton;
	   private var _titleBorder:uint = 0x7f9db9;
	   private var howManyToShow:int;
	   private var thumbWidth:int;	   
	   private var tfGroesse_Preis:TextField;
	   private var _selectedLinkbox:LinkBox;
	   private var _selectedColor:uint = 0x316ac5;
 
      public function Menu(tFormat:TextFormat, width:Number, height:Number)
      {
        _textFormat = tFormat;
		_menuWidth = width;
		_menuHeight = height;	
		thumbWidth = 10;		
      }
	  
	  //------------------functions content of menu-------------	  
	  //the menu needs to be created new everytime the fotoeditor opens, because there is a new list of format with 
	  //different number of formate each time
	  public function fillMenu(names:Array, title:String, arrGroups:Array =null):void
	  {
		_arrNames = names;
		_defaultSelected = title;		
		_arrGroupnames = arrGroups;	
		
		howManyToShow = 4;
		if (_arrNames.length < howManyToShow)
		{
			howManyToShow = _arrNames.length;
		}
		
		/*******************************************
		 * Scrollbox setup
		 * ******************************************/			
		
		//scrollbox
		var numRows:int;		
		numRows = howManyToShow;		
		var fillColor:uint = 0xffffff;
		_scrollbox = new ScrollBox(_menuWidth+1,_menuHeight, numRows, howManyToShow, fillColor);
		_scrollbox.x = 0;
		_scrollbox.y = 0;
		_scrollbox.name = "scrollbox";		
		this.addChild(_scrollbox);
		
		//scrollbar
		
		var iHeight:int = _menuHeight * howManyToShow + 1;
		
		_scrollbar = new ScrollBar(stage, thumbWidth, iHeight);		
		_scrollbar.x = _scrollbox.x + _menuWidth+2;
		_scrollbar.y = _scrollbox.y;
		_scrollbar.name = "scrollbar";
		_scrollbar.visible = false;
		this.addChild(_scrollbar);
		
		try{
			_scrollbar.addEventListener(ScrollBarEvent.VALUE_CHANGED, onScroll, false, 0, true);	
		}catch (e:Error) { trace("error" + e); }
		
	/*	menuTitle = new LinkBox(_defaultSelected, _textFormat, _menuWidth, _menuHeight, _titleBorder);
		menuTitle.name = "mainBox";
		menuTitle.x = 0;
		menuTitle.y = 0;
		this.addChild(menuTitle);	*/	
		 	
		//choices
		  var nextY:int = 0;
		  for(var i:int=0;i<_arrNames.length;i++)
		  {
			   var blnClickable:Boolean = true;			  
			   //if it´s a groupname, don´t make it clickable
			  if (_arrGroupnames !== null)
			  {
				  for (var j:int = 0; j < _arrGroupnames.length; j++)
				  {
					  if (_arrNames[i] == _arrGroupnames[j])
					  {
						  blnClickable = false;
					   }
				  }
			  }
			  
			  var boxTextFormat:TextFormat = new TextFormat("Arial, Helvetica, sans-serif",11,0x999999,true);
			  if (blnClickable)
			  {
				boxTextFormat = _textFormat;
			  }
			  var menuBorder:uint = 0xffffff;
			  var choiceBgColor:uint;
			  if (i % 2 == 0)
			  {
				 choiceBgColor = 0xeaeaea; 
			  }else {
				  choiceBgColor = 0xffffff;
			  }
			  var linkBox:LinkBox = new LinkBox(_arrNames[i], boxTextFormat, _menuWidth, _menuHeight, menuBorder, choiceBgColor);
			  _arrLinkBoxes.push(linkBox);
			  linkBox.y = nextY;
			  this._scrollbox.addImage(linkBox);
			  //linkBox.alpha = 0;
			  nextY += _menuHeight;	
			 
			  if (blnClickable)
			  {
				try{
					linkBox.addEventListener(MouseEvent.CLICK, select, false, 0, true);						
					//linkBox.addEventListener(MouseEvent.ROLL_OVER, onHover, false, 0, true);						
				}catch (e:Error) 
				{ //trace ("Error adding Click listener" +e); 
				}
			  }		  
			 
		  }	//end for	
		  
		  //make the first one the selected one (can´t do it earlier, because it changes the textcolor for all)
		  var chosenLinkbox:LinkBox = _arrLinkBoxes[0]; 
		  chosenLinkbox.changeColor (_selectedColor);
		   _selectedLinkbox = chosenLinkbox;
		   _selected = _arrNames[0];
		   
		   if (_arrNames.length > howManyToShow)
		  {
			_scrollbar.visible = true;
			_scrollbar.activate();				
		  }else {
			  _scrollbar.showTrackwithoutThumb();
			  _scrollbar.visible = true;
		  }
			//draw a box around it
			var box:Sprite = new Sprite();
			box.graphics.lineStyle(2, 0x9e9e9e);
			try{ box.graphics.drawRect(_scrollbox.x - 2, _scrollbox.y - 2, _scrollbox.width + _scrollbar.width + 4, _scrollbox.boxHeight + 4);}catch(e:Error){}	
			this.addChild(box);	
	  }	  
	  
	  //the user has clicked on a menu item, place that in the title box
	  private function select(e:Event):void
	  {
		  var lb:LinkBox = e.target as LinkBox;
		  lb.changeColor (_selectedColor);
		  
		  //reset last selected linkbox
		  if (_selectedLinkbox != null)
		  {
			 // _selectedLinkbox.addEventListener(MouseEvent.ROLL_OUT, onOut, false, 0, true);			 
			  _selectedLinkbox.changeColorBack();			  	  
		  }		  
		  
		  _selectedLinkbox = lb;
		  _selected = e.currentTarget.selected;
		  
		 // lb.removeEventListener(MouseEvent.ROLL_OUT, onOut);
		  //lb.addEventListener(MouseEvent.ROLL_OVER, onHover, false, 0, true);
		 
		//  menuTitle.select(e.currentTarget.selected);
		  try {		 
			  //create custom event, which can be listened for from OrderView
			  dispatchEvent(new DropDownSelectEvent(e.currentTarget.selected));			  
		 }catch (e:Error) 
		 { //trace ("select error"+e); 
		}
	  }
	  
	/*  //the user has clicked on a photo, show the former selection
	  public function setSelection(selected:String):void
	  {
		  menuTitle.select(selected);
	  } */
	  
	   //the user has accepted, return the selection
	  public function getSelection():String
	  {
		  return _selected;
	  }
	  
	/*  public function defaultPos():void
	  {
	   menuTitle.select(_defaultSelected);
	  }	 */
	  
	/*  //hovering over menu choice highlights the item
		private function onHover(e:MouseEvent):void
		{			
			var lb:LinkBox = e.target as LinkBox;
			lb.removeEventListener(MouseEvent.ROLL_OVER, onHover);
			lb.addEventListener(MouseEvent.ROLL_OUT, onOut, false, 0, true);			
			lb.changeColor (_selectedColor);
		} */
		
	/*	//moving off menu choice brings original coloring back
		private function onOut(e:MouseEvent):void
		{
			var lb:LinkBox = e.target as LinkBox;
			lb.removeEventListener(MouseEvent.ROLL_OUT, onOut);
			lb.addEventListener(MouseEvent.ROLL_OVER, onHover, false, 0, true);
			lb.changeColorBack ();
		}	*/
	  
	  //------------------functions related to scrollbox-------------
	  //scroll the scrollbox
		private function onScroll(e:ScrollBarEvent):void
		{
			
			_scrollbox.sbChange(e.scrollPercent);
		}		
   }	  
}