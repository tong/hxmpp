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
package jabber.jingle;

import haxe.io.Bytes;
import jabber.jingle.io.ByteStreamOutput;
import jabber.jingle.io.Transport;
//import jabber.io.Transport;
//import jabber.io.ByteStreamOutput;
import xmpp.IQ;
#if sys
import sys.FileSystem;
import sys.io.File;
import haxe.io.Path;
#elseif nodejs
import js.Node;
import js.FileSystem;
import js.io.File;
import js.io.Path;
#end

/**
	EXPERIMENTAL!
*/
class FileTransfer extends OutgoingSession<ByteStreamOutput> {
	
	public dynamic function onProgress( bytes : Int ) {}
	public dynamic function onComplete() {}
	
	var input : haxe.io.Input;
	var filesize : Int;
	
	public function new( stream : jabber.Stream, entity : String, contentName : String = "file-offer" ) {
		super( stream, entity, contentName, xmpp.Jingle.XMLNS_S5B );
	}
	
	public function sendData( bytes : Bytes, name : String, ?desc : String, ?date : String ) {
		this.input = new haxe.io.BytesInput( bytes );
		sendRequest( name, bytes.length, date, desc );
	}
	
	public function sendFile( filepath : String, ?desc : String ) {
		if( !FileSystem.exists( filepath ) )
			throw "file not found ["+filepath+"]";
		this.input = File.read( filepath, true );
		var fstat = FileSystem.stat( filepath );
		var fname = Path.withoutDirectory( filepath );
		var fdate = fstat.mtime.toString();
		filesize = Std.int( fstat.size );
		sendRequest( fname, filesize, fdate, desc );
	}
	
	function sendRequest( name : String, size : Int,
						  ?date : String, ?desc : String ) {
		for( t in transports ) {
			//t.__onConnect = handleTransportConnect;
			t.__onClientConnect = handleClientConnect;
			t.__onProgress = onTransportProgress;
			t.__onFail = onTransportFail;
			try t.init() catch( e : Dynamic ) {
				trace(e);
				transports.remove(t);
			}
		}
		if( transports.length == 0 ) {
			onFail( "unable to activate a streamhost" );
			return;
		}
		//TODO
		var xdesc = Xml.createElement( "description" );
		xdesc.set( "xmlns", "urn:xmpp:jingle:apps:file-transfer:1" );
		var xoffer = Xml.createElement( "offer" );
		var xfile = Xml.createElement( "file" );
		xfile.set( "xmlns", xmpp.file.File.XMLNS );
		//TODO if( hash != null ) xfile.set( "hash", hash );
		xfile.set( "date", xmpp.DateTime.utc( date ) );
		xfile.set( "name", name );
		xfile.set( "size", Std.string( size ) );
		if( desc != null ) xfile.addChild( xmpp.XMLUtil.createElement( "desc", desc ) );
		xoffer.addChild( xfile );
		xdesc.addChild( xoffer );
		sendSessionInit( xdesc );
	}
	
	function handleClientConnect( t : ByteStreamOutput ) {
		transport = t;
		transport.__onComplete = onTransportComplete;
	}
	
	function onTransportProgress( bytes : Int ) {
		onProgress( bytes );
	}
	
	function onTransportComplete() {
		//trace("onTransportComplete");
		onComplete();
		//
	}
	
	function onTransportFail( e : String ) {
		//trace("onTransportFail");
		onFail(e);
		//TODO
	}
	
	override function processSessionPacket( iq : IQ, j : xmpp.Jingle ) {
		switch( j.action ) {
		case session_accept :
			var content = j.content[0];
			/*
			candidates = new Array();
			for( t in transports ) {
				for( e in content.other ) {
					if( e.get( "host" ) == t.host && Std.parseInt( e.get( "port" ) ) == t.port ) {
						candidates.push( t );
						continue; // break;
					}
				}
			}
			if( candidates.length == 0 ) {
				trace("TODO No valid transport candidate selected");
				return;
			}
			*/
			for( t in transports ) {
				for( e in content.other ) {
					if( e.get( "host" ) == t.host && Std.parseInt( e.get( "port" ) ) == t.port ) {
						transport = t;
						break;
					}
				}
			}
		//	if( transport == null )----
			stream.sendPacket( IQ.createResult( iq ) );
			transport.send( input, filesize );
			
		default :
			trace("Jingle session packet not handled");
		}
	}
	
	override function createCandidateXml( t : Transport ) : Xml {
		var x = t.toXml();
		x.set( "jid", stream.jid.toString() );
		return x;
	}
	
}
