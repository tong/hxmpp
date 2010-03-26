/*
 *	This file is part of HXMPP.
 *	Copyright (c)2009 http://www.disktree.net
 *	
 *	HXMPP is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU Lesser General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  HXMPP is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 *	See the GNU Lesser General Public License for more details.
 *
 *  You should have received a copy of the GNU Lesser General Public License
 *  along with HXMPP. If not, see <http://www.gnu.org/licenses/>.
*/
package jabber;

/**
	PubSub client implementation. <a href="http://xmpp.org/extensions/xep-0060.html">XEP-0060: Publish-Subscribe</a>
*/
class PubSub {
	
	public dynamic function onNodeCreate( node : String ) : Void;
	public dynamic function onNodeDelete( node : String ) : Void;
	public dynamic function onSubscribe( sub : xmpp.pubsub.Subscription ) : Void;
	public dynamic function onUnsubscribe( node : String ) : Void;
	public dynamic function onSubscriptions( subs : xmpp.pubsub.Subscriptions ) : Void;
	public dynamic function onPublish( node : String, item : xmpp.pubsub.Item ) : Void;
	public dynamic function onItems( node : String, items : xmpp.pubsub.Items ) : Void;
	public dynamic function onAffiliations( a : xmpp.pubsub.Affiliations ) : Void;
	public dynamic function onRetract( r : xmpp.pubsub.Retract ) : Void;
	public dynamic function onPurge( node : String ) : Void;
	//TODO public dynamic function onConfigForm( node : String, form : xmpp.DataForm ) : Void;
	public dynamic function onError( e : XMPPError ) : Void;
	
	public var stream(default,null) : Stream;
	/** Name of the pubsub service */
	public var service(default,null) : String;
	
	public function new( stream : Stream, service : String ) {
		this.stream = stream;
		this.service = service;
	}
	
	/**
		Create a pubsub node with the given name.
	*/
	public function createNode( name : String, ?config : xmpp.DataForm ) {
		//TODO config
		var iq = new xmpp.IQ( xmpp.IQType.set, null, service );
		var x = new xmpp.PubSub();
		x.create = name;
		x.configure = config;
		iq.x = x;
		var me = this;
		sendIQ( iq, function(r:xmpp.IQ) { me.onNodeCreate( name ); } );
	}
	
	/**
		Delete pubsub node with the given name.
	*/
	public function deleteNode( name : String ) {
		var iq = new xmpp.IQ( xmpp.IQType.set, null, service );
		var xt = new xmpp.PubSubOwner();
		xt.delete = name;
		iq.x = xt;
		var me = this;
		sendIQ( iq, function(r:xmpp.IQ) { me.onNodeDelete( name ); } );
	}
	
	/*
	public function configNode() {
		//TODO
	}
	
	public function submitConfig( node : String, form : xmpp.DataForm ) {
		//TODO
	}
	
	public function cancelConfig( node : String ) {
		var iq = new xmpp.IQ( xmpp.IQType.set, null, service );
		var xt = new xmpp.PubSubOwner();
		xt.configure = new xmpp.pubsub.Config( node, xmpp.DataForm( xmpp.dataform.FormType.cancel ) );
		iq.x = xt;
		stream.sendIQ( iq );
	}
	*/
	
	/**
		Subscribe to the given pubsub node.
	*/
	public function subscribe( node : String, ?jid : String ) {
		var iq = new xmpp.IQ( xmpp.IQType.set, null, service );
		var x = new xmpp.PubSub();
		x.subscribe = { node : node,
						jid : ( jid == null ) ? stream.jidstr : jid };
		iq.x = x;
		var me = this;
		sendIQ( iq, function(r:xmpp.IQ) {
			me.onSubscribe( xmpp.PubSub.parse( r.x.toXml() ).subscription );
		} );
	}
	
	/**
		Unsubscribe from the given pubsub node.
	*/
	public function unsubscribe( node : String, ?jid : String, ?subid : String ) {
		var iq = new xmpp.IQ( xmpp.IQType.set, null, service );
		var x = new xmpp.PubSub();
		x.unsubscribe = { jid : ( jid != null ) ? jid : stream.jidstr ,
						  node : node,
						  subid : subid };
		iq.x = x;
		var me = this;
		sendIQ( iq, function(r:xmpp.IQ) {
			me.onUnsubscribe( node );
		} );
	}
	
