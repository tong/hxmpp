package util;


class SystemUtil {
	
	#if !js
	public static inline function systemName() : String {
		return
		#if neko neko.Sys.systemName();
		#elseif php php.Sys.systemName();
		#elseif flash9 flash.system.Capabilities.os;
		#end
	}
	#else
	public static function systemName() : String {
		var s = js.Lib.window.navigator.appVersion;
		var os = "Unknown";
		if( s.indexOf( "Win" ) != -1 ) return "Windows";
		if( s.indexOf( "Mac" ) != -1 ) return "MacOS";
		if( s.indexOf( "X11" ) != -1 ) os = "Unix";
		if( s.indexOf( "Linux" ) != -1 ) os = "Linux";
		return os;
	}
	#end
	
}
