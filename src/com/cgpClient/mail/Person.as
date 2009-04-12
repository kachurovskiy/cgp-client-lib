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

package com.cgpClient.mail
{
public class Person
{
	
	public static function fromString(string:String):Person
	{
		// 3 is a@b
		if (!string || string.length < 3)
			return null;
		var name:String;
		var mail:String;
		var spaceDelimited:Array = string.split(/(,|\"|\'|<|>| )/);
		var n:int = spaceDelimited.length;
		for (var i:int = 0; i < n; i++)
		{
			var part:String = spaceDelimited[i];
			if (part.indexOf("@") >= 0)
			{
				spaceDelimited.splice(i, 1);
				mail = part;
				name = spaceDelimited.join(" "); 
				return new Person(name, mail);
			}
		}
		return null;
	}
	
	public static function fromXML(node:XML):Person
	{
		return new Person(node.hasOwnProperty("@realName") ? 
			node.@realName : null, node.toString());
	}
	
	public function toXML(nodeName:String):XML
	{
		var node:XML = <{nodeName}>{mail}</{nodeName}>;
		if (name)
			node.@realName = name;
		return node;
	}
	
	public var name:String;
	
	public var mail:String;
	
	public function Person(name:String, mail:String)
	{
		this.name = name;
		this.mail = mail;
	}
	
	public function toString():String
	{
		if (name && mail)
			return "\"" + name + "\" <" + mail + ">";
		else if (name)
			return name;
		else if (mail)
			return mail;
		return "";
	}

}
}