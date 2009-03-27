package model
{
[Bindable]
public class Model
{
	
	//--------------------------------------------------------------------------
	//
	//  Static properties
	//
	//--------------------------------------------------------------------------

	private static var _instance:Model;
	
	public static function get instance():Model
	{
		if (!_instance)
			_instance = new Model();
		
		return _instance;
	}

	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------

	public var loginUserName:String;

	public var host:String;

	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------
	
	public function Model()
	{
		if (_instance)
			throw new Error("Singleton exception");
	}

}
}