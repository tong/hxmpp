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

//TODO data context (name) ??
// needed ..? the jid is already a data context (?)

/**
	<a href="http://haxe.org/doc/remoting">haXe-remoting</a><br/>
	haXe remoting connection to a XMPP entity.<br/>
	User ServiceDiscovery to determine if an entity supports haXe-remoting.
*/
class Connection implements AsyncConnection, implements Dynamic<AsyncConnection> {
	
	//static var connections = new Hash<Connection>();
	
	/** JID of current active entity */
	public var target : String;
	public var stream(default,null) : jabber.Stream;
	
	//var __data : { name : String, ctx : Context, #if js flash : String #end };//TODO data context
	var __error : Dynamic->Void;
	var __path : Array<String>;
	
	function new( stream : jabber.Stream, target : String, path : Array<String>, error : Dynamic->Void ) {
		this.stream = stream;
		this.target = target;
		//__data = data;
		__path = path;
		__error = error;
	}
	
	public function resolve( name : String ) : AsyncConnection {
		var c = new Connection( stream, target, __path.copy(), __error );
		c.__path.push( name );
		return c;
	}
	
	/*TODO
	public function close() {
		connections.remove( __data.name );
	}
	*/
	
	public function setErrorHandler( h : Dynamic->Void ) {
		__error = h;
	}
	
	/**
	*/
	public function call( params : Array<Dynamic>, ?onResult : Dynamic->Void ) {
		var s = new haxe.Serializer();
		s.serialize( __path );
		s.serialize( params );
		var iq = new xmpp.IQ( null, null, target, stream.jidstr );
		iq.properties.push( xmpp.HXR.create( s.toString() ) );
		var error = __error;
		stream.sendIQ( iq, function(r) {
			switch( r.type ) {
			case IQType.result :
				var v = xmpp.HXR.getData( r.x.toXml() );
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
					onResult( ret );
			case IQType.error :
				//TODO check
				//var err = xmpp.Error.parse( r.x.toXml() );
				var err = r.errors[0];
				error( err );
			default :
				#if JABBER DEBUG
				trace( "Invalid remoting response type "+r.type );
				#end
			}
		} );
	}
	
	/**
	*/
	public static function create( stream : jabber.Stream, target : String ) {
		return new Connection( stream, target, [], function(e) throw e );
	}
	
}
