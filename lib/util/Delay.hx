package util;


class Delay {
	
	/*
	public function new() {
	}
	function run() {
	}
	*/
	
	
	/**
		Hack to have a neko timer delay ( in a seperate thread ).
	*/
	public static function run( handler : Void->Void, secs : Float ) {
		
		#if neko
		if( secs <= 0 ) throw "Invalid argument";
		var t = function() {
			var thread = neko.vm.Thread.create( function() {
				neko.Sys.sleep( secs );
				handler();
			} );
		}
		t();
		
		#elseif ( flash || js )
		haxe.Timer.delay( handler, Std.int( secs*1000 ) );
		
		#elseif php
		throw "PHP util.Delay not supported.";
		
		#end
	}
	
}
