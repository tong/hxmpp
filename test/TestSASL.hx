
import utest.Assert.*;
import xmpp.sasl.*;
import haxe.crypto.Base64;
import haxe.io.Bytes;

class TestSASL extends utest.Test {

	function test_plain_createAuthenticationText() {
		var mech = new xmpp.sasl.PlainMechanism();
        var z = String.fromCharCode( 0 );
		equals( z+'user'+z+'password', mech.createAuthenticationText( 'user', null, 'password' ) );
	}

    function test_plain_createChallengeResponse() {
		var mech = new xmpp.sasl.PlainMechanism();
		isNull( mech.createChallengeResponse( 'challenge' ) );
	}

	function test_anonymous_createAuthenticationText() {
		var mech = new xmpp.sasl.AnonymousMechanism();
		isNull( mech.createAuthenticationText( 'user', null, 'password' ) );
	}

    function test_anonymous_createChallengeResponse() {
		var mech = new xmpp.sasl.AnonymousMechanism();
		equals( 'any', mech.createChallengeResponse( 'challenge' ) );
	}

	@:access(xmpp.sasl.SCRAMSHA1Mechanism)
	function test_scramsha1_createAuthenticationText() {
		var mech = new SCRAMSHA1Mechanism();
		equals( 'n,,n=user,r=f63fa22e4accf72ab91b2b59af83c545', mech.createAuthenticationText( 'user', null, 'password' ) );
		equals( 'f63fa22e4accf72ab91b2b59af83c545', mech.cnonce );
		equals( 'n=user,r=f63fa22e4accf72ab91b2b59af83c545', mech.initialMessage );
	}

    function test_scramsha1_parseChallenge() {
		var mech = new SCRAMSHA1Mechanism();
		var c = SCRAMSHA1Mechanism.parseChallenge( 'r=0efd61802e130ed7ad814e8d6e014b7ec06c328d-29ca-4530-adc7-2644abad33df,s=5jZ9/GexSS3fDp4/PQTcSL01kZRURa3H,i=4096' );
		equals( '0efd61802e130ed7ad814e8d6e014b7ec06c328d-29ca-4530-adc7-2644abad33df', c.r );
		equals( '5jZ9/GexSS3fDp4/PQTcSL01kZRURa3H', c.s );
		equals( 4096, c.i );
	}

