import utest.Assert.*;
import xmpp.Response;
import xmpp.XML;

using xmpp.Oob;

class TestVCard extends StreamTest {
	function test_vcard_parse() {
		// https://xmpp.org/extensions/xep-0054.html#sect-idm45723967564960
		final v = xmpp.VCard.parse(XML.fromString('<vCard xmlns="vcard-temp">
			<FN>Peter Saint-Andre</FN>
			<N><FAMILY>Saint-Andre</FAMILY><GIVEN>Peter</GIVEN><MIDDLE/></N>
			<NICKNAME>stpeter</NICKNAME>
			<URL>http://www.xmpp.org/xsf/people/stpeter.shtml</URL>
			<BDAY>1966-08-06</BDAY>
			<ORG><ORGNAME>XMPP Standards Foundation</ORGNAME><ORGUNIT/></ORG>
			<TITLE>Executive Director</TITLE>
			<ROLE>Patron Saint</ROLE>
			<TEL><WORK/><VOICE/><NUMBER>303-308-3282</NUMBER></TEL>
			<TEL><WORK/><FAX/><NUMBER/></TEL>
			<EMAIL><INTERNET/><PREF/><USERID>stpeter@jabber.org</USERID></EMAIL>
			<JABBERID>stpeter@jabber.org</JABBERID>
			<DESC>
				More information about me is located on my
				personal website: http://www.saint-andre.com/
			</DESC>
		</vCard>'));
		equals('Peter Saint-Andre', v.fn);
		equals('Saint-Andre', v.family);
		equals('Peter', v.given);
		isNull(v.middle);
		equals('stpeter', v.nickname);
		equals('1966-08-06', v.bday);
		equals('XMPP Standards Foundation', v.orgName);
		equals('Executive Director', v.title);
		equals(1, v.tel.length);
		equals('303-308-3282', v.tel[0].number);
		equals('WORK,VOICE', v.tel[0].types.join(','));
		equals('stpeter@jabber.org', v.email[0].userid);
		equals('INTERNET,PREF', v.email[0].types.join(','));
		equals('stpeter@jabber.org', v.jabberId);
		isTrue(StringTools.startsWith(v.desc, 'More information'));
	}

	function test_vcard_create() {
		final photo = haxe.io.Bytes.ofString('PNGDATA');
		final xml = xmpp.VCard.create({
			fn: 'Peter Saint-Andre',
			given: 'Peter',
			family: 'Saint-Andre',
			nickname: 'stpeter',
			photo: {type: 'image/png', data: photo},
			tel: [{number: '303-308-3282', types: ['work', 'voice']}],
			email: [{userid: 'stpeter@jabber.org'}]
		});
		equals('vCard', xml.name);
		equals(xmpp.VCard.XMLNS, xml.get('xmlns'));
		equals('Saint-Andre', xml.elements.named('N')[0].elements.named('FAMILY')[0].text);
		equals('WORK', xml.elements.named('TEL')[0].firstElement.name);
		final v = xmpp.VCard.parse(XML.fromString(xml.toString()));
		equals('Peter Saint-Andre', v.fn);
		equals('image/png', v.photo.type);
		equals('PNGDATA', v.photo.data.toString());
		equals('303-308-3282', v.tel[0].number);
		equals('stpeter@jabber.org', v.email[0].userid);

		// setVCard sends the vCard without nesting
		xmpp.VCard.setVCard(stream, xml, r -> {});
		final iq = lastSent();
		equals('set', iq.get('type'));
		equals('vCard', iq.firstElement.name);
		equals(0, iq.firstElement.elements.named('vCard').length);
		equals('FN', iq.firstElement.firstElement.name);
	}

	function test_vcard_empty() {
		isTrue(xmpp.VCard.isEmpty(Response.success()));
		isTrue(xmpp.VCard.isEmpty(Response.success(XML.fromString('<vCard xmlns="vcard-temp"/>'))));
		isTrue(xmpp.VCard.isEmpty(Response.failure(cancel, item_not_found)));
		isTrue(xmpp.VCard.isEmpty(Response.failure(cancel, service_unavailable)));
		isFalse(xmpp.VCard.isEmpty(Response.failure(auth, forbidden)));
		isFalse(xmpp.VCard.isEmpty(Response.success(XML.fromString('<vCard xmlns="vcard-temp"><FN>x</FN></vCard>'))));
	}
}