	/**
		Load list of current subscriptions.
	*/
	public function loadSubscriptions( ?node : String ) {
		var iq = new xmpp.IQ( null, null, service );
		var x = new xmpp.PubSub();
		x.subscriptions = new xmpp.pubsub.Subscriptions( node );
		iq.x = x;
		var me = this;
		sendIQ( iq, function(r:xmpp.IQ) {
			me.onSubscriptions( xmpp.PubSub.parse( r.x.toXml() ).subscriptions );
		} );
	}
	
	//TODO
	/*
	public function loadSubConfig() {
	<iq type='get'
    from='francisco@denmark.lit/barracks'
    to='pubsub.shakespeare.lit'
    id='options1'>
  <pubsub xmlns='http://jabber.org/protocol/pubsub'>
    <options node='princely_musings' jid='francisco@denmark.lit'/>
  </pubsub>
</iq>
	}
	*/
	
	/**
		Load list of affiliations for all nodes at the service.
	*/
	public function loadAffiliations() {
		var iq = new xmpp.IQ( null, null, service );
		var xt = new xmpp.PubSub();
		xt.affiliations = new xmpp.pubsub.Affiliations();
		iq.x = xt;
		var me = this;
		sendIQ( iq, function(r:xmpp.IQ) {
			me.onAffiliations( xmpp.PubSub.parse( r.x.toXml() ).affiliations );
		} );
	}
	
	//TODO why subid required?
	/**
		Load all items from the given node.
	*/
	public function loadItems( node : String, ?subid : String, ?maxItems : Int, ?ids : Array<String> ) {
		var iq = new xmpp.IQ( null, null, service );
		var x = new xmpp.PubSub();
		x.items = new xmpp.pubsub.Items( node, subid, maxItems );
		if( ids != null ) {
			for( id in ids )
				x.items.add( new xmpp.pubsub.Item( id ) );
		}
		iq.x = x;
		var me = this;
		sendIQ( iq, function(r:xmpp.IQ) {
			var items = xmpp.pubsub.Items.parse( r.x.toXml() );
			me.onItems( node, items );
		} );
	}
	
	//TODO ?? retractItems( node : String, ids : Array<String> )
	/**
		Publisher deletes an item once it has been published to a node that supports persistent items.
	*/
	public function retract( retract : xmpp.pubsub.Retract ) {
		var iq = new xmpp.IQ( xmpp.IQType.set, null, service );
		var x = new xmpp.PubSub();
		x.retract = retract;
		iq.x = x;
		var me = this;
		sendIQ( iq, function(r:xmpp.IQ) {
			me.onRetract( retract );
		} );
	}
	
	/**
		Remove all items from the persistent store, with the exception of the last published item, which MAY be cached.
		(This is a optional feature for a pubsub service).
	*/
	public function purge( node : String ) {
		var iq = new xmpp.IQ( xmpp.IQType.set, null, service );
		var x = new xmpp.PubSubOwner();
		x.purge = node;
		iq.x = x;
		var me = this;
		sendIQ( iq, function(r:xmpp.IQ) {
			me.onPurge( node );
		} );
	}

	/**
		Publish an item to a node.
	*/
	public function publish( node : String, item : xmpp.pubsub.Item, ?options : xmpp.DataForm ) {
		var iq = new xmpp.IQ( xmpp.IQType.set, null, service );
		var x = new xmpp.PubSub();
		var p = new xmpp.pubsub.Publish( node );
		p.add( item );
		x.publish = p;
		iq.x = x;
		// TODO check options ?
		if( options != null ) {
			var po = Xml.createElement( "publish-options" );
			po.addChild( options.toXml() );
			iq.properties.push( po );
		}
		var me = this;
		sendIQ( iq, function(r:xmpp.IQ) {
			//TODO
			var i : xmpp.pubsub.Item = null;
		//	try {
			i = xmpp.PubSub.parse( r.x.toXml() ).publish.first();
		//	} catch( e : Dynamic ) {
		//		me.onError( new jabber.XMPPError( me ) );
		//		return;	
		//	}
			me.onPublish( node, i );
		} );
	}
	
	function sendIQ( iq : xmpp.IQ, h : xmpp.IQ->Void ) {
		var me = this;
		stream.sendIQ( iq, function(r:xmpp.IQ) {
			switch( r.type ) {
			case result : h( r );
			case error : me.onError( new jabber.XMPPError( me, r ) );
			default : // #
			}
		} );
	}

}
