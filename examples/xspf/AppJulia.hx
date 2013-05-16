
import xspf.Playlist;
using jabber.JIDUtil;

/**
	Example/Test of playlist sharing using XSPF
*/
class AppJulia extends XMPPClient {
	
	var playlist : Playlist;
	
	override function onLogin() {
		
		super.onLogin();
		
		playlist = Playlist.parse( Xml.parse('<playlist version="1" xmlns="http://xspf.org/ns/0/">
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

		new jabber.PresenceListener( stream, onPresence );
		var playlistListener = new jabber.XSPFListener( stream );
		playlistListener.onRequest = onPlaylistRequest;
		new jabber.ServiceDiscoveryListener( stream, [{category:"client",type:"pc",name:"HXMPP"}] );
		stream.sendPresence();
	}
	
	function onPresence( p : xmpp.Presence ) {
	}
	
	function onPlaylistRequest( jid : String ) : Playlist {
		trace( jid+" is requesting my playlist" );
		return playlist;
	}
	
	static inline function print(t) Sys.println(t);
	
	static function main() {
		var jid = "julia@disktree";
		var app = new AppJulia();
		app.login( jid );
	}
	
}
