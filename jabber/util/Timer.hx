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
package jabber.util;

#if !(neko||cpp)
typedef Timer = haxe.Timer;
#else

#if neko
import neko.vm.Thread;
import neko.Sys;
#elseif cpp
import cpp.vm.Thread;
import cpp.Sys;
#end

/**
	Patched version of haxe.Timer supporting neko too.
	!! This approach is NOT safe, but seems to work so far.
*/
class Timer {
	
	#if (php)
	#else

	private var id : Null<Int>;

	#if js
	private static var arr = new Array<Timer>();
	private var timerId : Int;
	#elseif (neko||cpp)
	private var runThread : Thread;
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
		#elseif (neko||cpp)
		var me = this;
		runThread = Thread.create(function() { me.runLoop(time_ms); });
		#end
	}

	public function stop() {
		#if( php || flash9 || flash || js )
		if( id == null )
			return;
		#end
		#if flash9
		untyped __global__["flash.utils.clearInterval"](id);
		#elseif flash
		untyped _global["clearInterval"](id);
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
		#elseif (neko||cpp)
		run = function() {};
		runThread.sendMessage("stop");
		#end
		id = null;
	}

	public dynamic function run() {
	}

	#if (neko||cpp)
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

	public static function delay( f : Void -> Void, time_ms : Int ) {
		var t = new Timer(time_ms);
		t.run = function() {
			t.stop();
			f();
		};
	}

	#end

	/**
		Returns a timestamp, in seconds
	*/
	public static inline function stamp() : Float {
		#if flash
		return flash.Lib.getTimer() / 1000;
		#elseif (neko||cpp)
		return Sys.time();
		#elseif php
		return php.Sys.time();
		#elseif js
		return Date.now().getTime() / 1000;
		#else
		return 0;
		#end
	}

}

#end
