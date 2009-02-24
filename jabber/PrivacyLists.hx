package jabber;


/**
	Block communication with unknown or undesirable entities.
	
	<a href="http://xmpp.org/extensions/xep-0016.html">XEP-0016: Privacy Lists</a>
*/
class PrivacyLists {
	
	public dynamic function onLists( p : PrivacyLists, lists : xmpp.PrivacyLists  ) {}
	public dynamic function onInfo( p : PrivacyLists, l : xmpp.PrivacyList ) {}
	public dynamic function onUpdate( p : PrivacyLists, l : xmpp.PrivacyList ) {}
	public dynamic function onRemoved( p : PrivacyLists, l : xmpp.PrivacyList ) {}
	public dynamic function onActivate( p : PrivacyLists, l : String ) {}
	public dynamic function onDeactivate( p : PrivacyLists ) {}
	public dynamic function onDefaultChange( p : PrivacyLists, l : String ) {}
	public dynamic function onError( e : jabber.XMPPError ) {}
	
	public var stream(default,null) : jabber.Stream;
	
	
	public function new( stream : Stream ) {
		
		this.stream = stream;
		
		stream.features.add( xmpp.PrivacyLists.XMLNS );
		
		// TODO add collectors for server push
	}
	
	
	public function loadLists() {
		var me = this;
		sendRequest( xmpp.IQType.get, function(r) {
			var lists = xmpp.PrivacyLists.parse( r.ext.toXml() );
			me.onLists( me, lists );
		} );
	}
	
	public function load( name : String ) {
		var me = this;
		sendRequest( xmpp.IQType.get, function(r) {
			var lists = xmpp.PrivacyLists.parse( r.ext.toXml() );
			me.onInfo( me, lists.list[0] );
		}, null, null, new xmpp.PrivacyList( name ) );
	}
	
	public function activate( name : String ) {
		var me = this;
		sendRequest( xmpp.IQType.set, function(r) {
			var lists = xmpp.PrivacyLists.parse( r.ext.toXml() );
			me.onActivate( me, lists.active );
		}, name );
	}
	
	public function deactivate() {
		var me = this;
		sendRequest( xmpp.IQType.set, function(r) {
			me.onDeactivate( me );
		}, "" );
	}
	
	public function changeDefault( name : String ) {
		//TODO!!!!!!!!!
		var iq = new xmpp.IQ( xmpp.IQType.set );
		var ext = new xmpp.PrivacyLists();
		ext._default = name;
		iq.ext = ext;
		var me = this;
		stream.sendIQ( iq, function(r:xmpp.IQ) {
			switch( r.type ) {
				case result :
					me.onDefaultChange( me, name );
				case error :
					me.onError( new jabber.XMPPError( me, r ) );
				default :
			}
		} );
	}
	
	public inline function update( list : xmpp.PrivacyList ) {
		_update( list );
	}
	
	public inline function add( list : xmpp.PrivacyList ) {
		_update( list );
	}
	
	public function remove( name : String ) {
		var me = this;
		sendRequest( xmpp.IQType.set, function(r) {
			var lists = xmpp.PrivacyLists.parse( r.ext.toXml() );
			me.onRemoved( me, lists.list[0] );
		}, null, null, new xmpp.PrivacyList( name ) );
	}
	
	
	function _update( list : xmpp.PrivacyList ) {
		var me = this;
		sendRequest( xmpp.IQType.set, function(r) {
			var lists = xmpp.PrivacyLists.parse( r.ext.toXml() );
			me.onUpdate( me, lists.list[0] );
		}, null, null, list );
	}
	
	function sendRequest( iqType : xmpp.IQType, resultHandler : xmpp.IQ->Void,
						  ?active : String, ?_default : String, ?list : xmpp.PrivacyList ) {
		var iq = new xmpp.IQ( iqType );
		var xt = new xmpp.PrivacyLists();
		if( active != null ) xt.active = active;
		else if( _default != null ) xt._default = _default; 
		else if( list != null ) xt.list.push( list );
		iq.ext = xt;
		var me = this;
		stream.sendIQ( iq, function(r:xmpp.IQ) {
			switch( r.type ) {
				case result : resultHandler( r );
				case error : me.onError( new jabber.XMPPError( me, r ) );
				default : // #
			}
		} );
	}
	
	function handleListPush( iq : xmpp.IQ ) {
		//TODO
	}
	
}
