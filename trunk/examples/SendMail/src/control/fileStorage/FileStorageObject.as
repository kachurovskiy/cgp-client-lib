package control.fileStorage
{
[Bindable]
public class FileStorageObject
{
	
	protected var _path:String;
	
	public function get path():String
	{
		return _path;
	}
	
	public function set path(value:String):void
	{
		if (_path == value)
			return;
		
		_path = value;
		parsePath();
	}
	
	public var name:String;
	
	public var directory:String;
	
	public var size:int = 0;
	
	public function FileStorageObject(path:String = null)
	{
		this.path = path;
	}
	
	public function update(xml:XML):void
	{
		// file and directory handle all by themselves
	}
	
	protected function parsePath():void
	{
		if (_path)
		{
			var split:Array = _path.split("/");
			name = String(split.pop());
			directory = split.length == 0 ? "" : split.join("/");
		}
		else
		{
			name = null;
			directory = null;
		}
	}
	
}
}