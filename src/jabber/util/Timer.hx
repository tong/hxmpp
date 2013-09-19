/*
 * Copyright (c) disktree.net
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

#if (!cpp&&!neko)
typedef Timer = haxe.Timer;
#else

#if neko
import neko.vm.Thread;
#elseif cs
import cs.vm.Thread;
#elseif java
import java.vm.Thread;
#elseif cpp
import cpp.vm.Thread;
#end

/**
	Patched version of haxe.Timer supporting neko and cpp.
*/
class Timer {
	
	#if php
	#else

	var id : Null<Int>;

	#if js
	static var arr = new Array<Timer>();
	var timerId : Int;
	
	#elseif (cpp||css||java||neko)
	var runThread : Thread;
	
	#end

	public function new( time_ms : Int ){
		
		#if flash9
		var me = this;
		id = untyped __global__["flash.utils.setInterval"](function() { me.run(); },time_ms);
		
		#elseif flash
		var me = this;
		id = untyped _global["setInterval"](function() { me.run(); },time_ms);
		
		#elseif js
		id = arr.length;
		arr[id] = this;
		timerId = untyped window.setInterval("haxe.Timer.arr["+id+"].run();",time_ms);
		
		#elseif (cpp||cs||java||neko)
		var me = this;
		runThread = Thread.create(function() { me.runLoop(time_ms); });
		
		#end
	}

	public function stop() {
		
		#if (flash9||flash||js)
		if( id == null )
			return;
		#end
		
		#if flash9
		untyped __global__[ "flash.utils.clearInterval" ]( id );
		
		#elseif flash
		untyped _global[ "clearInterval" ]( id );
		
		#elseif js
		untyped window.clearInterval(timerId);
		arr[id] = null;
		if( id > 100 && id == arr.length - 1 ) {
			// compact array
			var p = id - 1;
			while( p >= 0 && arr[p] == null )
				p--;
			arr = arr.slice(0,p+1);
		}
		
		#elseif (cpp||cs||java||neko)
		run = function() {};
		runThread.sendMessage("stop");
		
		#end
		
		id = null;
	}

	public dynamic function run() {}

	#if (cpp||cs||java||neko)
	
	private function runLoop(time_ms) {
	  	var shouldStop = false;
	  	while( !shouldStop ) {
		try {
			Sys.sleep(time_ms/1000);
	      	run();
	      	var msg = Thread.readMessage(false);
	      	if( msg == "stop" )
				shouldStop = true;
	    } catch( ex:Dynamic ) {}
	  }
	}
	
	#end

	public static function delay( f : Void -> Void, ms : Int ) : Timer {
		var t = new Timer( ms );
		t.run = function() {
			t.stop();
			f();
		};
		return t;
	}

	#end

	/**
		Returns a timestamp, in seconds
	*/
	public static inline function stamp() : Float {
		#if flash
		return flash.Lib.getTimer() / 1000;
		#elseif sys
		return Sys.time();
		#elseif js
		return Date.now().getTime() / 1000;
		#else
		return 0;
		#end
	}

}

#end
