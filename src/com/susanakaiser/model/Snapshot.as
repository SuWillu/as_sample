/* **************************************************************************
'	Class		: Snapshot			                           				*
'	Name		: Susanne Kaiser   							  				*
'	Date		: 11/27/2009								       				*
'	Description	: This saves .jpg or .bmp files to the server, it uses save_jpgs.php.    *
' most of the code is from:http://actionscript-blog.imaginationdev.com/5/save-jpg-jpeg-png-bmp-image-action-script-3/ *
'	Version		: 1.0										   				*
' 2010/03/12 SWK added more error handling.								    *
'************************************************************************** */

package com.susanakaiser.model
{
	import flash.display.*;
	import com.adobe.images.JPGEncoder;
	import flash.net.*;
	import flash.events.*;
	import flash.utils.Timer;
    import flash.events.TimerEvent;
    import flash.utils.ByteArray;
	
	public class Snapshot 
	{
	
		private var serverUniqueFileName:String;
	//mcSavingMsg.visible=false;
	
	//Need to change the name to the specified server
	private var serverPath:String = "";
	//var serverPath:String = "http://localhost/";
	
	//to check, if saving to server is complete
	private var timer:Timer;
	
	//for download on user´s PC
	private var isDownloadProgress:Boolean = false;
	private var downloadURL:URLRequest;
	private var file:FileReference;
	private var fileType:String;
	private var mcImage:MovieClip;
	private var strResult:String;
	private var strFolder:String;
	private var jpgURLLoader:URLLoader;

	
		public function Snapshot(mcPicture:MovieClip, strPath:String, strUserid:String, strType:String, strNewFolder:String ):void 
		{			
			fileType = strType;			
			serverUniqueFileName=strUserid;				
			serverPath = strPath;
			mcImage = new MovieClip();
			mcImage = mcPicture;
			strResult = "not sent";
			strFolder = strNewFolder;
		}
		
		public function saveSnapshot ():String
		{
			if(fileType == ".jpg")
			{
				createJPG(mcImage, 85, serverUniqueFileName+".jpg");
			}
			else
			{
				//createBmp(mcImage,serverUniqueFileName+".bmp");
			}
			return strResult;
		}
				
		private function getUniqueFileName(fileName:String):String
		{
			var date:Date = new Date();
			return fileName+date.getTime();
		}
		
		
		////////////////////////////////////////////////////////////////////////////////////
		// Creating JPG Image
		////////////////////////////////////////////////////////////////////////////////////
		private function createJPG(m:MovieClip, q:Number, fileName:String="snapshot.jpg"):void
		{
			serverUniqueFileName = fileName;
			try
			{
				var jpgSource:BitmapData = new BitmapData (m.width, m.height);
				jpgSource.draw(m);
			}catch (e:ArgumentError) { 
				//trace (e);
			}catch (e:SecurityError) { 
				//trace (e);
			}
			
			var jpgEncoder:JPGEncoder = new JPGEncoder(q);
			var jpgStream:ByteArray = jpgEncoder.encode(jpgSource);
		
			var header:URLRequestHeader = new URLRequestHeader ("Content-type", "application/octet-stream");
			var jpgURLRequest:URLRequest = new URLRequest (serverPath+"save_jpgs.php?name=" + fileName+"&folder="+strFolder);	
					
			jpgURLRequest.requestHeaders.push(header);
			jpgURLRequest.method = URLRequestMethod.POST;
			jpgURLRequest.data = jpgStream;

			jpgURLLoader = new URLLoader();
			jpgURLLoader.dataFormat = URLLoaderDataFormat.VARIABLES;
			jpgURLLoader.addEventListener( Event.COMPLETE, imageUrlLoaderComplete, false, 0, true );
			
			jpgURLLoader.addEventListener(Event.OPEN, openHandler, false, 0, true);
            jpgURLLoader.addEventListener(ProgressEvent.PROGRESS, progressHandler, false, 0, true);
            jpgURLLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler, false, 0, true);
            jpgURLLoader.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler, false, 0, true);
			
			jpgURLLoader.addEventListener(ErrorEvent.ERROR, sendError, false, 0, true );
			jpgURLLoader.addEventListener( IOErrorEvent.IO_ERROR, sendIOError, false, 0, true );
			try {
                jpgURLLoader.load( jpgURLRequest );
				strResult=("loaded"+serverPath+"-"+fileName);
            }
            catch (error:Error)
            {
                strResult= "A SecurityError has occurred.";
            }
		}	
		
		//Fired when URL Loading Complete
		private function imageUrlLoaderComplete(evt:Event):void
		{
			jpgURLLoader.removeEventListener( Event.COMPLETE, imageUrlLoaderComplete );
			
			jpgURLLoader.removeEventListener(Event.OPEN, openHandler);
            jpgURLLoader.removeEventListener(ProgressEvent.PROGRESS, progressHandler);
            jpgURLLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
            jpgURLLoader.removeEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
			
			jpgURLLoader.removeEventListener(ErrorEvent.ERROR, sendError );
			jpgURLLoader.removeEventListener( IOErrorEvent.IO_ERROR, sendIOError );
			 //var write = evt.target.data;
			
			 var written:String = evt.target.data.write;
			if(written=="yes")			
				//FileReference_download();
				strResult = "it worked!";
			else{
				strResult = "sorry, it didn´t work.";
			} 
			jpgURLLoader = null;
		}
		
		private function sendIOError(event:Event):void
		{
			strResult=("IO Error occured");
		}		
		
		private function sendError(event:Event):void
		{
			strResult=("Error occured");
		}		
		
		
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		//To delete temp file from the server
		public function deleteTempFile(fileName:String):void
		{
			var header:URLRequestHeader = new URLRequestHeader ("Content-type", "application/octet-stream");
			var jpgURLRequest:URLRequest = new URLRequest (serverPath+"save_jpgs.php?delname=" + fileName);
			jpgURLRequest.requestHeaders.push(header);
			jpgURLRequest.method = URLRequestMethod.POST;
			var jpgURLLoader:URLLoader = new URLLoader();
			jpgURLLoader.dataFormat = URLLoaderDataFormat.VARIABLES;
		
			jpgURLLoader.addEventListener( Event.COMPLETE, deleteTempServerFile, false, 0, true );
			
			jpgURLLoader.addEventListener(Event.OPEN, openHandler, false, 0, true);
            jpgURLLoader.addEventListener(ProgressEvent.PROGRESS, progressHandler, false, 0, true);
            jpgURLLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler, false, 0, true);
            jpgURLLoader.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler, false, 0, true);
			
			jpgURLLoader.addEventListener( IOErrorEvent.IO_ERROR, sendIOErrorDeleteFile, false, 0, true );
			jpgURLLoader.load( jpgURLRequest );
		}
		
		private function deleteTempServerFile(evt:Event):void
		{
			//var write:String = evt.target.data.write;
			//trace ('DeleteFileWrite ' + write);
		}
	
		private function sendIOErrorDeleteFile(event:IOErrorEvent):void
		{
			var write:String = event.text;			
		}
		
		 private function openHandler(event:Event):void {
            strResult=("openHandler: " + event);
        }
        private function progressHandler(event:ProgressEvent):void {
             strResult=("progressHandler loaded:" + event.bytesLoaded + " total: " + event.bytesTotal);
        }
        private function securityErrorHandler(event:SecurityErrorEvent):void {
            strResult=("securityErrorHandler: " + event);
        }
        private function httpStatusHandler(event:HTTPStatusEvent):void {
             strResult=("httpStatusHandler: " + event);
        }
	}	
}