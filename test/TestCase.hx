
//http://code.google.com/p/haxe/source/browse/trunk/tests/unit/Test.hx

class TestCase extends haxe.unit.TestCase {
	
	inline function eq<T>( a : T, b : T, ?pos ) {
		assertEquals( a, b );
	}

	inline function at( v : Bool ) {
		assertTrue( v );
	}
	
	inline function af( v : Bool ) {
		assertFalse( v );
	}
	
	//function report( s : String, ?pos : haxe.PosInfos ) {
	
}
