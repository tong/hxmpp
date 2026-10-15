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
	/** Any occupant is allowed to see the user's full JID (entering a room) **/
	var SEE_FULL_JID = 100;

	/** User's affiliation changed while not in the room (message) **/
	var AFFILIATION_CHANGED_IN_ABSENCE = 101;

	/** Room now shows unavailable members (configuration change) **/
	var SHOW_UNAVAILABLE_MEMBERS = 102;

	/** Room now does not show unavailable members (configuration change) **/
	var HIDE_UNAVAILABLE_MEMBERS = 103;

	/** A non-privacy-related room configuration change has occurred **/
	var CONFIGURATION_CHANGED = 104;

	/** Presence refers to the user itself (self-presence) **/
	var PRESENCE_REFERS_TO_OCCUPANT = 110;

	/** Room logging is now enabled **/
	var LOGGING_ENABLED = 170;

	/** Room logging is now disabled **/
	var LOGGING_DISABLED = 171;

	/** Room is now non-anonymous **/
	var NON_ANONYMOUS = 172;

	/** Room is now semi-anonymous **/
	var SEMI_ANONYMOUS = 173;

	/** Room is now fully-anonymous (deprecated, fully-anonymous rooms were removed from XEP-0045) **/
	var FULL_ANONYMOUS = 174;

	/** A new room has been created **/
	var NEW_ROOM = 201;

	/** Service has assigned or modified the occupant's roomnick **/
	var ROOMNICK_MODIFIED = 210;

	/** User has been banned from the room **/
	var BANNED = 301;

	/** New room nickname of an occupant (nickname change) **/
	var NEW_ROOM_NICKNAME = 303;

	/** User has been kicked from the room **/
	var KICKED = 307;

	/** User was removed because of an affiliation change **/
	var REMOVED_CAUSE_AFFILIATION_CHANGE = 321;

	/** User was removed because the room changed to members-only and the user is not a member **/
	var MEMBERS_ONLY_NOW = 322;

	/** User was removed because the MUC service is being shut down **/
	var SYSTEM_SHUTDOWN = 332;

	/** User was removed because of an error reply (technical removal) **/
	var REMOVED_CAUSE_ERROR = 333;
}

typedef Item = {
	var jid:String;
	var affiliation:Affiliation;
	var role:Role;
	var ?nick:String;

	/** Reason given for a change, e.g. a kick **/
	var ?reason:String;
}

/**
	Why the own occupant left the room.
**/
enum LeaveReason {
	/** Left the room (`leave`) **/
	Left;

	/** Kicked from the room **/
	Kicked;

	/** Banned from the room **/
	Banned;

	/** Removed because of an affiliation change **/
	AffiliationChanged;

	/** Removed because the room became members-only **/
	MembersOnly;

	/** Removed because the service is shutting down **/
	Shutdown;

	/** Removed because of an error reply (technical removal) **/
	ServiceError;

	/** The room was destroyed, `alternate` is the address of a replacement room, if any **/
	Destroyed(?alternate:String);
}

/**
	Invitation to a room, see `Muc.getInvitation`.
**/
typedef Invitation = {
	/** Address of the room **/
	var room:String;

	/** Address of the inviting entity, if known **/
	var ?from:String;

	var ?reason:String;
	var ?password:String;
}

/**
	Extension for multi-user text chat, whereby multiple users can exchange messages in the context of a room or channel.

	In addition to standard chatroom features such as room topics and invitations, the protocol defines a strong room control model, including the ability to kick and ban users, to name room moderators and administrators, to require membership or passwords in order to join the room, etc.

	Usage: pass all received presences and messages of the room to `handlePresence` and `handleMessage`:

		stream.onPresence = p -> if (muc.isFromRoom(p.from)) muc.handlePresence(p);
		stream.onMessage = m -> if (muc.isFromRoom(m.from)) muc.handleMessage(m);

	[XEP-0045: Multi-User Chat](https://xmpp.org/extensions/xep-0045.html)  
	[XEP-0249: Direct MUC Invitations](https://xmpp.org/extensions/xep-0249.html)
**/
@xep(45)
class Muc {
	public static inline var XMLNS = "http://jabber.org/protocol/muc";
	public static inline var XMLNS_USER = "http://jabber.org/protocol/muc#user";

	/** Namespace of direct invitations ([XEP-0249](https://xmpp.org/extensions/xep-0249.html)) **/
	public static inline var XMLNS_CONFERENCE = "jabber:x:conference";

	/** Groupchat message to all occupants **/
	public dynamic function onMessage(message:xmpp.Message) {}

