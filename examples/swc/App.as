package {
	
	/**
		Example usage of the HXMPP lib from actionscript3 (mxmlc) using hxmpp.swc.
	*/

	import flash.Boot;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.text.TextField;
	import jabber.JID;
	import jabber.SocketConnection;
	import jabber.ServiceDiscovery;
	import jabber.client.Stream;
	import jabber.client.Authentication;
	import jabber.client.Roster;
	import jabber.client.VCardTemp;
	import jabber.sasl.MD5Mechanism;
	
	/**
		Basic XMPP client exmaple.
	*/
	public class Test extends MovieClip {
		
		private var tf : TextField;
		private var stream : jabber.client.Stream;
		
		public function Test() {
			
			haxe.init(this); // init haXe SWC
			
			stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;
			stage.align = flash.display.StageAlign.TOP_LEFT;
			
			tf = new TextField();
			tf.x = 10;
			tf.y = 100;
			tf.width = tf.height = 800;
			addChild( tf );
			
			info( "initializing HXMPP lib ..." );
			
			var jid : JID = new JID( "romeo@disktree/HXMPP" );
			var cnx : SocketConnection = new SocketConnection( "127.0.0.1" ); 
			stream = new Stream( cnx );
			stream.onOpen = function():void {
				info( "XMPP stream opened" );
           	 	var auth : Authentication = new Authentication( stream, [new MD5Mechanism()] );
           	 	auth.onSuccess = onLoginSuccess;
           	 	auth.start( "test", "hxmpp" );
			};
			stream.onClose = function(e:*):void {
				info( "XMPP stream closed ("+e+")" );
			};
			stream.open( jid );
		}
		
		private function onLoginFail() : void {
			info( "Failed to login" );
		}
		
		private function onLoginSuccess() : void {
			info( "Login success" );
			var roster : Roster = new Roster( stream );
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