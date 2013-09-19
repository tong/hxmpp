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
package jabber.util;

class SystemUtil {
	
	/**
		Returns the name of the operating system used (crossplatform).
	*/
	public static
	#if (nodejs||!js) inline #end
	function systemName() : String {
		
		#if sys
		return Sys.systemName();

		#elseif nodejs
		return Node.process.platform;
		
		#elseif flash
		return flash.system.Capabilities.os;
		
		#elseif js
		var t : String  = untyped window.navigator.appVersion;
		t = t.substr( t.indexOf("(")+1, t.indexOf(")")-3 );
		return if( t.indexOf( "Linux" ) != -1 ) "Linux";
		else if( t.indexOf( "Macintosh" ) != -1 ) "Macintosh";
		else if( t.indexOf( "Windows" ) != -1 ) "Windows";
		else null;
		
		#end
	}
	
}