	/** Private message from an occupant, or a message from the room itself **/
	public dynamic function onPrivateMessage(message:xmpp.Message) {}

	/** Error returned by the room **/
	public dynamic function onError(error:xmpp.Stanza.Error) {}

	/** Presence of an occupant (including the own) **/
	public dynamic function onPresence(presence:xmpp.Presence) {}

	/** The own nick was changed **/
	public dynamic function onNick(nick:String) {}

	/** The room subject was changed, an empty string if cleared **/
	public dynamic function onSubject(subject:String) {}

	/** The own occupant left the room, with the reason text if given **/
	public dynamic function onLeave(reason:LeaveReason, ?text:String) {}

	public final stream:Stream;

	public var host(default, null):String;
	public var room(default, null):String;
	public var nick(default, null):String;
	public var role(default, null):Role;
	public var affiliation(default, null):Affiliation;
	public var subject(default, null):String;

	/** Occupant jid of the own user (`room@host/nick`) **/
	public var jid(get, null):Jid;

	inline function get_jid()
		return new Jid(room, host, nick);

	public function new(stream:Stream, host:String, room:String) {
		this.stream = stream;
		this.host = host;
		this.room = room;
	}

	/**
		Returns `true` if `jid` is the room or one of its occupants.
	**/
	public function isFromRoom(jid:Null<String>):Bool
		return jid != null && Jid.normalize(Jid.parseBare(jid)) == Jid.normalize('$room@$host');

	/**
		Enter groupchat.

		Calls `handler` with `Error` if the room refused the entry (e.g. `conflict` if the nick is in use).
	**/
	public function join(nick:String, ?password:String, handler:Response<XML>->Void) {
		final x = XML.create('x').set('xmlns', XMLNS);
		if (password != null)
			x.append(XML.create('password', password));
		final p = new Presence();
		p.to = '$room@$host/$nick';
		p.properties.push(x);
		stream.query(p, xml -> {
			final presence:Presence = xml;
			if (presence.type == error) {
				handler(Error(presence.error));
				return;
			}
			handleSelfPresence(presence, nick);
			handler(Result(xml));
		});
	}

	/**
		Leave groupchat.
	**/
	public function leave(?message:String, ?handler:Void->Void) {
		final p = new Presence(null, message);
		p.type = unavailable;
		p.to = jid;
		stream.query(p, xml -> {
			if (handler != null)
				handler();
		});
	}

	/**
		Invite a user to this room through the room (mediated invitation).
	**/
	public function invite(jid:String, ?reason:String):Message {
		final invite = XML.create("invite").set("to", jid);
		if (reason != null)
			invite.append(XML.create("reason", reason));
		final m = new xmpp.Message('$room@$host', null, null, normal);
		m.properties.push(XML.create("x").set("xmlns", XMLNS_USER).append(invite));
		return stream.send(m);
	}

	/**
		Invite a user to this room with a message sent directly to the user ([XEP-0249](https://xmpp.org/extensions/xep-0249.html)).
	**/
	public function inviteDirect(jid:String, ?reason:String, ?password:String):Message {
		final m = new xmpp.Message(jid, null, null, normal);
		m.properties.push(XML.create("x")
			.set("xmlns", XMLNS_CONFERENCE)
			.set("jid", '$room@$host')
			.set("reason", reason)
			.set("password", password));
		return stream.send(m);
	}

	/**
		Returns the room invitation contained in `message` (mediated or direct), or `null`.
	**/
	public static function getInvitation(message:xmpp.Message):Null<Invitation> {
		for (e in message.properties) {
			if (e.name == "x" && e.is(XMLNS_USER)) {
				final invite = e.elements.findElement("invite");
				if (invite == null || message.from == null)
					continue;
				final reason = invite.elements.findElement("reason");
				final password = e.elements.findElement("password");
				return {
					room: Jid.parseBare(message.from),
					from: invite.get("from"),
					reason: (reason == null) ? null : StringTools.trim(reason.text ?? ""),
					password: (password == null) ? null : password.text
				};
			}
		}
		for (e in message.properties)
			if (e.name == "x" && e.is(XMLNS_CONFERENCE) && e.has("jid"))
				return {
					room: e.get("jid"),
					from: message.from,
					reason: e.get("reason"),
					password: e.get("password")
				};
		return null;
	}

	/**
		Send a message to all occupants in the room.
	**/
	public function say(message:String) {
		return stream.send(new Message('$room@$host', message, null, groupchat));
	}

