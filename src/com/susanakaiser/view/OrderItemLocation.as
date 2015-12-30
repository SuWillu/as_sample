package com.susanakaiser.view
{	

	import flash.display.MovieClip;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.*;
	import flash.events.MouseEvent;
	import flash.geom.*;
	import com.susanakaiser.view.FotoView;
	import flash.text.*;
	import com.susanakaiser.model.MotivOrder;
	import com.susanakaiser.events.ModifyOrderEvent;
	
	public class OrderItemLocation extends MovieClip
	{	
		public static const DELETE:String = "delete";
		public static const EDIT:String = "edit";
		private var _imgX:Number;
		private var _imgY:Number;
		//max size of the thumbnail
		private var _imgW:Number;
		private var _imgH:Number;
		
		//is it the first, second, ... order?
		private var _intOrderPos:int = -1;
		
		private var _hasItem:Boolean;
		private var objMotivOrder:MotivOrder;
		private var _Motivname:String;
		private var _itemW:int = 0;
		private var _itemH:int = 0;
		private var bg:Sprite;
		private var fTitle:TextFormat;
		private var tfTitle:TextField;
		private var fValue:TextFormat;
		private var fPreis:TextFormat;
		private var tfFarbe:TextField;
		private var tfMaterial:TextField;
		private var tfBilder:TextField;		
		private var tfPasspartout:TextField;
		private var tfPreis:TextField;	
		public var bmp:Bitmap;
		private var btnEdit:CustomButton;
		private var btnDelete:CustomButton;
		
		
		public function OrderItemLocation()
		{
			bmp=new Bitmap();				
		
			objMotivOrder = new MotivOrder();
			_Motivname = "";
			this._hasItem = false;			
		}
		
			//setter for the bitmap data
		public function set imageData(value:BitmapData):void {
			try{
				//if the old value is not null dispose the data
				if (bmp.bitmapData!=null) {
					bmp.bitmapData.dispose();
				}
				//set the new data
				bmp.bitmapData=value;
		
				//force the smoothing
				bmp.smoothing=true;		  
				bmp.alpha = 1;
				this.scaleX=1;
				this.scaleY = 1;
			} catch (e:Error) {}
		}
		
		public function createItemLocation(intArrPos:int, itemW:int, itemH:int, fillColor:uint = 0xcccccc):void
		{	
			this._itemW = itemW;
			this._itemH = itemH;
			this._intOrderPos = intArrPos;
			
			bg = new Sprite();
			bg.graphics.lineStyle(1, 0xffffff);
			bg.graphics.beginFill(fillColor);
			try{ bg.graphics.drawRect(0, 0, _itemW, _itemH);}catch(e:Error){}				
			bg.graphics.endFill();
			this.addChild(bg);	
			
			fTitle = new TextFormat("Arial, Helvetica, sans-serif", 14, 0x4a4a4a, true);
			fTitle.align = "left";
			tfTitle = new TextField();
			tfTitle.x = 0;
			tfTitle.y = 10;
			tfTitle.background = false;
			tfTitle.multiline = false;
			tfTitle.width = 400;
			tfTitle.text = "1)Rahmen: blablabla Artikelnummer: blablabla";
			tfTitle.setTextFormat(fTitle);
			bg.addChild(tfTitle);
			
			var editW:Number=50;
			var editH:Number = 17;			
			var strEditUrl:String = "images/btnEdit.png";				
			btnEdit = new CustomButton(strEditUrl, editW, editH);
			btnEdit.x = 410;
			btnEdit.y = 10;
			btnEdit.mouseChildren=false;
			btnEdit.buttonMode = true;
			btnEdit.useHandCursor = true;			
			bg.addChild(btnEdit);
			btnEdit.addEventListener(MouseEvent.CLICK, editMotivOrder);  		
		
			var wkW:Number=50;
			var wkH:Number = 15;			
			var strwkUrl:String = "images/btnDelete.png";				
			btnDelete = new CustomButton(strwkUrl, wkW, wkH);
			btnDelete.x = 470;
			btnDelete.y = 10;
			btnDelete.mouseChildren=false;
			btnDelete.buttonMode = true;
			btnDelete.useHandCursor = true;			
			bg.addChild(btnDelete);
			btnDelete.addEventListener(MouseEvent.CLICK, deleteMotivOrder);  
		
			_imgX = 20;
			_imgY = 35;			
		
			var fLabel:TextFormat = new TextFormat("Arial, Helvetica, sans-serif", 10, 0x000000, false);
			fValue = new TextFormat("Arial, Helvetica, sans-serif",11,0x000000,true);
				
			var tfFarbeLbl:TextField = new TextField();
			tfFarbeLbl.background = false;
			tfFarbeLbl.autoSize = TextFieldAutoSize.LEFT;
			tfFarbeLbl.multiline = false;
			tfFarbeLbl.x = 135;
			tfFarbeLbl.y = 50;
			tfFarbeLbl.text = "Farbe: ";	
			try{
				tfFarbeLbl.setTextFormat(fLabel);
			}catch(e:Error){trace("error"+e);}
			bg.addChild(tfFarbeLbl);			
			
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
			bg.addChild(tfFarbe);	
			
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
			bg.addChild(tfMaterialLbl);		
				
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
			bg.addChild(tfMaterial);	
			
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
			bg.addChild(tfBilderLbl);	
			
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
			bg.addChild(tfBilder);
			
			var tfPreisLbl:TextField = new TextField();
			tfPreisLbl.background = false;
			tfPreisLbl.autoSize = TextFieldAutoSize.LEFT;
			tfPreisLbl.multiline = false;
			tfPreisLbl.x = tfBilder.x + 50
			tfPreisLbl.y = 50;
			tfPreisLbl.text = "Preis: ";	
			try{
				tfPreisLbl.setTextFormat(fLabel);
			}catch(e:Error){trace("error"+e);}
			bg.addChild(tfPreisLbl);	
			
			fPreis = new TextFormat("Arial, Helvetica, sans-serif",18,0x000000,true);
			tfPreis = new TextField();
			tfPreis.background = false;
			tfPreis.autoSize = TextFieldAutoSize.LEFT;
			tfPreis.multiline = false;
			tfPreis.x = tfPreisLbl.x + 30;
			tfPreis.y = 45;
			tfPreis.text = "Preis: ";	
			try{
				tfPreis.setTextFormat(fPreis);
			}catch(e:Error){trace("error"+e);}
			bg.addChild(tfPreis);				
		}
		
		//places a thumbnail of a photo inside the thumbnail location
		//it also adds stuff on top of the thumbnail
		public function attachItem(indx:int, objMotivOrder:MotivOrder):String
		{			
			tfTitle.text = String(indx);
			tfTitle.appendText(String(objMotivOrder));
			
			var enumarate:int = indx + 1;
			tfTitle.text =  enumarate + ") " + objMotivOrder.Motivname;
			tfTitle.setTextFormat(fTitle);					
			//resize and center the thumbnail of the ordered Rahmen
			var thumbnailSize:int = 60;
			var currWidth:int = objMotivOrder.bmp.bitmapData.width;
			var currHeight:int = objMotivOrder.bmp.bitmapData.height;
			var newWidth:int = 0;
			var newHeight:int = 0;
			var newX:int = 0;
			var newY:int = 0;
			//for testing
			var msg:String = "";
			if ((currWidth > thumbnailSize) || (currHeight > thumbnailSize))
			{
				if (currWidth > currHeight) {
					//tfTitle.text = "landscape w:" + currWidth + " h:" + currHeight;
					//msg += "h:" + this.height + "w:" + this.width + "th:" + thumbnailSize + "\n";
					newHeight = Math.round(currHeight / currWidth * thumbnailSize);					
					newWidth = thumbnailSize;					
					newX = _imgX;
					newY = _imgY + (thumbnailSize - newHeight) / 2;
					//msg += "after: h:" + this.height + "w:" + this.width + "th:" + thumbnailSize + "\n";
				}else {
					//	tfTitle.text = "portrait" + currWidth + " h:" + currHeight;
					//msg += "w:" + this.width + "h:" + this.height + "th:" + thumbnailSize + "\n";
					newWidth = Math.round(currWidth / currHeight * thumbnailSize);					
					newHeight = thumbnailSize;
					newX = _imgX + (thumbnailSize - newWidth) / 2;
					newY = _imgY;
					//msg += "after: h:" + this.height + "w:" + this.width + "th:" + thumbnailSize + "\n";
				}			
			} else { //it´s already in thumbnail size, just place it
				msg = "3";
				if (currWidth > currHeight) {
					newX = _imgX;
					newY = _imgY + (thumbnailSize - newHeight) / 2;						
				}else {
					msg = "4";
					newX = _imgX + (thumbnailSize - newWidth) / 2;
					newY = _imgY;
				}				
			}			
			
			bmp.bitmapData = new BitmapData(objMotivOrder.bmp.bitmapData.width, objMotivOrder.bmp.bitmapData.height, true);
			bmp.bitmapData.copyPixels(objMotivOrder.bmp.bitmapData, new Rectangle(0, 0, objMotivOrder.bmp.bitmapData.width, objMotivOrder.bmp.bitmapData.height), new Point(0, 0) ); 
			//and add it to the image container
		
				bmp.x = newX;
			bmp.y = newY;
			bmp.width = newWidth;
			bmp.height = newHeight;
			
		/*	bmp.width = newWidth;
			bmp.height = newHeight;
			
			bmp.rotation = objMotivOrder.frameRotation;
			
			//Flash swaps width and height at 90 or -90 degrees
			if (bmp.rotation == 90)
			{	
				bmp.x = newX + newWidth / 2 + newHeight / 2 ;			
				bmp.y = newY + newHeight / 2 - newWidth / 2;		
			}else if (bmp.rotation == -90)
			{	
				bmp.x = newX + newWidth/2 - newHeight/2;
				bmp.y = newY + newWidth/2 + newHeight/2;
			}else if (bmp.rotation == 180)
			{
				bmp.x = newX + bmp.width;
				bmp.y = newY + bmp.height;
			}else{
				
				bmp.x = newX;
				bmp.y = newY;
			} */
			this.addChild(bmp);
			
			tfFarbe.text = objMotivOrder.Farbe;
			tfFarbe.setTextFormat(fValue);
			tfMaterial.text = objMotivOrder.Material;
			tfMaterial.setTextFormat(fValue);
			tfBilder.text = String(objMotivOrder.intBilder);
			tfBilder.setTextFormat(fValue);
			tfPreis.text = objMotivOrder.Preis;
			tfPreis.setTextFormat(fPreis);
			return String("");
		}
		
		public function clearImage():void
		{
		/*	//var strMsg:String = "";// "num" + this.numChildren + "!\n";
			if (this._hasPhoto)
			{					
				var fotoview:FotoView = new FotoView();
				//child at 0 should be the thumbnail grafic. Find the fotoview
				for (var i:int = this.numChildren-1; i > 0; --i)
				{	
					//strMsg = strMsg + "i:" + i;
					if (this.getChildAt(i) is FotoView)
					{
						fotoview = FotoView(this.getChildAt(i));
						fotoview.destroy();	
						this.removeChild(fotoview);
					}		
				} 
				this._photoName = "";
				this._hasPhoto = false;	
				tfTitle.text = "";
			}
			//return strMsg + "\n" ; */
		}
		
		public function removeImage():void
		{	
			var fotoview:FotoView = new FotoView();
			//child at 0 should be the thumbnail grafic. Find the fotoview
			for (var i:int = this.numChildren-1; i > 0; --i)
			{	
				if (this.getChildAt(i) is FotoView)
				{
					fotoview = FotoView(this.getChildAt(i));
					//for some reason, this causes the app to halt, so I can´t do it.
					//this.removeChild(fotoview);
				}		
			} 
			tfTitle.text = "";
			this._Motivname = "";
			this._hasItem = false;				
		}
		
		public function hasItem():Boolean
		{
			return this._hasItem;
		}
		public function get Motivname():String
		{
			return this._Motivname;
		}
				
		public function get imgX():Number
		{
			return _imgX;
		}
		public function set imgX(newX:Number):void
		{
			_imgX = newX;
		}		
				
		public function get imgY():Number
		{
			return _imgY;
		}
		public function set imgY(newY:Number):void
		{
			_imgY = newY;
		}	
		
		public function get imgW():Number
		{
			return _imgW;
		}
		
		public function get imgH():Number
		{
			return _imgH;
		}
		
		private function editMotivOrder(e:MouseEvent):void
		{
			e.target.dispatchEvent(new ModifyOrderEvent(EDIT, true, true, this._intOrderPos));				
		}
		
		private function deleteMotivOrder(e:MouseEvent):void
		{
			e.target.dispatchEvent(new ModifyOrderEvent(DELETE, true, true, this._intOrderPos));	
			this.deleteItemLocation();
		}
		
		public function deleteItemLocation():void
		{
			try{
				//if the old value is not null dispose the data
				if (bmp.bitmapData!=null) {
					bmp.bitmapData.dispose();
				}							
			} catch (e:Error) { }
			
			this.btnEdit.deleteButton();
			this.btnDelete.deleteButton();
			
			var i:int = bg.numChildren;
			while( i -- )
			{
				bg.removeChildAt( i );
			}
			
			this.bg.graphics.clear();
			
			var j:int = this.numChildren;
			while( j -- )
			{
				this.removeChildAt( j );
			}		
		}	
	}
}

