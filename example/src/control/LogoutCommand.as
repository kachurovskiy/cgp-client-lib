package control
{
import com.cgpClient.net.Net;

import model.Model;
	
public class LogoutCommand
{
	public function start():void
	{
		Net.ximss(<bye/>, null, responseCallBack);
	}
	
	private function responseCallBack(object:Object):void
	{
		Model.instance.setDefaultValues();
		
		// Not sure we really need to show such errors to user
	}

}
}