package {
	
	/*
	
	# Compile with SWC
	mxmlc JabberClientDemo.as -default-size 800 600 -include-libraries ../bin/hxmpp.swc -output ../bin/test.swf
	
	# Compile with AS3
	mxmlc JabberClientDemo.as -default-size 800 600 -sp ../bin/as3/ -output ../bin/test.swf
	
	*/

	import flash.Boot;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.text.TextField;
	import jabber.JID;
	import jabber.SocketConnection;
	import jabber.XMPPDebug;
	import jabber.client.Stream;
	import jabber.client.NonSASLAuthentication;
	import jabber.client.Roster;
	
	/**
		Example usage of the HXMPP library.
	*/
	public class JabberClientDemo extends MovieClip {
		
		private var tf : TextField;
		
		public function JabberClientDemo() {
			
			new flash.Boot( this ); // init haXe SWC
			
			stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;
			stage.align = flash.display.StageAlign.TOP_LEFT;
			
			tf = new TextField();
			tf.y = 300;
			tf.width = tf.height = 800;
			addChild( tf );
			
			info( "initializing HXMPP lib .." );
			
			var jid : JID = new JID( "account@disktree" );
			var cnx : SocketConnection = new SocketConnection( "127.0.0.1", Stream.defaultPort ); 
			var stream : Stream = new Stream( jid, cnx );
			stream.onOpen = streamOpenHandler;
	
			stream.onOpen = function():void {
				info( "XMPP stream opened" );
           	 	var auth : NonSASLAuthentication = new NonSASLAuthentication( stream );
           	 	auth.onSuccess = onLoginSuccess;
           	 	auth.authenticate( "test", "hxmpp" );
			};
			stream.onClose = function():void {
           		info( "XMPP stream closed" );
			};
			stream.onError = function(e:*):void {
				info( "XMPP stream error "+e );
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
