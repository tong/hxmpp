package jabber.util;

#if neko
import neko.net.Socket;
#elseif cpp
import cpp.net.Socket;
#elseif nodejs
import js.Node;
typedef Socket = Stream;
#elseif (air&&flash)
import flash.net.Socket;
#elseif (air&&js)
import air.Socket;
#end

class FlashPolicy {
	
	public static function allow( request : String, socket : Socket, host : String, port : Int ) {
		if( request.length == 23 && request.substr(0,22) == "<policy-file-request/>" ) {
			#if (neko||cpp)
			socket.write( '<cross-domain-policy><allow-access-from domain="'+host+'" to-ports="'+port+'"/></cross-domain-policy>'+String.fromCharCode(0) );
			socket.output.flush();
			#elseif nodejs
			socket.write( '<cross-domain-policy><allow-access-from domain="'+host+'" to-ports="'+port+'"/></cross-domain-policy>'+String.fromCharCode(0) );
			#elseif air
			socket.writeUTFBytes( '<cross-domain-policy><allow-access-from domain="'+host+'" to-ports="'+port+'"/></cross-domain-policy>'+String.fromCharCode(0) );
			socket.flush();
			#end
		}
	}
	
}
