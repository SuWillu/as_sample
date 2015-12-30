/*****************************************************
 * 2010 Guesken, Krefeld
 * Actionscript 3 für Flash 10 Susanne Kaiser 2010
 *
 * adapted from the tutorial at 
 * http://blog.sugarpillfactory.com/?p=171
 ****************************************************/ 

package com.susanakaiser.utils
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.*;
	import caurina.transitions.Tweener;
	import flash.text.TextFormat;
	import com.susanakaiser.events.DropDownSelectEvent;
	import com.susanakaiser.utils.LinkBox;
	
	//import flash.text.TextField;
	
   public class DropDownMenu extends MovieClip
   {
	   private var _names:Array;
	   private var _defaultSelected:String;
	   private var _selected:String;
	   private var _menuWidth:Number;
	   private var _menuHeight:Number;
	   private var _textFormat:TextFormat = new TextFormat();
	   private var menuTitle:LinkBox;
	   private var linkBox:LinkBox;
	   private var _arrGroupnames:Array;
	   private var blnShowing:Boolean = false;
	 //  private var testTextField:TextField;
 
      public function DropDownMenu(names:Array, title:String, tFormat:TextFormat, width:Number, height:Number, arrGroups:Array =null)
      {
        _names = names;
		_defaultSelected = title;
		_textFormat = tFormat;
		_menuWidth = width;
		_menuHeight = height;
		_arrGroupnames = arrGroups;
		
		initMenu();
		
		/*	//FOR TESTING ONLY
			testTextField = new TextField();
			testTextField.x = 300;
			testTextField.y = 0;
			testTextField.background = true;			
			testTextField.multiline = true;
			testTextField.width = 50;
			testTextField.text= "test";
			addChild(testTextField);*/
      }
	  
	  private function initMenu():void
	  {
		  for(var i:int=0;i<_names.length;i++)
		  {
			  var menuBorder:uint = 0xED8000;
			  linkBox = new LinkBox(_names[i],_textFormat, _menuWidth, _menuHeight, menuBorder);
			  addChild(linkBox);
			  linkBox.alpha = 0;
			  
			  var blnClickable:Boolean = true;
			  
			   //if it´s a groupname, don´t make it clickable
			  if (_arrGroupnames !== null)
			  {
				  for (var j:int = 0; j < _arrGroupnames.length; j++)
				  {
					  if (_names[i] == _arrGroupnames[j])
					  {
						  blnClickable = false;
					   }
				  }
			  }
			  if (blnClickable)
			  {
				try{
					linkBox.addEventListener(MouseEvent.CLICK, select, false, 0, true);
				}catch (e:Error) 
				{ //trace ("Error adding Click listener" +e); 
				}
			  }
		  }
		  var titleBorder:uint = 0x7f9db9;
		  menuTitle = new LinkBox(_defaultSelected, _textFormat, _menuWidth, _menuHeight, titleBorder);
		  menuTitle.name = "mainBox";
		  addChild(menuTitle);	
		
	  }
	  
	  public function showMenu(e:Event = null):void
	  {
		   this.addEventListener(MouseEvent.ROLL_OUT, hideMenu, false, 0, true);
		    menuTitle.removeEventListener(MouseEvent.MOUSE_OVER, showMenu);
		  try
		  {
			  for(var i:int = 0;i<this.numChildren;i++)
			  {
				  var tempChild:* = this.getChildAt(i);
				  var startY:int = tempChild.height;
				  if(tempChild != e.currentTarget)
				  {
					 Tweener.addTween(tempChild, { y:(startY + (tempChild.height) * i), alpha:1, time:.7, transition:"easeOutCubic" } );
				  }
			  }				 
			 // this.addEventListener(MouseEvent.MOUSE_OUT, hideMenu, false, 0, true);
			  //testTextField.text = "rolled out";
		  }catch (e:Error) 
		  { //trace ("showMenu error"+e); 
		  }
		   blnShowing = true;
	  }
	  
	  public function hideMenu(e:Event = null):void
	  {	
		  this.removeEventListener(MouseEvent.ROLL_OUT, hideMenu);
		 // menuTitle.addEventListener(MouseEvent.MOUSE_OVER, showMenu, false, 0, true);
		  try
		  {
			  for(var i:int = 0;i<this.numChildren;i++)
			  {
				 var tempChild:* = this.getChildAt(i);
				  if(tempChild.y !=0)
				  {
					Tweener.addTween(tempChild, {y:0, time:.7, alpha:0, transition:"easeOutCubic"});
				  }
			  }
			  //testTextField.text = "hidden";
		  }catch (e:Error) 
			{ //trace ("hideMenu error"+e); 
			}
		blnShowing = false;			
		//this.removeEventListener(MouseEvent.MOUSE_OUT, hideMenu);
	  }
	  
	  //the user has clicked on a menu item, place that in the title box
	  private function select(e:Event):void
	  {
		  menuTitle.select(e.currentTarget.selected);
		  hideMenu();
		  try {		 
			  //create custom event, which can be listened for from OrderView
			  dispatchEvent(new DropDownSelectEvent(e.currentTarget.selected));
		 }catch (e:Error) 
		 { //trace ("select error"+e); 
		}
	  }
	  
	  //the user has clicked on a photo, show the former selection
	  public function setSelection(selected:String):void
	  {
		  menuTitle.select(selected);
	  }
	  
	   //the user has accepted, return the selection
	  public function getSelection():String
	  {
		  return menuTitle.selected;
	  }
	  
	  public function defaultPos():void
	  {
		   menuTitle.select(_defaultSelected);
	  }	 
	  
	  public function activate():void
	  {
		  try
		  {
			menuTitle.addEventListener(MouseEvent.MOUSE_OVER, showMenu, false, 0, true);
		  }catch (e:Error) 
		  { //trace ("activate error"+e); 
		  }
	  }
	  
	  //called by the dropdownbutton
	  public function rollMenu():void
	  {
		  if (blnShowing)
		  {
			  rollbackMenu();
		  }else {
			 rolloutMenu(); 
		  }
	  }
	  
	  public function rolloutMenu():void
	  {
		  try
		  {
			  for(var i:int = 0;i<this.numChildren;i++)
			  {
				  var tempChild:* = this.getChildAt(i);
				  var startY:int = tempChild.height;
				  
				  if(tempChild != this.getChildByName("mainBox"))
				  {
					 Tweener.addTween(tempChild, {y:(startY+(tempChild.height)*i), alpha:1, time:.5, transition:"easeOutCubic"});
				  }
			  }	
			 // menuTitle.removeEventListener(MouseEvent.MOUSE_OVER, showMenu);
			 // this.addEventListener(MouseEvent.ROLL_OUT, hideMenu, false, 0, true);
			  //this.addEventListener(MouseEvent.MOUSE_OUT, hideMenu, false, 0, true);
			  //testTextField.text = "rolled out";
		   }catch (e:Error) 
		   { //trace ("rolloutMenu error"+e); 
		   }
		   blnShowing = true;
	  }
	  
	  public function rollbackMenu():void
	  {
		  try
		  {
			//  menuTitle.addEventListener(MouseEvent.MOUSE_OVER, showMenu, false, 0, true);
			//  this.removeEventListener(MouseEvent.ROLL_OUT, hideMenu);
			  //this.removeEventListener(MouseEvent.MOUSE_OUT, hideMenu);
			  
			  for(var i:int = 0;i<this.numChildren;i++)
			  {
				 var tempChild:* = this.getChildAt(i);
				  if(tempChild.y !=0)
				  {
					Tweener.addTween(tempChild, {y:0, time:.5, alpha:0, transition:"easeOutCubic"});
				  }
			  }
			 
			  
		  }catch (e:Error) 
		  { 
			  //trace ("rolbackMenu error"+e); 
		  }
		  blnShowing = false;
	  } 
   }	  
}
