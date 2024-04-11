package xmpp;

import xmpp.Response;

/**
	Long-lived association or connection with a room.  

	[Affiliations](https://xmpp.org/extensions/xep-0045.html#affil)
**/
enum abstract Affiliation(String) from String to String {
	var none;
	var owner;
	var admin;
	var member;
	var outcast;
}

/**
	[Roles](https://xmpp.org/extensions/xep-0045.html#roles)
**/
enum abstract Role(String) from String to String {
	var none;
	var visitor;
	var participant;
	var moderator;
}

/**
	[Multi-User Chat Status Codes](https://xmpp.org/registrar/mucstatus.html)
**/
enum abstract StatusCode(Int) from Int to Int {
	var SEE_FULL_JID = 100;
	var AFFILIATION_CHANGED_IN_ABSENCE = 101;
	var SHOW_UNAVAILABLE_MEMBERS = 102;
	var HIDE_UNAVAILABLE_MEMBERS = 103;
	var CONFIGURATION_CHANGED = 104;
	var PRESENCE_REFERS_TO_OCCUPANT = 110;
	var LOGGING_ENABLED = 170;
	var LOGGING_DISABLED = 171;
	var NON_ANONYMOUS = 172;
	var SEMI_ANONYMOUS = 173;
	var FULL_ANONYMOUS = 174;
	var NEW_ROOM = 201;
	var ROOMNICK_MODIFIED = 210;
	var BANNED = 301;
	var NEW_ROOM_NICKNAME = 303;
	var KICKED = 307;
	var REMOVED_CAUSE_AFFILIATION_CHANGE = 321;
	var MEMBERS_ONLY_NOW = 322;
	var SYSTEM_SHUTDOWN = 332;
}

typedef Item = {
	var jid:String;
	var affiliation:Affiliation;
	var role:Role;
	var ?nick:String;
	// var actor : String;
	// var reason : String;
	// var continue_ : String;
}

/**
	Extension for multi-user text chat, whereby multiple users can exchange messages in the context of a room or channel.

	In addition to standard chatroom features such as room topics and invitations, the protocol defines a strong room control model, including the ability to kick and ban users, to name room moderators and administrators, to require membership or passwords in order to join the room, etc.

	[XEP-0045: Multi-User Chat](https://xmpp.org/extensions/xep-0045.html)  
	[XEP-0249: Direct MUC Invitations](https://xmpp.org/extensions/xep-0249.html)
**/
@xep(45)
class Muc {
	public static inline var XMLNS = "http://jabber.org/protocol/muc";

	public dynamic function onMessage(message:xmpp.Message) {}

	public dynamic function onPresence(presence:xmpp.Presence) {}

	public dynamic function onNick(nick:String) {}

	public dynamic function onSubject(subject:String) {}

	public final stream:Stream;

	public var host(default, null):String;
	public var room(default, null):String;
	public var nick(default, null):String;
	public var role(default, null):Role;
	public var affiliation(default, null):Affiliation;
	public var subject(default, null):String;

	// public var joined(default,null)	= false;
	public var jid(get, null):Jid;

	inline function get_jid()
		return new Jid(room, host, nick);

	public function new(stream:Stream, host:String, room:String) {
		this.stream = stream;
		this.host = host;
		this.room = room;
	}

	/**
		Enter groupchat.
	**/
	public function join(nick:String, ?password:String, handler:Response<XML>->Void) {
		final p = new Presence();
		p.id = Stream.makeRandomId();
		p.to = '$room@$host/$nick';
		p.properties.push(XML.create('x').set('xmlns', '$XMLNS'));
		stream.query(p, xml -> {
			final r = parseUserPresence(xml);
			if (r.statusCodes.contains(PRESENCE_REFERS_TO_OCCUPANT)) {
				final item = r.items[0];
				this.affiliation = item.affiliation;
				this.role = item.role;
				this.nick = item.nick;
				// onLeave();
				// handler(Result(null));
			}
			if (r.statusCodes.contains(PRESENCE_REFERS_TO_OCCUPANT)) {
				handler(Result(null));
			} else {
				trace("???");
			}
		});
	}

