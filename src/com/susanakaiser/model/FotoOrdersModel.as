
package com.susanakaiser.model
{
  import com.susanakaiser.utils.Observer;
  import com.susanakaiser.view.FotoView;
  
  public class FotoOrdersModel extends Observer
  {

    static private var instance:FotoOrdersModel;
	private var _iTotalQtyOrdered:int;
	private var _imgPos:int;
	private var _fotoview:FotoView;
	private var _blnTooSmall:Boolean = false;

   public function FotoOrdersModel() 
   {      
	   // set defaults here
	  _iTotalQtyOrdered = 0;
    }
	
	public function registerView(foto:FotoView, index:int):void
	{
		_imgPos = index;
		this._fotoview = foto;
		super.addSubscriber(foto);
	}
	
	public function addSubOrder(intNew:int):void
	{		
		_iTotalQtyOrdered = _iTotalQtyOrdered + intNew;
		blnTooSmall = false;
		super.notifyChanges();
	}
	
	public function removeSubOrder(intNew:int):void
	{
		_iTotalQtyOrdered = _iTotalQtyOrdered - intNew;
		blnTooSmall = false;
		super.notifyChanges();
	}
	
	public function cancelAll():void
	{
		_iTotalQtyOrdered = 0;
		blnTooSmall = false;
		super.notifyChanges();
	}
	
	public function get imgPos ():int
	{
		return _imgPos;
	}
	
	public function set imgPos( value:int ):void 
	{
      _imgPos = value;
	}
	
	//--------------------------
    // called by FotoView
    //--------------------------

	public function get iTotalQtyOrdered ():int
	{
		return _iTotalQtyOrdered;
	}
	
	public function set iTotalQtyOrdered( value:int ):void 
	{
      _iTotalQtyOrdered = value;
	}
		
	public function get blnTooSmall ():Boolean
	{
		return _blnTooSmall;
	}
	
	public function set blnTooSmall( value:Boolean ):void 
	{
      _blnTooSmall = value;
	  notifyChanges();
	}	
  }
}
