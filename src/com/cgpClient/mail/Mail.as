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
import com.cgpClient.CGPUtils;
import com.cgpClient.mail.actions.MailFlagAction;
import com.cgpClient.mail.mime.MIME;

import flash.events.Event;
import flash.events.EventDispatcher;

import mx.collections.ArrayCollection;
	
[Bindable]
public class Mail extends EventDispatcher
{
	
	public static const PREVIEW:String = "preview";
	
	public static const LOADING:String = "loading";
	
	public static const VIEW:String = "view";
	
	public static const COMPOSING:String = "composing";
	
	public static const SENDING:String = "sending";
	
	public static const SENT:String = "sent";
	
	public var status:String = PREVIEW;
	
	public var errors:ArrayCollection = new ArrayCollection();
	
	public var uid:int;
	
	public var partId:String;
	
	public var index:int;
	
	public var date:Date;
	
	public var timeShift:int;
	
	public var folder:Folder;
	
	private var _flags:Array = [];
	private var mailFlagAction:MailFlagAction;
	
	[Bindable("flagsChange")]
	public function get flags():Array
	{
		return _flags;
	}
	
	public function set flags(value:Array):void
	{
		if (_flags == value)
			return;
		
		if (partId)
			throw new Error("setting flags for message parts is not allowed");
		
		if (!value)
			throw new Error("flags can not be set to null. Use empty Array.");
		
		_flags = value;
		seen = value.indexOf("Seen") >= 0;
		dispatchEvent(new Event("flagsChange"));
		
		if (!mailFlagAction)
			mailFlagAction = new MailFlagAction(this);
		else
			mailFlagAction.start();
	}
	
	private var _seen:Boolean = true;
	
	public function get seen():Boolean
	{
		return _seen;
	}
	
	public function set seen(value:Boolean):void
	{
		if (_seen == value)
			return;
		
		_seen = value;
		
		var seenIndex:int = _flags.indexOf("Seen");
		if (_seen)
		{
			if (seenIndex == -1)
			{
				_flags.push("Seen");
				flags = flags.concat();
			}
		}
		else
		{
			if (seenIndex >= 0)
			{
				_flags.splice(seenIndex, 1);
				flags = flags.concat();
			}
		}
	}
	
	public var subject:String;
	
	public var from:Person;
	
	public var toValue:Array = [];
	
	public var cc:Array = [];
	
	public var bcc:Array = [];
	
	private var _mime:MIME;
	
	[Bindable("mimeChange")]
	public function get mime():MIME
	{
		return _mime;
	}
	
	public function set mime(value:MIME):void
	{
		if (_mime == value)
			return;
		
		_mime = value;
		dispatchEvent(new Event("mimeChange"));
	}
	
	public var priority:String;
	
	public function Mail(xml:XML = null)
	{
		super();
		
		if (xml)
			update(xml);
	}
	
