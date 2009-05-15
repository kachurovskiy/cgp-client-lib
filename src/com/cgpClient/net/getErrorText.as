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

package com.cgpClient.net
{

/**
 *  Retreives error text from Error or &lt;response/&gt; XML.
 * 
 *  <p><strong>Example:</strong>
 *  <listing>
 *  function someAction():void
 *  {
 *      Net.ximss(&lt;folderOpen ... /&gt;, dataCallback, responseCallback); 
 *  }
 * 
 *  function responseCallback(object:Object):void
 *  {
 *      var text:String = getErrorText(object);
 *      if (text)
 *      {
 *          // show error to user
 *          errorLabel.text = text;
 *      }
 *      else
 *      {
 *          // request completed successfuly
 *      }
 *  }</listing></p>
 * 
 *  @param object Argument that was passed in your response callback.
 * 
 *  @return Error text, if any.
 */
public function getErrorText(object:Object):String
{
	var text:String;
	if (object is Error)
		text = Error(object).message;
	else if (object is XML && XML(object).hasOwnProperty("@errorText"))
		text = XML(object).@errorText;
	return text;
}
	
}