
class TestXMPPVCard extends haxe.unit.TestCase {
	
	public function testParse() {
		var x = Xml.parse('<vcard xmlns="urn:ietf:params:xml:ns:vcard-4.0">
<fn>
	<text>Peter Saint-Andre</text>
</fn>
<n>
	<surname>Saint-Andre</surname>
    <given>Peter</given>
    <middle></middle>
</n>
<nickname>
	<text>stpeter</text>
</nickname>
<nickname>
	<text>psa</text>
</nickname>
<photo>
    <uri>http://me.stpeter.im/images/stpeter_oscon.jpg</uri>
  </photo>
 <photo>
	<uri>http://me.stpeter.im/images/stpeter_hell.jpg</uri>
</photo>
<bday>
    <date>1966-08-06</date>
</bday>
<adr>
    <parameters>
      <type><text>work</text></type>
      <pref><integer>1</integer></pref>
    </parameters>
    <ext>Suite 600</ext>
    <street>1899 Wynkoop Street</street>
    <locality>Denver</locality>
    <region>CO</region>
    <code>80202</code>
    <country>USA</country>
</adr>
<adr>
    <parameters><type><text>home</text></type></parameters>
    <ext></ext>
    <street></street>
    <locality>Denver</locality>
    <region>CO</region>
    <code>80210</code>
    <country>USA</country>
</adr>
<tel>
    <parameters>
      <type><text>work</text><text>voice</text></type>
      <pref><integer>1</integer></pref>
    </parameters>
    <uri>tel:303-308-3282</uri>
</tel>
<tel>
    <parameters>
      <type><text>work</text><text>fax</text></type>
    </parameters>
    <uri>tel:303-308-3219</uri>
</tel>
<tel>
    <parameters>
      <type><text>home</text><text>voice</text></type>
    </parameters>
    <uri>tel:303-555-1212</uri>
</tel>
<email>
    <text>stpeter@jabber.org</text>
</email>
<email>
    <parameters>
      <type><text>work</text></type>
    </parameters>
    <text>psaintan@cisco.com</text>
</email>
<impp>
	<uri>xmpp:stpeter@jabber.org</uri>
 </impp>
 <tz>
	<text>America/Denver</text>
 </tz>
 <geo>
	<uri>geo:39.59,-105.01</uri>
 </geo>
 <title>
	<text>Executive Director</text>
 </title>
 <role>
	<text>Patron Saint</text>
 </role>
 <logo>
	<uri>data:image/jpeg;gAXQ3JlYXRlZCB3aXRoIFRoZSBHSU=</uri>
 </logo>
 <org>
	<text>XMPP Standards Foundation</text>
 </org>
 <url>
	<uri>https://stpeter.im/</uri>
 </url>
 <url>
	<uri>http://www.saint-andre.com/</uri>
 </url>
<key>
	<text>--- KEY BLOCK HERE ---</text>
</key>
 <note>
	<text>More information about me is located on my personal website: https://stpeter.im/</text>
 </note>
</vcard>').firstElement();

		var vc = xmpp.VCard.parse( x );
		
		assertEquals( "Peter Saint-Andre", vc.fn );
		
		assertEquals( "Saint-Andre", vc.n.surname );
		assertEquals( "Peter", vc.n.given );
		assertEquals( null, vc.n.middle );
		
		assertEquals( 2, vc.nickname.length );
		assertEquals( "stpeter", vc.nickname[0] );
		assertEquals( "psa", vc.nickname[1] );
	
		//TODO photo
		
		assertEquals( "1966-08-06", vc.bday );
		
		//.....
		
		assertEquals( 1, vc.title.length );
		assertEquals( "Executive Director", vc.title[0] );
		
		assertEquals( 1, vc.role.length );
		assertEquals( "Patron Saint", vc.role[0] );
		
		assertEquals( 2, vc.url.length );
		assertEquals( "https://stpeter.im/", vc.url[0] );
		assertEquals( "http://www.saint-andre.com/", vc.url[1] );
		
		assertEquals( 1, vc.note.length );
		assertEquals( "More information about me is located on my personal website: https://stpeter.im/", vc.note[0] );
		
		assertEquals( null, vc.prodid );
		
		assertEquals( "xmpp:stpeter@jabber.org", vc.impp );
		
		assertEquals( 1, vc.key.length );
		assertEquals( "--- KEY BLOCK HERE ---", vc.key[0] );
		
		assertEquals( 1, vc.org.length );
		assertEquals( "XMPP Standards Foundation", vc.org[0] );
		
		assertEquals( 1, vc.logo.length );
		assertEquals( "data:image/jpeg;gAXQ3JlYXRlZCB3aXRoIFRoZSBHSU=", vc.logo[0] );
		
		
		//trace( vc.toXml() );
	}
	
}
