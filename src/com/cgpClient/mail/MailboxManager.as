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

package com.cgpClient.mail
{
import com.cgpClient.net.Net;
import com.cgpClient.net.NetEvent;
import com.cgpClient.net.NetStatus;
import com.cgpClient.net.getErrorText;

import mx.collections.ArrayCollection;
import mx.collections.Sort;
import mx.collections.SortField;

/**
 *  This class manages mailboxes list and folders list. Use it to read that 
 *  lists, open or close folders, create or remove mailboxes and any other way
 *  you will find it usable.
 */
public class MailboxManager
{
	
	private static var _mailboxes:ArrayCollection;
	
	/**
	 *  List of user mailboxes. To modify this collection use XIMSS requests,
	 *  they are automatically watched.
	 */
	public static function get mailboxes():ArrayCollection
	{
		return _mailboxes;
	}
	
	private static var _folders:ArrayCollection = new ArrayCollection();
	
	/**
	 *  List of all open folders. To modify this collection use XIMSS requests,
	 *  they are automatically watched.
	 */
	public static function get folders():ArrayCollection
	{
		return _folders;
	}
	
	private static var _enabled:Boolean = false;
	
	public static function get enabled():Boolean
	{
		return _enabled;
	}
	
	public static function set enabled(value:Boolean):void
	{
		if (_enabled == value)
			return;
		
		_enabled = value;
		
		if (_enabled)
		{
			if (!_mailboxes)
			{
				_mailboxes = new ArrayCollection();
				var sort:Sort = new Sort();
				sort.fields = [ new SortField("mailbox") ];
				_mailboxes.sort = sort;
				_mailboxes.refresh();
			}
			Net.watch(ximssCallback, dataCallback, responseCallback, asyncCallback);
			Net.dispatcher.addEventListener(NetEvent.STATUS, statusHandler);
		}
		else
		{
			Net.unwatch(ximssCallback, dataCallback, responseCallback, asyncCallback);
			Net.dispatcher.removeEventListener(NetEvent.STATUS, statusHandler);
			_mailboxes.removeAll();
			_folders.removeAll();
		}
	}
	
	/**
	 *  Retreives mailbox from <code>mailboxes</code> by it's name.
	 */
	public static function getMailbox(name:String):Mailbox
	{
		var n:int = _mailboxes.length;
		for (var i:int = 0; i < n; i++)
		{
			var mailbox:Mailbox = Mailbox(_mailboxes.getItemAt(i));
			if (mailbox.mailbox == name)
				return mailbox;
		}
		return null;
	}
	
	/**
	 *  Retreives folder from <code>folders</code> by it's name.
	 */
	public static function getFolder(name:String):Folder
	{
		var n:int = _folders.length;
		for (var i:int = 0; i < n; i++)
		{
			var folder:Folder = Folder(_folders.getItemAt(i));
			if (folder.name == name)
				return folder;
		}
		return null;
	}
	
	private static function ximssCallback(xml:XML):void {}
	
	private static function dataCallback(xml:XML, originalXML:XML):void
	{
		var name:String = xml.name();
		var mailbox:Mailbox;
		var mailboxName:String;
		var folder:Folder;
		if (name == "mailbox")
		{
			mailboxName = xml.@mailbox;
			// is it's a mailbox from other account - do not add it here
			// it will be added on mailboxSubscription data
			if (mailboxName.charAt(0) == "~")
				return;
				
			mailbox = getMailbox(mailboxName);
			if (!mailbox)
			{
				mailbox = new Mailbox();
				mailbox.update(xml); // need to update BEFORE adding to collection
				_mailboxes.addItem(mailbox);
			}
			else
			{
				mailbox.update(xml);
			}
		}
		else if (name == "folderReport" && (originalXML.name() == "folderOpen" || 
			originalXML.name() == "folderReopen"))
		{
			// From docs: if "mailbox" and "mailboxClass" attributes are 
			// specified and that Mailbox does not exist, Mailbox is created
			if (originalXML.hasOwnProperty("@mailbox") &&
				originalXML.hasOwnProperty("@mailboxClass"))
			{
				mailbox = getMailbox(originalXML.@mailbox);
				if (!mailbox)
				{
					mailbox = new Mailbox();
					mailbox.mailbox = originalXML.@mailbox;
					mailbox.mailboxClass = originalXML.@mailboxClass;
					_mailboxes.addItem(mailbox);
				}
			}
			
			mailboxName = originalXML.hasOwnProperty("@mailbox") ?
				originalXML.@mailbox : originalXML.@folder;
			mailbox = getMailbox(mailboxName);
			if (!mailbox)
				throw new Error("folderOpen was watched, but corresponding " + 
					"mailbox \"" + mailboxName + "\" is not found");
			folder = getFolder(originalXML.@folder);
			if (folder)
				throw new Error("folderOpen was watched, but folder \"" + 
					originalXML.@folder + "\" already exists");
			folder = new Folder();
			folder.mailbox = mailbox;
			folder.update(originalXML);
			folder.update(xml);
			_folders.addItem(folder);
		}
		else if (name == "folderReport" || name == "folderMessage")
		{
			folder = getFolder(xml.@folder);
			if (!folder)
				throw new Error(name + " was watched, but folder \"" + 
					xml.@folder + "\" is not found");
			folder.update(xml);
		}
		else if (name == "mailboxSubscription")
		{
			mailboxName = xml.@mailbox;
			mailbox = getMailbox(mailboxName);
			if (!mailbox)
			{
				mailbox = new Mailbox();
				mailbox.mailbox = mailboxName;
				_mailboxes.addItem(mailbox);
			}
		}
		else if (name == "mailboxRights")
		{
			mailboxName = xml.@mailbox;
			mailbox = getMailbox(mailboxName);
			if (!mailbox)
			{
				mailbox = new Mailbox();
				mailbox.mailbox = mailboxName;
				_mailboxes.addItem(mailbox);
			}
			mailbox.rights = xml.toString();
		}
	}
	
	private static function responseCallback(object:Object, originalXML:XML):void
	{
		var errorText:String = getErrorText(object);
		if (errorText)
			return;
		
		var name:String = originalXML.name();
		var mailbox:Mailbox;
		var folder:Folder;
		if (name == "mailboxCreate")
		{
			mailbox = new Mailbox();
			mailbox.mailbox = originalXML.@mailbox;
			if (originalXML.hasOwnProperty("@mailboxClass"))
				mailbox.mailboxClass = originalXML.@mailboxClass;
			_mailboxes.addItem(mailbox);
		}
		else if (name == "mailboxRename")
		{
			mailbox = getMailbox(originalXML.@mailbox);
			if (!mailbox)
				throw new Error("mailbox renaming was watched, but initial mailbox is not found");
			var previousName:String = mailbox.mailbox;
			var newName:String = originalXML.@newName;
			mailbox.mailbox = newName;
			if (originalXML.hasOwnProperty("@children")) // rename all children
			{
				var n:int = _mailboxes.length;
				for (var i:int = 0; i < n; i++)
				{
					mailbox = Mailbox(_mailboxes.getItemAt(i));
					if (mailbox.mailbox.indexOf(previousName + "/") == 0)
						mailbox.mailbox = mailbox.mailbox.substr(previousName.length + 1) + newName; 
				}
			}
		}
		else if (name == "mailboxRemove")
		{
			mailbox = getMailbox(originalXML.@mailbox);
			if (!mailbox)
				throw new Error("mailbox removal was watched, but initial mailbox is not found");
			var index:int = _mailboxes.getItemIndex(mailbox); // swear it's not -1
			_mailboxes.removeItemAt(index);
		}
		else if (name == "messageCopy" || name == "messageMove")
		{
			mailbox = getMailbox(originalXML.@mailbox);
			if (!mailbox) // request is successful - mailboxClass is defined and mailbox is created
			{
				mailbox = new Mailbox();
				mailbox.mailbox = originalXML.@mailbox;
				mailbox.mailboxClass = originalXML.@mailboxClass;
			} 
		}
		else if (name == "folderClose")
		{
			folder = getFolder(originalXML.@folder);
			if (!folder)
				throw new Error("folderClose was watched, but folder \"" + 
					originalXML.@folder + "\" is not found");
			folder.open = false;
			_folders.removeItemAt(_folders.getItemIndex(folder)); // index is ok
		}
		else if (name == "mailboxSubUpdate")
		{
			for each (var node:XML in originalXML.mailboxSubscription)
			{
				var mailboxString:String = node.@mailbox;
				var mode:String = node.@mode;
				mailbox = getMailbox(mailboxString);
				if (mode == "add" && !mailbox)
				{
					mailbox = new Mailbox();
					mailbox.mailbox = mailboxString;
					_mailboxes.addItem(mailbox);
				}
				else if (mode != "add" && mailbox)
				{
					_mailboxes.removeItemAt(_mailboxes.getItemIndex(mailbox));
				}
			}
		}
	}
	
	private static function asyncCallback(xml:XML):void
	{
		
	}
	
	private static function statusHandler(event:NetEvent):void
	{
		if (event.newStatus != NetStatus.LOGGED_IN)
		{
			_mailboxes.removeAll();
			_folders.removeAll();
		}
	}
	
}
}
