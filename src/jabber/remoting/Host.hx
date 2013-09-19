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

import haxe.remoting.Context;

/**
	HaXe remoting host.<br/>
	<a href="http://haxe.org/doc/remoting">http://haxe.org/doc/remoting</a>
*/
class Host {
	
	static function __init__() {
		numActive = 0;
	}
	
	public static var numActive(default,null) : Int; 
	
	/** JID of current/last processed entity */
	public var client(default,null) : String;
	public var ctx : Context;
	public var stream(default,null) : jabber.Stream;
	
	var c : PacketCollector;
	
	public function new( stream : jabber.Stream, ctx : Context ) {
		this.stream = stream;
		this.ctx = ctx;
		stream.features.add( xmpp.HXR.XMLNS );
		c = stream.collect( [new xmpp.filter.IQFilter( xmpp.HXR.XMLNS, xmpp.IQType.get )], handleIQ, true );
		numActive++;
	}
	
	public function close() {
		//TODO maybe other hosts are active (check in this class internal, statics)
		stream.removeCollector( c );
		if( --numActive == 0 )
			stream.features.remove( xmpp.HXR.XMLNS );
	}
	
	function handleIQ( iq : xmpp.IQ ) {
		client = iq.from;
		var request = xmpp.HXR.getData( iq.x.toXml() );
		var response = processRequest( request, ctx );
		var r = xmpp.IQ.createResult( iq );
		//TODO send empty result IQ (void)
		r.properties.push( xmpp.HXR.create( response ) );
		stream.sendPacket( r );
		/*
		//TODO check error settings
		var r = xmpp.IQ.createErrorResult( iq, [new xmpp.Error(xmpp.ErrorType.modify,null,xmpp.ErrorCondition.NOT_ACCEPTABLE)] );
		stream.sendPacket( r );
		*/
	}
	
	public static function processRequest( data : String, ctx : Context ) : String {
		try {
			var u = new haxe.Unserializer( data );
			var path = u.unserialize();
			//trace(path);
			var args = u.unserialize();
			//trace(args);
			var d = ctx.call( path, args );
			var s = new haxe.Serializer();
			s.serialize( d );
			return "hxr"+s.toString();
		} catch( e : Dynamic ) {
			var s = new haxe.Serializer();
			s.serializeException( e );
			return "hxr"+s.toString();
		}
	}
	
}
