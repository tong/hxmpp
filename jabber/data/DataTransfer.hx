/*
 * Copyright (c) 2012, tong, disktree.net
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
