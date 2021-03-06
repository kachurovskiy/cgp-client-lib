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
import com.cgpClient.net.Net;
import com.cgpClient.net.getErrorText;

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
		Net.ximss(<fileList directory={directory}/>, dataCallback, responseCallback);
	}
	
	private function dataCallback(xml:XML):void
	{
		fileStorage.update(xml);
	}
	
	private function responseCallback(object:Object):void
	{
		var text:String = getErrorText(object);
		if (text)
			error(text);
		else
			complete();
	}
	
}
}