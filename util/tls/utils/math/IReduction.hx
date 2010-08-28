package tls.utils.math;

extern interface IReduction {
	function convert(p0 : BigInteger) : BigInteger;
	function mulTo(p0 : BigInteger, p1 : BigInteger, p2 : BigInteger) : Void;
	function reduce(p0 : BigInteger) : Void;
	function revert(p0 : BigInteger) : BigInteger;
	function sqrTo(p0 : BigInteger, p1 : BigInteger) : Void;
}
