package xmpp;

import xmpp.IQ;

/**
	Action of a command request.
**/
enum abstract Action(String) from String to String {
	/** The command should be canceled. **/
	var cancel;

	/** The command should be completed (if possible). **/
	var complete;

	/**
		The command should be executed or continue to be executed (the default).
		For a continued command it is equivalent to the default action of the stage, see `AdHocCommand.getDefaultAction`.
	**/
	var execute;

	/** The command should progress to the next stage of execution. **/
	var next;

	/** The command should digress to the previous stage of execution. **/
	var prev;

	@:noCompletion public static function fromString(s:Null<String>):Null<Action>
		return switch s {
			case 'cancel': cancel;
			case 'complete': complete;
			case 'execute': execute;
			case 'next': next;
			case 'prev': prev;
			case _: null;
		}
}

/**
	Action allowed in a stage of execution (`cancel` is always allowed).
**/
enum abstract Actions(String) from String to String {
	/** Complete the command, typically the "finish" button of a wizard. **/
	var complete;

	/** Progress to the next stage, typically the "next" button of a wizard. **/
	var next;

	/** Revert to the previous stage, typically the "back" button of a wizard. **/
	var prev;
}

/**
	Status of a command execution.
**/
enum abstract CommandStatus(String) from String to String {
	/** The command has been canceled, the command session has ended. **/
	var canceled;

	/** The command has completed (successfully or not, see the notes), the command session has ended. **/
	var completed;

	/** The command is being executed. **/
	var executing;
}

/**
	Severity of a note.
**/
enum abstract NoteType(String) from String to String {
	/** Informational only (the default). **/
	var info;

	/** A warning, possibly due to illogical (yet valid) data. **/
	var warn;

	/** An error, the text indicates the reason. **/
	var error;
}

/**
	Human-readable note about the current status of a command.
**/
typedef Note = {
	var type:NoteType;
	var text:String;
}

/**
	A command response, as parsed with `AdHocCommand.parseCommand`.
**/
typedef Command = {
	/** The command **/
	var node:String;

	/** Session of the command execution, to be kept to continue the command **/
	var ?sessionid:String;

	var ?status:CommandStatus;

	/** Allowed actions of the stage, `null` if the response has no `<actions/>` element **/
	var ?actions:Array<Actions>;

	/** The action equivalent to `execute` of the `<actions/>` element, the default action of the stage **/
	var ?execute:Action;

	var notes:Array<Note>;

	/** Data form of the stage (to be filled out) or the result **/
	var ?form:DataForm;

	/** Other payload elements (e.g. out-of-band data), in order of precedence **/
	var payload:Array<XML>;

	var ?lang:String;
}

/**
	A stage of a command, as provided by a command handler.
**/
typedef CommandStage = {
	/** Data form to be filled out, or the result **/
	var ?form:DataForm;

	/** Allowed actions of an executing stage, defaults to `[complete]` **/
	var ?actions:Array<Actions>;

	/** The default action of an executing stage, must be one of `actions` **/
	var ?execute:Actions;

	/** Notes; a failed command completes with at least one `error` note **/
	var ?notes:Array<Note>;

	/** Other payload elements (e.g. out-of-band data) **/
	var ?payload:Array<XML>;
}

/**
	Result of a command handler.
**/
enum CommandResult {
	/** The command requires more interaction: the next stage. **/
	Executing(stage:CommandStage);

	/** The command has completed (the session ends). **/
	Completed(stage:CommandStage);

	/** Error response, e.g. `bad-request` with `AdHocCommand.BAD_PAYLOAD` (the session is kept). **/
	Failed(error:xmpp.Stanza.Error);
}

/**
	Request to a command handler.
**/
typedef CommandRequest = {
	/** The requesting entity **/
	var from:Null<String>;

	var node:String;
	var sessionid:String;

	/** `execute` for the first stage, otherwise the requested action (`execute` resolved to the default action of the stage) **/
	var action:Action;

	/** The submitted data form **/
	var ?form:DataForm;

	/** The `<command/>` element of the request **/
	var payload:XML;

	var ?lang:String;
}

