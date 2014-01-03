
import XSPFPlaylist;
using jabber.JIDUtil;

/**
	Example/Test of sharing a xspf playlist 
*/
class App extends XMPPClient {
	
	var playlists : Map<String,XSPFPlaylist>;
	var playlist : XSPFPlaylist;
	
	override function onLogin() {
		
		super.onLogin();
		
		playlists = new Map();
		playlist = XSPFPlaylist.parse( Xml.parse('<playlist version="1" xmlns="http://xspf.org/ns/0/">
	<title>XSPF Example Playlist</title>
	<creator>tong</creator>
	<info>http:/xspf.org/xspf-v1.html</info>
	<identifier>20eabe5d64b0e216796e834f52d61fd0b70332fc</identifier>
	<image>http://download.disktree.net/music/sdk_sperrplan/GRAUESCHMIERE_cover.jpg</image>
	<date>2008-01-08T17:10:23-05:00</date>
	<license>CreativeCommons</license>
	<attribution>
		<location>http://disktree.net/modified_version_of_original_playlist.xspf
		</location>
		<identifier>somescheme:original_playlist.xspf</identifier>
	</attribution>
	<trackList>
		<track>
			<title>ARUK</title>
			<location>http://download.disktree.net/music/tong/ARUK.mp3</location>
		</track>
		<track>
			<title>arturia_extended_5</title>
			<creator>tong</creator>
			<location>http://download.disktree.net/music/tong/arturia_extended_5.mp3</location>
			<info>http://spp.tt4.at</info>
			<image>http://download.disktree.net/music/sdk_sperrplan/GRAUESCHMIERE_cover.jpg</image>
		</track>
		<track>
			<title>ybot_e54_4_5</title>
			<annotation>DJ-mix by ytong at E54 (2005).
			</annotation>
			<info>http://www.spp.tt4.at</info>
			<location>http://download.disktree.net/music/tong/ybot_e54_4_5.mp3</location>
			<image>http://download.disktree.net/music/sdk_sperrplan/GRAUESCHMIERE_cover.jpg</image>
		</track>
	</trackList>
</playlist>').firstElement());

		var playlistListener = new jabber.XSPFListener( stream );
		playlistListener.onRequest = onPlaylistRequest;
		
		new jabber.ServiceDiscoveryListener( stream, [{category:"client",type:"pc",name:"hxmpp"}] );
		stream.sendPresence();
	}
	
	override function onPresence( p : xmpp.Presence ) {
		if( p.type == null ) {
			if( !playlists.exists( p.from ) ) {
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
	
	function onPlaylistRequest( jid : String ) : XSPFPlaylist {
		trace( jid+" is requesting my playlist" );
		return playlist;
	}

	function onPlaylistRecieved( jid : String, playlist : XSPFPlaylist ) {
		if( playlist == null ) {
			trace( jid+" currently does not have a active xspf playlist");
		} else {
			trace( "Playlist recieved from "+jid+":" );
			trace( "\t"+playlist.title );
			for( t in playlist.tracklist) {
				trace( "\t\t"+t );
			}
		}
	}
	
	static function main() {
		var creds = XMPPClient.readArguments();
		new App( creds.jid, creds.password, creds.ip, creds.http ).login();
	}
	
}
