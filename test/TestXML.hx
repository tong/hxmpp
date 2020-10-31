
import utest.Assert.*;
import xmpp.XML;

using xmpp.XML;

class TestXML extends utest.Test {

	static var XML_SALES = XML.parse(
			'<sales vendor="John">
				<item type="peas" price="4" quantity="6"/>
				<item type="carrot" price="3" quantity="10"/>
				<item type="chips" price="5" quantity="3"/>
			</sales> ');

	function test_type() {
		equals( Xml.XmlType.Element, XML.create( 'node' ).type );
		equals( Xml.XmlType.Element, XML_SALES.type );
	}
	
	function test_name() {
		equals( 'node', XML.create( 'node' ).name );
	}

	function test_parent() {
		notNull( XML_SALES.parent );
		isNull( XML.create( 'node' ).parent );
	}

	function test_attributes() {

        var xml = XML.create( 'node' ).set( 'id', 'abc' );

        isTrue( xml.has( 'id' ) );
        isFalse( xml.has( 'nope' ) );
        equals( 'abc', xml.get( 'id' ) );
        equals( 'abc', xml['id'] );

        xml['id'] = 'xyz';
        isTrue( xml.has( 'id' ) );
        isFalse( xml.has( 'nope' ) );
        equals( 'xyz', xml.get( 'id' ) );
        equals( 'xyz', xml['id'] );
    }

	function test_text() {

        var xml = XML.create( 'node', 'value' );

		equals( 'node', xml.name );
		equals( 'value', xml.text );

		xml.text = 'another';

		equals( 'another', xml.text );

		xml.text = null;

		isNull( xml.text );
    }

	/* function test_is() {

		var xml = XML.parse( '<node id="123">abc</node>' );
		isFalse( xml.is( 'https://disktree.net' ) );
		
		var xml = XML.parse( '<node xmlns="https://disktree.net" id="123">abc</node>' );
		isTrue( xml.is( 'https://disktree.net' ) );
	} */

	function test_count() {
		equals( 3, XML_SALES.elements.count() );
	} 

	function test_elements() {

		equals( 'peas', XML_SALES.elements.get(0).get('type') );
		equals( 'peas', XML_SALES.elements[0].get('type') );
		equals( 'carrot', XML_SALES.elements[1].get('type') );
		
		equals( 'chips', XML_SALES.elements.get(2).get('type') );

		equals( 3, XML_SALES.elements.named('item').length );
		equals( 3, XML_SALES.elements['item'].length );
		//equals( 3, XML_SALES.elements.count() );

		/* var others = XML.parse(
			'<others>
				<item type="aaa" price="111" quantity="111"/>
				<item type="bbb" price="222" quantity="222"/>
			</others> ');
		
		XML_SALES.elements = others.elements;

		equals( 2, XML_SALES.elements.named('item').length );
		equals( 'aaa', XML_SALES.elements.get(0).get('type') );
		equals( 'bbb', XML_SALES.elements.get(1).get('type') ); */
	} 

/* 	function test_element() {
		var xml = XML_SALES;

	}  */
	
	/*
	function test_unset() {
		var xml = XML.parse( '<node id="123">abc</node>' );
		isTrue( xml.has( 'id' ) );
		xml.unset( 'id' );
		isFalse( xml.has( 'id' ) );
	}
	*/

	function test_parse() {

		var xml = XML_SALES;

		equals( 'sales', xml.name );
		equals( 'John', xml.get('vendor') );

		equals( 3, xml.elements.count() );

		equals( 'peas', xml.elements[0]['type'] );
		equals( '4', xml.elements[0]['price'] );
		equals( '6', xml.elements[0]['quantity'] );

		equals( 'carrot', xml.elements[1]['type'] );
		equals( '3', xml.elements[1]['price'] );
		equals( '10', xml.elements[1]['quantity'] );

		equals( 'chips', xml.elements[2]['type'] );
		equals( '5', xml.elements[2]['price'] );
		equals( '3', xml.elements[2]['quantity'] );

		equals( 3, xml.elements['item'].length );
		equals( 0, xml.elements['nope'].length );
	}

	function test_insert() {

        var xml = XML.create( 'node' );

        xml.append( XML.create( 'a' ) );
        xml.append( XML.create( 'b' ) );
        xml.append( XML.create( 'c' ) );

        equals( 3, xml.elements.count() );
        equals( 'a', xml.elements[0].name );
        equals( 'b', xml.elements[1].name );
        equals( 'c', xml.elements[2].name );

        xml.insert( XML.create( 'x' ), 1 );

        equals( 4, xml.elements.count() );
        equals( 'a', xml.elements[0].name );
        equals( 'x', xml.elements[1].name );
        equals( 'b', xml.elements[2].name );
        equals( 'c', xml.elements[3].name );

        xml.insert( XML.create( 'y' ) );

        equals( 5, xml.elements.count() );
        equals( 'y', xml.elements[0].name );
        equals( 'a', xml.elements[1].name );
        equals( 'x', xml.elements[2].name );
        equals( 'b', xml.elements[3].name );
        equals( 'c', xml.elements[4].name );
    }
	
	function test_primitive_bool() {

		var xml : XML = '<node>true</node>';
		equals( 'true', xml.text );
		var b  : Bool = xml.text;
		isTrue( b );
		
		var xml : XML = '<node>false</node>';
		equals( 'false', xml.text );
		var b  : Bool = xml.text;
		isFalse( b );
		
		var xml : XML = '<node></node>';
		var b  : Bool = xml.text;

		var b : Bool = XML.parse('<node></node>').text;
		isFalse(b);
		
		var b : Bool = XML.parse('<node>0</node>').text;
		isFalse(b);
	
		var b : Bool = XML.parse('<node>false</node>').text;
		isFalse(b);
		
		var b : Bool = XML.parse('<node>null</node>').text;
		isFalse(b);
		
		var b : Bool = XML.parse('<node>1</node>').text;
		isTrue(b);
		
		var b : Bool = XML.parse('<node>true</node>').text;
		isTrue(b);
	}
	
	function test_primitive_int() {

		var xml : XML = '<node>23</node>';
		equals( '23', xml.text );

		var i  : Int = xml.text;
		equals( 23, i );
		equals( 23.0, i );
	}
	
	function test_primitive_float() {

		var xml : XML = '<node>1.988</node>';
		equals( '1.988', xml.text );

		var f  : Float = xml.text;
		equals( 1.988, f );
	}

		/*
	function test_find() {

        var xml = XML_SALES;

		//var item = xml.elements.doFind( e -> return e.get("type") == "chips" );
        //equals( 'chips', item.get("type") );

		xml.element["item"].find(element["type"] == "oranges")["quantity"] = "4";

		//var item = xml.elements.find( element["type"] == "chips" );
        equals( 'item', item.name );
        equals( '3', item['price'] );
		*/

    /**
     <sales vendor="John">
				<item type="peas" price="4" quantity="6"/>
				<item type="carrot" price="3" quantity="10"/>
				<item type="chips" price="5" quantity="3"/>
			</sales>
    }
     */
	

	/* 
	function test_getChild() {

		var xml = XML.parse(
			'<sales vendor="John">
				<item type="peas" price="4" quantity="6"/>
				<item type="carrot" price="3" quantity="10"/>
				<item type="chips" price="5" quantity="3"/>
			</sales>; ');
		//trace(xml.getChild(0));
		//trace(xml.getChild(1).get('type'));
		//trace(xml.getChild(2));
		//trace(xml);
	}
	*/

	function test_markup() {
		var x = XML.markup( <div id="myid">MyContent</div> );
		equals( 'div', x.name );
		equals( 'myid', x.get('id') );
		equals( 'MyContent', x.text );
	}
	
}
