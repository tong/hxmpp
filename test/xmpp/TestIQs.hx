package test.xmpp;



class TestIQs {
	
	static function main() {
		
		#if flash9
		flash.Lib.current.stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;
		flash.Lib.current.stage.align = flash.display.StageAlign.TOP_LEFT;
		#end
		
		var r = new haxe.unit.TestRunner();
		r.add( new TestVCard() );
		r.run();
	}
}



class TestVCard extends haxe.unit.TestCase   {
	
	
	static var VCARD =
'<vCard xmlns="vcard-temp">
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
    <DESC>More information about me is located on my personal website: http://www.saint-andre.com/</DESC>
  </vCard>';
	
	
	static var vc = xmpp.iq.VCard.parse( Xml.parse( VCARD ).firstElement() );
	
	
	public function testParsing() {
		
		assertEquals( "Peter Saint-Andre", vc.fullName );
		
		assertEquals( "Saint-Andre", vc.name.family );
		assertEquals( "Peter", vc.name.given );
		assertEquals( null, vc.name.middle );
		assertEquals( null, vc.name.prefix );
		assertEquals( null, vc.name.suffix );
		
		assertEquals( "stpeter", vc.nickName );
		
		assertEquals( null, vc.photo );
		
		assertEquals( "1966-08-06", vc.birthday );
		
		assertEquals( null, vc.addresses[0].home );
		assertEquals( null, vc.addresses[0].work );
		assertEquals( null, vc.addresses[0].postal );
		assertEquals( null, vc.addresses[0].parcel );
		assertEquals( null, vc.addresses[0].pref );
		assertEquals( null, vc.addresses[0].pobox );
		assertEquals( "Suite 600", vc.addresses[0].extadd );
		assertEquals( "1899 Wynkoop Street", vc.addresses[0].street );
		assertEquals( "Denver", vc.addresses[0].locality );
		assertEquals( "CO", vc.addresses[0].region );
		assertEquals( "80202", vc.addresses[0].pcode );
		assertEquals( "USA", vc.addresses[0].ctry );
		
		assertEquals( "Denver", vc.addresses[1].locality );
		assertEquals( "CO", vc.addresses[1].region );
		assertEquals( "80202", vc.addresses[0].pcode );
		assertEquals( "USA", vc.addresses[0].ctry );
		
		assertEquals( "303-308-3282", vc.tels[0].number );
		
		assertEquals( null, vc.tels[1].number );
		assertEquals( null, vc.tels[2].number );
		
		assertEquals( "stpeter@jabber.org", vc.email.userid );
		
		assertEquals( "stpeter@jabber.org", vc.jid );
		
		assertEquals( null, vc.tz );
		
		assertEquals( null, vc.geo );
		
		//..
		
		assertEquals( "More information about me is located on my personal website: http://www.saint-andre.com/", vc.desc );
	}
	
	
	public function testCreating() {
		
		var vcx = vc.toXml();
		
		trace( vcx );
		
		assertTrue( true );		
		/*
		var vc = new xmpp.iq.VCard();
		assertEquals( vc.toString(), '<vCard xmlns="vcard-temp"/>' );
		vc.fullName = "ronald mcdonald";
		assertEquals( vc.toString(), '<vCard xmlns="vcard-temp"><FN>ronald mcdonald</FN></vCard>' );
		*/
	}

}
