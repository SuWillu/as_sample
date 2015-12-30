package com.susanakaiser.utils
{
    import fl.controls.*;
    import flash.display.*;
    import flash.events.*;
    import flash.geom.*;
    import flash.text.*;
	import com.susanakaiser.view.WarningTriangle;
	import com.susanakaiser.view.SimpleDrawnButton;
	import mx.graphics.GradientEntry;
  	import mx.graphics.LinearGradient;


    public class AlertBox extends Sprite
    {
        protected var spAlert:Sprite;
        protected var shMask:Shape;
        public var selectedButtonNumber:int;
        private var buttonsArray:Array;
        public static var instanceName:String;
        public static var dragInstance:Object;
		private var objParent:Object;
		private var callback:Function;
		private var _testField:TextField;
		
		//private var myTextField:TextField;

        public function AlertBox(parent:Object, rectSize:Rectangle, txt:String, strTitle:String, arrButtonLabels:Array, fillColor:uint = 0xece9d8, txtColor:uint = 0x000000, colorTitlebar:uint = 0x0053e1, functionToCall:Function = null) : void
        {           
            objParent = parent;
            var sizeRect:Rectangle = rectSize;
			var title:String = strTitle;
            var message:String = txt; 
            var BoxColor:uint = fillColor;
            var messageColor:uint = txtColor;
            var titleColor:uint = colorTitlebar;
            callback = functionToCall;
            var buttonFormat:TextFormat= new TextFormat("Arial, Helvetica, sans-serif", 10, 0xffffff, true);         
            this.buttonsArray = arrButtonLabels;
            
            this.spAlert = new Sprite();  
			
			var radMatrix:Matrix = new Matrix();
			radMatrix.createGradientBox(sizeRect.width,sizeRect.height, Math.PI / 2);

            with (this.spAlert)
            {
                graphics.beginGradientFill(GradientType.LINEAR, [BoxColor, 0xd3d3d3],[1, 1], [0, 255], radMatrix);
                graphics.drawRoundRect(sizeRect.x, sizeRect.y, sizeRect.width, sizeRect.height, 25, 25);
                graphics.endFill();
                graphics.beginFill(titleColor, 1);
                graphics.drawRoundRect(sizeRect.x + 1, sizeRect.y + 1, sizeRect.width -2, 25, 25, 25);
                graphics.endFill();
				graphics.beginFill(titleColor, 1);
                graphics.drawRect(sizeRect.x + 1, sizeRect.y + 1 + 12, sizeRect.width -2, 13);
                graphics.endFill();
				buttonMode = true;
				useHandCursor = true;
                addEventListener(MouseEvent.MOUSE_DOWN, doStartDrag, false, 0, true);
                addEventListener(MouseEvent.MOUSE_UP, doStopDrag, false, 0, true);
            }			
            addChild(this.spAlert);
        
            var tfTitle:TextField = new TextField();			
			tfTitle.wordWrap = true;
            tfTitle.selectable = false;
            tfTitle.htmlText = "<font face=\"Arial, Helvetica, sans-serif\" size=\"16\"><strong>" + title + "</strong></font>";
            tfTitle.textColor = 0xffffff;
            tfTitle.height = 20;
            tfTitle.width = sizeRect.width - 10;
            tfTitle.x = sizeRect.x + 5 + 15;
            tfTitle.y = sizeRect.y + 5;
            tfTitle.autoSize = TextFieldAutoSize.LEFT;
            tfTitle.name = "tfTitle";
            this.spAlert.addChild(tfTitle);
						
			var myTextField:TextField = new TextField();
			//myTextField = new TextField();
            myTextField.wordWrap = true;
            myTextField.htmlText = "<font face=\"Arial, Helvetica, sans-serif\"><strong>" + message + "</strong></font>";
            myTextField.textColor = 0x000000;			
            myTextField.height = sizeRect.height - 60;
            myTextField.width = sizeRect.width - 40;
            myTextField.x = sizeRect.x + 40;
            myTextField.y = sizeRect.y + 25 + (sizeRect.height - myTextField.height) / 2;
            myTextField.autoSize = TextFieldAutoSize.CENTER;
            myTextField.name = "myTextField";
            this.spAlert.addChild(myTextField);
			
			//Warning triangle
			var stroke:uint= 0xac904b;
			var fillCol:uint = 0xedd109;	
			var width:int = 20;			 
			var triangleHeight:uint = 20;			
			var triangle:WarningTriangle = new WarningTriangle(width,triangleHeight, fillCol, stroke);
			triangle.x = sizeRect.x + 10;
			triangle.y =  myTextField.y + 5;
			this.spAlert.addChild(triangle);
			
			_testField = new TextField();            
           
            _testField.text = "";     			
			var totalButtonW:int = 0;
			
			for (var k:int = 0; k < this.buttonsArray.length; ++k)
			{
				_testField.text = buttonsArray[k];
				_testField.autoSize = TextFieldAutoSize.CENTER;
			   _testField.setTextFormat(buttonFormat);
			   totalButtonW = totalButtonW + _testField.width;
			}
			
			totalButtonW = totalButtonW + 24 * buttonsArray.length;			
            var buttonsSpace:Number = Math.round(sizeRect.width - totalButtonW);
            var buttonsSpaceSingle:Number = Math.round(buttonsSpace / (this.buttonsArray.length + 1));
			var nextX:int = buttonsSpaceSingle;
            var i:int = 0;
			var buttonWidth:int = 0;
           while (i < this.buttonsArray.length)
           {
			   var bgColor:uint = 0x656565;
			   
			   _testField.text = buttonsArray[i];
			   _testField.setTextFormat(buttonFormat);
			   buttonWidth = _testField.width;
			   
                var myButton:SimpleDrawnButton = new SimpleDrawnButton(buttonWidth, 28, this.buttonsArray[i], buttonFormat, bgColor);
			   
                myButton.x = nextX;  
					//myTextField.appendText  ("i: " + i + "buttonspace: " + String (buttonsSpace * i) + " buttonsSpaceSingle: " + buttonsSpaceSingle + " x: " + String(myButton.x) + " " + "totalButtonW:" +totalButtonW);
                myButton.y = sizeRect.y + sizeRect.height - 50;
				myButton.mouseChildren=false;
				myButton.buttonMode = true;
				myButton.useHandCursor = true;	
				myButton.name = this.buttonsArray[i];
                myButton.addEventListener(MouseEvent.CLICK, onButtonClick, false, 0, true);	
                this.spAlert.addChild(myButton);
				nextX = myButton.x + buttonWidth  + 24 + buttonsSpaceSingle;
                i = (i + 1);
            } 
			
            instanceName = this.spAlert.name;
            dragInstance = this.spAlert;
            return;
        }
		
		
        protected function onButtonClick(event:Event) : void
        {
          var strButton:String = null;
		    if (event.target is SimpleDrawnButton)
            {
                strButton = event.target.name;
                this.selectedButtonNumber = this.buttonsArray.indexOf(strButton);
			
                if (callback !== null)
                {
                    this.callback(this.selectedButtonNumber, this);
                }
            }             
			this.spAlert.removeEventListener(MouseEvent.MOUSE_DOWN, doStartDrag);
            this.spAlert.removeEventListener(MouseEvent.MOUSE_UP, doStopDrag);
			
			var i:int = 0;
			while (i < this.buttonsArray.length)
            {
				var myButton:SimpleDrawnButton = SimpleDrawnButton(this.spAlert.getChildByName(buttonsArray[i]));
				myButton.removeEventListener(MouseEvent.CLICK, onButtonClick);
				this.spAlert.removeChild(myButton);
				myButton = null;
			 	i = (i + 1);
			}  
			
			i = 0;
			while (i < this.spAlert.numChildren)
			{				
				this.spAlert.removeChildAt(i);				
				i = (i + 1);
			} 
			this.removeChild(this.spAlert);
			this.spAlert = null;
			parent.removeChild(this);
            delete this[this];
            return; 
        }

        public static function doStopDrag(event:MouseEvent) : void
        {
            if (event.target.name == AlertBox.instanceName || event.target.name == "tfTitle")
            {
                AlertBox.dragInstance.stopDrag();
            }
            return;
        }

        public static function doStartDrag(event:MouseEvent) : void
        {
            if (event.target.name == AlertBox.instanceName || event.target.name == "tfTitle")
            {
                AlertBox.dragInstance.startDrag();
            }
            return;
        }

    }
}