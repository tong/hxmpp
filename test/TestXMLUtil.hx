
import xmpp.XMLUtil;

class TestXMLUtil extends TestCase {

	public function test() {
		
		var x = XMLUtil.createElement( "node", "value" );
		eq( "node", x.nodeName );
		eq( "value", x.firstChild().nodeValue );
		
		x = Xml.createElement( "node" );
		XMLUtil.addElement( x, "child", "value" );
		eq( "node", x.nodeName );
		eq( "child", x.firstElement().nodeName );
		eq( "value", x.firstElement().firstChild().nodeValue );
		
		x = Xml.createElement( "node" );
		var src = { child : "value" };
		XMLUtil.addField( x, src, "child", true );
		eq( "node", x.nodeName );
		eq( "child", x.firstElement().nodeName );
		eq( "value", x.firstElement().firstChild().nodeValue );
		
		x = Xml.createElement( "node" );
		var src = { child : "value", disk : "tree", fuck : "you" };
		XMLUtil.addFields( x, src );
		eq( 3, Lambda.count( x ) );
		eq( "node", x.nodeName );
		
		x = Xml.createElement( "node" );
		XMLUtil.addFields( x, src, ["disk","fuck"] );
		eq( 2, Lambda.count( x ) );
		
		x = Xml.createElement( "node" );
		eq( "http://disktree.net", XMLUtil.ns( x, "http://disktree.net" ) );
		eq( "http://disktree.net", x.get( "xmlns" ) );
		eq( "http://disktree.net", XMLUtil.ns(x) );
	}
	
}