	/**
	 *  <folderMessage folder="INBOX" id="A38" UID="4422">
	 *      <EMail>
	 *          <X-Junk-Score>0 []</X-Junk-Score>
	 *          <X-Real-To>maria@domain.com</X-Real-To>
	 *          <Return-Path>vasiliy@domain.com</Return-Path>
	 *          <Received>from ...</Received>
	 *          <X-Autogenerated>group</X-Autogenerated>
	 *          <Reply-To realName="HTML Development">html-dev@domain.com</Reply-To>
	 *          <Date localTime="20090404T015200" timeShift="14400">20090403T215200Z</Date>
	 *          <To realName="HTML Development">html-dev@domain.com</To>
	 *          <Subject>Re: [Fwd: JavaScript Error - Case[BQEO0330-856AN]]</Subject>
	 *          <From realName="Vasily Petrov">vpetr@stalker.com</From>
	 *          <Organization>HTML Systems</Organization>
	 *          <Cc realName="Alexey Markovich">amar@domain.com</Cc>
	 *          <References>...</References>
	 *          <Message-ID>&lt;urty0z2abnozkt@maria-notebook.msk&gt;</Message-ID>
	 *          <In-Reply-To>&lt;49D6700C.5090300@domain.com&gt;</In-Reply-To>
	 *          <User-Agent>Opera Mail/9.64 (Win32)</User-Agent>
	 *          <MIME charset="koi8-r" estimatedSize="250" subtype="plain" type="text" 
	 *              Type-delsp="yes" Type-format="flowed">Thanks for the question. 
	 *              The answer is yes, you can.\n\nFor example ...\n\n> Is there 
	 *              any way of telling if an e-mail address is valid\n\n> without 
	 *              sending a message to the e-mail address?</MIME>
	 *      </EMail>
	 *  </folderMessage>
	 * 
	 *  <folderReport id="A003" folder="Drafts" index="127" UID="755" 
	 *      mode="added" messages="302" unseen="1">
	 *      <FLAGS>Recent,Drafts</FLAGS>
	 *      <From>Other Name</From>
	 *  </folderReport>
	 * 
	 *  <EMail partID="02-01-04">
	 *      <X-Junk-Score>0 []</X-Junk-Score>
	 *      <... />
	 *  </EMail>
	 */
	public function update(xml:XML):void
	{
		if (xml.hasOwnProperty("@UID"))
			uid = xml.@UID;
		if (xml.hasOwnProperty("@partID"))
			partId = xml.@partID;
		
		
		if (xml.hasOwnProperty("@index"))
			index = xml.@index;
		if (xml.FLAGS.length() > 0)
		{
			var flagsString:String = xml.FLAGS;
			if (flagsString.length > 0)
				flags = flagsString.split(",");
			else
				flags = [];
		}
		
		if (xml.EMail.length() > 0)
			xml = xml.EMail[0];
		
		var dateXML:XML = xml.Date.length() > 0 ? xml.Date[0] : null;
		if (dateXML) // <Date localTime="20090404T015200" timeShift="14400">20090403T215200Z</Date>
		{
			timeShift = dateXML.hasOwnProperty("@timeShift") ? int(dateXML.@timeShift) : 0;
			date = CGPUtils.dateFromString(dateXML.toString());
		}
		if (xml.From.length() > 0)
			from = Person.fromXML(xml.From[0]);
		if (xml.Subject.length() > 0)
			subject = xml.Subject;
		if (xml.Pty.length() > 0)
			priority = xml.Pty;
		var person:Person;
		var array:Array;
		if (xml.To.length() > 0)
		{
			array = [];
			for each (var toNode:XML in xml.To)
			{
				person = Person.fromXML(toNode);
				array.push(person);
			}
			toValue = array;
		}
		if (xml.Cc.length() > 0)
		{
			array = [];
			for each (var ccNode:XML in xml.Cc)
			{
				person = Person.fromXML(ccNode);
				array.push(person);
			}
			cc = array;
		}
		if (xml.Bcc.length() > 0)
		{
			array = [];
			for each (var bccNode:XML in xml.Bcc)
			{
				person = Person.fromXML(bccNode);
				array.push(person);
			}
			bcc = array;
		}
		if (xml.MIME.length() > 0)
		{
			if (status == PREVIEW)
				status = VIEW;
			var newMIME:MIME = new MIME();
			newMIME.mail = this;
			newMIME.update(xml.MIME[0]);
			mime = newMIME;
		}
	}
	
	public function toXML(userName:String, realName:String):XML
	{
		var xml:XML = <EMail/>;
		var node:XML = <From>{userName}</From>;
		if (realName)
			node.@realName = realName;
		xml.appendChild(node);
		if (subject)
		{
			node = <Subject>{subject}</Subject>
			xml.appendChild(node);
		}
		var person:Person;
		var n:int = toValue.length;
		var i:int;
		for (i = 0; i < n; i++)
		{
			xml.appendChild(Person(toValue[i]).toXML("To"));
		}
		n = cc.length;
		for (i = 0; i < n; i++)
		{
			xml.appendChild(Person(cc[i]).toXML("Cc"));
		}
		n = bcc.length;
		for (i = 0; i < n; i++)
		{
			xml.appendChild(Person(bcc[i]).toXML("Bcc"));
		}
		if (flags.length > 0)
		{
			xml.appendChild(<FLAGS>{flags.join(",")}</FLAGS>);
		}
		if (mime)
		{
			node = mime.toXML();
			xml.appendChild(node);
		}
		
		return xml;
	}
	
	public function getPart(partId:String):MIME
	{
		var mimeChildren:ArrayCollection = mime.children;
		var n:int = mimeChildren.length;
		for (var i:int = 0; i < n; i++)
		{
			var mimeChild:MIME = MIME(mimeChildren.getItemAt(i));
			if (mimeChild.partId == partId)
				return mimeChild;
		}
		return null;
	}
	
}
}