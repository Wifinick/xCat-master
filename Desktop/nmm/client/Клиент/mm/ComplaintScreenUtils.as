package mm {
	import flash.sampler.Sample;
	import flash.display.MovieClip;
	import flash.events.*;
	import com.smartfoxserver.v2.core.SFSEvent;
	import com.smartfoxserver.v2.entities.*;
	import com.smartfoxserver.v2.requests.*;
	import com.smartfoxserver.v2.entities.data.SFSObject;
	import com.smartfoxserver.v2.entities.data.ISFSObject;
	import com.hurlant.crypto.symmetric.NullPad;
	
	public class ComplaintScreenUtils {
		
		private static var suspect_name:String;
		private static var complaintScreen:ComplaintScreen;

		public function ComplaintScreenUtils() {
			super();
		}
		
		public static function init(username:String):void
		{
			complaintScreen = new ComplaintScreen();
			
			Main.sfs.addEventListener(SFSEvent.EXTENSION_RESPONSE, sfsExtensionResponse);
			
			complaintScreen.overlay.addEventListener(MouseEvent.CLICK, overlayClick);
			complaintScreen.panel.btnSendComplaint.addEventListener(MouseEvent.CLICK, btnSendComplaintClick);
			
			suspect_name = username;
			complaintScreen.panel.message.text = "";

			if(!Main.main.contains(complaintScreen))
			{
				Main.main.addChild(complaintScreen);
			}
		}
		
		private static function overlayClick(event:MouseEvent):void
		{
			Main.main.removeChild(complaintScreen);
		}
		
		private static function btnSendComplaintClick(event:MouseEvent):void
		{
			var dataLoadingScreen:DataLoadingScreen = new DataLoadingScreen();
			dataLoadingScreen.name = "dls";
			Main.main.addChild(dataLoadingScreen);
			
			var message:String = String(complaintScreen.panel.message.text);
			var username:String = String(suspect_name);
			
			var params:ISFSObject = new SFSObject();
			params.putUtfString("username", username);
			params.putUtfString("message", message);

			Main.sfs.send(new ExtensionRequest("complaint", params));
		}
		
		public static function sfsExtensionResponse(evt:SFSEvent):void
		{			
			if (evt.params.cmd == "complaint_response")
			{
				var responseParams = evt.params.params as SFSObject;
				
				complaintScreen.panel.response.text = responseParams.getUtfString("message");
				complaintScreen.panel.message.text = "";
				
				Main.main.removeChild(Main.main.getChildByName("dls"));
			}
		}

	}
	
}
