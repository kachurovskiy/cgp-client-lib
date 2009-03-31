package control.fileStorage.actions
{
import com.cgpClient.net.Net;
import com.cgpClient.net.getErrorText;

import control.fileStorage.FileStorage;
import control.fileStorage.FileStorageDirectory;
	
/**
 *  Lists all directories and files.
 */
public class ExploreAction extends FileStorageAction
{
	
	private var fromDirectory:String;
	
	private var directoriesToList:Array;
	
	private var errors:Array = [];
	
	public function start(fileStorage:FileStorage, fromDirectory:String):void
	{
		this.fileStorage = fileStorage;
		this.fromDirectory = fromDirectory;
		
		startRunning();
		
		directoriesToList = [ fromDirectory ];
		check();
	}
	
	private function check():void
	{
		if (directoriesToList.length > 0)
		{
			var path:String = directoriesToList.shift();
			Net.ximss(<fileList directory={path}/>, dataCallBack, responseCallBack);
		}
		else if (errors.length > 0)
		{
			error(errors.join("\n"));
		}
		else
		{
			complete();
		}
	}
	
	private function dataCallBack(xml:XML):void
	{
		var directory:FileStorageDirectory = fileStorage.update(xml) as 
			FileStorageDirectory;
		if (directory)
			directoriesToList.push(directory.path);
	}
	
	private function responseCallBack(object:Object):void
	{
		var text:String = getErrorText(object);
		if (text)
			errors.push(text);
		check();
	}
	
}
}