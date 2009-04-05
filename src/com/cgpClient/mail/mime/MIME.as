package com.cgpClient.mail.mime
{
import com.cgpClient.mail.Mail;

import mx.collections.ArrayCollection;
	
[Bindable]
public class MIME
{
	
	public var partId:String;
	
	public var estimatedSize:int;
	
	public var type:String;
	
	public var subtype:String;
	
	public var charset:String;
	
	public var contentId:String;
	
	public var disposition:String;
	
	public var description:String;
	
	public var location:String;
	
	public var classValue:String;
	
	public var types:ArrayCollection = new ArrayCollection();
		/* contains Type-name */
	
	public var dispositions:ArrayCollection = new ArrayCollection(); 
		/* contains Disposition-name */
	
	public var children:ArrayCollection = new ArrayCollection(); 
		/* contains MIMEs, EMails and other Objects */
	
	private var xml:XML;
	
	public function MIME(xml:XML = null)
	{
		if (xml)
			update(xml);
	}
	
	public function toString():String
	{
		return children.source.join("\n-------------------------------------------\n");
	}
	
	private function update(xml:XML):void
	{
		this.xml = xml;
		
		if (xml.hasOwnProperty("@partID"))
			partId = xml.@partID;
		if (xml.hasOwnProperty("@estimatedSize"))
			estimatedSize = int(xml.@estimatedSize);
		if (xml.hasOwnProperty("@type"))
			type = xml.@type;
		if (xml.hasOwnProperty("@subtype"))
			subtype = xml.@subtype;
		if (xml.hasOwnProperty("@charset"))
			charset = xml.@charset;
		if (xml.hasOwnProperty("@contentID"))
			contentId = xml.@contentID;
		if (xml.hasOwnProperty("@disposition"))
			disposition = xml.@disposition;
		if (xml.hasOwnProperty("@description"))
			description = xml.@description;
		if (xml.hasOwnProperty("@location"))
			location = xml.@location;
		if (xml.hasOwnProperty("@class"))
			classValue = xml["@class"];
		
		// TODO: fill dispositions and children
		
		children.removeAll();
		for each (var node:XML in xml.children())
		{
			var child:Object = factorChildren(node);
			if (child)
				children.addItem(child);
		}
	}
	
	public function toXML():XML
	{
		if (type == "text")
			return <MIME type="text" subtype="plain">{children[0]}</MIME>;
		throw new Error("Only text is implemented");
		return null;
	}
	
	private function factorChildren(node:XML):Object
	{
		var child:Object;
		if (type == "message" && (subtype == "rfc822" ||
			subtype == "rfc822-headers"))
		{
			child = new Mail(node);
		}
		else if (type == "text") // any subtype, don't work with that yet
		{
			child = node.toString();
		}
		else if (type == "message" && (subtype == "disposition-notification" ||
			subtype == "delivery-status"))
		{
			child = new MIMEReport(node);
		}
		else // type == "multipart" && others
		{
			child = new MIME(node);
		}
		return child;
	}

}
}