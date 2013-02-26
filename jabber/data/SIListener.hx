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
package jabber.data;

import xmpp.IQ;

/**
	Listens/Negotiates incoming data transfer requests <a href="http://xmpp.org/extensions/xep-0096.html">XEP-0096: SI File Transfer</a>
*/
class SIListener {
	
	public dynamic function onFail( info : String ) {}
	
	public var stream(default,null) : jabber.Stream;
	/** Callback handler for incoming transfer requests */
	public var handler : DataReciever->Void;
	/** Available file transfer methods */
	public var methods(default,null) : Array<DataReciever>;
	
	var c : PacketCollector;
	
	public function new( stream : jabber.Stream, handler : DataReciever->Void ) {
		if( !stream.features.add( xmpp.file.File.XMLNS ) )
			throw "SI data transfer listener already added";
		this.stream = stream;
		this.handler = handler;
		methods = new Array();
		c = stream.collect( [new xmpp.filter.IQFilter( xmpp.file.SI.XMLNS, xmpp.IQType.set, "si" )],
						 	 handleRequest, true );
	}
	
	public function dispose() {
		stream.removeCollector( c );
		stream.features.remove( xmpp.file.File.XMLNS  );
	}
	
	function handleRequest( iq : IQ ) {
		if( this.methods.length == 0 ) {
			#if jabber_debug trace( "No file tranfer methods registerd with the SI listener", "warn" ); #end
			return;
		}
		var si = xmpp.file.SI.parse( iq.x.toXml() );
		var file : xmpp.file.File = null;
		var _methods = new Array<String>();
		for( e in si.any ) {
			if( e.nodeName == "feature" && e.get( "xmlns" ) == xmpp.FeatureNegotiation.XMLNS ) {
				for( e in e.elements() ) {
					switch( e.nodeName ) {
					case "x" :
						var form = xmpp.DataForm.parse( e );
						var f = form.fields[0];
						if( f.variable == "stream-method" ) {
							for( o in f.options )
								_methods.push( o.value );
						}
					}
				}
			} else if( e.nodeName == "file" && e.get( "xmlns" ) == xmpp.file.File.XMLNS ) {
				file = xmpp.file.File.parse( e );
			}
		}
		if( file == null ) {
			stream.sendPacket( IQ.createError( iq, [new xmpp.Error( xmpp.ErrorType.cancel, "bad-request" )] ) );
			onFail( "invalid file transfer request" );
			return;
		}
		var a_methods = new Array<DataReciever>();
		for( m in methods ) {
			for( _m in _methods ) {
				if( m.xmlns == _m ) a_methods.push( m );
			}
		}
		if( a_methods.length == 0 ) {
			onFail( "no matching file transfer method" );
			stream.sendPacket( IQ.createError( iq, [new xmpp.Error( xmpp.ErrorType.cancel, "bad-request" )] ) );
			return;
		}
		// new FileTransferNegotiator();
		var m = a_methods[0];
		m.init( file, iq, si.id );
		handler( m );
	}
	
}
