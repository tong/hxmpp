package {
	
	/**
		mxmlc Test.as -default-size 800 600 -compiler.include-libraries ../hxmpp/bin/hxmpp.swc -output test.swf
	*/

	import flash.Boot;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.text.TextField;
	import jabber.JID;
	import jabber.SocketConnection;
	import jabber.util.XMPPDebug;
	import jabber.client.Stream;
	import jabber.client.NonSASLAuthentication;
	import jabber.client.Roster;
	
	/**
		Example usage of the the HXMPP library.
	*/
	public class Test extends MovieClip {
		
		private var tf : TextField;
		
		public function Test() {
			
			new flash.Boot( this ); // init haXe
			
			stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;
			stage.align = flash.display.StageAlign.TOP_LEFT;
			
			//haxe.Firebug.redirectTraces();
			//XMPPDebug.redirectTraces();
			//trace("HHXMPP HXMPP HXMPP HXMPP HXMPP HXMPP HXMPP XMPP ");
			
			tf = new TextField();
			tf.y = 300;
			tf.width = tf.height = 800;
			info( "initializing HXMPP lib ..\n" );
			addChild( tf );
			
			var jid : JID = new JID( "account@disktree" );
			var cnx : SocketConnection = new SocketConnection( "127.0.0.1", Stream.defaultPort ); 
			var stream : Stream = new Stream( jid, cnx );
			stream.onOpen = streamOpenHandler;
	
           	stream.onOpen = function(s:Stream):void {
           	 	info( "XMPP stream opened" );
           	 	var auth : NonSASLAuthentication = new NonSASLAuthentication( stream );
           	 	auth.onSuccess = onLoginSuccess;
           	 	auth.authenticate( "test", "hxmpp" );
           	 };
           	 stream.onClose = function(s:Stream):void {
           		 info( "XMPP stream closed" );
           	 };
           	 stream.onError = function(s:Stream,e:*):void {
           		 info( "XMPP stream error "+e );
           	 };
           	 stream.open();
		}
		
		private function streamOpenHandler( s : Stream ) : void {
			info( "Stream Opened" );
		}

		private function onLoginSuccess( s : Object ) : void {
			info( "Login success" );
		}
		
		private function info( t : String ) : void {
			tf.appendText( t+"\n" );
		}
			
	}
	
}

