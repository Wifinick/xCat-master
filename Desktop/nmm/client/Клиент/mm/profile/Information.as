package mm.profile {
	
	import com.smartfoxserver.v2.entities.data.SFSObject;
	
	public class Information extends mm.profile.Profile {
		
		private var _params:SFSObject;

		public function Information(params:SFSObject) {
			super(params.getUtfString("name"));
			
			_params = params;
			
			// Если профиль инициализирован, инициализируем информацию, если нет - сам профиль
			if(super._page)
			{
				super.init(_params);
			}
			else
			{
				initInformation();
			}
		}
		
		private function initInformation()
		{
			trace("Хуй");
		}

	}
	
}
