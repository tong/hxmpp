
import haxe.Timer;
import haxe.Template;
#if sys
import sys.FileSystem;
import sys.io.File;
#elseif nodejs
import js.Node;
#elseif js
import js.Browser.document;
#end
#if macro
import haxe.macro.Context;
#end

private typedef Platform = {
	var name : String;
	var color : String;
}

private typedef HTMLContext = { > Platform,
	var time : Int;
	var result : String;
	var js : Bool;
}

class Run {

	static inline var HTML_TPL = 'test.tpl.html';

	#if flash
	static var tf : flash.text.TextField;
	#end
	
	static var r : haxe.unit.TestRunner;
	static var result : String;
	static var platform : Platform =
		#if cpp
		{ name : "cpp", color : "#ffffff" }
		#elseif cs
		{ name : "cs", color : "#2E96D5" }
		#elseif flash
		{ name : "flash", color : "#CC181D" }
		#elseif java
		{ name : "java", color : "#F00000" }
		#elseif neko
		{ name : "neko", color : "#FFA157" }
		#elseif nodejs
		{ name : "nodejs", color : "#8BC84B" }
		#elseif js
		{ name : "js", color : "#ff5000" }
		#elseif php
		{ name : "php", color : "#9999CC" }
		#end;
		
	static inline function addResult( v : Dynamic ) {
		//trace(v);
		result += StringTools.htmlEscape( Std.string(v) ).split( "\n" ).join( "<br/>" );
	}

	static function addTests_core() {
		r.add( new TestBase64() );
		r.add( new TestJID() );
		r.add( new TestMD5() );
		r.add( new TestMUCUtil() );
		r.add( new TestSHA1() );
	}

	static function addTests_util() {
		r.add( new TestXMLUtil() );
	}

	static function addTests_xmpp() {
		r.add( new TestXMPPAuth() );
		r.add( new TestXMPPBind() );
		r.add( new TestXMPPBlockList() );
		r.add( new TestXMPPBOB() );
		r.add( new TestXMPPBookmark() );
		r.add( new TestXMPPChatState() );
		r.add( new TestXMPPCompression() );
		r.add( new TestXMPPDataForm() );
		r.add( new TestXMPPDateTime() );
		r.add( new TestXMPPDelayedDelivery() );
		r.add( new TestXMPPDisco() );
		r.add( new TestXMPPEntityCapabilities() );
		r.add( new TestXMPPEntityTime() );
		r.add( new TestXMPPError() );
		r.add( new TestXMPPFile() );
		r.add( new TestXMPPIBByteStream() );
		r.add( new TestXMPPIQPacket() );
		r.add( new TestXMPPJingle() );
		r.add( new TestXMPPLastActivity() );
		r.add( new TestXMPPMessagePacket() );
		r.add( new TestXMPPMUC() );
		r.add( new TestXMPPPacketFilters() );
		r.add( new TestXMPPPersonalEvent() );
		r.add( new TestXMPPPresencePacket() );
		r.add( new TestXMPPPrivacyLists() );
		r.add( new TestXMPPPrivateStorage() );
		r.add( new TestXMPPPubSub() );
		r.add( new TestXMPPRegister() );
		r.add( new TestXMPPRoster() );
		r.add( new TestXMPPSASL() );
		r.add( new TestXMPPSHIM() );
		r.add( new TestXMPPSoftwareVersion() );
		r.add( new TestXMPPStream() );
		r.add( new TestXMPPStreamError() );
		r.add( new TestXMPPUserSearch() );
		r.add( new TestXMPPVCard() );
		r.add( new TestXMPPVCardTemp() );
		r.add( new TestXMPPXHTML() );
	}

	static function main() {
		
		#if jabber_component
		platform.name = platform.name+"-component";
		platform.color = "#666";
		#end
		
		#if flash
		flash.Lib.current.stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;
		flash.Lib.current.stage.align = flash.display.StageAlign.TOP_LEFT;
		tf = new flash.text.TextField();
		tf.width = flash.Lib.current.stage.stageWidth;
		tf.height = flash.Lib.current.stage.stageHeight-1;
		tf.multiline = true;
		var format = new flash.text.TextFormat( "sans", 9 );
		format.leading = -1;
		tf.defaultTextFormat = format;
		tf.text = "FLASH\n";
		flash.Lib.current.addChild( tf );
		#end

		result = "";
		haxe.unit.TestRunner.print = addResult;
		
		r = new haxe.unit.TestRunner();
		
		addTests_core();
		addTests_util();
		addTests_xmpp();
		
		var ts = Timer.stamp();
		r.run();
		var stime = Std.string( (Timer.stamp()-ts)*1000 );
		var i = stime.indexOf( "." );
		if( i != -1 ) stime = stime.substr( 0, i );
		var time = Std.parseInt( stime );
		
		#if flash
		tf.htmlText = '<b>FLASH</b> <span>'+time+'ms</span><br><div>'+result+'</div>';
		
		#elseif nodejs
		Node.fs.writeFileSync( 'out/run_${platform.name}.html', new Template( Node.fs.readFileSync( HTML_TPL, NodeC.ASCII ) ).execute( createHTMLContext( time ) ) );
		
		#elseif js
		document.getElementById( "time" ).innerHTML = time+"ms";
		document.getElementById( "result" ).innerHTML = result;
		
		#elseif sys
		File.saveContent( 'out/run_${platform.name}.html', new Template( File.getContent( HTML_TPL ) ).execute( createHTMLContext( time ) ) );
		
		#end
	}
	
	static function createHTMLContext( ?time : Int ) {
		return {
			platform : platform.name,
			color : platform.color,
			time : time,
			result : result,
			js : platform.name == "js"
		};
	}
	
	#if macro
	static function writePlatformHTML( platform : String, color : String ) {
		File.saveContent( 'out/run_$platform.html', new Template( File.getContent( HTML_TPL ) ).execute( {
			platform : platform,
			color : color,
			time : 0,
			result : "",
			js : platform == "js"
		} ) );
	}
	#end
	
}
