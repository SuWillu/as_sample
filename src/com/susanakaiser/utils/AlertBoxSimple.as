package com.susanakaiser.utils
{
    import fl.controls.*;
    import flash.display.*;
    import flash.events.*;
    import flash.geom.*;
    import flash.text.*;
	import com.susanakaiser.view.WarningTriangle;
	import com.susanakaiser.view.SimpleDrawnButton;

    public class AlertBoxSimple extends Sprite
    {
        protected var spAlert:Sprite;
        protected var shMask:Shape;
        public var selectedButtonNumber:int;
        private var buttonsArray:Array;
        public static var instanceName:String;
        public static var dragInstance:Object;
		private var objParent:Object;
		private var callback:Function;
	//	private var btnClose:Sprite;
		
		//private var myTextField:TextField;

        public function AlertBoxSimple(parent:Object, rectSize:Rectangle, txt:String, strTitle:String, arrButtonLabels:Array, fillColor:uint = 0xece9d8, txtColor:uint = 0x000000, colorTitlebar:uint = 0x0053e1, functionToCall:Function = null) : void
        {           
            objParent = parent;
            var sizeRect:Rectangle = rectSize;
			var title:String = strTitle;
            var message:String = txt;            
            var arrButtonText:Array = arrButtonLabels;
            var BoxColor:uint = fillColor;
            var messageColor:uint = txtColor;
            var titleColor:uint = colorTitlebar;
            callback = functionToCall;
            var buttonFormat:TextFormat= new TextFormat("Arial, Helvetica, sans-serif", 12, messageColor, true);         
            this.buttonsArray = arrButtonText;
            
            this.spAlert = new Sprite();           
            with (this.spAlert)
            {
                graphics.lineStyle(1);				
				graphics.lineStyle(6, titleColor, 1);
				graphics.beginFill(BoxColor);
				try{
					graphics.drawRoundRect( sizeRect.x, sizeRect.y, sizeRect.width, sizeRect.height, 30, 30);	
				} catch (e:ArgumentError) {
                   // testTextField.appendText("create snapshot error");
				}
				graphics.endFill();             
            }			
            addChild(this.spAlert);
			
			var msgFormat:TextFormat= new TextFormat("Arial, Helvetica, sans-serif", 13, messageColor, true);   
			var myTextField:TextField = new TextField();
			//myTextField = new TextField();
            myTextField.wordWrap = true;
            myTextField.htmlText = "<font face=\"Arial, Helvetica, sans-serif\">" + message + "</font>";
            myTextField.textColor = messageColor;			
            myTextField.height = sizeRect.height - 60;
            myTextField.width = sizeRect.width - 145;
            myTextField.x = sizeRect.x + 140;
            myTextField.y = sizeRect.y + 10;
            myTextField.autoSize = TextFieldAutoSize.CENTER;
            myTextField.name = "myTextField";
            this.spAlert.addChild(myTextField);
			try{
				myTextField.setTextFormat(msgFormat);
			}catch (e:Error) { //testTextField.appendText("error" + e);  
			}
			
			//Warning triangle
			var stroke:uint= 0xe77b18;
			var fill:uint = 0xffffff;	
			var width:int = 115;			 
			var triangleHeight:uint = 100;	
			var exclY:int = 0;
			var triangle:WarningTriangle = new WarningTriangle(width,triangleHeight, fill, stroke, exclY);
			triangle.x = sizeRect.x + 10;
			triangle.y =  sizeRect.y + 10;
			this.spAlert.addChild(triangle);
			
            var buttonsSpace:Number = sizeRect.width / this.buttonsArray.length;
            var buttonsSpaceLeft:Number = (buttonsSpace - 50) / 2;
            var i:int = 0;
           while (i < this.buttonsArray.length)
           {
                var myButton:SimpleDrawnButton = new SimpleDrawnButton(45, 25, this.buttonsArray[i], buttonFormat);                
                myButton.x = sizeRect.x + buttonsSpace * i + buttonsSpaceLeft;
                myButton.y = sizeRect.y + sizeRect.height - 30;
				myButton.mouseChildren=false;
				myButton.buttonMode = true;
				myButton.useHandCursor = true;	
				myButton.name = this.buttonsArray[i];
                myButton.addEventListener(MouseEvent.CLICK, onButtonClick, false, 0, true);	
                this.spAlert.addChild(myButton);
                i = (i + 1);
            } 
            instanceName = this.spAlert.name;
            dragInstance = this.spAlert;
            return;
        }// end function
		
		
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
			
			//remove all event listeners, remove all children and set them to null
			/*btnClose.removeEventListener(MouseEvent.CLICK, onButtonClick);
			this.spAlert.removeChild(btnClose);
			btnClose = null; */
			
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
            if (event.target.name == AlertBoxSimple.instanceName || event.target.name == "tfTitle")
            {
                AlertBoxSimple.dragInstance.stopDrag();
            }
            return;
        }

        public static function doStartDrag(event:MouseEvent) : void
        {
            if (event.target.name == AlertBoxSimple.instanceName || event.target.name == "tfTitle")
            {
                AlertBoxSimple.dragInstance.startDrag();
            }
            return;
        }

    }
}