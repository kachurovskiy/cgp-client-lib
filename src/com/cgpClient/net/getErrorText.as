package com.cgpClient.net
{

/**
 *  Retreives error text from Error or &lt;response/&gt; XML.
 * 
 *  <p><strong>Example:</strong>
 *  <listing>
 *  function someAction():void
 *  {
 *      Net.ximss(&lt;folderOpen ... /&gt;, dataCallBack, responseCallBack); 
 *  }
 * 
 *  function responseCallBack(object:Object):void
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