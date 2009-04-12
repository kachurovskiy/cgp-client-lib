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
	
	public var types:Object = [];
		/* String (ex. "name") -> String (ex. "file1.png"), contains Type-name */
	
	public var dispositions:Object = []; 
		/* String (ex. "filename") -> String (ex. "file1.png"), contains Disposition-name */
	
	public var children:ArrayCollection = new ArrayCollection(); 
		/* contains MIMEs, EMails and other Objects */
	
	private var _xml:XML;
	
	public function get xml():XML
	{
		return _xml;
	}
	
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
		_xml = xml;
		
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
		
		// fill dispositions and types
		for each (var attribute:XML in xml.attributes())
		{
			var name:String = attribute.name();
			if (name.indexOf("Disposition-") == 0)
				dispositions[name.substr(12)] = attribute.toString();
			else if (name.indexOf("Type-") == 0)
				types[name.substr(5)] = attribute.toString();
		}
		
		children.removeAll();
		if (type == "multipart")
		{
			for each (var node:XML in xml.children())
			{
				var childMIME:MIME = new MIME(node);
				children.addItem(childMIME);
			}
		}
		else if ((type == "message" && subtype == "rfc822") ||
			(type == "text" && subtype == "rfc822-headers"))
		{
			var mail:Mail = new Mail(xml.EMail[0]);
			children.addItem(mail);
		}
		else if (type == "text" && (subtype == "directory" || subtype == "x-vcard"))
		{
			var vCard:VCard = new VCard(xml.vCard[0]);
			children.addItem(vCard);
		}
		else if (type == "text" && subtype == "x-vgroup")
		{
			var vCardGroup:VCardGroup = new VCardGroup(xml.vCardGroup[0]);
			children.addItem(vCardGroup);
		}
		else if (type == "text" && subtype == "calendar")
		{
			var iCalendar:ICalendar = new ICalendar(xml.iCalendar[0]);
			children.addItem(iCalendar);
		}
		else if (type == "message" && (subtype == "disposition-notification" ||
			subtype == "delivery-status"))
		{
			var mimeReport:MIMEReport = new MIMEReport(xml.MIMEReport[0]);
			children.addItem(mimeReport);
		}
		else if (type == "text")
		{
			var string:String = xml.toString();
			children.addItem(string);
		}
		else
		{
			// not sure that it's an error. We can receive very strange things.
		}
	}
	
	public function toXML():XML
	{
		if (type == "text" && subtype == "plain")
			return <MIME type="text" subtype="plain">{children[0]}</MIME>;
		throw new Error("Only text is implemented");
		return null;
	}
	
}
}