	@:access(xmpp.sasl.SCRAMSHA1Mechanism)
	function test_scramsha1_createChallengeResponse() {

		var mech = new SCRAMSHA1Mechanism();

		var password = 'test';

		var initialMessage = 'n=user,r=f63fa22e4accf72ab91b2b59af83c545';
		var serverMessage = SCRAMSHA1Mechanism.decodeBase64( 'cj1mNjNmYTIyZTRhY2NmNzJhYjkxYjJiNTlhZjgzYzU0NTQ3ZTg0N2Q2LWUzOTgtNDA5ZC05OGRlLWZhNjI1MmU2ZjI5ZixzPTVqWjkvR2V4U1MzZkRwNC9QUVRjU0wwMWtaUlVSYTNILGk9NDA5Ng==' ).toString();
		var ch = SCRAMSHA1Mechanism.parseChallenge( serverMessage );
		var snonce = ch.r;
		var clientFinalMessageBare = 'c=biws,r='+snonce;

		var salt = SCRAMSHA1Mechanism.decodeBase64( ch.s );
		var iterations = ch.i;

		var saltedPassword = SCRAMSHA1Mechanism.Hi( password, salt, iterations );
		//trace( SCRAMSHA1Mechanism.encodeBase64( saltedPassword ) );
		equals( '5reb7rJoBLb3oMtpz1kMpurP9yY=', SCRAMSHA1Mechanism.encodeBase64( saltedPassword ) );

		/*
		#if nodejs
		var clientKey = SCRAMSHA1Mechanism.HMAC( saltedPassword, js.node.Buffer.from( SCRAMSHA1Mechanism.CLIENT_KEY ) );
		equals( 'NLHNGsBTkyQdh6SGwtHvBG6/OM8=', SCRAMSHA1Mechanism.encodeBase64( clientKey ) );
		var serverKey = SCRAMSHA1Mechanism.HMAC( saltedPassword, js.node.Buffer.from( SCRAMSHA1Mechanism.SERVER_KEY ) );
		equals( 'ZqjUswSIo0h+5epn1kAtKWu2JHc=', SCRAMSHA1Mechanism.encodeBase64( serverKey ) );

		#else
		var clientKey = SCRAMSHA1Mechanism.HMAC( saltedPassword, Bytes.ofString( SCRAMSHA1Mechanism.CLIENT_KEY ) );
		equals( 'NLHNGsBTkyQdh6SGwtHvBG6/OM8=', SCRAMSHA1Mechanism.encodeBase64( clientKey ) );
		var serverKey = SCRAMSHA1Mechanism.HMAC( saltedPassword, Bytes.ofString( SCRAMSHA1Mechanism.SERVER_KEY ) );
		equals( 'ZqjUswSIo0h+5epn1kAtKWu2JHc=', SCRAMSHA1Mechanism.encodeBase64( serverKey ) );

		#end

		var storedKey = SCRAMSHA1Mechanism.H( clientKey );
		equals( 'Retzkjz3oXdobOx5KDxWV8VZDTc=', SCRAMSHA1Mechanism.encodeBase64( storedKey ) );

		var authMessage = initialMessage + ',' + serverMessage + ',' + clientFinalMessageBare;

		#if nodejs
		var clientSignature = SCRAMSHA1Mechanism.HMAC( storedKey, js.node.Buffer.from( authMessage ) );
		#else
		var clientSignature = SCRAMSHA1Mechanism.HMAC( storedKey, Bytes.ofString( authMessage ) );
		#end
		*/

		var clientKey = SCRAMSHA1Mechanism.HMAC( saltedPassword, Bytes.ofString( SCRAMSHA1Mechanism.CLIENT_KEY ) );
		equals( 'NLHNGsBTkyQdh6SGwtHvBG6/OM8=', SCRAMSHA1Mechanism.encodeBase64( clientKey ) );
		var serverKey = SCRAMSHA1Mechanism.HMAC( saltedPassword, Bytes.ofString( SCRAMSHA1Mechanism.SERVER_KEY ) );
		equals( 'ZqjUswSIo0h+5epn1kAtKWu2JHc=', SCRAMSHA1Mechanism.encodeBase64( serverKey ) );

		var storedKey = SCRAMSHA1Mechanism.H( clientKey );
		equals( 'Retzkjz3oXdobOx5KDxWV8VZDTc=', SCRAMSHA1Mechanism.encodeBase64( storedKey ) );

		var authMessage = initialMessage + ',' + serverMessage + ',' + clientFinalMessageBare;
		var clientSignature = SCRAMSHA1Mechanism.HMAC( storedKey, Bytes.ofString( authMessage ) );

		equals( 'yyjZ0d2iVQ4MSKL6GRcJS5SA1Wg=', SCRAMSHA1Mechanism.encodeBase64( clientSignature ) );

		/*
		var time = Sys.time();
		var key = Bytes.ofString('abcdefg123');
		var msg = Bytes.ofString('disktree');
		for( i in 0...10000 ) {
			var x = SCRAMSHA1Mechanism.HMAC( key, msg );
		}
		trace(Sys.time()-time);
		*/
	}

	/*
	@:access(sasl.SCRAMSHA1Mechanism)
	function test_scramsha1_crypto() {

		#if nodejs

		var buffer = js.node.Buffer.from('abc');
		var h = SCRAMSHA1Mechanism.encodeBase64( SCRAMSHA1Mechanism.H( buffer ) );
		equals( 'qZk+NkcGgWq6PiVxeFDCbJzQ2J0=', h );

		var buffer = js.node.Buffer.from('abc');
		var h = SCRAMSHA1Mechanism.HMAC( buffer, 'xyz' );
		equals( 'joSS/6IA6pfEcKUwpc1UswfMJ2E=', h.toString('base64') );

		#else

		var bytes = Bytes.ofString('abc');
		var h = SCRAMSHA1Mechanism.encodeBase64( SCRAMSHA1Mechanism.H( bytes ) );
		equals( 'qZk+NkcGgWq6PiVxeFDCbJzQ2J0=', h );

		//var buffer = Bytes.ofString('abc');
		//var h = SCRAMSHA1Mechanism.HMAC( buffer, 'xyz' );
		//equals( 'joSS/6IA6pfEcKUwpc1UswfMJ2E=', SCRAMSHA1Mechanism.encodeBase64(h) );

		#end
	}
	*/

	function test_md5_createAuthenticationText() {
		var mech = new MD5Mechanism();

		isNull( mech.createAuthenticationText('user','host','password') );
	}