/**
	A command provided by `AdHocCommand.handleRequests`.
**/
typedef CommandDefinition = {
	/** Unique identifier of the command **/
	var node:String;

	/** Label of the command **/
	var name:String;

	/** Returns `true` if the requester is allowed to list and execute the command, all requesters if `null` **/
	var ?allowed:(jid:Null<String>) -> Bool;

	/** Executes a stage of the command **/
	var execute:(request:CommandRequest, respond:CommandResult->Void) -> Void;

	/** Called if the requester canceled the command session **/
	var ?cancel:(sessionid:String) -> Void;
}

private typedef Session = {
	var node:String;
	var from:Null<String>;
	var stage:CommandStage;
}

/**
	Advertise and execute application-specific commands.

	Requester:

		AdHocCommand.requestCommandList(stream, jid, res -> trace(ServiceDiscovery.parseItems(res.payload)));
		stream.execute(jid, 'config', res -> {
			final cmd = AdHocCommand.parseCommand(res.payload);
			// fill out cmd.form, then
			stream.continueCommand(jid, cmd, cmd.form.createSubmit(values), res -> {});
		});

	Rules:
	- Each command is a service discovery item of the node `http://jabber.org/protocol/commands`.
	- Keep the `node` and `sessionid` of a command while executing it; the session ends with the
	  status `completed` or `canceled`. Cancel commands that are not completed (`cancelCommand`).
	- Submit forms with the type `submit` (`DataForm.createSubmit`).
	- `completed` does not mean success: a failed command has an `error` note.

	[XEP-0050: Ad-Hoc Commands](https://xmpp.org/extensions/xep-0050.html)
**/
@xep(50)
class AdHocCommand {
	public static inline var XMLNS = "http://jabber.org/protocol/commands";

	/** Service discovery node of the command list **/
	public static inline var NODE = XMLNS;

	/** Application error conditions (with `bad-request` or `not-allowed`) **/
	public static inline var MALFORMED_ACTION = "malformed-action";

	public static inline var BAD_ACTION = "bad-action";
	public static inline var BAD_LOCALE = "bad-locale";
	public static inline var BAD_PAYLOAD = "bad-payload";
	public static inline var BAD_SESSIONID = "bad-sessionid";
	public static inline var SESSION_EXPIRED = "session-expired";

	/**
		Request the commands provided by `jid` (the server if `null`), use `ServiceDiscovery.parseItems` to read
		the result: the `node` of each item identifies the command, the `name` is its label.
	**/
	public static inline function requestCommandList(stream:Stream, ?jid:String, handler:Response<XML>->Void):IQ
		return ServiceDiscovery.discoItems(stream, jid, NODE, handler);

	/**
		Execute the command `node` of the entity `jid` (the server if `null`).
		Use `parseCommand` to read the result.
	**/
	public static function execute(stream:Stream, jid:Null<String>, node:String, handler:Response<XML>->Void):IQ
		return stream.set(createRequest(node, null, Action.execute), jid ?? stream.domain, handler);

	/**
		Continue the `command` (the last response of the session) with `action` (default: the default action of the
		stage) and the submitted `form`. Use `parseCommand` to read the result.
	**/
	public static function continueCommand(stream:Stream, jid:Null<String>, command:Command, ?action:Action, ?form:DataForm,
			handler:Response<XML>->Void):IQ {
		final xml = createRequest(command.node, command.sessionid, action);
		if (form != null)
			xml.append(form);
		return stream.set(xml, jid ?? stream.domain, handler);
	}

	/**
		Cancel the `command` session.
	**/
	public static inline function cancelCommand(stream:Stream, jid:Null<String>, command:Command, handler:Response<XML>->Void):IQ
		return continueCommand(stream, jid, command, cancel, handler);

	/**
		Parses a `<command/>` element.
	**/
	@:noUsing
	public static function parseCommand(xml:XML):Command {
		final cmd:Command = {node: xml.get("node"), notes: [], payload: []};
		if (xml.has("sessionid"))
			cmd.sessionid = xml.get("sessionid");
		if (xml.has("status"))
			cmd.status = xml.get("status");
		if (xml.has("xml:lang"))
			cmd.lang = xml.get("xml:lang");
		for (e in xml.elements) {
			if (e.name == "actions" && (e.ns == null || e.ns == XMLNS)) {
				cmd.actions = [for (a in e.elements) if (a.name == complete || a.name == next || a.name == prev) (a.name : Actions)];
				if (e.has("execute"))
					cmd.execute = Action.fromString(e.get("execute"));
			} else if (e.name == "note" && (e.ns == null || e.ns == XMLNS)) {
				cmd.notes.push({type: e.get("type") ?? info, text: e.text ?? ""});
			} else if (e.name == "x" && e.is(DataForm.XMLNS) && cmd.form == null) {
				cmd.form = DataForm.fromXML(e);
			} else {
				cmd.payload.push(e);
			}
		}
		return cmd;
	}

