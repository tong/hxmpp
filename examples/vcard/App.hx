
#if js
import js.Browser.document;
import js.Browser.window;
#end
import jabber.util.Base64;
import haxe.io.Bytes;

class App extends XMPPClient {
	
	override function onLogin() {
		
		super.onLogin();
		stream.sendPresence();
		
		//vcard = new jabber.client.VCard( stream );
		var vcard = new jabber.client.VCardTemp( stream );
		vcard.onError = function(e) {
			trace( "VCard error: "+e );
		}
		vcard.onLoad = onVCardLoad;
		vcard.onUpdate = function(){
			trace( "VCard updated" );
		}
		vcard.load(); // load own vcard
		
		// load roster and vcards of all contacts
		/*
		var roster = new jabber.client.Roster( stream );
		roster.onLoad = function(){
			for( i in roster.items ) {
				vcard.load( i.jid );
			}
		}
		roster.load();
		*/
		
		// Load another vcard
		//vcard.load("julia@disktree");
	}
	
	function onVCardLoad( jid : String, d : xmpp.VCardTemp ) {
		
		if( jid == null )
			trace( 'Own vcard received' );
		else
			trace( 'VCard of [$jid] loaded' );
		
		if( d == null || d.photo == null || d.photo.binval == null || d.photo.type == null )
			return;
		
		#if js
		var e = document.createImageElement();
		e.src = 'data:${d.photo.type};base64,${d.photo.binval}';
		//e.setAttribute( "src", "data:"+d.photo.type+";base64,"+d.photo.binval );
		document.getElementById( "vcards" ).appendChild( e );
		
		#elseif flash
		var t = d.photo.binval.split("\n").join("");
		var l = new flash.display.Loader();
		l.loadBytes( Base64.decodeBytes( Bytes.ofString(t) ).getData() );
		flash.Lib.current.addChild( l );

		#elseif sys
		var t = d.photo.binval.split("\n").join("");
		var type =  d.photo.type;
		type = type.substr( type.indexOf( "/" )+1 );
		var pic = Base64.decode( t );
		var f = sys.io.File.write( "recieved."+type );
		f.writeString( pic );
		f.flush();
		f.close();
		
		#end
		
		// update own vcard
		/*
		if( jid == null ) {
			data.birthday = "9/11 2001";
			vcard.update( data );
		}
		*/
	}
	
	static function main() {
		#if js
		window.onload = function(_){
			var creds = XMPPClient.readArguments();
			new App( creds.jid, creds.password, creds.ip, creds.http ).login();
		}
		#else
		var creds = XMPPClient.readArguments();
		new App( creds.jid, creds.password, creds.ip, creds.http ).login();
		#end
	}
	
}
