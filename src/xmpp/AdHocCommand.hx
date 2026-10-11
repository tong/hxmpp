package xmpp;

import xmpp.IQ;

enum abstract Action(String) from String to String {
	
	/**
        The command should be canceled.
	**/
	var cancel;

	/**
        The command should be completed (if possible).
    **/
	var complete;
	
	/** 
        The command should be executed or continue to be executed.  
        This is the default value.
    **/
	var execute;
	
	/**
        The command should progress to the next stage of execution.
	**/
	var next;
	
	/** 
        The command should be digress to the previous stage of execution.
    **/
	var prev;
}

/**
    The allowed actions for a particular stage of execution.
**/
enum abstract Actions(String) from String to String {
	
	/** */
	var complete;
	
	/** */
	var next;
	
	/** */
	var prev;
}

/**
    Describes the current status of this command.
**/
private enum abstract Status(String) from String to String {
	
	/**
		The command has been canceled, the command session has ended.
	**/
	var canceled;
	
	/**
		The command has completed, the command session has ended.
	**/
	var completed;

	/**
		The command is being executed.
	**/
	var executing;
}

/**
    Advertise and execute application-specific commands.

    [XEP-0050: Ad-Hoc Commands](https://xmpp.org/extensions/xep-0050.html)
**/
@xep(50)
class AdHocCommand {

	public static inline var XMLNS = "http://jabber.org/protocol/commands";

    /**
        Execute the command `node` of the entity `jid` (the server if `null`).
    **/
    public static function execute(stream: xmpp.Stream, jid: Null<String>, node: String, handler: Response<XML>->Void):IQ {
        return stream.set(Payload.create(XMLNS, "command")
                .set("node", node)
                .set("action", "execute"),
            jid ?? stream.domain,
            handler);
    }

    //public function cancel() {
}
