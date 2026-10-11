import utest.Assert.*;
import xmpp.Uuid;

class TestUuid extends utest.Test {
	function test_make() {
		final format = ~/^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/;
		final variants = new Map<String, Bool>();
		final uuids = new Map<String, Bool>();
		for (_ in 0...200) {
			final uuid = Uuid.make();
			isTrue(format.match(uuid), uuid);
			variants.set(uuid.charAt(19), true);
			uuids.set(uuid, true);
		}
		equals(200, Lambda.count(uuids));
		// all four variant characters occur
		for (c in ['8', '9', 'a', 'b'])
			isTrue(variants.exists(c), 'variant $c');
	}
}
