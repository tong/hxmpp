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
	public dynamic function onInit( t : FileTransfer ) : Void;
	public dynamic function onComplete( t : FileTransfer ) : Void;
	public dynamic function onFail( t : FileTransfer, e : jabber.XMPPError  ) : Void;
	
	public var stream(default,null) : jabber.Stream;
	/** The namespace of the transfer method used */
	public var xmlns(default,null) : String;
	/** */
	public var sid : String; //public var sid(default,null) : String;
	/** JID of the transfer reciever */
	public var reciever(default,null) : String;
//	/** Data to be transfered */
//	public var data(default,null) : haxe.io.Bytes;
	
	var input : haxe.io.Input;
	 
	function new( stream : jabber.Stream, xmlns : String, reciever : String ) {
		this.stream = stream;
		this.xmlns = xmlns;
		this.reciever = reciever;
	}
	
	public function init( input : haxe.io.Input ) {
		throw "Abstract method";
	}
	
}
