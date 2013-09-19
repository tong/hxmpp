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
import jabber.jingle.io.ByteStreamInput;
//import jabber.io.ByteStreamInput;

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
