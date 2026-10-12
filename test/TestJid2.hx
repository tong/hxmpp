import utest.Assert.*;



abstract Jid(String) {

    inline function new(s:String) this = s;

    @:from public static inline function fromString(s:String) {
    }
}

class TestJid extends utest.Test {

    function test_ereg() {
    }
}
