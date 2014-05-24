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

import haxe.Serializer;
import haxe.Unserializer;
import haxe.remoting.Context;
import xmpp.IQ;
import xmpp.HXR;
import xmpp.HXR.XMLNS;
import jabber.Stream;

/**
	Haxe/XMPP remoting host (http://haxe.org/doc/remoting)
*/
class Host {
	
	public static var num(default,null) : Int = 0; 
	
	/** Jid of current/last active entity */
	public var client(default,null) : String;
	public var stream(default,null) : Stream;
	public var ctx : Context;
	
	var c : PacketCollector;
	
	public function new( stream : Stream, ctx : Context ) {
		
		this.stream = stream;
		this.ctx = ctx;

		stream.features.add( XMLNS );
		c = stream.collectPacket( [new xmpp.filter.IQFilter( XMLNS, xmpp.IQType.get )], handleIQ, true );
		num++;
	}
	
	public function close() {
		//TODO maybe other hosts are active (check in this class internal, statics)
		stream.removeCollector( c );
		if( --num == 0 )
			stream.features.remove( XMLNS );
	}
	
	function handleIQ( iq : IQ ) {
		client = iq.from;
		var req = HXR.getData( iq.x.toXml() );
		var res = processRequest( req, ctx );
		var r = IQ.createResult( iq );
		//TODO send empty result IQ (void)
		r.properties.push( HXR.create( res ) );
		stream.sendPacket( r );
		/*
		//TODO check error settings
		var r = xmpp.IQ.createErrorResult( iq, [new xmpp.Error(xmpp.ErrorType.modify,null,xmpp.ErrorCondition.NOT_ACCEPTABLE)] );
		stream.sendPacket( r );
		*/
	}
	
	public static function processRequest( data : String, ctx : Context ) : String {
		try {
			var u = new Unserializer( data );
			var path = u.unserialize();
			var args = u.unserialize();
			var d = ctx.call( path, args );
			var s = new Serializer();
			s.serialize( d );
			return "hxr"+s.toString();
		} catch( e : Dynamic ) {
			var s = new Serializer();
			s.serializeException( e );
			return "hxr"+s.toString();
		}
	}
	
}
