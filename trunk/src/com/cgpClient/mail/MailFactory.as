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
import com.cgpClient.mail.mime.MIME;

import mx.collections.ArrayCollection;
import mx.containers.VBox;
import mx.controls.Label;
import mx.controls.Text;
import mx.core.UIComponent;
	
public class MailFactory
{
	
	/**
	 *  Creates visual representation of some MIME element. Pass main Mail
	 *  mime element to get mail view. 
	 * 
	 *  @mime Some MIME instance. Usually it is <code>Mail.mime</code>.
	 * 
	 *  @return UIComponent instance representing given MIME instance.
	 */
	public static function factorMIMEView(mime:MIME):UIComponent
	{
		// go from simplest cases to more complex ones
		var type:String = mime.type;
		var subtype:String = mime.subtype;
		var children:ArrayCollection = mime.children;
		if (type == "text" && subtype == "plain")
		{
			var plainText:String = String(children.getItemAt(0));
			plainText = CGPUtils.plainToFlash(plainText);
			var plainTextComponent:Text = createText();
			plainTextComponent.text = plainText; 
			return plainTextComponent;
		}
		else if (type == "text" && subtype == "html")
		{
			var htmlText:String = String(children.getItemAt(0));
			htmlText = CGPUtils.htmlToFlash(htmlText);
			var htmlTextComponent:Text = createText();
			htmlTextComponent.htmlText = htmlText; 
			return htmlTextComponent;
		}
		else if (type == "message" && (subtype == "disposition-notification" ||
			subtype == "delivery-status"))
		{
			var mimeReportLabel:Label = createLabel("MIME Report, " + subtype);
			return mimeReportLabel;
		}
		else if (type == "text" && subtype == "calendar")
		{
			var iCalendarLabel:Label = createLabel("Calendar, " + subtype);
			return iCalendarLabel;
		}
		else if (type == "text" && subtype == "x-vgroup")
		{
			var vCardGroupLabel:Label = createLabel("VCard Group, " + subtype);
			return vCardGroupLabel;
		}
		else if (type == "text" && (subtype == "directory" || subtype == "x-vcard"))
		{
			var vCardLabel:Label = createLabel("VCard, " + subtype);
			return vCardLabel;
		}
		// skip (type == "message" && subtype == "rfc822") ||
		// (type == "text" && subtype == "rfc822-headers") - render only as attachment
		else if (type == "multipart")
		{
			var n:int = children.length;
			var i:int;
			var childView:UIComponent;
			if (subtype == "mixed" || subtype == "digest")
			{
				var container:VBox = new VBox();
				container.percentWidth = 100;
				for (i = 0; i < n; i++)
				{
					var childMIME:MIME = MIME(children.getItemAt(i));
					childView = factorMIMEView(childMIME);
					if (childView)
						container.addChild(childView);
				}
				return container;
			}
			else if (subtype == "alternative")
			{
				var bestAlternativeMIME:MIME = chooseBestAlternative(mime);
				if (bestAlternativeMIME)
					childView = factorMIMEView(bestAlternativeMIME);
				return childView;
			}
		}
		return null;
	}
	
	private static function createText():Text
	{
		var textComponent:Text = new Text();
		textComponent.percentWidth = 100;
		return textComponent;
	}

	private static function createLabel(text:String):Label
	{
		var label:Label = new Label();
		label.percentWidth = 100;
		label.setStyle("fontWeight", "bold");
		label.text = text;
		return label;
	}
	
	private static function chooseBestAlternative(mime:MIME):MIME
	{
		var children:ArrayCollection = mime.children;
		var n:int = mime.children.length;
		var lastOkMIME:MIME;
		var hasPlain:Boolean = false;
		for (var i:int = 0; i < n; i++)
		{
			var childMIME:MIME = MIME(children.getItemAt(i));
			var type:String = childMIME.type;
			var subtype:String = childMIME.subtype;
			if (type == "text" && subtype == "plain")
			{
				hasPlain = true;
				lastOkMIME = childMIME; 
			}
			else if (type == "text" && subtype == "html")
			{
				if (!hasPlain) // if we have plain, do not get html.
					lastOkMIME = childMIME;
			}
			else // we can't handle something more complex
			{
				break;
			}
		}
		return lastOkMIME; // can be null
	}
	
	/**
	 *  Selects all child MIMEs that should be treated as attachments. Forwared
	 *  mail is treated as attachment too. 
	 */
	public static function retrieveAttachments(mime:MIME):Array
	{
		var result:Array = [];
		if (mime.type != "multipart" || mime.subtype != "mixed")
			return result;
		
		var children:ArrayCollection = mime.children;
		var n:int = children.length;
		for (var i:int = 0; i < n; i++)
		{
			var childMIME:MIME = MIME(children.getItemAt(i));
			if (childMIME.disposition == "attachment")// ||
				//(childMIME.type == "message" && childMIME.subtype == "rfc822"))
				result.push(childMIME);
		}
		return result;
	}

}
}