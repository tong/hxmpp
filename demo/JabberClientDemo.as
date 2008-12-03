package {
	
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.text.TextField;
	
	/**
	 * 
	 * Example usage of the the hxmpp library from AS3 by loading required classes from a precompiled swf.
	 * 
	 * -) Loads required classes
	 * -) Opens xmpp stream
	 * -) Authenticates using non-sasl-authentication.
	 * -) Loads roster items
	 * 
	 */
	public class JabberClientDemo extends Sprite {
		
		private static const HXMPP_PATH : String = "../bin/hxmpp.swf";
		
		public static var JID : Class;
		public static var Stream : Class;
		public static var SocketConnection : Class;
		public static var NonSASLAuthentication : Class;
		public static var Roster : Class;
		
		private var loader : Loader;
		private var info : TextField;
		
		public function JabberClientDemo() {
			
			stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;
			stage.align = flash.display.StageAlign.TOP_LEFT;
		
			info = new TextField();
			info.width = info.height = 800;
			info.text = "loading HXMPP lib ..";
			addChild( info );
			
			loader = new Loader();
			var context : LoaderContext = new LoaderContext();
			context.applicationDomain = ApplicationDomain.currentDomain;
			loader.contentLoaderInfo.addEventListener( Event.COMPLETE, onHXMPPLoad );
			loader.load( new URLRequest( HXMPP_PATH ), context );
		}
		
		private function onHXMPPLoad( e : Event ) : void {
			info.appendText( " .. HXMPP lib loaded.\n" );
			try {
				JID = getClass( "jabber.JID" );
				Stream = getClass( "jabber.client.Stream" );
				SocketConnection = getClass( "jabber.SocketConnection" );
				NonSASLAuthentication = getClass( "jabber.client.NonSASLAuthentication" );
				Roster = getClass( "jabber.client.Roster" );
			} catch( e : * ) {
				info.appendText( "Error loading class "+e );
			}
			var jid : Object = new JID( "hxmpp@disktree" );
			var cnx : Object = new SocketConnection( "127.0.0.1", Stream.defaultPort ); 
			var stream : Object = new Stream( jid, cnx );
           		stream.onOpen = function(s:Object):void {
           	 	info.appendText( "XMPP stream opened\n" );
           	 	var auth : Object = new NonSASLAuthentication( s );
           	 	auth.onSuccess = onLoginSuccess;
           	 	auth.authenticate( "test", "hxmpp" );
           	 };
           	 info.appendText( "Connecting ...\n" );
           	 stream.open();
		}
		
		private function getClass( id : String ) : Class {
			return loader.contentLoaderInfo.applicationDomain.getDefinition( id ) as Class;
		}
		
		private function onLoginSuccess( s : Object ) : void {
			info.appendText( "Login success\n" );
			var roster : Object = new Roster( s );
			roster.onLoad = rosterLoadHandler;
			roster.load();
		}
		
		private function rosterLoadHandler( r : Object ) : void {
			info.appendText( "Roster loaded "+r.items.length+" items\n" );
		}
		
	}
}
