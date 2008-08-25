package xmpp;

import util.XmlUtil;


/*
enum XMPPStreamType {
	stream;
	error;
	features;
}
*/


class XMPPStream {
	
	/** the entity has sent XML that cannot be processed; this error MAY be used instead of the more specific XML-related errors, such as bad-namespace-prefix, invalid-xml, restricted-xml, unsupported-encoding, and xml-not-well-formed, although the more specific errors are preferred. */
	public static inline var BAD_FORMAT = "bad-format";
	/** the entity has sent a namespace prefix that is unsupported, or has sent no namespace prefix on an element that requires such a prefix (see XML Namespace Names and Prefixes (XML Namespace Names and Prefixes)). */
	public static inline var BAD_NAMESPACE_PREFIX = "bad-namespace-prefix";
	/** the server is closing the active stream for this entity because a new stream has been initiated that conflicts with the existing stream. */
	public static inline var CONFLICT = "conflict";
 	/** the entity has not generated any traffic over the stream for some period of time (configurable according to a local service policy). */
	public static inline var CONNECTION_TIMEOUT = "connection-timeout";
	/** the value of the 'to' attribute provided by the initiating entity in the stream header corresponds to a hostname that is no longer hosted by the server. */
	public static inline var HOST_GONE = "host-gone";
	/** the value of the 'to' attribute provided by the initiating entity in the stream header does not correspond to a hostname that is hosted by the server. */
	public static inline var HOST_UNKNOWN = "host-unknown";
	/** a stanza sent between two servers lacks a 'to' or 'from' attribute (or the attribute has no value). */
	public static inline var IMPROPER_ADDRESSING = "improper-addressing";
	/** the server has experienced a misconfiguration or an otherwise-undefined internal error that prevents it from servicing the stream. */
	public static inline var INTERNAL_SERVER_ERROR = "internal-server-error";
	/** the JID or hostname provided in a 'from' address does not match an authorized JID or validated domain negotiated between servers via SASL or dialback, or between a client and a server via authentication and resource binding. */
	public static inline var INVALID_FORM = "invalid-from";
	/** the stream ID or dialback ID is invalid or does not match an ID previously provided. */
	public static inline var INVALID_ID = "invalid-id";
	/** the streams namespace name is something other than "http://etherx.jabber.org/streams" or the dialback namespace name is something other than "jabber:server:dialback" (see XML Namespace Names and Prefixes (XML Namespace Names and Prefixes)). */
	public static inline var INVALID_NAMESPACE = "invalid-namespace";
	/** the entity has sent invalid XML over the stream to a server that performs validation (see Validation (Validation)). */
	public static inline var INVALID_XML = "invalid-xml";
	/** the entity has attempted to send data before the stream has been authenticated, or otherwise is not authorized to perform an action related to stream negotiation; the receiving entity MUST NOT process the offending stanza before sending the stream error. */
	public static inline var NOT_AUTHORIZED = "not-authorized";
	/** the entity has violated some local service policy; the server MAY choose to specify the policy in the <text/> element or an application-specific condition element. */
	public static inline var POLICY_VIOLATION = "policy-violation";
	/** the server is unable to properly connect to a remote entity that is required for authentication or authorization. */
	public static inline var REMOTE_CONNECTION_FAILED = "remote-connection-failed";
	/** the server lacks the system resources necessary to service the stream. */
	public static inline var RESOURCE_CONSTRAINT = "resource-constraint";
	/** the entity has attempted to send restricted XML features such as a comment, processing instruction, DTD, entity reference, or unescaped character (see Restrictions (Restrictions)). */
	public static inline var RESTRICTED_XML = "restricted-xml";
	/** the server will not provide service to the initiating entity but is redirecting traffic to another host; the server SHOULD specify the alternate hostname or IP address (which MUST be a valid domain identifier) as the XML character data of the see-other-host element. */
	public static inline var SEE_OTHER_HOST = "see-other-host";
	/** the server is being shut down and all active streams are being closed. */
	public static inline var SYSTEM_SHUTDOWN = "system-shutdown";
	/** the error condition is not one of those defined by the other conditions in this list; this error condition SHOULD be used only in conjunction with an application-specific condition. */
	public static inline var UNDEFINED_CONDITION = "undefined-condition";
	/** the initiating entity has encoded the stream in an encoding that is not supported by the server (see Character Encoding (Character Encoding)). */
	public static inline var UNSUPPORTED_ENCODING = "unsupported-encoding";
	/** the initiating entity has sent a first-level child of the stream that is not supported by the server. */
	public static inline var UNSUPPORTED_STANZA_TYPE = "unsupported-stanza-type";
	/** the value of the 'version' attribute provided by the initiating entity in the stream header specifies a version of XMPP that is not supported by the server; the server MAY specify the version(s) it supports in the <text/> element. */
	public static inline var UNSUPPORTED_VERSION = "unsupported-version";
	/** the initiating entity has sent XML that is not well-formed as defined by [XML] (Bray, T., Paoli, J., Sperberg-McQueen, C., and E. Maler, “Extensible Markup Language (XML) 1.0 (2nd ed),” October 2000.). */
	public static inline var XML_NOT_WELL_FORMED = "xml-not-well-formed";
	
	
	public static inline var XMLNS_STREAM = "http://etherx.jabber.org/streams";
	public static inline var XMLNS_CLIENT = "jabber:client";
	public static inline var XMLNS_SERVER = "jabber:client";
	public static inline var XMLNS_COMPONENT = "jabber:component:accept";
	
	static inline var reg_stream = new EReg( "stream:stream", "" );
	static inline var reg_stream_features = new EReg( "stream:features", "" );
	static inline var reg_stream_error = new EReg( "stream:error", "" );
	//...
	
	
	/**
	*/
	public static function createOpenStream( xmlns : String, to : String,
											 ?version : String, ?lang : String, ?xmlHeader : Bool = true ) : String {
		var buf = new StringBuf();
		buf.add( '<stream:stream xmlns="' );
		buf.add( xmlns );
		buf.add( '" xmlns:stream="http://etherx.jabber.org/streams" to="' );
		buf.add( to );
		buf.add( '"' );
		if( version != null ) {
			buf.add( ' version="' );
			buf.add( version );
			buf.add( '"' );
		}
		if( lang != null ) {
			buf.add( ' xml:lang="' );
			buf.add( lang );
			buf.add( '"' );
		}
		buf.add( '>' );
		return if( xmlHeader ) XmlUtil.XML_HEADER.toString() + buf.toString();
		else buf.toString();
	}
	
	
	/**
	*/
	public static function isStream( src : String ) : Bool {
 		var r : EReg = ~/stream:([a-z])/;
		return r.match( src );
	}
	
	
	/**
	*/
	public static function getStreamType( s : String ) : String {
		return if( reg_stream.match( s ) ) "stream";
		  else if( reg_stream_features.match( s ) ) "features";
		  else if( reg_stream_error.match( s ) ) "error";
		//else if( new EReg( "?" ).match( src ) ) return "close";
		  else null;
	}
	
	
	/*
	public static function parseError( s : String ) : String {
		trace("PARSE ERRororrr .. " +s );
		var sei = s.indexOf( "</stream:error>" );
		s = s.substr( 0, sei + 15 );
		var error = StreamError.parse( Xml.parse( s ).firstElement() );
		trace("#########################################");
		return s;
	}
	*/
	
	
	public static function parseFeatures( src : Xml ) {
		/*	//TODO
		for( e in src.elements() ) {
		switch( e.nodeName ) {
			case "starttls" :
				case "mechanisms" :
				case "compression" :
				case "auth" :
				case "register" :
		}
		*/
	}

}