	/**
		Leave groupchat.
	**/
	public function leave(?message:String, ?handler:Void->Void) {
		final p = new Presence(null, message);
		p.type = unavailable;
		p.id = Stream.makeRandomId();
		p.to = jid;
		// p.properties.push(XML.create('x').set('xmlns','$XMLNS'));
		stream.query(p, xml -> {
			final r = parseUserPresence(xml);
			if (r.statusCodes.contains(PRESENCE_REFERS_TO_OCCUPANT)) {
				final item = r.items[0];
				this.affiliation = item.affiliation;
				this.role = item.role;
				this.nick = item.nick;
				// onLeave();
				if (handler != null)
					handler();
			}
		});
	}

	/**
		Invite user to this room.
	**/
	public function invite(jid:String, reason:String):Message {
		// TODO: https://xmpp.org/extensions/xep-0249.html
		final m = new xmpp.Message(jid);
		m.properties.push(XML.create("x")
			.set("xmlns", '$XMLNS#user')
			.append(XML.create("invite").set("to", '$room@$host').append(XML.create("reason", reason))));
		return stream.send(m);
	}

	/**
		Send a message to all occupants in the room.
	**/
	public function say(message:String) {
		var m = new Message(jid, message, null, groupchat);
		// m.id = Stream.makeRandomId();
		return stream.send(m);
	}

	/**
		Send a private message to a member of the room.
	**/
	public function sendPrivateMessage(nick:String, message:String) {
		var m = new Message('$room@$host/$nick', message, null, groupchat);
		m.properties.push(XML.create('x').set('xmlns', '$XMLNS#user'));
		// m.id = Stream.makeRandomId();
		return stream.send(m);
	}

	/**
		Change your nick name.
	**/
	public function changeNick(nick:String, handler:xmpp.Stanza.Error->Void) {
		final p = new Presence();
		p.id = Stream.makeRandomId();
		p.to = '$room@$host/$nick';
		stream.query(p, xml -> {
			final r = parseUserPresence(xml);
			if (r.statusCodes.contains(PRESENCE_REFERS_TO_OCCUPANT)) {
				handler(null);
			} else {
				trace("????");
			}
		});
	}

	/**
		Change the room subject.
	**/
	public function changeSubject(subject:String) {
		// todo id handling query
		stream.send(new xmpp.Message('$room@$host', null, subject));
	}

	public function handlePresence(presence:Presence) {
		final jid:Jid = presence.from;
		if (jid.getBare() != this.jid.getBare()) {
			trace('???????????????????????????');
			return;
		}
		// var nick = jid.resource;
		var r = parseUserPresence(presence);
		if (r.statusCodes.contains(PRESENCE_REFERS_TO_OCCUPANT)) {
			if (r.statusCodes.contains(NEW_ROOM_NICKNAME)) {
				onNick(r.items[0].nick);
			}
		}
	}

	public function handleMessage(message:Message) {
		final jid:Jid = message.from;
		if (jid.getBare() != this.jid.getBare()) {
			trace('???????????????????????????');
			return;
		}
		switch message.type {
			case groupchat:
				if (message.subject != null) {
					onSubject(this.subject = message.subject);
				}
				if (message.body != null) {
					onMessage(message);
				}
			case _:
				trace("?????");
		}
	}

	static function parseUserPresence(p:xmpp.Presence):{statusCodes:Array<StatusCode>, items:Array<Item>} {
		final r = {statusCodes: new Array<StatusCode>(), items: new Array<Item>()}
		for (e in p.properties) {
			// if(e != '$XMLNS#user')
			if (!e.is('$XMLNS#user'))
				continue;
			for (e in e.elements) {
				switch e.name {
					case "status":
						if (e.has("code")) {
							final code:Null<StatusCode> = try Std.parseInt(e["code"]) catch (e) null;
							if (code != null)
								r.statusCodes.push(code);
						}
					case "item":
						r.items.push({
							jid: e["jid"],
							affiliation: e["affiliation"],
							role: e["role"],
							nick: e["nick"],
						});
				}
			}
		}
		return r;
	}
}
