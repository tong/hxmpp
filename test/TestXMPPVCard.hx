
class TestXMPPVCard extends TestCase {
	
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
		
		eq( "Peter Saint-Andre", vc.fn );
		
		eq( "Saint-Andre", vc.n.surname );
		eq( "Peter", vc.n.given );
		eq( null, vc.n.middle );
		
		eq( 2, vc.nickname.length );
		eq( "stpeter", vc.nickname[0] );
		eq( "psa", vc.nickname[1] );
	
		//TODO photo
		
		eq( "1966-08-06", vc.bday );
		
		//.....
		
		eq( 1, vc.title.length );
		eq( "Executive Director", vc.title[0] );
		
		eq( 1, vc.role.length );
		eq( "Patron Saint", vc.role[0] );
		
		eq( 2, vc.url.length );
		eq( "https://stpeter.im/", vc.url[0] );
		eq( "http://www.saint-andre.com/", vc.url[1] );
		
		eq( 1, vc.note.length );
		eq( "More information about me is located on my personal website: https://stpeter.im/", vc.note[0] );
		
		eq( null, vc.prodid );
		
		eq( "xmpp:stpeter@jabber.org", vc.impp );
		
		eq( 1, vc.key.length );
		eq( "--- KEY BLOCK HERE ---", vc.key[0] );
		
		eq( 1, vc.org.length );
		eq( "XMPP Standards Foundation", vc.org[0] );
		
		eq( 1, vc.logo.length );
		eq( "data:image/jpeg;gAXQ3JlYXRlZCB3aXRoIFRoZSBHSU=", vc.logo[0] );
		
		
		
		
		//trace( vc.toXml() );
	}
	
}
