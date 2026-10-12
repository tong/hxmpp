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

	function test_is_valid() {
		isTrue(Uuid.isValid(Uuid.make()));
		isTrue(Uuid.isValid('F47AC10B-58CC-4372-A567-0E02B2C3D479'));
		isFalse(Uuid.isValid('f47ac10b-58cc-1372-a567-0e02b2c3d479')); // version 1
		isFalse(Uuid.isValid('f47ac10b-58cc-4372-c567-0e02b2c3d479')); // variant
		isFalse(Uuid.isValid('f47ac10b58cc4372a5670e02b2c3d479'));
		isFalse(Uuid.isValid(''));
		isFalse(Uuid.isValid(null));
	}

	function test_random() {
		equals(16, xmpp.Random.bytes(16).length);
		equals(0, xmpp.Random.bytes(0).length);
		notEquals(xmpp.Random.bytes(16).toHex(), xmpp.Random.bytes(16).toHex());
	}
}
