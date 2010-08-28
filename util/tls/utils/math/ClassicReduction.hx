package tls.utils.math;

extern class ClassicReduction implements IReduction {
	function new(p0 : BigInteger) : Void;
	function convert(p0 : BigInteger) : BigInteger;
	function mulTo(p0 : BigInteger, p1 : BigInteger, p2 : BigInteger) : Void;
	function reduce(p0 : BigInteger) : Void;
	function revert(p0 : BigInteger) : BigInteger;
	function sqrTo(p0 : BigInteger, p1 : BigInteger) : Void;
}
