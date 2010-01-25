/* Copyright (c) 2010 Maxim Kachurovskiy

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

package com.cgpClient.fileStorage.actions
{
import com.cgpClient.fileStorage.FileStorage;
import com.cgpClient.fileStorage.FileStorageDirectory;
import com.cgpClient.net.Net;
import com.cgpClient.net.getErrorText;
	
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
			Net.ximss(<fileList directory={path}/>, dataCallback, responseCallback);
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
	
	private function dataCallback(xml:XML):void
	{
		var directory:FileStorageDirectory = fileStorage.update(xml) as 
			FileStorageDirectory;
		if (directory)
			directoriesToList.push(directory.path);
	}
	
	private function responseCallback(object:Object):void
	{
		var text:String = getErrorText(object);
		if (text)
			errors.push(text);
		check();
	}
	
}
}