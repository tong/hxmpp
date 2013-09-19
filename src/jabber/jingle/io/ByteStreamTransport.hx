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
package jabber.jingle.io;

#if (neko||cpp)
import sys.net.Socket;
#end
#if flash
import flash.net.Socket;
#elseif nodejs
import js.Node;
private typedef Socket = Stream;
#end

class ByteStreamTransport extends Transport {
	
	public var __onComplete : Void->Void;
	
	public var host(default,null) : String;
	public var port(default,null) : Int;
	
	var socket : Socket;
	var bufsize : Int;
	
	public function new( host : String, port : Int, bufsize : Int = 4096 ) {
		super();
		this.host = host;
		this.port = port;
		this.bufsize = bufsize;
	}
	
	public override function toXml() : Xml {
		var x = Xml.createElement( 'candidate' ); // TODO out of spec ..should be 'streamhost'
		x.set( 'host', host );
		x.set( 'port', Std.string( port )  );
		return x;
	}
	
}
