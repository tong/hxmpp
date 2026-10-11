package xmpp;

import xmpp.IQ;

/**
	https://xmpp.org/extensions/xep-0060.html#affiliations
**/
enum abstract AffiliationState(String) from String to String {
	var none;
	var owner;
	var publisher;
	var member;
	var outcast;
}

/**
	https://xmpp.org/extensions/xep-0060.html#accessmodels
**/
enum abstract NodeAccessModel(String) from String to String {
	
	/**
		Any entity may subscribe to the node (i.e., without the necessity for subscription approval) and any entity may retrieve items from the node (i.e., without being subscribed).  
		This SHOULD be the default access model for generic pubsub services.
	**/
	var open;
	
	/**
		Any entity with a subscription of type "from" or "both" may subscribe to the node and retrieve items from the node.  
		This access model applies mainly to instant messaging systems.
	**/
	var presence;
	
	/**
		Any entity in the specified roster group(s) may subscribe to the node and retrieve items from the node.  
		This access model applies mainly to instant messaging systems.
	**/
	var roster;
	
	/**
		The node owner must approve all subscription requests, and only subscribers may retrieve items from the node.
	**/
	var authorize;
	
	/**
		An entity may subscribe or retrieve items only if on a whitelist managed by the node owner.  
		The node owner MUST automatically be on the whitelist.  
		In order to add entities to the whitelist, the node owner SHOULD use the protocol specified in the Manage Affiliated Entities section of this document, specifically by setting the affiliation to "member".
	**/
	var whitelist;
	
}

/**
**/
enum abstract SubscriptionState(String) from String to String {
	
	/**
		The node MUST NOT send event notifications or payloads to the Entity.

	**/
	var none;
	
	/**
		An entity has requested to subscribe to a node and the request has not yet been approved by a node owner.
		The node MUST NOT send event notifications or payloads to the entity while it is in this state.
	**/
	var pending;
	
	/**
		An entity has subscribed but its subscription options have not yet been configured.
		The node MAY send event notifications or payloads to the entity while it is in this state.
		The service MAY timeout unconfigured subscriptions.
	**/
	var unconfigured;
	
	/**
		An entity is subscribed to a node.
		The node MUST send all event notifications (and, if configured, payloads) to the entity while it is in this state
		(subject to subscriber configuration and content filtering).
	**/
	var subscribed;
}

/**
    Generic publish-subscribe functionality.

    [XEP-0060: Publish Subscribe](https://xmpp.org/extensions/xep-0060.html)
**/
@xep(60)
class PubSub {

	public static inline var XMLNS = "http://jabber.org/protocol/pubsub";

    /**
    **/
    public static inline function createNode(stream:Stream, jid:String, node:String, handler:Response<XML>->Void) : IQ
        return stream.set(payload(XML.create("create").set("node", node)), jid, handler);

    /**
    **/
    public static inline function requestNodeConfig(stream:Stream, jid:String, node:String, handler:Response<XML>->Void) : IQ
        return stream.get(payload(XML.create("configure").set("node", node), "#owner"), jid, handler);

    /**
    **/
    public static inline function requestDefaultNodeConfig(stream:Stream, jid:String, handler:Response<XML>->Void) : IQ
        return stream.get(payload(XML.create("default"), "#owner"), jid, handler);

    /**
    **/
    public static inline function configNode(stream:Stream, jid:String, node:String, data:DataForm, handler:Response<XML>->Void) : IQ
        return stream.set(payload(XML.create("configure").set("node", node).append(data), "#owner"), jid, handler);

    /**
    **/
    public static inline function deleteNode(stream:Stream, jid:String, node:String, handler:Response<XML>->Void) : IQ
        //return stream.set(payload().append(XML.create("delete").set("node", name)));
        return stream.set(payload(XML.create("delete").set("node", node)), jid, handler);

    /**
    **/
    public static inline function purgeItems(stream:Stream, jid:String, node:String, handler:Response<XML>->Void) : IQ
        //return stream.set(payload().append(XML.create("purge").set("node", name)));
        return stream.set(payload(XML.create("purge").set("node", node)), jid, handler);

    /**
    **/
    public static inline function getSubscriptions(stream:Stream, jid:String, node:String, handler:Response<XML>->Void) : IQ
        return stream.get(payload(XML.create("subscriptions").set("node", node)), jid, handler);

    /**
    **/
    public static inline function subscribe(stream:Stream, jid:String, node:String, handler:Response<XML>->Void) : IQ
        return stream.set(payload(XML.create("subscribe").set("node", node)), jid, handler);

    /**
    **/
    public static inline function unsubscribe(stream:Stream, jid:String, node:String, handler:Response<XML>->Void) : IQ
        return stream.set(payload(XML.create("unsubscribe").set("node", node)), jid, handler);

    /**
    **/
    public static inline function getAffiliations(stream:Stream, jid:String, node:String, handler:Response<XML>->Void) : IQ
        return stream.get(payload(XML.create("affiliations").set("node", node)), jid, handler);

    /**
        Send only modified affiliations (i.e., a "delta"), not the complete list.
    **/
    public static inline function setAffiliation(stream:Stream, jid:String, node:String, affiliation: { jid: String, affiliation:String }, handler:Response<XML>->Void) : IQ
        return stream.set(payload(XML.create("affiliations").set("node", node)
            .append(XML.create("affiliation")
                .set("jid", affiliation.jid)
                .set("affiliation", affiliation.affiliation))), jid, handler);

    /**
        Request node items.
    **/
    public static inline function loadItems(stream:Stream, jid:String, node:String, ?maxItems: Int, handler:Response<XML>->Void) : IQ {
        var items = XML.create("items").set("node", node);
        if(maxItems != null) items.set("max_items", Std.string(maxItems));
        return stream.get(payload(items), jid, handler);
    }

    /**
        Request a particular item.
    **/
    public static inline function loadItem(stream:Stream, jid:String, node:String, id: String, handler:Response<XML>->Void) : IQ
        return stream.get(payload(XML.create("items").set("node", node).append(XML.create("item").set("id", id))), jid, handler);

    /**
        Delete an item.
    **/
    public static inline function retractItem(stream:Stream, jid:String, node:String, id: String, handler:Response<XML>->Void) : IQ
        return stream.set(payload(XML.create("retract").set("node", node).append(XML.create("item").set("id", id))), jid, handler);

    /**
    **/
    public static inline function publish(stream: Stream, jid: String, node: String, item: XML, handler: Response<Payload>->Void): IQ
        return stream.set(Payload.create(XMLNS, "pubsub").append(XML.create("publish").set("node", node).append(item)), jid, handler);

    //static function pubsub() 

    static function payload(content:XML, ns="") : XML {
        return Payload.create('$XMLNS$ns', "pubsub").append(content);
    }
}
