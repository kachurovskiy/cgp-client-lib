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