    function test_md5_parseChallenge() {

		var challenge = 'cmVhbG09ImphYmJlci5kaXNrdHJlZS5uZXQiLG5vbmNlPSJZYUErQVMrSXdwbFRBUFgzZTU4NVVnVDZBMUJoL2dMVzhZWGpkWTY0IixjaGFyc2V0PXV0Zi04LGFsZ29yaXRobT1tZDUtc2Vzcw==';
		var r = MD5Mechanism.parseChallenge( challenge );

		equals( 'jabber.disktree.net', r.realm );
		equals( 'YaA+AS+IwplTAPX3e585UgT6A1Bh/gLW8YXjdY64', r.nonce );
	}

	@:access(xmpp.sasl.MD5Mechanism)
	function test_md5_computeResponse() {

		var host = 'jabber.disktree.net';
		var serverType = 'xmpp';
		var username = 'tong';
		var realm = 'jabber.disktree.net';
		var password = 'test';
		var nonce = 'YaA+AS+IwplTAPX3e585UgT6A1Bh/gLW8YXjdY64';
		var digest_uri = '$serverType/$host';
		var cnonce = 'YickYRKK8b';

		var X = '$username:$realm:$password';
		equals( 'tong:jabber.disktree.net:test', X );

		var Y = MD5Mechanism.H( Bytes.ofString( X ) );
		equals( '1cBjf9VjDQhvBL280dOySw==', Base64.encode(Y) );
		equals( 'd5c0637fd5630d086f04bdbcd1d3b24b', Y.toHex() );

		/*
		#if nodejs
		//var A1 = Y+':$nonce:$cnonce';
		var buf = new haxe.io.BytesBuffer();
		buf.add(Y);
		buf.addString(':$nonce:$cnonce');
		var A1 = buf.getBytes().toString();

		#else
		var A1 = Y+':$nonce:$cnonce';

		#end
		*/

		//TODO A1 is broken on all except cpp,neko

		var A1 = Y+':$nonce:$cnonce';
		var A2 = 'AUTHENTICATE:${digest_uri}';

		equals( 'd5c0637fd5630d086f04bdbcd1d3b24b3a5961412b41532b4977706c54415058336535383555675436413142682f674c573859586a645936343a5969636b59524b4b3862', Bytes.ofString(A1).toHex() );
		equals( '41555448454e5449434154453a786d70702f6a61626265722e6469736b747265652e6e6574', Bytes.ofString(A2).toHex() );

		equals( 'AUTHENTICATE:xmpp/jabber.disktree.net', A2 );

		var HA1 = MD5Mechanism.HH( A1 );
		var HA2 = MD5Mechanism.HH( A2 );

		equals( '28303d327229d6aeb8f0c63df3842dae', HA1 );
		equals( '8baa447cbf2e204e03287d8bce2fc84f', HA2 );

		var KD = '$HA1:$nonce:00000001:$cnonce:auth:$HA2';
		var Z = MD5Mechanism.HH( KD );

		equals( '28303d327229d6aeb8f0c63df3842dae:YaA+AS+IwplTAPX3e585UgT6A1Bh/gLW8YXjdY64:00000001:YickYRKK8b:auth:8baa447cbf2e204e03287d8bce2fc84f', KD );
		equals( 'bef82e55d5636c6c18c142b58e686f91', Z );

		/*
		//var byte = Bytes.alloc( Y.length + nonce.length + cnonce.length );
		var buf = new haxe.io.BytesBuffer();
		buf.add(Y);
		buf.add( Bytes.ofString(':'+nonce+':'+cnonce) );
		//buf.add( Bytes.ofString(':'+cnonce) );
		trace(buf.getBytes());
		var A1 = buf.getBytes();
		var A2 = 'AUTHENTICATE:${digest_uri}';

		//var A1 = Y+':$nonce:$cnonce';
		//var A2 = 'AUTHENTICATE:${digest_uri}';
		trace( A1 );
		trace( A2 );
		//equals( 'AUTHENTICATE:xmpp/jabber.disktree.net', Base64.encode(A1) );
		*/

		/*
		var HA1 = MD5Mechanism.HH( A1 );
		var HA2 = MD5Mechanism.HH( A2 );
		equals( '28303d327229d6aeb8f0c63df3842dae', HA1 );
		equals( '8baa447cbf2e204e03287d8bce2fc84f', HA2 );
		*/
	}

}

