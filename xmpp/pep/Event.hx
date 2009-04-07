package xmpp.pep;

/**
	Abstract base for personal event classes.
	The implementing class HAS TO HAVE a static XMLNS field (required by the jabber.PersonalEventListener)!
*/
class Event {
	
	public var nodeName(default,null) : String;
	public var xmlns(default,null) : String;
	
	function new( nodeName : String, xmlns : String ) {
		this.nodeName = nodeName;
		this.xmlns = xmlns;
	}
	
	/**
		Returns the (subclass) namespace.
	*/
	public function getNode() : String {
		return xmlns;
	}
	
	/**
		Returns a empty XML node for disabling the personal event.
	*/
	public function empty() : Xml {
		var x = Xml.createElement( nodeName );
		x.set( "xmlns", xmlns );
		return x;
	}
	
	public function toXml() : Xml {
		return throw "Abstract error";
	}
	
	public inline function toString() : String {
		return toXml().toString();
	}
	
	/*
	public static function emptyXml() : Xml {
		return null;
	}
	*/
	
	/*
	public static function fromMessage( m : xmpp.Message ) : xmpp.pep.Event {
		////////
	}
	*/
	
}
