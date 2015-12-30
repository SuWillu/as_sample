package com.susanakaiser.view
{		
	import flash.display.MovieClip;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	//import flash.display.*;
	import flash.geom.*;
	import flash.events.MouseEvent;	
	import com.susanakaiser.model.SubOrder;
	import com.susanakaiser.view.CustomButton;		
	import flash.geom.Matrix;	

	import com.susanakaiser.view.FotoView;	
	
	import flash.text.TextFieldAutoSize;
	import flash.display.Sprite;
	import flash.utils.Dictionary;
	import com.cartogrammar.drawing.DashedLine;
	import com.susanakaiser.view.LoadedImage;
	
	//for GalerieRahmen
	import com.susanakaiser.model.MotivModel;
	import com.susanakaiser.model.MotivOrder;
	import com.susanakaiser.model.BildModel;	
	
	//for testing
	import flash.text.*;
	
	public class PasspartoutAusschnitt extends MovieClip
	{
		private var bg:Sprite;
		
		public var bmp:Bitmap;//the foto	 
		private var _maxWidth:int = 0; //maxSize of Foto in popup
	    public var _product:String = "";
	   
		private var _fotoformatMask:Sprite; 
	     
	    private var _objBildausschnitt:BildModel;	  
	    private var _dashedLine1:DashedLine;
	    private var _dashedLine2:DashedLine;
	    
	    private var _btnVerschieben:CustomButton;
	    private var _btnSkalieren:CustomButton;
	    private var left:Number;
	    private var top:Number;
	    private var right:Number;
	    private var bottom:Number;
	    
	    private var _myOrderView:OrderView;
	    private var _fotoview:FotoView;
	   	   
	    //----for foto editing---
	    //top left corner of foto
	    private var _startX:Number;
	    private var _startY:Number;
	    
	    //top left corner of Ausschnitt - defined by format to foto ratio
	    private var _topleftCornerX:Number; 
	    private var _topleftCornerY:Number; 
	    
	    //top left corner of Ausschnitt - defined by current position of Ausschnitt
	    private var _currentCornerX:Number; 
	    private var _currentCornerY:Number; 
	    
	    //current foto size in Flash
	    private var _fotoW:Number;
	    private var _fotoH:Number;
	    
	    //current format size in Flash
	    private var _formatW:Number;
	    private var _formatH:Number;
	    
	    private var _currentFormatW:Number;
	    private var _currentFormatH:Number;
	    
	    //actual format size in pixels oriented like the foto
	    private var _pixelW:Number;
	    private var _pixelH:Number;
		private var _fotoRotation:int;
	    
	    //difference between mouse and the corner that determines the move (for skaling the bottom right, for moving top left)
	    private var _diffX:Number;
	    private var _diffY:Number;
	   
	    //position of fotoeditor in orderview
	    private var fotoeditorX:int = 150;
	    private var fotoeditorY:int = 50;
	    
	    private var _intIndx_of_Ausschnitt:int = -1;
	    private var _mMotiv:MotivModel = new MotivModel();
		private var _frameRotation:int = 0;
	    private var _currEdge:int = 0;  //It´s the 5mm edge in pixels
	    private var edgeMask:Sprite;
	   
		private var mcEditingBg:MovieClip;		  
	    private var _edgeWidth_in_mm:Number = 5;
		
		private var _mcPicture:MovieClip;
		
	//private var testTextField:TextField;
		
		public function PasspartoutAusschnitt(maxSize:int, view:OrderView):void
		{	
			bmp = new Bitmap();
			_myOrderView = view;					
			//_maxWidth = maxSize;
			this.init();
		}
		
		public function init():void
		{
			//---------------verschieben Button----------	
			var btnWv:int = 53;
			_btnVerschieben = new CustomButton("images/verschieben.png", btnWv, btnWv);	
			
			//---------------skalieren button----------	
			var btnWs:int = 52;
			_btnSkalieren = new CustomButton("images/skalieren.png", btnWs, btnWs);				
			
			//bg is the background. Everything in here will be attached to it. That way, when
			//the whole PasspartoutAusschnitt gets turned, everything gets turned with it.  //??? may not be needed any more
			bg = new Sprite();					
			bg.x = 0;
			bg.y = 0;
			this.addChild(bg);
			
			//mcEditingBg is the background, which turns with bmp, to trick the rotation point to be in the center
			mcEditingBg = new MovieClip();	
			//center the movieclip in the fotoeditor, so that it´s rotation point will be the center				
			mcEditingBg.x = 0;
			mcEditingBg.y = 0;
			bg.addChild(mcEditingBg);
			mcEditingBg.addChild(bmp);		
		}
		
		
		//for filling the format scrollbox popup and adding the foto, called from OrderView 
		public function openFotoEditor(fotoviewImg:FotoView, strProduct:String, mMotiv:MotivModel, intIndx:int, frameRotation:int):void 
		{
			_frameRotation = frameRotation;
			_fotoRotation = -_frameRotation;
			_fotoview = fotoviewImg;
			_product = strProduct;
			_mMotiv = mMotiv;
			_intIndx_of_Ausschnitt = intIndx;
			_objBildausschnitt = mMotiv.arrBilder[_intIndx_of_Ausschnitt];			
						
			//foto was already resized in main to fit into 500 x 500			
			setFoto();
			
			//adding a new foto, whether the Rahmen is turned or not, the foto needs to be upright. Only the format needs 
			//to be turned  
			mcEditingBg.rotation = 0;
			//TODO: take the code I need out of the function turnFoto and put it here
			this.turnFoto(0);						
		}
		
		//setter for the bitmap data
		private function setFoto():void 
		{
			_fotoW = _fotoview.bmp.bitmapData.width;
			_fotoH = _fotoview.bmp.bitmapData.height;
			
			var copiedBitmapData:BitmapData=new BitmapData(_fotoW, _fotoH, true, 0xFFFFFFFF);
			copiedBitmapData.draw(_fotoview.bmp.bitmapData);
			
			try{
				//if the old value is not null dispose the data
				if (bmp.bitmapData!=null) {
					bmp.bitmapData.dispose();
				}
				//set the new data
				bmp.bitmapData=copiedBitmapData;
		
				//force the smoothing
				bmp.smoothing=true;		  
				bmp.alpha = 1;
				this.scaleX=1;
				this.scaleY = 1;
				/*	Because in as3, the registration point is on the top left corner and cannot be changed with code,
				*	we create a bg movieclip with its top left corner the center of the fotoeditor, then lay the foto
				*	on top of it, offset , so that it´s corner is half up and to the left. This way we trick it so that it rotates 
				*	around its center. */				
				
				bmp.x = Math.floor(-bmp.bitmapData.width / 2);
				bmp.y = Math.floor(-bmp.bitmapData.height / 2);				
				
			} catch (e:Error) {}
		} 
		
		//on opening fotoeditor or changing format, it adjusts the Ausschnitt -according to the format- to the foto
	    private function getResizedFormat(firstCurrFoto:Number, secondCurrFoto:Number, firstFormat:Number, secondFormat:Number ):Array
	   {		   
		   var ratio1:Number =  firstFormat / firstCurrFoto ;
		   var ratio2:Number =  secondFormat / secondCurrFoto;
		   var chosenRatio:Number = 0;
		   
		   var resizedFirst:Number = 0;
		   var resizedSecond:Number = 0;
		   var ausschnittWidth:Number = 0;
		   var ausschnittHeight:Number = 0;
		   
		   //testTextField.appendText ("\na" + firstCurrFoto + " b" + secondCurrFoto + " c" + firstFormat + " d" + secondFormat);
		   // testTextField.text = ("ratio1: " + ratio1 + "ratio2: " + ratio2);
		   
		   //figure out, how to fit the largest possible version of the format into the displayed picture
		   if (ratio1 ===ratio2)//same "format fits"
		   {
			   resizedFirst = firstCurrFoto;
			   resizedSecond = secondCurrFoto;	
			   chosenRatio = ratio1;				 
		   }else {	
			   //keep the fotoHeight, change fotoWidth
			   if (ratio1 < ratio2)
			   {
				   resizedFirst = Math.floor(firstFormat / ratio2);
				   resizedSecond = secondCurrFoto;	
				   chosenRatio = ratio2;
				    
			   }else { //keep the fotoWidth, change fotoHeight
				   resizedFirst  = firstCurrFoto;
				   resizedSecond = Math.floor(secondFormat / ratio1);
				   chosenRatio = ratio1;				  
			   }
		   }		   
		   var arrSize:Array = [];
		   arrSize[0] = resizedFirst;
		   arrSize[1] = resizedSecond; 
		   arrSize[2] = chosenRatio;
		   return arrSize;
		}
		
		//drawFormatMask gets called, when the fotoeditor is first opened, it displays the foto with a default ausschnitt
		private function drawFormatMask(startX:Number, startY:Number, fotoW:Number, fotoH:Number, formatW:Number, formatH:Number, ratioEdge:Number) : void 
		{ 		
			_fotoformatMask = new Sprite(); 
			
			//the top left corner of the foto in fotoeditor
			_startX = startX;
			_startY = startY;
			
			//the current width & height of the bmp in pixel
			_fotoW = fotoW;
			_fotoH = fotoH;
			
			//
			_formatW = formatW;
			_formatH = formatH;
			
			_currentFormatW = formatW;
			_currentFormatH = formatH;
			
			//center the mask
			_topleftCornerX = _startX + (fotoW - _formatW) / 2;
			_currentCornerX = _topleftCornerX;			
			_topleftCornerY = _startY + (fotoH - _formatH) / 2;
			_currentCornerY = _topleftCornerY;
			
			//draw the 50%alpha mask, and the other one inside it cuts the window into it.
			_fotoformatMask.graphics.beginFill(0x000000); 
			_fotoformatMask.graphics.drawRect(_startX, _startY,_fotoW, _fotoH); 
			_fotoformatMask.graphics.moveTo(_topleftCornerX,_topleftCornerY); 
			_fotoformatMask.graphics.drawRect(_topleftCornerX,_topleftCornerY, _formatW, _formatH); 
			_fotoformatMask.graphics.endFill(); 
			_fotoformatMask.alpha = .6;
			
			//find out the topleft point of the shownAusschnitt inside the edge, which will be under the matting.	
			edgeMask = new Sprite();			
			//find the ratio of the actual size edge to the size edge currently in flash
			var ratioEdge:Number = _objBildausschnitt.Breite_in_mm / _currentFormatW;
			_currEdge = Math.floor(_edgeWidth_in_mm / ratioEdge );
			
		//testTextField.appendText("edge:" + _currEdge + "ratioEdge: " + ratioEdge + "pixelw:" + _objBildausschnitt.actualPxlBreit + "_currentFormatW" + _currentFormatW);
		
			//draw the edge, and the shown ausschnitt inside it cuts the window into it.
			edgeMask.graphics.beginFill(0x000000); 
			edgeMask.graphics.drawRect(_topleftCornerX + 2,_topleftCornerY + 2, _formatW -4, _formatH -4); 
			edgeMask.graphics.moveTo(_topleftCornerX + _currEdge,_topleftCornerY + _currEdge); 
			edgeMask.graphics.drawRect(_topleftCornerX + _currEdge,_topleftCornerY + _currEdge, _formatW - (2 * _currEdge), _formatH - (2 * _currEdge)); 
			edgeMask.graphics.endFill(); 
			edgeMask.alpha = .2;	
			
			var topleftX:int = _topleftCornerX + _currEdge;
			var topleftY:int = _topleftCornerY + _currEdge;
			
			_dashedLine1 = new DashedLine(1,0x000000,new Array(8,4,8,4));
			_dashedLine1.moveTo(_topleftCornerX + _currEdge + 1,_topleftCornerY + _currEdge + 1);
			_dashedLine1.lineTo(_topleftCornerX - _currEdge + _formatW - 1,_topleftCornerY + _currEdge + 1);
			_dashedLine1.lineTo(_topleftCornerX - _currEdge + _formatW - 1, _topleftCornerY - _currEdge + _formatH - 1);
			_dashedLine1.lineTo(_topleftCornerX + _currEdge + 1, _topleftCornerY - _currEdge + _formatH - 1);
			_dashedLine1.lineTo(_topleftCornerX + _currEdge + 1,_topleftCornerY + _currEdge + 1);
			this.bg.addChild(_dashedLine1);
			
			_dashedLine2 = new DashedLine(1,0xffffff,new Array(4,8,4,8));
			_dashedLine2.moveTo(_topleftCornerX + _currEdge + 1,_topleftCornerY + _currEdge + 1);
			_dashedLine2.lineTo(_topleftCornerX - _currEdge + _formatW - 1,_topleftCornerY + _currEdge + 1);
			_dashedLine2.lineTo(_topleftCornerX - _currEdge + _formatW - 1, _topleftCornerY - _currEdge + _formatH - 1);
			_dashedLine2.lineTo(_topleftCornerX + _currEdge + 1, _topleftCornerY - _currEdge + _formatH - 1);
			_dashedLine2.lineTo(_topleftCornerX + _currEdge + 1,_topleftCornerY + _currEdge + 1);			
			this.bg.addChild(_dashedLine2);
			
			this.bg.addChild(_fotoformatMask); 
			this.bg.addChild(edgeMask); 
						
			//button Verschieben
			_btnVerschieben.x = _topleftCornerX + _currEdge + 3;
			_btnVerschieben.y = _topleftCornerY + _currEdge + 3;
			_btnVerschieben.addEventListener(MouseEvent.MOUSE_DOWN, onVerschieben, false, 0, true);  
			this.bg.addChild(_btnVerschieben);
			
			//button Skalieren
			_btnSkalieren.x = _topleftCornerX - _currEdge + _formatW - 56;
			_btnSkalieren.y = _topleftCornerY - _currEdge + _formatH - 56;
			_btnSkalieren.addEventListener(MouseEvent.MOUSE_DOWN, onSkalieren, false, 0, true);  
			this.bg.addChild(_btnSkalieren);
		} 
		
				//called from orderview - when Kunde wants to reedit a foto
		public function reopenFotoEditor(fotoviewImg:FotoView, strProduct:String, mMotiv:MotivModel, intIndx:int, suborder:SubOrder, frameRotation:int):void 
		{	
			var addtnlFrameRotation:int = 0;
			//if the frame was turned after the ausschnitt was determined, find out the difference
			if (suborder.frameRotation != frameRotation)
			{
				addtnlFrameRotation = frameRotation - suborder.frameRotation;
			}
			
			 _frameRotation = frameRotation;			
		//testTextField.appendText("frameRot: " + frameRotation + "suborder rot: " + suborder.frameRotation + "rot b4: " + suborder.rotationB4);
			_fotoview = fotoviewImg;
			_product = strProduct;
			_mMotiv = mMotiv;
			_intIndx_of_Ausschnitt = intIndx;
			_objBildausschnitt = mMotiv.arrBilder[_intIndx_of_Ausschnitt];
			
		/*	try{
				//if the old value is not null dispose the data
				if (bmp.bitmapData!=null) {
					bmp.bitmapData.dispose();
				}
				
				//---resize and attach image---
				//var scaleFactor:Number = 1;					
			//	testTextField.appendText("\nfotoW: " +_fotoview.bmp.bitmapData.width + "fotoH:" + _fotoview.bmp.bitmapData.height);
				if (_fotoview.bmp.bitmapData.width > _fotoview.bmp.bitmapData.height) {					
					newHeight = Math.round(_fotoview.bmp.bitmapData.height / _fotoview.bmp.bitmapData.width * _maxWidth);					
					newWidth = _maxWidth;
					//scaleFactor = _maxWidth / _fotoview.bmp.bitmapData.width;
				}else {
					newWidth = Math.round(_fotoview.bmp.bitmapData.width / _fotoview.bmp.bitmapData.height * _maxWidth);					
					newHeight = _maxWidth;
					//scaleFactor = _maxWidth / _fotoview.bmp.bitmapData.height;
				}
			//	testTextField.appendText("\nwidth:" + newWidth + "height:" + newHeight);
				var scaledBitmapData:BitmapData=new BitmapData(newWidth,newHeight,true,0xFFFFFFFF);
				var scaleMatrix:Matrix=new Matrix();
				//scaleMatrix.scale(scaleFactor, scaleFactor);
				scaleMatrix.scale(1,1);
				scaledBitmapData.draw(_fotoview.bmp.bitmapData,scaleMatrix);
				bmp.bitmapData=scaledBitmapData;
				//force the smoothing
				bmp.smoothing=true;		  
				bmp.alpha = 1;	
					//testTextField.appendText(" x:" + bmp.x  + " y:" + bmp.y);
				
				bmp.x = -bmp.bitmapData.width/2;
				bmp.y = -bmp.bitmapData.height/2;				
				
				this.scaleX=1;
				this.scaleY = 1;	*/
				setFoto();
				
				//turn foto and maskframe, if necessary, add the additional frame rotation
				var totalRotation:int = suborder.rotationB4 + addtnlFrameRotation;
				
				//if rediting a foto, that was modified for this Rahmen
				//??? I have to find some other way, how to determine, if they switched motiv
			//testTextField.appendText("total" + totalRotation);
				if (suborder.blnChosen)  
				{			
					//this.clearMask();				
					_currentCornerX = suborder.flashX;
					_currentCornerY = suborder.flashY;
					_currentFormatW = suborder.newFormatW;
					_currentFormatH = suborder.newFormatH;
					//mcEditingBg.rotation = suborder.rotationB4;
				
				//testTextField.appendText("draw startx:" + _startX + "starty:" + _startY + "current:" + String(_currentCornerX) + " " + String(_currentCornerY) + " " + String(suborder.newFormatW) + " " + String(suborder.newFormatH) + "\n");
					//this.drawCurrentMask(_startX, _startY, _fotoW, _fotoH, _currentCornerX, _currentCornerY, _currentFormatW, _currentFormatH);
					this.turnFoto_wAusschnitt(totalRotation);
				}else {
					this.turnFoto(totalRotation);
				}
			//} catch (e:Error) { }			
		}
		
		public function clearMask():void
		{
			if (_btnVerschieben.hasEventListener(MouseEvent.CLICK))
			{
				_btnVerschieben.removeEventListener(MouseEvent.CLICK, onVerschieben);  
			}
			
			if (this.contains(_btnVerschieben))
			{
				this.bg.removeChild(_btnVerschieben);
			}
			
			if (_btnSkalieren.hasEventListener(MouseEvent.CLICK))
			{
				_btnSkalieren.removeEventListener(MouseEvent.CLICK, onSkalieren); 
			}
			if (this.contains(_btnSkalieren))
			{
				this.bg.removeChild(_btnSkalieren);
			}
			
			if (this.contains(_fotoformatMask))
			{
				_fotoformatMask.graphics.clear();
				this.bg.removeChild(_fotoformatMask); 
				_fotoformatMask = null;
			}
			if (this.contains(edgeMask))
			{
				edgeMask.graphics.clear();
				this.bg.removeChild(edgeMask); 
				edgeMask = null;
			}
			
			if (this.contains(_dashedLine1))
			{
				_dashedLine1.clear();
				this.bg.removeChild(_dashedLine1);
				_dashedLine1 = null;
			}
			
			if (this.contains(_dashedLine2))
			{
				_dashedLine2.clear();
				this.bg.removeChild(_dashedLine2);
				_dashedLine2 = null;
			}			
		}	
		
		//-------------------functions for foto editing
		private function onSkalieren (e:MouseEvent):void
		{	
			//this.stage.frameRate = 35;
			//the difference between mouse and right bottom corner of Ausschnitt
			_diffX = fotoeditorX  + _currentCornerX + _currentFormatW - stage.mouseX;		
			_diffY = fotoeditorY + _currentCornerY + _currentFormatH - stage.mouseY;
			
			//testTextField.appendText("\n formatW:" + _formatW + "formatH:" + _formatH);
			//allow drop
			_btnSkalieren.addEventListener(MouseEvent.MOUSE_UP, dropSkalieren, false, 0, true);	
			stage.addEventListener(MouseEvent.MOUSE_UP, dropSkalieren, false, 0, true);		
			//_btnSkalieren.startDrag();			
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onSkalierenMove, false, 0, true);	
		}
		
		private function dropSkalieren(e:MouseEvent):void
		{
			//_btnSkalieren.stopDrag();
			_btnSkalieren.removeEventListener(MouseEvent.MOUSE_UP, dropSkalieren);	
			if (stage.hasEventListener(MouseEvent.MOUSE_UP))
			{
				stage.removeEventListener(MouseEvent.MOUSE_UP, dropSkalieren);	
			}
			if (stage.hasEventListener(MouseEvent.MOUSE_MOVE))
			{
				stage.removeEventListener(MouseEvent.MOUSE_MOVE, onSkalierenMove);	
			}
			//this.stage.frameRate = 30;
		}
		
		private function onSkalierenMove(e:MouseEvent):void
		{
			
			//set the boundaries of the Ausschnitt
			var left:Number = _currentCornerX + 100;
			var bottom:Number = _currentCornerY + 100;
			var right:Number = _startX + _fotoW;
			var top:Number = _startY + _fotoH;
			
			var ratio:Number = _formatH / _formatW;
			var localmousePoint:Point = globalToLocal(new Point(stage.mouseX, stage.mouseY));
				//testTextField.appendText("\nonSkalierenMove - mousex:" + localmousePoint.x + "mousey:" + localmousePoint.y); 
			var newFormatW:Number = stage.mouseX + _diffX - (fotoeditorX + _currentCornerX);
			var newFormatH:Number = Math.round(newFormatW * ratio);//stage.mouseY + _diffY - 50 - _currentCornerY;			
				//testTextField.appendText("mouseX"+ stage.mouseX + "diffX" +_diffX + "fotoeditorx:"+ fotoeditorX + "currCornerx:" + _currentCornerX + "newW" + newFormatW + "newH" + newFormatH);			
			//check that the Ausschnitt is no bigger than the maxAuschschnitt
			if ((newFormatW <= _formatW) && (newFormatH <= _formatH))
			{
			//testTextField.appendText("\ncurrCX" + _currentCornerX + "newW" + newFormatW + "left" + left + "right" + right + "currCY" + _currentCornerY + newFormatH + "top" + top + "bottom" + bottom + "newH" + "\n");			
			//testTextField.appendText("a:" + (_currentCornerX + newFormatW >= left) + "b:" + (_currentCornerX + newFormatW <= right) + "c:" + (_currentCornerY + newFormatH <= top) + "d:" + (_currentCornerY + newFormatH >= bottom) + "\n");
				//check that the new Ausschnitt doesn´t cross the boundaries of the foto
				if ((_currentCornerX + newFormatW >= left) && (_currentCornerX + newFormatW <= right) && (_currentCornerY + newFormatH <= top) && (_currentCornerY + newFormatH >= bottom))
				{
					//testTextField.appendText("zoom normal, ");
					this.clearMask();
					//create the editMask				
					drawCurrentMask(_startX, _startY, _fotoW, _fotoH, _currentCornerX, _currentCornerY, newFormatW, newFormatH);
				}else if ((_currentCornerX + newFormatW < left) && (_currentCornerX + newFormatW > right)){
					//testTextField.appendText("\ncurrCX" + _currentCornerX + "left" + left + "right" + right + "currCY" + _currentCornerY + "top" + top + "bottom" + bottom + "newW" + newFormatW + "newH" + newFormatH);		
					//testTextField.appendText("zoom outside width, ");
					//_btnSkalieren.stopDrag();
					this.clearMask();
					drawCurrentMask(_startX, _startY, _fotoW, _fotoH, _currentCornerX, _currentCornerY, _currentFormatW, newFormatH);
				}else if ((_currentCornerY + newFormatH > top) && (_currentCornerY + newFormatH < bottom))
				{
					//testTextField.appendText("zoom outside height, ");
					this.clearMask();
					drawCurrentMask(_startX, _startY, _fotoW, _fotoH, _currentCornerX, _currentCornerY, newFormatW, _currentFormatH);
				}else {
					//testTextField.appendText("zoom else, ");
					this.clearMask();
					drawCurrentMask(_startX, _startY, _fotoW, _fotoH, _currentCornerX, _currentCornerY, _currentFormatW, _currentFormatH);
				}
			}else {
					//_btnSkalieren.stopDrag();
					this.clearMask();
					drawCurrentMask(_startX, _startY, _fotoW, _fotoH, _currentCornerX, _currentCornerY, _currentFormatW, _currentFormatH);
			}
			//testTextField.appendText("done");
		}
		
		private function onVerschieben (e:MouseEvent):void
		{	
			//this.stage.frameRate = 35;
			//the difference between the mouse position and the top left corner of the Ausschnitt
			_diffX = (fotoeditorX + _currentCornerX) - stage.mouseX;		
			_diffY = (fotoeditorY + _currentCornerY) - stage.mouseY;
			//testTextField.appendText(String(_diffX));
			//allow drop
			_btnVerschieben.addEventListener(MouseEvent.MOUSE_UP, dropVerschieben, false, 0, true);	
			stage.addEventListener(MouseEvent.MOUSE_UP, dropVerschieben, false, 0, true);	
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onVerschiebenMove, false, 0, true);	
		}
		
		private function dropVerschieben(e:MouseEvent):void
		{
			//this.stage.frameRate = 30;
			//_btnVerschieben.stopDrag();
			_btnVerschieben.removeEventListener(MouseEvent.MOUSE_UP, dropVerschieben);	
			//_btnVerschieben.removeEventListener(MouseEvent.MOUSE_OUT, dropVerschieben);
			if (stage.hasEventListener(MouseEvent.MOUSE_UP))
			{
				stage.removeEventListener(MouseEvent.MOUSE_UP, dropVerschieben);	
			}
			if (stage.hasEventListener(MouseEvent.MOUSE_MOVE))
			{
				stage.removeEventListener(MouseEvent.MOUSE_MOVE, onVerschiebenMove);	
			}
		}
		
		private function onVerschiebenMove(e:MouseEvent):void
		{
			//set the boundaries of the Ausschnitt
			var left:Number = _startX;
			var top:Number = _startY;
			var right:Number = _startX + _fotoW;
			var bottom:Number = _startY + _fotoH;			
			
			var newCornerX:Number = stage.mouseX + _diffX - fotoeditorX;
			var newCornerY:Number = stage.mouseY + _diffY - fotoeditorY;
			//testTextField.appendText("\n" + newCornerX + "w" + _formatW + "r" + right);
			//if it´s out of bounds in both directions, stop
			if (((newCornerX < left) || ((newCornerX + _currentFormatW) > right)) && ((newCornerY < top) || ((newCornerY + _currentFormatH) > bottom)))
			{ 
				//testTextField.appendText("move outside both, " + ((newCornerX < left) || ((newCornerX + _currentFormatW) > right)) + newCornerX + "<" + left + "||" + (newCornerX + _currentFormatW) + ">" + right);
				//testTextField.appendText("move outside both, top:" + top + " newY:" + newCornerY + " bottom: " + bottom + "\n");
				newCornerX = _currentCornerX;
				newCornerY = _currentCornerY;	
				 //_btnVerschieben.stopDrag();
			}else{
				if (newCornerX < left)
				{	
					//testTextField.appendText("move outside left, ");
					 newCornerX = _currentCornerX;					
				} else if (newCornerX + _currentFormatW > right)
				{
					//testTextField.appendText("move outside right, ");
					newCornerX = _currentCornerX;
				}
				
				if (newCornerY < top) 
				{				
					//testTextField.appendText("move < top, ");
					newCornerY = _currentCornerY;					
				}else if (newCornerY + _currentFormatH > bottom)
				{
					//testTextField.appendText("move > bottom, ");
					newCornerY = _currentCornerY;	
				}				
				//testTextField.appendText("currentx" + _currentCornerX + "newX" + newCornerX + "currenty" + _currentCornerY + "newY" + newCornerY);		
			}	
			this.clearMask();
			//create the editMask				
			drawCurrentMask(_startX, _startY, _fotoW, _fotoH, newCornerX, newCornerY, _currentFormatW, _currentFormatH);				
		}
		
		private function drawCurrentMask(startX:Number, startY:Number, fotoW:Number, fotoH:Number, topLeftX:Number, topLeftY:Number, formatW:Number, formatH:Number) : void 
		{ 
			_fotoformatMask = new Sprite(); 
			edgeMask = new Sprite();
			
			_startX = startX;
			_startY = startY;
			_fotoW = fotoW;
			_fotoH = fotoH;
			_currentFormatW = formatW;
			_currentFormatH = formatH;
			_currentCornerX = topLeftX;
			_currentCornerY = topLeftY;
			
			//draw regular mask
			_fotoformatMask.graphics.beginFill(0x000000); 
			_fotoformatMask.graphics.drawRect(_startX, _startY,_fotoW, _fotoH); 
			_fotoformatMask.graphics.moveTo(_currentCornerX,_currentCornerY); 
			_fotoformatMask.graphics.drawRect(_currentCornerX,_currentCornerY, _currentFormatW, _currentFormatH); 
			_fotoformatMask.graphics.endFill(); 
			_fotoformatMask.alpha = .5;
			
			//testTextField.appendText(String(_currentCornerX) + " " + String(_currentCornerY) + " " + String(_currentFormatW) + " " + String(_currentFormatH) + "\n");			
			var ratioEdge:Number = _objBildausschnitt.Breite_in_mm / _currentFormatW;
			_currEdge = Math.floor(_edgeWidth_in_mm/ ratioEdge );			
			//draw edge mask
			edgeMask.graphics.beginFill(0x000000); 
			edgeMask.graphics.drawRect(_currentCornerX + 2,_currentCornerY + 2, _currentFormatW - 4 , _currentFormatH - 4); 
			edgeMask.graphics.moveTo(_currentCornerX  + _currEdge,_currentCornerY + _currEdge); 
			edgeMask.graphics.drawRect(_currentCornerX + _currEdge ,_currentCornerY + _currEdge, _currentFormatW - (2 * _currEdge), _currentFormatH - (2 * _currEdge)); 
			edgeMask.graphics.endFill(); 
			edgeMask.alpha = .2;			
			
			_dashedLine1 = new DashedLine(1,0x000000,new Array(8,4,8,4));
			_dashedLine1.moveTo(_currentCornerX + _currEdge + 1,_currentCornerY + _currEdge + 1);
			_dashedLine1.lineTo(_currentCornerX - _currEdge + _currentFormatW - 1,_currentCornerY + _currEdge + 1);
			_dashedLine1.lineTo(_currentCornerX - _currEdge + _currentFormatW - 1, _currentCornerY - _currEdge + _currentFormatH - 1);
			_dashedLine1.lineTo(_currentCornerX + _currEdge + 1, _currentCornerY - _currEdge + _currentFormatH - 1);
			_dashedLine1.lineTo(_currentCornerX + _currEdge + 1,_currentCornerY + _currEdge + 1);
			this.bg.addChild(_dashedLine1);
			
			_dashedLine2 = new DashedLine(1,0xffffff,new Array(4,8,4,8));
			_dashedLine2.moveTo(_currentCornerX + _currEdge + 1,_currentCornerY + _currEdge + 1);
			_dashedLine2.lineTo(_currentCornerX - _currEdge + _currentFormatW - 1,_currentCornerY + _currEdge + 1);
			_dashedLine2.lineTo(_currentCornerX - _currEdge + _currentFormatW - 1, _currentCornerY - _currEdge + _currentFormatH - 1);
			_dashedLine2.lineTo(_currentCornerX + _currEdge + 1, _currentCornerY - _currEdge + _currentFormatH - 1);
			_dashedLine2.lineTo(_currentCornerX + _currEdge + 1,_currentCornerY + _currEdge + 1);			
			this.bg.addChild(_dashedLine2);
			
			this.bg.addChild(_fotoformatMask); 
			this.bg.addChild(edgeMask);
			
			/*	//move the buttons and turn them (frameRotation is opposite of fotoRotation)
				if (_frameRotation == -90)
				{	
			testTextField.appendText("turnFrame -90");
					_btnVerschieben.x = _currentCornerX + _currentFormatW - 56;
					_btnVerschieben.y = _currentCornerY + 3;		
					_btnSkalieren.x = _topleftCornerX + _currEdge + 3;
					_btnSkalieren.y = _currentCornerY + _currentFormatH - 56;
			testTextField.appendText("turnedFrame -90");
				}else if (_frameRotation == -90)
				{
			testTextField.appendText("turnFrame +90");	
					_btnVerschieben.x = _currentCornerX + 3;
					_btnVerschieben.y = _currentCornerY + _currentFormatH - 57;				
					_btnSkalieren.x = _currentCornerX + _currentFormatW - 56;
					_btnSkalieren.y = _topleftCornerY + _currEdge + 3;
			testTextField.appendText("turnedFrame +90");		
				}else if (_frameRotation == 180)
				{
			testTextField.appendText("turnFrame 180");	//???				
				//	_btnVerschieben.y = _currentCornerY + _currentFormatH - 57;				
				//	_btnSkalieren.y = _topleftCornerY + _currEdge + 3;
			testTextField.appendText("turnedFrame +180");		
				}else{		*/	
				
				
			//button Verschieben
			_btnVerschieben.x = _currentCornerX + 3;
			_btnVerschieben.y = _currentCornerY + 3;			
			
			//button Skalieren
			_btnSkalieren.x = _currentCornerX + _currentFormatW - 56;
			_btnSkalieren.y = _currentCornerY + _currentFormatH - 56;
		//	}
			
			_btnVerschieben.addEventListener(MouseEvent.MOUSE_DOWN, onVerschieben, false, 0, true);  
			this.bg.addChild(_btnVerschieben);
			
			_btnSkalieren.addEventListener(MouseEvent.MOUSE_DOWN, onSkalieren, false, 0, true);  
			this.bg.addChild(_btnSkalieren);
		}	
		
		//called from orderview - when Kunde switches frames w/ fotos already in it
		public function adeptAusschnitt(fotoviewImg:FotoView, strProduct:String, mMotiv:MotivModel, intIndx:int, suborder:SubOrder, frameRotation:int):FotoView
		{	
			 _frameRotation = frameRotation;
			_fotoview = fotoviewImg;
			_product = strProduct;
			_mMotiv = mMotiv;
			_intIndx_of_Ausschnitt = intIndx;
			_objBildausschnitt = _mMotiv.arrBilder[_intIndx_of_Ausschnitt];
					
			//if it´s a different format than the last motiv, start over
			if ((suborder.finalW != _objBildausschnitt.finalW) || (suborder.finalH != _objBildausschnitt.finalH))  //??? may need to change this
			{							
				try{			
										
					var formatW:Number = -1;
					var formatH:Number = -1;
					
					formatW = _objBildausschnitt.Breite_in_mm;
					formatH = _objBildausschnitt.Hoehe_in_mm;
					
					_pixelW = _objBildausschnitt.finalW;
					_pixelH = _objBildausschnitt.finalH;
					
					_fotoW = _fotoview.bmp.bitmapData.width;
					_fotoH = _fotoview.bmp.bitmapData.height;
					
			/*	if (_fotoview.bmp.bitmapData.width > _fotoview.bmp.bitmapData.height) {					
					newHeight = Math.round(_fotoview.bmp.bitmapData.height / _fotoview.bmp.bitmapData.width * _maxWidth);					
					newWidth = _maxWidth;
					//scaleFactor = _maxWidth / _fotoview.bmp.bitmapData.width;
				}else {
					newWidth = Math.round(_fotoview.bmp.bitmapData.width / _fotoview.bmp.bitmapData.height * _maxWidth);					
					newHeight = _maxWidth;
					//scaleFactor = _maxWidth / _fotoview.bmp.bitmapData.height;
				} */
					
					var arrMeasurements:Array = [];
					arrMeasurements = this.getResizedFormat(_fotoW, _fotoH, formatW, formatH);				
								
					_startX = Math.floor(_maxWidth - _fotoW / 2);
					_startY = Math.floor(_maxWidth - _fotoH / 2);					
				
					_formatW = arrMeasurements[0];
					_formatH = arrMeasurements[1];
					
					_currentFormatW = _formatW;
					_currentFormatH = _formatH;
					
					//center the mask
					_topleftCornerX = _startX + (_fotoW - _formatW) / 2;
					_currentCornerX = _topleftCornerX;			
					_topleftCornerY = _startY + (_fotoH - _formatH) / 2;
					_currentCornerY = _topleftCornerY;
		
					//saveAusschnitt	
					if (_mMotiv.intCurrOrder > -1)
					{
					
						//need to create a new suborder, the old one will have to be replaced with this one in ordermodel
						var objCurrentSuborder:SubOrder = new SubOrder();	
						objCurrentSuborder.intAusschnittPosition = _intIndx_of_Ausschnitt;
						
						//if they are coming back to edit, take it from the orders, otherwise use new suborder
						if (_mMotiv.arrMotivorders[_mMotiv.intCurrOrder] != null)
						{
						objCurrentSuborder = SubOrder(_mMotiv.arrMotivorders[_mMotiv.intCurrOrder][_intIndx_of_Ausschnitt]);
						}
						
						objCurrentSuborder.addOrder(_fotoview.iPos, _product, _intIndx_of_Ausschnitt);	//???needs to be index of order, not index of Ausschnitt or else don´t do intAusschnitt separately				
						
						//need to figure this part out using the ratios of actual to flash size to formatsize
						var imgX:Number = _currentCornerX - _startX;
						var imgY:Number = _currentCornerY - _startY;
						
						//store values for showing Ausschnitt in productcontent
						objCurrentSuborder.flashX = _currentCornerX;
						objCurrentSuborder.flashY = _currentCornerY;
						objCurrentSuborder.newFormatW = _currentFormatW;
						objCurrentSuborder.newFormatH = _currentFormatH; 
						/*	if (mcEditingBg.rotation != null)
						{
							objCurrentSuborder.rotation = mcEditingBg.rotation;
						} */
						
						//values for showing in big Rahmen in Flash
						objCurrentSuborder.showX = imgX + _currEdge;
						objCurrentSuborder.showY = imgY + _currEdge;
						objCurrentSuborder.showW = _currentFormatW - (2 * _currEdge);
						objCurrentSuborder.showH = _currentFormatH - (2 * _currEdge);
						
						//ratio of fotoview in flash to orig foto size
						var ratio:Number = _fotoview.origWidth / _fotoview.bmp.width;
						
				//_myOrderView.errorTextField.text ="width:" +_fotoview.bmp.width + "orig" +_fotoview.origWidth + "ratio" + String(ratio) + "x:" + String(imgX) + "y:" + String(imgY) + "w: " + String(_currentFormatW) + "h: " + String(_currentFormatH);
						objCurrentSuborder.realX = Math.round(imgX * ratio);
						objCurrentSuborder.realY = Math.round(imgY * ratio);
						
						//figure out what size needs to be cut from the original
						//_currentFormatW & H have the edge included in it, then it needs to be resized to the actual 
						//size, which is finalW and finalH, which now also have the edge included in it.
						objCurrentSuborder.cropW = Math.round(_currentFormatW * ratio);
						objCurrentSuborder.cropH = Math.round(_currentFormatH * ratio);
						
						//figure out the resize info (pixelwidth and height of the format)
						objCurrentSuborder.finalW = _pixelW;
						objCurrentSuborder.finalH = _pixelH;
						
						//figure out the position of this bild in the produktionsbild
						objCurrentSuborder.topleftX = _objBildausschnitt.topleftX;
						objCurrentSuborder.topleftY = _objBildausschnitt.topleftY;
						
						objCurrentSuborder.blnChosen = false;
						
						_fotoview.objSuborder = objCurrentSuborder;						
					}
			
					this.empty();
				
				}catch (e:Error) { }				
			} 
			return _fotoview;
		}
		
		private function turnClockwise(e:MouseEvent):void
		{	
			mcEditingBg.rotation += 90;			
			var arrMeasurements:Array = [];
			if ((mcEditingBg.rotation == 90)||(mcEditingBg.rotation == -90))
			{				
				arrMeasurements = this.getResizedFormat(bmp.bitmapData.height, bmp.bitmapData.width, _formatW, _formatH);				
				_startX = (_maxWidth - bmp.height)/2;
				_startY = (_maxWidth - bmp.width) / 2;		
				this.clearMask();	
				this.drawFormatMask(_startX, _startY, bmp.bitmapData.height, bmp.bitmapData.width, arrMeasurements[0], arrMeasurements[1], arrMeasurements[2]);
			}else{			
			arrMeasurements = this.getResizedFormat(bmp.bitmapData.width, bmp.bitmapData.height, _formatW, _formatH);			
			_startX = (mcEditingBg.x + bmp.x);
			_startY = (mcEditingBg.y + bmp.y);			
			this.clearMask();	
			this.drawFormatMask(_startX, _startY, bmp.bitmapData.width, bmp.bitmapData.height, arrMeasurements[0], arrMeasurements[1], arrMeasurements[2]);		
			}
		}
		
		private function turnCounterClockwise(e:MouseEvent):void
		{	
			mcEditingBg.rotation -= 90;	
		
			var arrMeasurements:Array = [];
			if ((mcEditingBg.rotation == 90)||(mcEditingBg.rotation == -90))
			{				
				arrMeasurements = this.getResizedFormat(bmp.bitmapData.height, bmp.bitmapData.width, _formatW, _formatH);				
				_startX = (_maxWidth - bmp.height) / 2;
				_startY = (_maxWidth - bmp.width) / 2;			
				this.clearMask();	
				this.drawFormatMask(_startX, _startY, bmp.bitmapData.height, bmp.bitmapData.width, arrMeasurements[0], arrMeasurements[1], arrMeasurements[2]);
			}else{			
			arrMeasurements = this.getResizedFormat(bmp.bitmapData.width, bmp.bitmapData.height, _formatW, _formatH);			
			_startX = (mcEditingBg.x + bmp.x);
			_startY = (mcEditingBg.y + bmp.y);			
			this.clearMask();	
			this.drawFormatMask(_startX, _startY, bmp.bitmapData.width, bmp.bitmapData.height, arrMeasurements[0], arrMeasurements[1], arrMeasurements[2]);		
			}	
		}
		
			//called by fotoeditor, when the Kunde turns the foto only
		public function rotate(degrees:int):void
		{
			var newTotalFotoRotation:int = this.mcEditingBg.rotation + degrees;
			//move _btnVerschieben and move and turn _btnSkalieren
			//??????
			
			//testTextField.appendText("x" + (mcEditingBg.x + bmp.x) + "y" + (mcEditingBg.y + bmp.y));
			//testTextField.appendText("bmp.width" + bmp.bitmapData.width + "bmp.height" + bmp.bitmapData.height);
			
			this.clearMask();			
			this.turnFoto(newTotalFotoRotation);
		}
		
		//
		private function turnFoto(rotation:int):void
		{	
			mcEditingBg.rotation = rotation;
			
			var formatW:Number = -1;
			var formatH:Number = -1;	
			var bmpW:int = 0;
			var bmpH:int = 0;
			
			if ((mcEditingBg.rotation == 90) || (mcEditingBg.rotation == -90))
			{		
				_startX = mcEditingBg.y + bmp.y;
				_startY = mcEditingBg.x + bmp.x;
				
				bmpW = bmp.bitmapData.height;
				bmpH = bmp.bitmapData.width;			
			}else {
				_startX = mcEditingBg.x + bmp.x;
				_startY = mcEditingBg.y + bmp.y;
				
				bmpW = bmp.bitmapData.width;
				bmpH = bmp.bitmapData.height;				
			}
			
			//if frame is on its side, turn the format
			if ((_frameRotation == 90) || ( _frameRotation == -90))
			{
				//does not include the edge			
				formatW = _objBildausschnitt.Hoehe_in_mm;
				formatH = _objBildausschnitt.Breite_in_mm;
							
				//includes the edge
				_pixelW = _objBildausschnitt.finalH;
				_pixelH = _objBildausschnitt.finalW;	
			}else {
				//does not include the edge
				formatW = _objBildausschnitt.Breite_in_mm;
				formatH = _objBildausschnitt.Hoehe_in_mm;
				//includes the edge
				_pixelW = _objBildausschnitt.finalW;
				_pixelH = _objBildausschnitt.finalH;
			}
			
		//testTextField.appendText( "_pixelW" + _pixelW +  "_pixelH" + _pixelH);
		
			var arrMeasurements:Array = [];
			arrMeasurements = this.getResizedFormat(bmpW, bmpH, formatW, formatH);				
		//testTextField.appendText( "w: " + formatW + " h:" + formatH + "newW:" + arrMeasurements[0] + "newH:" + arrMeasurements[1]);
		
			//create the editMask				
			drawFormatMask(_startX, _startY, bmpW, bmpH, arrMeasurements[0], arrMeasurements[1], arrMeasurements[2]); 
			
		/*	mcEditingBg.rotation = rotation;
			var arrMeasurements:Array = [];
			if ((mcEditingBg.rotation == 90)||(mcEditingBg.rotation == -90))
			{				
				arrMeasurements = this.getResizedFormat(bmp.bitmapData.height, bmp.bitmapData.width, _formatW, _formatH);				
				_startX = (_maxWidth - bmp.height)/2;
				_startY = (_maxWidth - bmp.width) / 2;		
				//this.clearMask();	
				this.drawFormatMask(_startX, _startY, bmp.bitmapData.height, bmp.bitmapData.width, arrMeasurements[0], arrMeasurements[1], arrMeasurements[2]);
			}else{			
			arrMeasurements = this.getResizedFormat(bmp.bitmapData.width, bmp.bitmapData.height, _formatW, _formatH);			
			_startX = (mcEditingBg.x + bmp.x);
			_startY = (mcEditingBg.y + bmp.y);			
			//this.clearMask();	
			this.drawFormatMask(_startX, _startY, bmp.bitmapData.width, bmp.bitmapData.height, arrMeasurements[0], arrMeasurements[1], arrMeasurements[2]);		
			} */
		}
		
		//???need to differentiate between rotation before and new frameRotation.???
		//called from reopenFotoedito
		private function turnFoto_wAusschnitt(rotation:int):void
		{	
			mcEditingBg.rotation = rotation;
	//	testTextField.appendText("rotate:" + String(rotation));
			
			var formatW:Number = -1;
			var formatH:Number = -1;	
			var newW:int = 0;
			var newH:int = 0;
			var newCx:int = 0;
			var newCy:int = 0;
			
			if ((mcEditingBg.rotation == 90) || (mcEditingBg.rotation == -90))
			{		
				_startX = mcEditingBg.y + bmp.y;
				_startY = mcEditingBg.x + bmp.x;
				
				_fotoW = bmp.bitmapData.height;
				_fotoH = bmp.bitmapData.width;
				
				//turn format - swap width and height
				newW = _currentFormatH;
				newH = _currentFormatW;
				_currentFormatW = newW;
				_currentFormatH = newH;	
				
				newCy = _currentCornerX;
				_currentCornerX = _currentCornerY;
				_currentCornerY = newCy;
			}else {
				_startX = mcEditingBg.x + bmp.x;
				_startY = mcEditingBg.y + bmp.y;
				_fotoW = bmp.bitmapData.width;
				_fotoH = bmp.bitmapData.height;
			}
					
			//create the editMask				
			this.drawCurrentMask(_startX, _startY, _fotoW, _fotoH, _currentCornerX, _currentCornerY, _currentFormatW, _currentFormatH);						}
		
		public function saveAusschnitt():void
		{
			if (_mMotiv.intCurrOrder > -1)
			{
				var objCurrentSuborder:SubOrder = new SubOrder();	
				objCurrentSuborder.intAusschnittPosition = _intIndx_of_Ausschnitt;
				
				//if they are coming back to edit, take it from the orders, otherwise use new suborder
				if (_mMotiv.arrMotivorders[_mMotiv.intCurrOrder] != null)
				{
					if (MotivOrder(_mMotiv.arrMotivorders[_mMotiv.intCurrOrder]).arrOrder[_intIndx_of_Ausschnitt] != null)
					{
						objCurrentSuborder = SubOrder(MotivOrder(_mMotiv.arrMotivorders[_mMotiv.intCurrOrder]).arrOrder[_intIndx_of_Ausschnitt]);  //???
					}
				}
				
				objCurrentSuborder.addOrder(_fotoview.iPos, _product, _intIndx_of_Ausschnitt);					
				
				//need to figure this part out using the ratios of actual to flash size to formatsize
				var imgX:Number = _currentCornerX - _startX;
				var imgY:Number = _currentCornerY - _startY;
				
				//store values for reediting Ausschnitt in fotoeditor
				objCurrentSuborder.flashX = _currentCornerX;
				objCurrentSuborder.flashY = _currentCornerY;
				objCurrentSuborder.newFormatW = _currentFormatW;
				objCurrentSuborder.newFormatH = _currentFormatH;
				
				objCurrentSuborder.frameRotation = this._frameRotation;
			//	objCurrentSuborder.fotoRotation = _fotoRotation; //_fotoRotation is the opposite of frameRotation
				objCurrentSuborder.rotationB4 = mcEditingBg.rotation; //previous frameRotation + new rotations
				objCurrentSuborder.rotationAfter = 0;
				
		_myOrderView.errorTextField.appendText("saving:" + String(_currentCornerX) + " " + String(_currentCornerY) + " " + String(_currentFormatW) + " " + String(_currentFormatH) + "rotation" + mcEditingBg.rotation + "\n");
				
				//values for showing in big Rahmen in Flash
				objCurrentSuborder.showX = imgX + _currEdge;
				objCurrentSuborder.showY = imgY + _currEdge;
				objCurrentSuborder.showW = _currentFormatW - (2 * _currEdge);
				objCurrentSuborder.showH = _currentFormatH - (2 * _currEdge);
				
				//ratio of fotoview in flash to orig foto size
				var ratio:Number = _fotoview.origWidth / _fotoview.bmp.width;
				
		//_myOrderView.errorTextField.text ="width:" +_fotoview.bmp.width + "orig" +_fotoview.origWidth + "ratio" + String(ratio) + "x:" + String(imgX) + "y:" + String(imgY) + "w: " + String(_currentFormatW) + "h: " + String(_currentFormatH);
				//store crop values for ImageMagick
				objCurrentSuborder.realX = Math.round(imgX * ratio);
				objCurrentSuborder.realY = Math.round(imgY * ratio);
				
				//figure out what size needs to be cut from the original
				objCurrentSuborder.cropW = Math.round(_currentFormatW * ratio);
				objCurrentSuborder.cropH = Math.round(_currentFormatH * ratio);
				
				//figure out the resize info (pixelwidth and height of the format)
				objCurrentSuborder.finalW = _objBildausschnitt.finalW;  //???need to change this to _finalW
				objCurrentSuborder.finalH = _objBildausschnitt.finalH;
				
				//copy the position of this bild in the produktionsbild
				objCurrentSuborder.topleftX = _objBildausschnitt.topleftX;
				objCurrentSuborder.topleftY = _objBildausschnitt.topleftY;
				
				objCurrentSuborder.blnChosen = true;
				
				//make snapshot here, then I don´t have to calculate it later 			
				var bmpMaskedData:BitmapData = new BitmapData(bmp.bitmapData.width, bmp.bitmapData.height, true, 0x3399cc);
				bmpMaskedData.draw(bmp);
				var bmpMaskedOnly:BitmapData = new BitmapData(objCurrentSuborder.showW, objCurrentSuborder.showH);
				bmpMaskedOnly.copyPixels(bmpMaskedData, new Rectangle(imgX + _currEdge, imgY + _currEdge, objCurrentSuborder.showW, objCurrentSuborder.showH), new Point());							
				objCurrentSuborder.imageData = bmpMaskedOnly;
				
			_myOrderView.addChild(objCurrentSuborder); //???
				
				_fotoview.objSuborder = objCurrentSuborder;
				
				_myOrderView.confirmPicture(_fotoview); 
				
				//clear the foto bitmap
				if (bmp.bitmapData!=null) {
					bmp.bitmapData.dispose();
				}
			}			
		}
		
		//called from orderview, when closing the fotoeditor
		public function empty():void
		{	
			mcEditingBg.rotation = 0;
			this.clearMask();		
			//if the old value is not null dispose the data
			if (bmp.bitmapData!=null) {
				bmp.bitmapData.dispose();
			}				
		}
	}
}