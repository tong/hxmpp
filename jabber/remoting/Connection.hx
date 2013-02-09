/*
 * Copyright (c) 2012, disktree.net
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */
package jabber.remoting;

import haxe.remoting.AsyncConnection;
import xmpp.IQType;

//TODO data context (name) ??
// needed ..? the jid is already a data context (?)

/**
	Haxe remoting connection to an XMPP entity.
	User ServiceDiscovery to determine if an entity supports haxe-remoting (hxr).

	http://haxe.org/doc/remoting
*/
class Connection implements AsyncConnection implements Dynamic<AsyncConnection> {
	
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
		var iq = new xmpp.IQ( null, null, target, stream.jid.toString() );
		iq.properties.push( xmpp.HXR.create( s.toString() ) );
		var error = __error;
		//trace("REMOTEOTE-OUT:::"+iq.id );
		stream.sendIQ( iq, function(r:xmpp.IQ) {
			//trace("RESSUUUUUUUUUUULT");
			switch( r.type ) {
			case result :
				var v = xmpp.HXR.getData( r.x.toXml() );
				var ok = true;
				var ret;
				//trace("RESSUlT2 "+v);
				try {
					if( v.substr(0,3) != "hxr" )
						throw "invalid response : '"+v+"'";
					var s = new haxe.Unserializer( v.substr( 3 ) );
					ret = s.unserialize();
				} catch( err : Dynamic ) {
					ret = null;
					ok = false;
					error( err );
				}
				//trace("REPORTED "+ret);
				if( ok && onResult != null )
					onResult( ret );
					
			case error :
				//TODO check
				//var err = xmpp.Error.parse( r.x.toXml() );
				var e = r.errors[0];
				error( e );
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
