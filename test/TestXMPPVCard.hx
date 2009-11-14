
class TestXMPPVCard extends haxe.unit.TestCase   {
	
	/*
	public function testCreate() {
		var vc = new xmpp.VCard();
		vc.n = untyped { family : "Saint-Andre" };
		assertEquals( "Saint-Andre", vc.n.family );
	}
	*/
	
	public function testParse() {
		var x = Xml.parse('<vCard xmlns="vcard-temp">
    <FN>Peter Saint-Andre</FN>
    <N>
      <FAMILY>Saint-Andre</FAMILY>
      <GIVEN>Peter</GIVEN>
      <MIDDLE/>
    </N>
    <NICKNAME>stpeter</NICKNAME>
    <URL>http://www.xmpp.org/xsf/people/stpeter.shtml</URL>
    <BDAY>1966-08-06</BDAY>
    <ORG>
      <ORGNAME>XMPP Standards Foundation</ORGNAME>
      <ORGUNIT/>
    </ORG>
    <TITLE>Executive Director</TITLE>
    <ROLE>Patron Saint</ROLE>
    <TEL><WORK/><VOICE/><NUMBER>303-308-3282</NUMBER></TEL>
    <TEL><WORK/><FAX/><NUMBER/></TEL>
    <TEL><WORK/><MSG/><NUMBER/></TEL>
    <ADR>
      <WORK/>
      <EXTADD>Suite 600</EXTADD>
      <STREET>1899 Wynkoop Street</STREET>
      <LOCALITY>Denver</LOCALITY>
      <REGION>CO</REGION>
      <PCODE>80202</PCODE>
      <CTRY>USA</CTRY>
    </ADR>
    <TEL><HOME/><VOICE/><NUMBER>303-555-1212</NUMBER></TEL>
    <TEL><HOME/><FAX/><NUMBER/></TEL>
    <TEL><HOME/><MSG/><NUMBER/></TEL>
    <ADR>
      <HOME/>
      <EXTADD/>
      <STREET/>
      <LOCALITY>Denver</LOCALITY>
      <REGION>CO</REGION>
      <PCODE>80209</PCODE>
      <CTRY>USA</CTRY>
    </ADR>
    <EMAIL><INTERNET/><PREF/><USERID>stpeter@jabber.org</USERID></EMAIL>
    <JABBERID>stpeter@jabber.org</JABBERID>
    <DESC>Check out my blog at https://stpeter.im/</DESC>
  </vCard>' ).firstElement();
  		
  		var vcard = xmpp.VCard.parse( x );
  		assertEquals( "Peter Saint-Andre", vcard.fn );
  		assertEquals( "Saint-Andre", vcard.n.family );
  		assertEquals( "Peter", vcard.n.given );
  		assertEquals( "stpeter", vcard.nickname );
  		assertEquals( "http://www.xmpp.org/xsf/people/stpeter.shtml", vcard.url );
  		assertEquals( "1966-08-06", vcard.birthday );
  		assertEquals( "XMPP Standards Foundation", vcard.org.orgname );
  		assertEquals( "Executive Director", vcard.title );
  		assertEquals( "Patron Saint", vcard.role );
  		//assertEquals( "TEL", vcard.org.name );
  		//assertEquals( "XMPP Standards Foundation", vcard.org.name );
  		//trace(vcard.tels);
  		assertEquals( "Denver", vcard.addresses[0].locality );
  		assertEquals( "CO", vcard.addresses[0].region );
  		assertEquals( "80202", vcard.addresses[0].pcode );
  		assertEquals( "USA", vcard.addresses[0].ctry );
  		assertEquals( "Denver", vcard.addresses[1].locality );
  		assertEquals( "CO", vcard.addresses[1].region );
  		assertEquals( "80209", vcard.addresses[1].pcode );
  		assertEquals( "USA", vcard.addresses[1].ctry );
  	//	assertEquals( "stpeter@jabber.org", vcard.email.userid );
  		assertEquals( "Check out my blog at https://stpeter.im/", vcard.desc );
  		//assertEquals( "stpeter@jabber.org", vcard.jabberid);
		
		//TODO
		
		//trace( vcard );
	}
	
}
