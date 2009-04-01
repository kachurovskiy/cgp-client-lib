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
import com.cgpClient.fileStorage.actions.ExploreAction;
import com.cgpClient.fileStorage.actions.FileDirInfoAction;

import mx.collections.ArrayCollection;

/**
 *  <b>Whole <code>com.cgpClient.fileStorage</code> package is in early state of
 *  development.</b>
 * 
 *  <p>This class represents remote File Storage. Now it allows only to list
 *  once all the remote File Storage, but soon it will allow much more: 
 *  directories creation, files operations, download, upload and so on.</p>
 * 
 *  <p>Most common use of this class is binding <code>tree</code> property
 *  to <code>dataProvider</code> of some <code>mx.controls.Tree</code>.</p>
 */
public class FileStorage
{
	
	[Bindable]
	/**
	 *  Tree of all known files and directories.
	 */
	public var tree:ArrayCollection = new ArrayCollection();
	
	[Bindable]
	/**
	 *  List of all known files and directories.
	 */
	public var list:ArrayCollection = new ArrayCollection();
	
	[Bindable]
	public var actions:ArrayCollection = new ArrayCollection();
	
	[Bindable]
	public var errors:ArrayCollection = new ArrayCollection();
	
	/**
	 *  Tree root can be constructor parameter, ex. private/mypictures.
	 */
	private var _root:String;
	
	public function get root():String
	{
		return _root;
	}
	
	private var _rootDirectory:FileStorageDirectory;
	
	public function get rootDirectory():FileStorageDirectory
	{
		return _rootDirectory;
	}
	
	public function FileStorage(root:String = "") 
	{
		this._root = root;
		
		// in common case root can not exist and could need creation
		// but now this class is used only for ""
		var infoAction:FileDirInfoAction = new FileDirInfoAction();
		infoAction.start(this, _root);
		
		// File Storage data should be requested only when user actually need
		// it - ex. clicks on directory in tree. But for this demo we will 
		// retrieve all data at stratup.
		var exploreAction:ExploreAction = new ExploreAction();
		exploreAction.start(this, _root);
	}
	
	/**
	 *  FileStorageAction's child classes use this method to delegate incoming 
	 *  data parse to this class.
	 * 
	 *  @return Object, that was created or updated with given XML.
	 */
	public function update(xml:XML):FileStorageObject
	{
		var name:String = xml.name();
		var directory:String = xml.hasOwnProperty("@directory") ? xml.@directory : "";
		var fileName:String = xml.hasOwnProperty("@fileName") ? xml.@fileName : "";
		var path:String = directory == "" ? fileName : directory + "/" + fileName;
		var fileStorageObject:FileStorageObject = getFileStorageObject(path);
		if (!fileStorageObject)
		{
			if (name == "fileDirInfo" || name == "fileInfo" && xml.hasOwnProperty("@type"))
				fileStorageObject = new FileStorageDirectory();
			else if (name == "fileInfo")
				fileStorageObject = new FileStorageFile();
			else
				throw new Error("Unknown XML: " + xml);
				
			fileStorageObject.update(xml);
			
			add(fileStorageObject);
		}
		else
		{
			fileStorageObject.update(xml);
		}
		return fileStorageObject;
	}
	
	/**
	 *  Adds object to corresponding directory or other place. Object should not
	 *  exist yet, existence is not checked.
	 */
	public function add(fileStorageObject:FileStorageObject):void
	{
		list.addItem(fileStorageObject);
		
		var directory:FileStorageDirectory = fileStorageObject as FileStorageDirectory;
		// var file:FileStorageFile = fileStorageObject as FileStorageFile;
		if (directory && directory.path == _root)
		{
			_rootDirectory = directory;
			tree.addItem(directory);
		}
		else
		{
			var parentDirectory:FileStorageDirectory = getFileStorageObject(
				fileStorageObject.directory) as FileStorageDirectory;
			if (!parentDirectory)
				throw new Error("Adding object with non-existing parent " + 
					"directories is not supported yet.");
			
			parentDirectory.children.addItem(fileStorageObject);
		}
	}
	
	/**
	 *  Not implemented yet.
	 */
	public function remove(fileStorageObject:FileStorageObject):void {}
	
	/**
	 *  @return Existing FileStorageObject with given path, if any. 
	 */
	public function getFileStorageObject(path:String):FileStorageObject
	{
		var array:Array = list.source;
		var n:int = array.length;
		var object:FileStorageObject;
		for (var i:int = 0; i < n; i++)
		{
			object = FileStorageObject(array[i]);
			if (object.path == path)
				return object;
		}
		return null;
	}
	
	/**
	 *  @return Parent directory object for given path, if such object exists.
	 *  <code>null</code> otherwise. 
	 */
	public function getParentDirectory(path:String):FileStorageDirectory
	{
		if (path == "")
			return null;
		
		var split:Array = path.split("/");
		split.pop();
		var directoryPath:String = split.join("/");
		return getFileStorageObject(directoryPath) as FileStorageDirectory;
	}
	
}
}