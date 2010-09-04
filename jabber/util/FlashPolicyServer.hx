package jabber.util;

#if nodejs
import js.Node;
#elseif neko
import neko.vm.Thread;
import neko.net.Host;
import neko.net.Socket;
#elseif cpp
import cpp.vm.Thread;
import cpp.net.Host;
import cpp.net.Socket;
#end

private typedef AllowedDomain = {
	var domain : String;
	var ports : Array<Int>;
}

/**
	A flash policy server (neko,cpp,nodejs).
*/
class FlashPolicyServer {
	
	static function __init__() {
		domains = new Array();
	}
	
	public static inline var PORT = 843;
	public static var domains(default,null) : Array<AllowedDomain>;
	public static var allowAll : Bool = false;
	
	#if nodejs
	static var s : js.Server;
	#elseif (neko||cpp)
	static var s : Socket;
	#end
	
	public static function start( host : String ) {
		#if nodejs
		s = Node.net.createServer( function(s:Stream) {
			s.setEncoding( Node.UTF8 );
			s.addListener( Node.EVENT_STREAM_DATA, function(data:String) {
				if( data.length == 23 && data.substr(0,22) == "<policy-file-request/>" ) {
					s.write( getXml() );
					trace( getXml() );
				}
			});
		});
		s.listen( PORT, host );
		#elseif (neko||cpp)
		var s = new Socket();
		s.bind( new Host( host ), PORT );
		s.listen( 10 );
		var t = Thread.create( runServer );
		t.sendMessage( s );
		#end
	}
	
	public static function stop() {
		s.close();
	}
	
	public static function clearDomains() {
		domains = new Array();
	}
	
	public static function getXml() : String {
		var t = "<cross-domain-policy>";
		if( allowAll ) t += '<allow-access-from domain="*" to-ports="*"/>';
		else {
			for( d in domains ) {
				var ports = "";
				for( p in d.ports ) ports += p+",";
				ports = ports.substr( 0, ports.length-1 );
				t += '<allow-access-from domain="'+d.domain+'" to-ports="'+ports+'"/>';
			}
		}
		return t+"</cross-domain-policy>"+String.fromCharCode(0);
	}
	
	#if (neko||cpp)
	static function runServer() {
		var s : Socket = Thread.readMessage( true );
		while( true ) {
			var c = s.accept();
			var d : String = null;
			try d = c.input.read( 23 ).toString() catch( e : Dynamic ) {
				return;
			}
			if( d.substr( 0, 22 ) == "<policy-file-request/>" )
				c.write( getXml() );
			c.close();
		}
	}
	#end
	
}
