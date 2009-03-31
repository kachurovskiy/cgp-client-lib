package control.fileStorage
{
import mx.collections.ArrayCollection;
	
[Bindable]
public class FileStorageDirectory extends FileStorageObject
{
	
	public var children:ArrayCollection = new ArrayCollection();
	
	public var files:int = 0;
	
	public var listed:Boolean = false;
	
	public function FileStorageDirectory(path:String = null)
	{
		super(path);
	}
	
	/**
	 *  What we handle:
	 * 
	 *  (sizeLimit and filesLimit only for root)
	 *  <fileDirInfo id="A36" directory="" size="133341375" files="241" 
	 *      sizeLimit="3" filesLimit="3000"/>
	 * 
	 *  <fileInfo id="A38" fileName="$DomainPBXApp" type="directory"/>
	 */
	override public function update(xml:XML):void
	{
		var name:String = xml.name();
		var directory:String = xml.hasOwnProperty("@directory") ? xml.@directory : "";
		if (name == "fileDirInfo")
		{
			path = directory;
			size = int(xml.@size);
			files = xml.@files;
		}
		else if (name == "fileInfo" && xml.hasOwnProperty("@type"))
		{
			var fileName:String = xml.@fileName;
			path = directory == "" ? fileName : directory + "/" + fileName;
		}
	}
	
}
}