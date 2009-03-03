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
	
	
		/*
	public static function getProcInfo() {
		if( neko.Sys.systemName() != "Linux" ) {
		}
		
		import os
_proc_status = '/proc/%d/status' % os.getpid( )
_scale = {'kB': 1024.0, 'mB': 1024.0*1024.0,
          'KB': 1024.0, 'MB': 1024.0*1024.0}
def _VmB(VmKey):
    ''' given a VmKey string, returns a number of bytes. '''
    # get pseudo file  /proc/<pid>/status
    try:
        t = open(_proc_status)
        v = t.read( )
        t.close( )
    except IOError:
        return 0.0  # non-Linux?
    # get VmKey line e.g. 'VmRSS:  9999  kB\n ...'
    i = v.index(VmKey)
    v = v[i:].split(None, 3)  # split on runs of whitespace
    if len(v) < 3:
        return 0.0  # invalid format?
    # convert Vm value to bytes
    return float(v[1]) * _scale[v[2]]
def memory(since=0.0):
    ''' Return virtual memory usage in bytes. '''
    return _VmB('VmSize:') - since
def resident(since=0.0):
    ''' Return resident memory usage in bytes. '''
    return _VmB('VmRSS:') - since
def stacksize(since=0.0):
    ''' Return stack size in bytes. '''
    return _VmB('VmStk:') - since
		
	}
		*/
	
}
