
//http://code.google.com/p/haxe/source/browse/trunk/tests/unit/Test.hx

class TestCase extends haxe.unit.TestCase {
	
	function eq<T>( a : T, b : T ) {
		assertEquals( a, b );
	}

	function at( v : Bool ) {
		assertTrue( v );
	}
	
	function af( v : Bool ) {
		assertFalse( v );
	}
	
	
}
