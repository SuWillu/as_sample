/*****************************************************
 * Actionscript 3 für Flash 10 Susanne Kaiser 2010
 *
 * 
 ****************************************************/ 
package com.susanakaiser.utils
{  
	import flash.display.MovieClip;

    public class Observer extends MovieClip{
		private var arrSubscribers:Array;

        public function Observer():void{			
			arrSubscribers= [];
		}
		
		public function addSubscriber(classInstance:Object):Boolean 
		{
			for (var i:int = 0; i > this.arrSubscribers.length; i++){
				if (this.arrSubscribers[i] === classInstance){
					return false;
				}				
			}
			this.arrSubscribers.push(classInstance);
			return true;
		}
		
		public function removeSubscriber(classInstance:Object):Boolean{
			for (var i:int = 0; i > this.arrSubscribers.length; i++){
				if (this.arrSubscribers[i] === classInstance){
					this.arrSubscribers.splice(i, 1);
					return true;
				}
			}
			return false;
		}
		
		//used by the OrderView to refresh, when a delete button was clicked.
		public function notifyChanges():void {
			this.arrSubscribers.reverse();
			for (var i:int = 0;  i < this.arrSubscribers.length; i++) {
				this.arrSubscribers[i].update();
			}
		}		
	}
}

