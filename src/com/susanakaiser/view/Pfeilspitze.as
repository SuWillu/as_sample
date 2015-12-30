package com.susanakaiser.view {
	
	import flash.display.Sprite;
	
			public class Pfeilspitze extends Sprite {
				
				public function Pfeilspitze(width:Number, height:Number, color:uint) {
				
					graphics.lineStyle(1 ,color ,1 );
					graphics.beginFill(color);
					graphics.moveTo(0, 0);
					graphics.lineTo(width, height/2);
					graphics.lineTo(0, height);
					graphics.lineTo(0, 0);
					graphics.endFill();
				}
			}
}