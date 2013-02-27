
import jabber.util.Base64;

class TestBase64 extends haxe.unit.TestCase {

	// $ echo -n "disktree" | openssl base64 
	// ZGlza3RyZWU=
	
	public function test() {
		
		assertEquals( "Zm9v", Base64.encode("foo") );
		assertEquals( "Zm9vYg==", Base64.encode("foob") );
		assertEquals( "Zm9vYmE=", Base64.encode("fooba") );
		assertEquals( "Zm9vYmFy", Base64.encode("foobar") );
		
		var t = "disktree";
		var te = "ZGlza3RyZWU=";
		assertEquals( te, Base64.encode( t ) );
		assertEquals( t, Base64.decode( te ) );
		assertEquals( t, Base64.decode( Base64.encode( t ) ) );
		
		t = "haxe";
		te = "aGF4ZQ==";
		assertEquals( te, Base64.encode(t) );
		assertEquals( t, Base64.decode(te) );
		assertEquals( t, Base64.decode(Base64.encode(t)) );
		
		t = "Man is distinguished, not only by his reason, but by this singular passion from other animals, which is a lust of the mind, that by a perseverance of delight in the continued and indefatigable generation of knowledge, exceeds the short vehemence of any carnal pleasure.";
		assertEquals( t, Base64.decode(Base64.encode(t)) );
		
		t = "any carnal pleas";
		te = "YW55IGNhcm5hbCBwbGVhcw==";
		assertEquals( te, Base64.encode( t ) );
		assertEquals( t, Base64.decode(te) );
		assertEquals( t, Base64.decode(Base64.encode(t)) );
		
		t = "any carnal pleasu";
		te = "YW55IGNhcm5hbCBwbGVhc3U=";
		assertEquals( te, Base64.encode( t ) );
		assertEquals( t, Base64.decode(te) );
		assertEquals( t, Base64.decode(Base64.encode(t)) );
		
		t = "any carnal pleasur";
		te = "YW55IGNhcm5hbCBwbGVhc3Vy";
		assertEquals( te, Base64.encode( t ) );
		assertEquals( t, Base64.decode(te) );
		assertEquals( t, Base64.decode(Base64.encode(t)) );
		
		//---------------------------+
		
		/*
		t = "Polyfon zwitschernd aßen Mäxchens Vögel Rüben, Joghurt und Quark";
		te = "UG9seWZvbiB6d2l0c2NoZXJuZCBhw59lbiBNw6R4Y2hlbnMgVsO2Z2VsIFLDvGJlbiwgSm9naHVydCB1bmQgUXVhcms=";
		assertEquals( te, Base64.encode( t ) );
		assertEquals( t, Base64.decode(te) );
		assertEquals( t, Base64.decode(Base64.encode(t)) );
		*/
	}
	
}