	/**
		Send a private message to a member of the room.
	**/
	public function sendPrivateMessage(nick:String, message:String) {
		final m = new Message('$room@$host/$nick', message, null, chat);
		m.properties.push(XML.create('x').set('xmlns', XMLNS_USER));
		return stream.send(m);
	}

	/**
		Change your nick name.

		Calls `handler` with the error if the room refused the change, `null` on success.
	**/
	public function changeNick(nick:String, handler:Null<xmpp.Stanza.Error>->Void) {
		final p = new Presence();
		p.to = '$room@$host/$nick';
		stream.query(p, xml -> {
			final presence:Presence = xml;
			if (presence.type == error) {
				handler(presence.error);
				return;
			}
			handleSelfPresence(presence, nick);
			handler(null);
		});
	}

	/**
		Change the room subject.
	**/
	public function changeSubject(subject:String) {
		stream.send(new xmpp.Message('$room@$host', null, subject, groupchat));
	}

	/**
		Updates nick, role and affiliation from the own occupant presence.
	**/
	function handleSelfPresence(presence:Presence, requestedNick:String) {
		// The room may assign a different nick, the actual one is the resource of the occupant jid
		this.nick = (presence.from != null ? Jid.parseResource(presence.from) : null) ?? requestedNick;
		final r = parseUserPresence(presence);
		if (r.items.length > 0) {
			this.affiliation = r.items[0].affiliation;
			this.role = r.items[0].role;
		}
	}

	/**
		Handle a presence received from the room.
	**/
	public function handlePresence(presence:Presence) {
		if (!isFromRoom(presence.from))
			return;
		final r = parseUserPresence(presence);
		final self = r.statusCodes.contains(PRESENCE_REFERS_TO_OCCUPANT) || (nick != null && Jid.parseResource(presence.from) == nick);
		if (self) {
			if (presence.type == unavailable) {
				if (r.statusCodes.contains(NEW_ROOM_NICKNAME)) {
					final newNick = (r.items.length > 0) ? r.items[0].nick : null;
					if (newNick != null) {
						this.nick = newNick;
						onNick(newNick);
					}
				} else {
					final reason = leaveReason(r);
					role = none;
					onPresence(presence);
					onLeave(reason, (r.destroyReason != null) ? r.destroyReason : (r.items.length > 0) ? r.items[0].reason : null);
					return;
				}
			} else if (presence.type == null) {
				handleSelfPresence(presence, nick);
			}
		}
		onPresence(presence);
	}

	/**
		Handle a message received from the room.
	**/
	public function handleMessage(message:Message) {
		if (!isFromRoom(message.from))
			return;
		switch message.type {
			case groupchat:
				if (message.subject != null)
					onSubject(this.subject = message.subject);
				if (message.body != null)
					onMessage(message);
			case error:
				if (message.error != null)
					onError(message.error);
			case _:
				onPrivateMessage(message);
		}
	}

	static function leaveReason(r:{statusCodes:Array<StatusCode>, destroyed:Bool, destroyAlternate:Null<String>}):LeaveReason {
		final c = r.statusCodes;
		return if (r.destroyed) Destroyed(r.destroyAlternate) else if (c.contains(BANNED)) Banned else if (c.contains(REMOVED_CAUSE_ERROR)) ServiceError else
			if (c.contains(KICKED)) Kicked else if (c.contains(REMOVED_CAUSE_AFFILIATION_CHANGE)) AffiliationChanged else if (c.contains(MEMBERS_ONLY_NOW))
				MembersOnly else if (c.contains(SYSTEM_SHUTDOWN)) Shutdown else Left;
	}

	static function parseUserPresence(p:xmpp.Presence) {
		final r = {
			statusCodes: new Array<StatusCode>(),
			items: new Array<Item>(),
			destroyed: false,
			destroyAlternate: (null : Null<String>),
			destroyReason: (null : Null<String>)
		};
		for (e in p.properties) {
			if (!e.is(XMLNS_USER))
				continue;
			for (e in e.elements) {
				switch e.name {
					case "status":
						final code:Null<Int> = Std.parseInt(e["code"]);
						if (code != null)
							r.statusCodes.push(code);
					case "item":
						final reason = e.elements.findElement("reason");
						r.items.push({
							jid: e["jid"],
							affiliation: e["affiliation"],
							role: e["role"],
							nick: e["nick"],
							reason: (reason == null) ? null : reason.text
						});
					case "destroy":
						r.destroyed = true;
						r.destroyAlternate = e["jid"];
						final reason = e.elements.findElement("reason");
						r.destroyReason = (reason == null) ? null : reason.text;
				}
			}
		}
		return r;
	}
}
