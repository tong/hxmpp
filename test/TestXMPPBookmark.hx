
class TestXMPPBookmark extends haxe.unit.TestCase {
	
	public function test() {
		
		// test parse
		
		var x = Xml.parse( "<storage xmlns='storage:bookmarks'>
          <conference name='The Play&apos;s the Thing' 
                      autojoin='true'
                      jid='theplay@conference.shakespeare.lit'>
            <nick>JC</nick>
          </conference>
        </storage>" ).firstElement();
        
        var b = xmpp.Bookmark.parse( x );
		assertEquals( 1, b.conferences.length );
        assertEquals( 0, b.urls.length );
		assertEquals( "The Play&apos;s the Thing", b.conferences[0].name );
		assertEquals( true, b.conferences[0].autojoin );
		assertEquals( "theplay@conference.shakespeare.lit", b.conferences[0].jid );
		assertEquals( "JC", b.conferences[0].nick );
		assertEquals( null, b.conferences[0].password );
		
		x = Xml.parse( "<storage xmlns='storage:bookmarks'>
      <url name='Complete Works of Shakespeare'
           url='http://the-tech.mit.edu/Shakespeare/'/>
    </storage>" ).firstElement();
		var b = xmpp.Bookmark.parse( x );
		assertEquals( 1, b.urls.length );
		assertEquals( 0, b.conferences.length );
		assertEquals( 'Complete Works of Shakespeare', b.urls[0].name );
		assertEquals( 'http://the-tech.mit.edu/Shakespeare/', b.urls[0].url );
		
		// test build
		
		x = b.toXml();
		assertEquals( 'storage', x.nodeName );
		assertEquals( 'storage:bookmarks', x.get('xmlns') );
		for( e in x.elements() ) {
			switch( e.nodeName ) {
			case 'url' :
				assertEquals( 'Complete Works of Shakespeare', e.get("name") );
				assertEquals( 'http://the-tech.mit.edu/Shakespeare/', e.get("url") );
			}
		}
	}
	
}
