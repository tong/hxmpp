/*
 * Copyright (c), disktree.net
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
package jabber.net;

#if flash

import flash.net.Socket;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;
import flash.events.ProgressEvent;
import flash.utils.ByteArray;
import haxe.io.Bytes;

/**
	Abstract base class for flash socket connections
*/
@:require(flash)
class SocketConnectionBase_fl extends jabber.StreamConnection {

	public static var defaultBufSize = #if php 65536 #else 256 #end; //TODO php buf
	public static var defaultMaxBufSize = 1<<22; // 4MB
	public static var defaultTimeout = 10;

	public var port(default,null) : Int;
	public var maxbufsize(default,null) : Int;
	public var timeout(default,null) : Int;
	public var socket(default,null) : Socket;

	var buf : Bytes;
	var bufpos : Int;
	var bufsize : Int;

	function new( host : String, port : Int, secure : Bool,
				  bufsize : Int = -1, maxbufsize : Int = -1,
				  timeout : Int = -1 ) {

		super( host, secure, false );
		this.port = port;
		this.bufsize = ( bufsize == -1 ) ? defaultBufSize : bufsize;
		this.maxbufsize = ( maxbufsize == -1 ) ? defaultMaxBufSize : maxbufsize;
		this.timeout = ( timeout == -1 ) ? defaultTimeout : timeout;
	}

}

#end
