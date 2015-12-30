package com.susanakaiser.events
{
	import flash.events.*;
	
	public class PopupEvent extends Event
	{
		public static const CLOSE_BOX:String = "closeBox";		
		
		public function PopupEvent(type:String):void
		{			
			super(type, true, true);		
		}		
	}
}
