
import xmpp.XMLUtil;

class TestXMLUtil extends haxe.unit.TestCase {

	public function test() {
		
		var x = XMLUtil.createElement( "node", "value" );
		assertEquals( "node", x.nodeName );
		assertEquals( "value", x.firstChild().nodeValue );
		
		x = Xml.createElement( "node" );
		XMLUtil.addElement( x, "child", "value" );
		assertEquals( "node", x.nodeName );
		assertEquals( "child", x.firstElement().nodeName );
		assertEquals( "value", x.firstElement().firstChild().nodeValue );
		
		x = Xml.createElement( "node" );
		var src = { child : "value" };
		XMLUtil.addField( x, src, "child", true );
		assertEquals( "node", x.nodeName );
		assertEquals( "child", x.firstElement().nodeName );
		assertEquals( "value", x.firstElement().firstChild().nodeValue );
		
		x = Xml.createElement( "node" );
		var src = { child : "value", disk : "tree", fuck : "you" };
		XMLUtil.addFields( x, src );
		assertEquals( 3, Lambda.count( x ) );
		assertEquals( "node", x.nodeName );
		
		x = Xml.createElement( "node" );
		XMLUtil.addFields( x, src, ["disk","fuck"] );
		assertEquals( 2, Lambda.count( x ) );
		
		x = Xml.createElement( "node" );
		assertEquals( "http://disktree.net", XMLUtil.ns( x, "http://disktree.net" ) );
		assertEquals( "http://disktree.net", x.get( "xmlns" ) );
		assertEquals( "http://disktree.net", XMLUtil.ns(x) );
	}
	
}
