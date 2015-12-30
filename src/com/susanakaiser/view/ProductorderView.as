package com.susanakaiser.view
{	

	import com.susanakaiser.model.MotivModel;
	import flash.display.MovieClip;	
	import flash.display.*;
	import flash.geom.*;
	import flash.text.TextDisplayMode;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import com.susanakaiser.model.MotivModel;
	
	public class ProductorderView extends MovieClip
	{	
		private var _hasPhoto:Boolean;
		//total of photos in format
		private var _count:int;
		//Preis
		private var _price:Number;		
		private var tfLieferzeit:TextField;
		private var tfPreis:TextField;
		private var tfTitle:TextField;
		private var _strTitle:String;
		private var tfSumme:TextField;
		private var lieferzeitFormat:TextFormat;
		private var lieferzeitFormat_sm:TextFormat;
		private var basicFormat:TextFormat;
		private var specialFormat:TextFormat;
		private var totalFormat:TextFormat;
		private var _imgY:Number;		
		private var objProdData:MotivModel;
		private var arrFormate:Array;
		private var product:LoadedImage;
		private var pfeil:LoadedImage;
		
		
		public function ProductorderView(strPfeil:String, strUrl:String, title:String, strDays:String):void
		{			
			
			_price = 0,00;			
			_hasPhoto = false;
			_count = 0;	
					
			pfeil = new LoadedImage(strPfeil); 
			pfeil.x = 29;
			pfeil.y = 93;
			pfeil.alpha = .5;
			this.addChild(pfeil);
			
			basicFormat = new TextFormat("Arial, Helvetica, sans-serif", 12, 0x000000, true);			
			_strTitle = title;
			tfTitle = new TextField();
			tfTitle.x = 420;
			tfTitle.y = 25;
			tfTitle.background = false;
			//tfTitle.autoSize = TextFieldAutoSize.CENTER;
			tfTitle.multiline = true;
			tfTitle.width = 100;
			tfTitle.height = 20;
			tfTitle.wordWrap = true;
			tfTitle.text = _strTitle;
			this.addChild(tfTitle);	
			tfTitle.setTextFormat(basicFormat);
			
			var url:String = strUrl;
			var nWidth:Number = 139;
			var nHeight:Number = 122;			
			product = new LoadedImage(url, nWidth, nHeight); 
			product.x = 350;
			product.y =  40;			
			this.addChild(product);				
			
			lieferzeitFormat = new TextFormat("Arial, Helvetica, sans-serif", 24, 0x000000, true);
			lieferzeitFormat_sm = new TextFormat("Arial, Helvetica, sans-serif", 10, 0x000000, false);			
			tfLieferzeit = new TextField();
			tfLieferzeit.x = 250;
			tfLieferzeit.y = 70;
			tfLieferzeit.background = false;
			//tfLieferzeit.autoSize = TextFieldAutoSize.LEFT;
			tfLieferzeit.width = 80;
			tfLieferzeit.multiline = true;	
			tfLieferzeit.wordWrap = true;
			//tfLieferzeit.embedFonts = true;
			tfLieferzeit.text = strDays + " Tage Lieferzeit";
			addChild(tfLieferzeit);
			try{
				tfLieferzeit.setTextFormat(lieferzeitFormat, 0, 1);
				tfLieferzeit.setTextFormat(lieferzeitFormat_sm, 1, 17);				
			}catch(e:Error){trace("error"+e);}
			
			totalFormat = new TextFormat("Arial, Helvetica, sans-serif", 10, 0x3d1e23, true);			
			tfSumme = new TextField();
			tfSumme.x = 375;
			tfSumme.y = 130;
			tfSumme.background = false;
			tfSumme.autoSize = TextFieldAutoSize.RIGHT;
			tfSumme.multiline = false;
			tfSumme.text="Anzahl: 4";
			tfSumme.setTextFormat(totalFormat);
			tfSumme.name = "summe";
			//addChild(tfSumme);
			
			tfPreis = new TextField();
			tfPreis.x = 375;
			tfPreis.y = 130 + 10;	
			tfPreis.background = false;
			tfPreis.multiline = false;
			tfPreis.autoSize = TextFieldAutoSize.RIGHT;
			tfPreis.text = "Preis: " + String("19.95").replace(".", ",") + " €";
			tfPreis.setTextFormat(totalFormat);
			tfPreis.name = ("preis");
			//addChild(tfPreis);
		}
						
		//adds a photo to the format
		public function addPicture():String
		{	
			_hasPhoto = true;		
			_count++;
			//var numSumme:Number = Math.round((_count * _price) * 100) / 100;
			tfSumme.text = String(_count); // + " Stück = " + numSumme.toFixed(2) + " €";
			tfSumme.setTextFormat(totalFormat);
			if (!this.getChildByName("summe"))
			{
				addChild(tfSumme);
			}
			if (!this.getChildByName("preis"))
			{
				addChild(tfPreis);
			}
			var msg:String = String(_count);		
			
			return msg + " |";
		}
		
		public function removePicture():void
		{			
			_count--;
			if (_count > 0)
			{
				tfSumme.text = String(_count);
				tfSumme.setTextFormat(totalFormat);	
			}else {
				_hasPhoto = false;	
				if (this.getChildByName("summe"))
				{
					removeChild(tfSumme);
				}
				if (this.getChildByName("preis"))
				{
					removeChild(tfPreis);
				}
			}
		}
		
		//call initiated from orderview, when user confirms a suborder
		public function updateAnzahl(anzahl:int, preis:Number):void
		{					
			_count = anzahl;
			_price = preis;
			
			if (_count > 0)
			{
				tfPreis.text = "Preis: " + String(Math.round(_price * 100) / 100).replace(".", ",") + " €";
				tfSumme.setTextFormat(totalFormat);
				_hasPhoto = true;	
				tfSumme.text = "Anzahl: " + String(_count); 
				tfSumme.setTextFormat(totalFormat);
				if (!this.getChildByName("summe"))
				{
					addChild(tfSumme);
				}
				if (!this.getChildByName("preis"))
				{
					addChild(tfPreis);
				}
			}else {					
				_hasPhoto = false;	
				if (this.getChildByName("summe"))
				{
					removeChild(tfSumme);
				}
				if (this.getChildByName("preis"))
				{
					removeChild(tfPreis);
				}
			}
		}
			
		public function hasPhoto():Boolean
		{
			return _hasPhoto;
		}		
		
						
		public function get price():Number
		{
			return _price;
		}
		
		//called from orderview, to set up the produktgruppe
		public function update(): void
		{			
		/*	//set price
			_price = objProdData.Preis;
			tfPreis.text = String(_price).replace(".", ",") + " €";
			tfPreis.setTextFormat(basicFormat); */
		}
			
		public function get imgY():Number
		{
			return _imgY;
		}
		public function set imgY(newY:Number):void
		{
			_imgY = newY;
		}
		
		public function cancelAll():void
		{
			_count= 0;			
			_hasPhoto = false;	
			if (this.getChildByName("summe"))
			{
				removeChild(tfSumme);
			}
			if (this.getChildByName("preis"))
			{
				removeChild(tfSumme);
			}	

		}
		
		public function positionImage(newX:Number, newY:Number):void
		{
			product.x = newX;
			product.y =  newY;			
			
		}
		
		public function positionLieferzeit(newX:Number, newY:Number):void
		{
			tfLieferzeit.x = newX;
			tfLieferzeit.y =  newY;
		}
		
		public function positionTitle(newX:Number, newY:Number):void
		{
			tfTitle.x = newX;
			tfTitle.y =  newY;		
		}
		
		public function positionTotal(newX:Number, newY:Number):void
		{
			tfSumme.x = newX;
			tfSumme.y = newY;	
			tfPreis.x = newX;
			tfPreis.y = newY+ 10;	
		}	
		
		public function positionPfeil(newX:Number, newY:Number):void
		{
			pfeil.x = newX;
			pfeil.y =  newY;		
		}
		
		public function get strTitle():String
		{
			return _strTitle;
		}
	}
}

