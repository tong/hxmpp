
import jabber.util.SHA1;

class TestSHA1 extends TestCase {

	public function test() {
		
		var t = "The quick brown fox jumps over the lazy dog";
		eq( "2fd4e1c67a2d28fced849ee1bb76e7391b93eb12", SHA1.encode(t) );
		
		t = "The quick brown fox jumps over the lazy cog";
		eq( "de9f2c7fd25e1b3afad3e85a0bd17d9b100db4b3", SHA1.encode(t) );
		
		/*
		var timestamp = haxe.Timer.stamp();
		for( i in 0...1 ) {
			var r = SHA1.encode(t);
		}
		trace( haxe.Timer.stamp()-timestamp );
		*/
		
	}
	
}
