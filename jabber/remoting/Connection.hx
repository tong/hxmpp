/*
 *	This file is part of HXMPP.
 *	Copyright (c)2009 http://www.disktree.net
 *	
 *	HXMPP is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU Lesser General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  HXMPP is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 *	See the GNU Lesser General Public License for more details.
 *
 *  You should have received a copy of the GNU Lesser General Public License
 *  along with HXMPP. If not, see <http://www.gnu.org/licenses/>.
*/
package jabber.remoting;

import haxe.remoting.AsyncConnection;

/**
	haXe remoting connection over XMPP.
*/
class Connection implements AsyncConnection, implements Dynamic<AsyncConnection> {
	
	public var target(default,null) : String;
	public var stream(default,null) : jabber.Stream;
	
	var __error : Dynamic->Void;
	var __path : Array<String>;
	
	function new( stream : jabber.Stream, target : String, path : Array<String>, error : Dynamic->Void ) {
		this.stream = stream;
		this.target = target;
		__path = path;
		__error = error;
	}
	
	public function resolve( name : String ) : AsyncConnection {
		var c = new Connection( stream, target, __path.copy(), __error );
		c.__path.push( name );
		return c;
	}
	
	public function setErrorHandler( h : Dynamic->Void ) {
		__error = h; //TODO
	}
	
	public function call( params : Array<Dynamic>, ?onResult : Dynamic -> Void ) {
		var s = new haxe.Serializer();
		s.serialize( __path );
		s.serialize( params );
		var iq = new xmpp.IQ( null, null, target );
		iq.properties.push( xmpp.HaXe.create( s.toString() ) );
		var error = __error;
		stream.sendIQ( iq, function(r) {
			switch( r.type ) {
			case result :
				var x = r.x.toXml();
				var v = x.firstChild().nodeValue;
				var ok = true;
				var ret;
				try {
					if( v.substr(0,3) != "hxr" )
						throw "Invalid response : '"+v+"'";
					var s = new haxe.Unserializer( v.substr( 3 ) );
					ret = s.unserialize();
				} catch( err : Dynamic ) {
					ret = null;
					ok = false;
					error( err );
				}
				if( ok && onResult != null )
					onResult(ret);
			case error :
				var err = xmpp.Error.fromPacket( r );
				error( err );
			default :
			}
		} );
	}
	
	public static function connect( stream : jabber.Stream, target : String ) {
		return new Connection( stream, target, [], function(e) throw e );
	}
	
}
