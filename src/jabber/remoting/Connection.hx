/*
 * Copyright (c) disktree.net
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

/**
	Haxe remoting connection to another XMPP entity.
	User ServiceDiscovery to determine if an entity supports haxe-remoting (hxr).

	http://haxe.org/doc/remoting
*/
class Connection implements AsyncConnection implements Dynamic<AsyncConnection> {
	
	/** Jid of opposite */
	public var target : String;
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
	
	/*
	TODO
	public function close() {
		connections.remove( __data.name );
	}
	*/
	
	public inline function setErrorHandler( h : Dynamic->Void ) {
		__error = h;
	}
	
	public function call( params : Array<Dynamic>, ?onResult : Dynamic->Void ) {
		var s = new haxe.Serializer();
		s.serialize( __path );
		s.serialize( params );
		var iq = new xmpp.IQ( null, null, target, stream.jid.toString() );
		iq.properties.push( xmpp.HXR.create( s.toString() ) );
		var error = __error;
		stream.sendIQ( iq, function(r:xmpp.IQ) {
			switch( r.type ) {
			case result :
				var v = xmpp.HXR.getData( r.x.toXml() );
				var ok = true;
				var ret;
				try {
					if( v.substr(0,3) != "hxr" )
						throw 'invalid response ($v)';
					var s = new haxe.Unserializer( v.substr( 3 ) );
					ret = s.unserialize();
				} catch( err : Dynamic ) {
					ret = null;
					ok = false;
					error( err );
				}
				if( ok && onResult != null )
					onResult( ret );
			case error :
				//var err = xmpp.Error.parse( r.x.toXml() ); // check
				var e = r.errors[0];
				error( e );
			default :
				#if JABBER DEBUG
				trace( "Invalid remoting response type "+r.type );
				#end
			}
		} );
	}
	
	public static inline function create( stream : jabber.Stream, target : String ) {
		return new Connection( stream, target, [], function(e) throw e );
	}
	
}
