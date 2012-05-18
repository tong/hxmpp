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
package jabber.data;

/**
	Abstract, outgoing data transfer.
*/
class DataTransfer {
	
	//public dynamic function onInit( ft : FileTransfer ) {} //TODO
	public dynamic function onProgress( bytes : Int ) {}
	public dynamic function onComplete() {}
	public dynamic function onFail( info : String  ) {}
	
	public var stream(default,null) : jabber.Stream;
	
	/** The namespace of this transfer method */
	public var xmlns(default,null) : String;
	
	/** JID of the recieving entity */
	public var reciever(default,null) : String;
	public var bufsize(default,null) : Int;
	public var file(default,null) : xmpp.file.File;
	
	var input : haxe.io.Input;
	var sid : String;
	 
	function new( stream : jabber.Stream, xmlns : String, reciever : String, bufsize : Int ) {
		this.stream = stream;
		this.xmlns = xmlns;
		this.reciever = reciever;
		this.bufsize = bufsize;
	}
	
	public function init( input : haxe.io.Input, sid : String, file : xmpp.file.File ) {
		this.input = input;
		this.sid = sid;
		this.file = file;
		// override me
	}
	
	/*
	//TODO
	public function abort() {
	}
	*/
	
	function handleTransportFail( info : String ) {
		//transport.dispose();
		onFail( info );
	}

}
