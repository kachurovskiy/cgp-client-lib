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