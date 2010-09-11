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
	Abstract, outgoing file transfer negotiator.
*/
class FileTransfer {
	
	//public dynamic function onReject( t : Transfer ) : Void;
	//public dynamic function onInit( ft : FileTransfer ) : Void;
	public dynamic function onComplete() : Void;
	public dynamic function onFail( info : String  ) : Void;
	
	public var stream(default,null) : jabber.Stream;
	public var xmlns(default,null) : String;
	public var reciever(default,null) : String;
	public var bufsize(default,null) : Int;
	
	var fileSize : Int;
	var input : haxe.io.Input;
	var sid : String;
	 
	function new( stream : jabber.Stream, xmlns : String, reciever : String, bufsize : Int ) {
		this.stream = stream;
		this.xmlns = xmlns;
		this.reciever = reciever;
		this.bufsize = bufsize;
	}
	
	public function __init( input : haxe.io.Input, sid : String, fileSize : Int ) {
		throw "Abstract method";
	}
	
}
