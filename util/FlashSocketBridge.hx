
import jabber.tool.SocketBridge;

/**
	Flash9+ socket bridge SWF for javascript applications.
*/
class FlashSocketBridge extends jabber.tool.SocketBridge {

	static function main() {
		flash.Lib.current.stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;
		flash.Lib.current.stage.align = flash.display.StageAlign.TOP_LEFT;
		var cm = new flash.ui.ContextMenu();
		cm.hideBuiltInItems();
		flash.Lib.current.contextMenu = cm;
		new SocketBridge( flash.Lib.current.loaderInfo.parameters.ctx );
	}
	
}
