import utest.Assert.*;
import xmpp.XML;
import xmpp.xml.Schema;

class TestXMLSchema extends utest.Test {
	function test_parse() {
		var xml = XML.parse('
<xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema">
<xs:element name="note">
  <xs:complexType>
    <xs:sequence>
      <xs:element name="to" type="xs:string"/>
      <xs:element name="from" type="xs:string"/>
      <xs:element name="heading" type="xs:string"/>
      <xs:element name="body" type="xs:string"/>
    </xs:sequence>
  </xs:complexType>
</xs:element>
</xs:schema>');

		var schema = Schema.parse(xml);

		equals(null, schema.targetNamespace);
		equals(null, schema.xmlns);
		equals(null, schema.elementFormDefault);
		equals(null, schema.annotation);

		equals(1, schema.elements.length);
		equals(0, schema.simpleType.length);
		equals(0, schema.complexType.length);

		equals('note', schema.elements[0].name);
		notNull(schema.elements[0].complexType);
		notNull(schema.elements[0].complexType.sequence);
		equals(4, schema.elements[0].complexType.sequence.elements.length);
	}

	function test_parse_2() {
		var xml = XML.parse("<?xml version='1.0' encoding='UTF-8' ?>

<xs:schema
    xmlns:xs='http://www.w3.org/2001/XMLSchema'
    targetNamespace='http://jabber.org/protocol/disco#info'
    xmlns='http://jabber.org/protocol/disco#info'
    elementFormDefault='qualified'>

  <xs:annotation>
    <xs:documentation>
      The protocol documented by this schema is defined in
      XEP-0030: http://www.xmpp.org/extensions/xep-0030.html
    </xs:documentation>
  </xs:annotation>

  <xs:element name='query'>
    <xs:complexType>
      <xs:sequence minOccurs='0'>
        <xs:element ref='identity' maxOccurs='unbounded'/>
        <xs:element ref='feature' maxOccurs='unbounded'/>
      </xs:sequence>
      <xs:attribute name='node' type='xs:string' use='optional'/>
    </xs:complexType>
  </xs:element>

  <xs:element name='identity'>
    <xs:complexType>
      <xs:simpleContent>
        <xs:extension base='empty'>
          <xs:attribute name='category' type='nonEmptyString' use='required'/>
          <xs:attribute name='name' type='xs:string' use='optional'/>
          <xs:attribute name='type' type='nonEmptyString' use='required'/>
        </xs:extension>
      </xs:simpleContent>
    </xs:complexType>
  </xs:element>

  <xs:element name='feature'>
    <xs:complexType>
      <xs:simpleContent>
        <xs:extension base='empty'>
          <xs:attribute name='var' type='xs:string' use='required'/>
        </xs:extension>
      </xs:simpleContent>
    </xs:complexType>
  </xs:element>

  <xs:simpleType name='nonEmptyString'>
    <xs:restriction base='xs:string'>
      <xs:minLength value='1'/>
    </xs:restriction>
  </xs:simpleType>

  <xs:simpleType name='empty'>
    <xs:restriction base='xs:string'>
      <xs:enumeration value=''/>
    </xs:restriction>
  </xs:simpleType>

</xs:schema>
");

		var schema = Schema.parse(xml);

		equals('http://jabber.org/protocol/disco#info', schema.targetNamespace);
		equals('http://jabber.org/protocol/disco#info', schema.xmlns);
		equals('qualified', schema.elementFormDefault);

		// trace(  schema.annotation.content );

		equals(3, schema.elements.length);
		equals(2, schema.simpleType.length);

		equals('nonEmptyString', schema.simpleType[0].name);
		equals(1, schema.simpleType[0].restriction.length);
		equals('xs:string', schema.simpleType[0].restriction[0].base);
		equals(1, schema.simpleType[0].restriction[0].minLength.value);

		equals('xs:string', schema.simpleType[1].restriction[0].base);
		equals('', schema.simpleType[1].restriction[0].enumeration[0].value);

		// TODO ...
	}
}
