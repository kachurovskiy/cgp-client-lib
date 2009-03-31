package control
{

import com.cgpClient.fileStorage.FileStorage;

import model.Model;
	
public class LoginCompleteAction
{
	
	public function start():void
	{
		Model.instance.fileStorage = new FileStorage("private");
	}

}
}