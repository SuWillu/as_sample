﻿package com.susanakaiser.events{	import flash.events.*;		public class DropDownSelectEvent extends Event	{		public static const VALUE_CHANGED:String = "valueChanged";		public var strValue:String;				public function DropDownSelectEvent(strNewValue:String):void		{			super(VALUE_CHANGED);			strValue = strNewValue;		}			}}