	/**
		Returns the action that `execute` is equivalent to in the stage of `command`:
		the `execute` attribute of the actions, `next` if absent, `complete` if the command has no actions.
	**/
	@:noUsing
	public static function getDefaultAction(command:{?actions:Array<Actions>, ?execute:Action}):Action
		return (command.actions == null) ? complete : command.execute ?? next;

	/**
		Returns `true` if `action` is allowed in the stage of `command`.
	**/
	@:noUsing
	public static function isActionAllowed(command:{?actions:Array<Actions>, ?execute:Action}, action:Action):Bool {
		if (action == cancel)
			return true;
		if (action == Action.execute)
			action = getDefaultAction(command);
		if (command.actions == null)
			return action == complete;
		return command.actions.contains((action : String));
	}

	/**
		Provide `commands` to other entities.

		Commands are listed (and executed) only if `allowed` for the requester. Command sessions are managed:
		the `sessionid` is created for the first stage, the requested action is checked against the allowed actions
		of the stage and invalid requests are answered with the errors of the specification.
		The command list and the command nodes are answered for service discovery
		(the `commands` feature is advertised by `ServiceDiscovery.handleRequests`).

		Sessions end when the command completes or is canceled.
	**/
	@:noUsing
	public static function handleRequests(stream:Stream, commands:Array<CommandDefinition>) {
		final sessions = new Map<String, Session>();
		function find(node:Null<String>):Null<CommandDefinition> {
			for (c in commands)
				if (c.node == node)
					return c;
			return null;
		}
		function isAllowed(c:CommandDefinition, jid:Null<String>):Bool
			return c.allowed == null || c.allowed(jid);

		stream.features.set(XMLNS, (iq, respond) -> {
			final xml = iq.payload;
			if (iq.type != Set || xml.name != "command") {
				respond(Response.failure(modify, bad_request));
				return;
			}
			final c = find(xml.get("node"));
			if (c == null) {
				respond(Response.failure(cancel, item_not_found));
				return;
			}
			if (!isAllowed(c, iq.from)) {
				respond(Response.failure(cancel, forbidden));
				return;
			}
			var action = xml.has("action") ? Action.fromString(xml.get("action")) : Action.execute;
			if (action == null) {
				respond(commandError(modify, bad_request, MALFORMED_ACTION));
				return;
			}
			final lang = xml.get("xml:lang") ?? iq.lang;
			var sessionid = xml.get("sessionid");
			if (sessionid == null) {
				if (action != Action.execute) {
					respond(commandError(modify, bad_request, BAD_ACTION));
					return;
				}
				do
					sessionid = c.node + ":" + xmpp.Stream.makeRandomId()
				while (sessions.exists(sessionid));
			} else {
				final session = sessions.get(sessionid);
				if (session == null) {
					respond(commandError(cancel, not_allowed, SESSION_EXPIRED));
					return;
				}
				if (session.node != c.node || !sameJid(session.from, iq.from)) {
					respond(commandError(modify, bad_request, BAD_SESSIONID));
					return;
				}
				if (action == cancel) {
					sessions.remove(sessionid);
					if (c.cancel != null)
						c.cancel(sessionid);
					respond(Response.success(createCommand(c.node, sessionid, canceled, null, lang)));
					return;
				}
				if (!isActionAllowed(stageActions(session.stage), action)) {
					respond(commandError(modify, bad_request, BAD_ACTION));
					return;
				}
				if (action == Action.execute)
					action = getDefaultAction(stageActions(session.stage));
			}
			final x = xml.elements.first(e -> e.name == "x" && e.is(DataForm.XMLNS));
			final request:CommandRequest = {
				from: iq.from,
				node: c.node,
				sessionid: sessionid,
				action: action,
				payload: xml
			};
			if (x != null)
				request.form = DataForm.fromXML(x);
			if (lang != null)
				request.lang = lang;
			final sid = sessionid;
			c.execute(request, result -> switch result {
				case Executing(stage):
					sessions.set(sid, {node: c.node, from: iq.from, stage: stage});
					respond(Response.success(createCommand(c.node, sid, executing, stage, lang)));
				case Completed(stage):
					sessions.remove(sid);
					respond(Response.success(createCommand(c.node, sid, completed, stage, lang)));
				case Failed(e):
					respond(Response.fromError(e));
			});
		});

		// service discovery of the command list and the command nodes
		wrapDisco(stream, ServiceDiscovery.XMLNS_ITEMS, (iq, node) -> {
			if (node != NODE)
				return null;
			final jid = iq.to ?? stream.jid;
			final query = Payload.create(ServiceDiscovery.XMLNS_ITEMS).set("node", NODE);
			for (c in commands)
				if (isAllowed(c, iq.from))
					query.append(XML.create("item").set("jid", jid).set("node", c.node).set("name", c.name));
			return Response.success(query);
		});
		wrapDisco(stream, ServiceDiscovery.XMLNS_INFO, (iq, node) -> {
			if (node == NODE)
				return Response.success(ServiceDiscovery.createInfo({category: "automation", type: "command-list"}, [XMLNS]).set("node", NODE));
			final c = find(node);
			if (c == null)
				return null;
			if (!isAllowed(c, iq.from))
				return Response.failure(cancel, forbidden);
			return Response.success(ServiceDiscovery.createInfo({category: "automation", type: "command-node", name: c.name}, [XMLNS, DataForm.XMLNS])
				.set("node", c.node));
		});
	}

