package control.fileStorage
{
[Bindable]
public class FileStorageFile extends FileStorageObject
{
	
	public var extension:String;
	
	public var timeModified:String;
	
	public function FileStorageFile(path:String = null)
	{
		super(path);
	}
	
	/**
	 *  What we handle: 
	 * 
	 *  <fileInfo id="A38" fileName="ProntoCore.swc" size="2925" 
	 *      timeModified="20090327T122925"/>
	 * 
	 *  <fileInfo id="A39" fileName="SoftwareEngineer.doc" directory="docs" 
	 *      size="36352" timeModified="20090326T101443"/>
	 */
	override public function update(xml:XML):void
	{
		var name:String = xml.name();
		if (name == "fileInfo")
		{
			var directory:String = xml.hasOwnProperty("@directory") ? xml.@directory : "";
			var fileName:String = xml.@fileName;
			path = directory == "" ? fileName : directory + "/" + fileName;
			size = int(xml.@size);
			timeModified = xml.@timeModified; 
		}
	}
	
	override protected function parsePath():void
	{
		super.parsePath();
		
		var nameSplit:Array = name.split(".");
		extension = nameSplit.length > 1 ? String(nameSplit.pop()) : null;
	}
	
}
}