package util;


class Delay {
	
	/**
		Hack to have a neko timer delay ( in a seperate thread ).
	*/
	public static function run( handler : Void->Void, secs : Int ) {
		
		#if neko
		if( secs == 0 ) secs = 1;
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
		throw "PHP not supported.";
		
		#end
	}
	
}
