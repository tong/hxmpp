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
package jabber.jingle;

import haxe.io.Bytes;
import jabber.jingle.io.ByteStreamOutput;
import jabber.jingle.io.Transport;
import xmpp.IQ;
#if neko
import neko.FileSystem;
import neko.io.File;
import neko.io.Path;
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
	
	//public dynamic function onProgress( bytes : Bytes ) {}
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
	
	function onTransportComplete() {
		trace("onTransportComplete");
		onComplete();
		//
	}
	
	function onTransportFail( e : String ) {
		trace("onTransportFail");
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
