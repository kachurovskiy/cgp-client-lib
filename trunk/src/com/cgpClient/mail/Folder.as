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
import mx.collections.Sort;
import mx.collections.SortField;
	
[Bindable]
/**
 *  Folder is a mailbox, opened with some filtering and other properties.
 */
public class Folder extends EventDispatcher
{
	
	/**
	 *  Corresponding mailbox.
	 */
	public var mailbox:Mailbox;
	
	/**
	 *  Name of this folder. Does not depend on mailbox.name and can be arbitary.
	 */
	public var name:String;
	
	public var open:Boolean = true;
	
	public var sortField:String = "INTERNALDATE";
	
	public var sortOrder:String;
	
	public var filter:String; /* ex. "Media,Unseen" */
	
	public var filterField:String;
	
	public var fields:Array; /* of String, ex. ["From", "To", "Subject"] */
	
	public var rights:String;
	
	public var messages:int = 0;
	
	public var unseen:int = 0;
	
	private var _items:ArrayCollection;
	
	public function get items():ArrayCollection
	{
		return _items;
	}

	public var notified:Boolean = false;
	
	public var uidValidity:int;
	
	public var uidMin:int;
	
	public function Folder(xml:XML = null)
	{
		_items = new ArrayCollection();
		var sort:Sort = new Sort();
		var field:SortField = new SortField("index", false, sortOrder == "desc", true);
		sort.fields = [ field ];
		_items.sort = sort;
		_items.refresh();
		
		if (xml)
			update(xml);
	}
	
	public function update(xml:XML):void
	{
		var xmlName:String = xml.name().toString();
		if (xmlName == "folderOpen") // this.name is not defined at this moment
		{
			name = xml.@folder;
			sortField = xml.@sortField;
			sortOrder = xml.hasOwnProperty("@sortOrder") ? xml.@sortOrder : null;
			filter = xml.hasOwnProperty("@filter") ? xml.@filter : null;
			filterField = xml.hasOwnProperty("@filterField") ? xml.@filterField : null;
			uidValidity = xml.hasOwnProperty("@UIDValidity") ? int(xml.@UIDValidity) : null;
			uidMin = xml.hasOwnProperty("@UIDMin") ? int(xml.@UIDMin) : null;
			var newFields:Array = [];
			for each (var node:XML in xml.field)
			{
				newFields.push(node.toString());
			}
			fields = newFields;
		}
		else if ((xmlName == "folderReport" || xmlName == "folderMessage") && 
			xml.@folder == name)
		{
			open = true;
			
			var mode:String = xml.hasOwnProperty("@mode") ? xml.@mode : "updated";
			if (xml.hasOwnProperty("@messages"))
				messages = xml.@messages;
			if (xml.hasOwnProperty("@unseen"))
				unseen = xml.@unseen;
			if (xml.hasOwnProperty("@rights"))
				rights = xml.@rights;
			if (xml.hasOwnProperty("@UIDValidity"))
				uidValidity = xml.@UIDValidity;
			
			var mailboxItem:Mail;
			if (xml.hasOwnProperty("@UID"))
				mailboxItem = getMail(xml.@UID);
			
			// <folderReport id="A002" folder="INBOX" index="3" UID="512">
			//     <FLAGS>Seen,Flagged</FLAGS><From>Admin@hq.example.com</From>
			//     <Subject>Shutdown @ 4:45AM</Subject>
			// </folderReport> 
			
			// <folderReport id="." folder="INBOX" index="1" UID="976" 
			//     mode="added" messages="233" unseen="12" >
    		//     <FLAGS>Recent</FLAGS><From>CGatePro Discussions</From>
    		//     <Subject>[CGP] Re: Session Timer?</Subject>
			// </folderReport>
			if (mode == "updated" || mode == "added")
			{
				if (!mailboxItem)
				{
					mailboxItem = new Mail();
					mailboxItem.folder = this;
					mailboxItem.update(xml);
					_items.addItem(mailboxItem);
				}
				else
				{
					mailboxItem.update(xml);
				}
			}
			// <folderReport id="A004" folder="INBOX" index="35" UID="117" 
			// mode="deleted" messages="233" unseen="11" /> 
			else if (mode == "removed")
			{
				if (mailboxItem)
					_items.removeItemAt(_items.getItemIndex(mailboxItem));
			}
		}
	}
	
	public function getFolderOpen():XML
	{
		var xml:XML = <folderOpen folder={name} mailbox={mailbox.mailbox}
			sortField={sortField} sortOrder={sortOrder} />;
		if (filter)
			xml.@filter = filter;
		if (filterField)
			xml.@filterField = filterField;
		if (fields)
		{
			var n:int = fields.length;
			for (var i:int = 0; i < n; i++)
			{
				xml.appendChild(<field>{fields[i]}</field>);
			}
		}
		return xml;
	}
	
	public function getMail(uid:int):Mail
	{
		var source:Array = _items.source;
		for each (var item:Mail in source)
		{
			if (item && item.uid == uid)
				return item;
		}
		return null;
	}

}
}
