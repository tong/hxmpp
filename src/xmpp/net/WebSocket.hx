package xmpp.net;

enum abstract ErrorCode(Int) from Int to Int {

	var normal_closure = 1000;
	var going_away = 1001;
	var protocol_error = 1002;
	var unsupported_data = 1003;
	var reserved = 1004;
	var no_status_rcvd = 1005;
	var abnormal_closure = 1006;
	var invalid_frame_payload_data = 1007;
	var policy_violation = 1008;
	var message_too_big = 1009;
	var mandatory_ext = 1010;
	var internal_server_error = 1011;
	var tls_handshake = 1015;

	public static function getMeaning( code : Int ) : String {
		return switch code {
		case 1000: 'Normal Closure';
		case 1001: 'Going Away';
		case 1002: 'Protocol error ';
		case 1003: 'Unsupported Data';
		case 1004: '---Reserved----';
		case 1005: 'No Status Rcvd';
		case 1006: 'Abnormal Closure';
		case 1007: 'Invalid frame payload data';
		case 1008: 'Policy Violation';
		case 1009: 'Message Too Big';
		case 1010: 'Mandatory Ext.';
		case 1011: 'Internal Server Serror';
		case 1015: 'TLS handshake ';
		case _: null;
		}
	}
}

/**
	[An Extensible Messaging and Presence Protocol (XMPP) Subprotocol for WebSocket](https://tools.ietf.org/html/rfc7395)
**/
class WebSocket {

	/**
		Subprotocol Identifier
	**/
	public static inline var PROTOCOL_IDENTIFIER = 'xmpp';

	/**
		Subprotocol Common Name
	**/
	public static inline var PROTOCOL_NAME = 'WebSocket Transport for the Extensible Messaging and Presence Protocol (XMPP)';

	/**
		URN sub-namespace for framing of Extensible Messaging and Presence Protocol (XMPP) streams

		https://tools.ietf.org/html/rfc7395#section-5.2
	**/
	public static inline var URI = 'urn:ietf:params:xml:ns:xmpp-framing';

    /*
    public static inline var MAGIC_STRING = "258EAFA5-E914-47DA-95CA-C5AB0DC85B11";

    public static function createKey( skey : String ) : String {
        return Base64.encode( Sha1.make( Bytes.ofString( '$skey$MAGIC_STRING' ) ) );
    }

    public static function readFrame( i : Input ) : Bytes {
        return switch i.readByte() {
        case 0x00:
            final buf = new BytesBuffer();
            var byte : Int;
            while( (byte = i.readByte()) != 0xFF ) buf.addByte( byte );
            buf.getBytes();
        case 0x81:
            var len = i.readByte();
            if( len & 0x80 != 0 ) { // mask
                len &= 0x7F;
                if( len == 126 ) {
                    final b2 = i.readByte();
                    final b3 = i.readByte();
                    len = (b2 << 8) + b3;
                } else if( len == 127 ) {
                    final b2 = i.readByte();
                    final b3 = i.readByte();
                    final b4 = i.readByte();
                    final b5 = i.readByte();
                    len = ( b2 << 24 ) + ( b3 << 16 ) + ( b4 << 8 ) + b5;
                }
                final mask = [
                    i.readByte(),
                    i.readByte(),
                    i.readByte(),
                    i.readByte() 
                ];
                final buf = new BytesBuffer();
                for( n in 0...len ) buf.addByte( i.readByte() ^ mask[n % 4] );
                buf.getBytes();
            } else null;
        case _: null;
        }
    }

    public static function writeFrame( o : Output, data : Bytes ) {
        o.writeByte( 0x81 );
        var len = if( data.length < 126 ) data.length else if( data.length < 65536 ) 126 else 127;
		o.writeByte( len | 0x00 );
		if( data.length >= 126 ) {
			if( data.length < 65536 ) {
				o.writeByte( (data.length >> 8) & 0xFF );
				o.writeByte( data.length & 0xFF );
			} else {
				o.writeByte( (data.length >> 24) & 0xFF );
				o.writeByte( (data.length >> 16) & 0xFF );
				o.writeByte( (data.length >> 8) & 0xFF );
				o.writeByte( data.length & 0xFF );
			}
		}
		o.write( data );
    }
    */

}
