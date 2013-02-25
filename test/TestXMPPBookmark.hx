
class TestXMPPBookmark extends TestCase {
	
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
		eq( 1, b.conferences.length );
        eq( 0, b.urls.length );
		eq( "The Play&apos;s the Thing", b.conferences[0].name );
		eq( true, b.conferences[0].autojoin );
		eq( "theplay@conference.shakespeare.lit", b.conferences[0].jid );
		eq( "JC", b.conferences[0].nick );
		eq( null, b.conferences[0].password );
		
		x = Xml.parse( "<storage xmlns='storage:bookmarks'>
      <url name='Complete Works of Shakespeare'
           url='http://the-tech.mit.edu/Shakespeare/'/>
    </storage>" ).firstElement();
		var b = xmpp.Bookmark.parse( x );
		eq( 1, b.urls.length );
		eq( 0, b.conferences.length );
		eq( 'Complete Works of Shakespeare', b.urls[0].name );
		eq( 'http://the-tech.mit.edu/Shakespeare/', b.urls[0].url );
		
		// test build
		
		x = b.toXml();
		eq( 'storage', x.nodeName );
		eq( 'storage:bookmarks', x.get('xmlns') );
		for( e in x.elements() ) {
			switch( e.nodeName ) {
			case 'url' :
				eq( 'Complete Works of Shakespeare', e.get("name") );
				eq( 'http://the-tech.mit.edu/Shakespeare/', e.get("url") );
			}
		}
	}
	
}
