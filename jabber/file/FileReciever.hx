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
package jabber.file;

/**
	Incoming file transfer handler base.
*/
class FileReciever {
	
	public dynamic function onComplete( r : FileReciever ) : Void;
	public dynamic function onFail( r : FileReciever, m : String ) : Void;
	public dynamic function onError( e : jabber.XMPPError ) : Void;
	
	public var stream(default,null) : jabber.Stream;
	public var xmlns(default,null) : String;
	public var initiator(default,null) : String;
	public var data(getData,null) : haxe.io.Bytes;
	
	var request : xmpp.IQ;
	
	function new( stream : jabber.Stream, xmlns : String ) {
		this.stream = stream;
		this.xmlns = xmlns;
	}
	
	function getData() : haxe.io.Bytes {
		return throw "Abstract error";
	}
	
	public function handleRequest( iq : xmpp.IQ ) : Bool {
		request = iq;
		initiator = iq.from;
		return true;
	}
	
	public function accept( yes : Bool = true ) {
		throw "Abstract method";
	}
	
}
