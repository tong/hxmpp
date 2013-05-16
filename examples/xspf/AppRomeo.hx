
import xspf.Playlist;
using jabber.JIDUtil;

/**
	Example of playlist sharing using XSPF
*/
class AppRomeo extends XMPPClient {
	
	var myPlaylist : Playlist;
	var playlists : Map<String,Playlist>; // recieved playlists
	
	override function onLogin() {
		super.onLogin();
		playlists = new Map();
		new jabber.PresenceListener( stream, onPresence );
		stream.sendPresence();
	}
	
	function onPresence( p : xmpp.Presence ) {
		if( p.type == null ) {
			if( !playlists.exists( p.from ) ) {
				if( p.from.node() != "julia" ) {
					return;
				}
				var disco = new jabber.ServiceDiscovery( stream );
				disco.onInfo = function(jid:String,info:xmpp.disco.Info) {
					for( feature in info.features ) {
						trace( "\t"+feature, "info"  );
						if( feature == xmpp.XSPF.XMLNS ) {
							var xspf = new jabber.XSPF( stream );
							xspf.onLoad = onPlaylistRecieved;
							xspf.request( p.from );
							break;
						}
					}
				}
				disco.info( p.from );
			}
		}
	}
	
	function onPlaylistRecieved( jid : String, playlist : Playlist ) {
		if( playlist == null ) {
			trace( jid+" currently does not have a active playlist");
		} else {
			print( "Playlist recieved from "+jid+":" );
			print( "\t"+playlist.title );
			for( t in playlist.tracklist) {
				print( "\t\t"+t );
			}
		}
	}
	
	static inline function print(t) Sys.println(t);
	
	static function main() {
		var args = Sys.args();
		var jid = "romeo@disktree";
		if( args.length > 0 ) {
			jid = args[0];
			if( !jabber.JIDUtil.isValid( jid ) ) {
				print( "Invalid JID ("+jid+")" );
				return;
			}
		}
		var app = new AppRomeo();
		app.login( jid );
	}
	
}
