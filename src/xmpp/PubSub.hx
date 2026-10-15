package xmpp;

import xmpp.IQ;

/**
	https://xmpp.org/extensions/xep-0060.html#affiliations
**/
enum abstract AffiliationState(String) from String to String {
	var none;
	var owner;
	var publisher;
	var publish_only = "publish-only";
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
	Event notification received from a pubsub service.

	https://xmpp.org/extensions/xep-0060.html#publisher-publish-success-withpayload
**/
enum PubSubEvent {

	/**
		Items published (`<item/>` elements, with payload if delivered) and/or retracted (item ids) at `node`.
	**/
	Items(node:String, items:Array<XML>, retracted:Array<String>);

	/**
		The `node` was deleted, `redirect` is the uri of a replacement node if any.
	**/
	Delete(node:String, ?redirect:String);

	/**
		All items of the `node` were deleted.
	**/
	Purge(node:String);

	/**
		The configuration of the `node` changed, `form` contains the new configuration if delivered.
	**/
	Configuration(node:String, ?form:DataForm);

	/**
		The subscription state of `jid` to `node` changed.
	**/
	Subscription(node:String, jid:String, subscription:SubscriptionState);
}

/**
    Generic publish-subscribe functionality.

    [XEP-0060: Publish Subscribe](https://xmpp.org/extensions/xep-0060.html)
**/
@xep(60)
class PubSub {

	public static inline var XMLNS = "http://jabber.org/protocol/pubsub";
	public static inline var XMLNS_OWNER = "http://jabber.org/protocol/pubsub#owner";
	public static inline var XMLNS_EVENT = "http://jabber.org/protocol/pubsub#event";

    /**
        Create a `node` at the pubsub service `jid`.
    **/
    public static inline function createNode(stream:Stream, jid:String, node:String, handler:Response<XML>->Void) : IQ
        return stream.set(payload(XML.create("create").set("node", node)), jid, handler);

    /**
        Request the configuration form of a `node` (owner).
    **/
    public static inline function requestNodeConfig(stream:Stream, jid:String, node:String, handler:Response<XML>->Void) : IQ
        return stream.get(payload(XML.create("configure").set("node", node), "#owner"), jid, handler);

    /**
        Request the default node configuration of the service (owner).
    **/
    public static inline function requestDefaultNodeConfig(stream:Stream, jid:String, handler:Response<XML>->Void) : IQ
        return stream.get(payload(XML.create("default"), "#owner"), jid, handler);

    /**
        Submit the configuration of a `node` (owner); `data` should be a form of type `submit`.
    **/
    public static inline function configNode(stream:Stream, jid:String, node:String, data:DataForm, handler:Response<XML>->Void) : IQ
        return stream.set(payload(XML.create("configure").set("node", node).append(data), "#owner"), jid, handler);

    /**
        Delete a `node` (owner).
    **/
    public static inline function deleteNode(stream:Stream, jid:String, node:String, handler:Response<XML>->Void) : IQ
        return stream.set(payload(XML.create("delete").set("node", node), "#owner"), jid, handler);

    /**
        Delete all items of a `node` (owner).
    **/
    public static inline function purgeItems(stream:Stream, jid:String, node:String, handler:Response<XML>->Void) : IQ
        return stream.set(payload(XML.create("purge").set("node", node), "#owner"), jid, handler);

    /**
        Request the own subscriptions at the service, or to `node` only.
    **/
    public static inline function getSubscriptions(stream:Stream, jid:String, ?node:String, handler:Response<XML>->Void) : IQ
        return stream.get(payload(XML.create("subscriptions").set("node", node)), jid, handler);

    /**
        Subscribe to a `node`.

        `subscriber` defaults to the bare jid of the stream.
    **/
    public static function subscribe(stream:Stream, jid:String, node:String, ?subscriber:String, handler:Response<XML>->Void) : IQ
        return stream.set(payload(XML.create("subscribe").set("node", node).set("jid", subscriber ?? ownBareJid(stream))), jid, handler);

    /**
        Unsubscribe from a `node`.

        `subscriber` defaults to the bare jid of the stream, `subid` is required if subscribed multiple times.
    **/
    public static function unsubscribe(stream:Stream, jid:String, node:String, ?subscriber:String, ?subid:String, handler:Response<XML>->Void) : IQ
        return stream.set(payload(XML.create("unsubscribe").set("node", node).set("jid", subscriber ?? ownBareJid(stream)).set("subid", subid)), jid, handler);

    /**
        Request the own affiliations at the service, or with `node` only.
    **/
    public static inline function getAffiliations(stream:Stream, jid:String, ?node:String, handler:Response<XML>->Void) : IQ
        return stream.get(payload(XML.create("affiliations").set("node", node)), jid, handler);

    /**
        Change the affiliation of an entity with a `node` (owner).
        Send only modified affiliations (i.e., a "delta"), not the complete list.
    **/
    public static inline function setAffiliation(stream:Stream, jid:String, node:String, affiliation: { jid: String, affiliation:AffiliationState }, handler:Response<XML>->Void) : IQ
        return stream.set(payload(XML.create("affiliations").set("node", node)
            .append(XML.create("affiliation")
                .set("jid", affiliation.jid)
                .set("affiliation", affiliation.affiliation)), "#owner"), jid, handler);

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
        Publish an `item` (`<item/>` element with optional `id` attribute and the payload) to a `node`.

        `options` are publish options (e.g. `"pubsub#access_model" => "whitelist"`): preconditions the node must meet,
        it is created with them if it doesn't exist (`precondition-not-met` if it has another configuration).
    **/
    public static function publish(stream: Stream, jid: String, node: String, item: XML, ?options: Map<String, String>, handler: Response<XML>->Void): IQ {
        final xml = payload(XML.create("publish").set("node", node).append(item));
        if (options != null) {
            final fields:Array<DataForm.Field> = [{variable: "FORM_TYPE", type: hidden, values: ['$XMLNS#publish-options']}];
            for (k => v in options)
                fields.push({variable: k, values: [v]});
            xml.append(XML.create("publish-options").append(new DataForm(submit, null, null, fields)));
        }
        return stream.set(xml, jid, handler);
    }

    /**
        Returns the pubsub event notification contained in the given message, or `null`.
    **/
    public static function getEvent(message:Message):Null<PubSubEvent> {
        for (e in message.properties) {
            if (e.name != "event" || !e.is(XMLNS_EVENT))
                continue;
            final c = e.firstElement;
            if (c == null)
                return null;
            final node = c.get("node");
            return switch c.name {
                case "items":
                    Items(node,
                        [for (i in c.elements) if (i.name == "item") i],
                        [for (i in c.elements) if (i.name == "retract") i.get("id")]);
                case "delete":
                    final redirect = c.elements.named("redirect")[0];
                    Delete(node, (redirect == null) ? null : redirect.get("uri"));
                case "purge":
                    Purge(node);
                case "configuration":
                    final x = c.elements.first(x -> x.name == "x" && x.is(DataForm.XMLNS));
                    Configuration(node, (x == null) ? null : DataForm.fromXML(x));
                case "subscription":
                    Subscription(node, c.get("jid"), c.get("subscription"));
                default: null;
            }
        }
        return null;
    }

    static function ownBareJid(stream:Stream):Null<String>
        return (stream.jid == null) ? null : Jid.parseBare(stream.jid);

    static function payload(content:XML, ns="") : XML {
        return Payload.create('$XMLNS$ns', "pubsub").append(content);
    }
}
