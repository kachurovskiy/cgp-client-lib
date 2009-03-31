package control.fileStorage.actions
{
import com.cgpClient.net.Net;
import com.cgpClient.net.getErrorText;

import control.fileStorage.FileStorage;

public class FileListAction extends FileStorageAction
{
	
	private var directory:String;
	
	public function start(fileStorage:FileStorage, directory:String):void
	{
		this.fileStorage = fileStorage;
		this.directory = directory;
		
		startRunning();
		
		// if directory is already listed, here we should remembed it's current
		// children and on request complete we should remove missing ones from
		// FileStorage. But in this example we list File Storage only once.
		Net.ximss(<fileList directory={directory}/>, dataCallBack, responseCallBack);
	}
	
	private function dataCallBack(xml:XML):void
	{
		fileStorage.update(xml);
	}
	
	private function responseCallBack(object:Object):void
	{
		var text:String = getErrorText(object);
		if (text)
			error(text);
		else
			complete();
	}
	
}
}