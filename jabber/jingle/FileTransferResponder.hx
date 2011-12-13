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
import jabber.jingle.io.ByteStreamInput;

/**
	EXPERIMENTAL!
*/
class FileTransferResponder extends SessionResponder<ByteStreamInput> {
	
	public dynamic function onProgress( data : Bytes ) {}
	public dynamic function onComplete() {}
	
	public var filename(default,null) : String;
	public var filedate(default,null) : String;
	public var filesize(default,null) : Int;
	
	public function new( stream : jabber.Stream ) {
		super( stream, xmpp.Jingle.XMLNS_S5B );
	}
	
	override function parseDescription( x : Xml ) {
		for( e in x.elements() ) {
			switch( e.nodeName ) {
			case "offer" :
				for( e in e.elements() ) {
					switch( e.nodeName ) {
					case "file" :
						filename = e.get( "name" );
						filedate = e.get( "date" );
						filesize = Std.parseInt( e.get( "size" ) );
					}
				}
			}
		}
	}
	
	override function handleTransportConnect() {
		transport.__onProgress = onProgress;
		transport.__onComplete = onComplete;
		super.handleTransportConnect();
		transport.read();
	}
	
	override function addTransportCandidate( x : Xml ) {
		candidates.push( new ByteStreamInput( x.get( "host" ), Std.parseInt( x.get( "port" ) ), filesize ) );
	}
	
}
