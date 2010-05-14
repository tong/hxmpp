package {
	
	/**
	
	Example usage of HXMPP lib from AS3 (mxmlc).
	
	# Compile with HXMPP-SWC
	mxmlc ClientDemo.as -default-size 800 600 -include-libraries ../../lib/hxmpp-debug.swc -output client_as3.swf
	
	*/

	import flash.Boot;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.text.TextField;
	import jabber.JID;
	import jabber.SocketConnection;
	import jabber.ServiceDiscovery;
	import jabber.client.Stream;
	import jabber.client.SASLAuth;
	import jabber.client.Roster;
	import jabber.client.VCard;
	import jabber.sasl.MD5Mechanism;
	
	/**
		Basic XMPP client exmaple.
	*/
	public class ClientDemo extends MovieClip {
		
		private var tf : TextField;
		
		public function ClientDemo() {
			
			new flash.Boot( this ); // init haXe SWC
			
			stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;
			stage.align = flash.display.StageAlign.TOP_LEFT;
			
			tf = new TextField();
			tf.x = 10;
			tf.y = 100;
			tf.width = tf.height = 800;
			addChild( tf );
			
			info( "initializing HXMPP lib ..." );
			
			var jid : JID = new JID( "username@example.com" );
			var cnx : SocketConnection = new SocketConnection( "127.0.0.1", 5222 ); 
			var stream : Stream = new Stream( jid, cnx );
			stream.onOpen = function():void {
				info( "XMPP stream opened" );
           	 	var auth : SASLAuth = new SASLAuth( stream, [new MD5Mechanism()] );
           	 	auth.onSuccess = onLoginSuccess;
           	 	auth.authenticate( "test", "hxmpp" );
			};
			stream.onClose = function(e:*):void {
				info( "XMPP stream closed ("+e+")" );
			};
			stream.open();
		}
		
		private function streamOpenHandler( s : Stream ) : void {
			info( "Stream Opened" );
		}

		private function onLoginSuccess( s : Stream ) : void {
			info( "Login success" );
			var roster : Roster = new Roster( s );
			roster.onLoad = function() : void {
				info( "Roster loaded("+roster.items.length+" items):" );
				for( var i : int = 0; i < roster.items.length; i++ ) {
					info( roster.items[i].jid.toString() );
				}
			};
			roster.load();
		}
		
		private function info( t : String ) : void {
			tf.appendText( t+"\n" );
		}
			
	}
	
}
