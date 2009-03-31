/* Copyright (c) 2009 Maxim Kachurovskiy

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE. */

package com.cgpClient.fileStorage
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