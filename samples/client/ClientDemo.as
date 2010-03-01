package {
	
	/**
	
	Example usage of HXMPP lib from AS3 (mxmlc).
	
	# Compile with HXMPP-SWC
	mxmlc JabberClientDemo.as -default-size 800 600 -include-libraries ../bin/hxmpp.swc -output ../bin/test.swf
	
	# Compile with HXMPP-AS3
	mxmlc JabberClientDemo.as -default-size 800 600 -sp ../bin/as3/ -output ../bin/test.swf
	
	*/

	import flash.Boot;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.text.TextField;
	import jabber.JID;
	import jabber.SocketConnection;
	import jabber.ServiceDiscovery;
	import jabber.client.Stream;
	import jabber.client.NonSASLAuthentication;
	import jabber.client.Roster;
	import jabber.client.VCard;
	
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
			tf.y = 300;
			tf.width = tf.height = 800;
			addChild( tf );
			
			info( "initializing HXMPP lib ..." );
			
			var jid : JID = new JID( "test@disktree" );
			var cnx : SocketConnection = new SocketConnection( "127.0.0.1", Stream.defaultPort ); 
			var stream : Stream = new Stream( jid, cnx );
			stream.onOpen = function():void {
				info( "XMPP stream opened" );
           	 	var auth : NonSASLAuth = new NonSASLAuth( stream );
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
			roster.onLoad = function(r:Roster) : void {
				info( "Roster loaded("+r.items.length+" items):" );
				for( var i : int = 0; i < r.items.length; i++ ) {
					info( r.items[i].jid.toString() );
				}
			};
			roster.load();
		}
		
		private function info( t : String ) : void {
			tf.appendText( t+"\n" );
		}
			
	}
	
}
