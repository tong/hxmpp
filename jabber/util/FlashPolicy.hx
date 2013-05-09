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
package jabber.util;

#if (sys)
import sys.net.Socket;
#elseif nodejs
import js.Node;
typedef Socket = Stream;
#elseif (air&&flash)
import flash.net.Socket;
#elseif (air&&js)
import air.Socket;
#end

class FlashPolicy {
	
	public static function allow( request : String, socket : Socket, host : String, port : Int ) {
		if( request.length == 23 && request.substr(0,22) == "<policy-file-request/>" ) {
			#if sys
			socket.write( '<cross-domain-policy><allow-access-from domain="'+host+'" to-ports="'+port+'"/></cross-domain-policy>'+String.fromCharCode(0) );
			socket.output.flush();
			#elseif nodejs
			socket.write( '<cross-domain-policy><allow-access-from domain="'+host+'" to-ports="'+port+'"/></cross-domain-policy>'+String.fromCharCode(0) );
			#elseif air
			socket.writeUTFBytes( '<cross-domain-policy><allow-access-from domain="'+host+'" to-ports="'+port+'"/></cross-domain-policy>'+String.fromCharCode(0) );
			socket.flush();
			#end
		}
	}
	
}
