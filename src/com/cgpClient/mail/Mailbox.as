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
import flash.events.EventDispatcher;

import mx.collections.ArrayCollection;

[Bindable]
/**
 *  Mailbox is a static object on server. It does not have "items" that can 
 *  be "read" in our sense. It's just info about some storage place.
 * 
 *  <p>Instead of it Folder is an open Mailbox. Folders have items and are 
 *  used to show actual emails.</p>
 */
public class Mailbox extends EventDispatcher
{
	
	public function Mailbox(xml:XML = null)
	{
		super();
		
		if (xml)
			update(xml);
	}
	
	public var mailbox:String;
	
	/**
	 *  Some int like 306169346. Who knows what's that?
	 */
	public var uidValidity:int;
	
	public var messages:int = 0;
	
	public var uidNext:String;
	
	public var unseen:int = 0;
	
	/**
	 *  Date of the oldest message stored in the mailbox.
	 */
	public var oldest:Date;
	
	public var mailboxClass:String;
	
	public var media:int = 0;
	
	/**
	 *  Number of messages that have the Media flag set but do not have the 
	 *  Seen flag set.
	 */
	public var unseenMedia:int = 0;
	
	public var size:int = 0;
	
	/**
	 *  It cannot contain messages, but it can contain sub-Mailboxes. 
	 */
	public var pureFolder:Boolean = false;
	
	/**
	 *  It can contain messages, and it can contain sub-Mailboxes.
	 */
	public var isFolder:Boolean = false;
	
	public var rights:String;
	
	private var _folders:ArrayCollection = new ArrayCollection();
	
	/**
	 *  Array of all folders, opened from this Mailbox. Do not modify
	 *  it manually, use <code>MailboxManager</code> methods.
	 */
	public function get folders():ArrayCollection
	{
		return _folders;
	}
	
	public function update(xml:XML):void
	{
		mailbox = xml.@mailbox;
		uidValidity = int(xml.@UIDValidity);
		messages = int(xml.@messages);
		uidNext = xml.@UIDNext;
		unseen = int(xml.@Unseen);
		oldest = new Date(); // TODO: parse from xml.@oldest like 20081130083551
		mailboxClass = xml.hasOwnProperty("@Class") ? xml.@Class : null;
		media = xml.hasOwnProperty("@Media") ? xml.@Media : 0;
		unseenMedia = xml.hasOwnProperty("@UnseenMedia") ? xml.@UnseenMedia : 0;
		size = int(xml.@size);
		pureFolder = xml.hasOwnProperty("@pureFolder") ? xml.@pureFolder == "yes" : false;
		isFolder = xml.hasOwnProperty("@isFolder") ? xml.@isFolder == "yes" : false;
		rights = xml.hasOwnProperty("@rights") ? xml.@rights : null;
	}
	
}
}
