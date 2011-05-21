package 
{
	import flash.net.LocalConnection;
	
	internal class YTBridgeInbox {
		
		private static const INBOX_NAME:String = "YTBHOSTCENTRAL";
		private var inbox:LocalConnection = new LocalConnection();
		
		public function YTBridgeInbox (connName:String) {
			inbox.client = this;
			var conn:String = INBOX_NAME + connName;
			trace('YTBridgeInbox says im connecting to:\'' + conn+'\'');
			inbox.connect( conn );
		}
		
		public function onChannelOpen (localConnectionName:String):void {
			YTPlayer.onChannelOpen( localConnectionName );
		}
	}
}