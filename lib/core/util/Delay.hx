package util;


class Delay {
	
	/**
		Hack to have a neko timer delay ( in a seperate thread ).
	*/
	public static function run( handler : Void->Void, t : Int ) {
		
		#if neko
		if( t == 0 ) t = 1;
		var t = function() {
			var thread = neko.vm.Thread.create( function() {
				neko.Sys.sleep( t );
				handler();
			} );
		}
		t();
		
		#elseif ( flash || js || flash9 || flash10 )
		haxe.Timer.delay( handler, Std.int( t*1000 ) );
		
		#elseif php
		throw "PHP not supported.";
		
		#end
	}
	
}