	/**
		Creates a command response `<command/>` element of the responder.
	**/
	@:noUsing
	public static function createCommand(node:String, sessionid:String, status:CommandStatus, ?stage:CommandStage, ?lang:String):XML {
		final xml = Payload.create(XMLNS, "command").set("node", node).set("sessionid", sessionid).set("status", status).set("xml:lang", lang);
		if (stage == null)
			return xml;
		if (status == executing) {
			final actions = stageActions(stage);
			final e = XML.create("actions").set("execute", actions.execute);
			for (a in actions.actions)
				e.append(XML.create(a));
			xml.append(e);
		}
		if (stage.notes != null)
			for (n in stage.notes)
				xml.append(XML.create("note", n.text).set("type", n.type));
		if (stage.form != null)
			xml.append(stage.form);
		if (stage.payload != null)
			for (e in stage.payload)
				xml.append(e);
		return xml;
	}

	static function createRequest(node:String, ?sessionid:String, ?action:Action):XML
		return Payload.create(XMLNS, "command").set("node", node).set("sessionid", sessionid).set("action", action);

	static function stageActions(stage:CommandStage):{actions:Array<Actions>, ?execute:Action} {
		final actions = stage.actions ?? [complete];
		final execute:Null<Action> = (stage.execute != null) ? (stage.execute : String) : (actions.length == 1) ? (actions[0] : String) : null;
		return {actions: actions, execute: execute};
	}

	static function commandError(type:xmpp.Stanza.ErrorType, condition:xmpp.Stanza.ErrorCondition, app:String):Response<XML>
		return Response.fromError(new xmpp.Stanza.Error(type, condition, null, {condition: app, xmlns: XMLNS}));

	static function sameJid(a:Null<String>, b:Null<String>):Bool
		return (a == null || b == null) ? a == b : Jid.normalize(a) == Jid.normalize(b);

	/**
		Answers service discovery requests for nodes with `handle` (if it returns a response),
		other requests with the previously registered handler.
	**/
	static function wrapDisco(stream:Stream, xmlns:String, handle:(iq:IQ, node:Null<String>) -> Null<Response<XML>>) {
		final previous = stream.features.get(xmlns);
		stream.features.set(xmlns, (iq, respond) -> {
			final node = iq.payload.get("node");
			final res = (iq.type == Get && node != null) ? handle(iq, node) : null;
			if (res != null)
				respond(res);
			else if (previous != null)
				previous(iq, respond);
			else
				respond(node == null ? null : Response.failure(cancel, item_not_found));
		});
	}
}
