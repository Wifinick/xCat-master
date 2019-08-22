package mm {
	//менеджер для работы с датами
	public class Dates {
		public function Dates():void {
		}
		public function IsAllow(From:String):Boolean {
			var Fr:Array = From.split(':');
			return int(Fr[0]) <= 0 && int(Fr[1]) <= 0 && int(Fr[2]) <= 0;
		}
		public function AddSeconds(From:String):String {
			var Fr:Array = From.split(':');
			if(!int(Fr[0]) && !int(Fr[1]) && !int(Fr[2])){
				trace('ОПА!', Fr);
				return Fr.join(':');
			}
			if(!int(Fr[2])){
				Fr[2] = 59;
				if(!int(Fr[1])){
					Fr[0]--;
					Fr[1] = 59;
				}
				else{
					Fr[1]--;
				}
			}
			Fr[2]--;
			if(String(Fr[0]).length == 1) Fr[0] = '0' + Fr[0];
			if(String(Fr[1]).length == 1) Fr[1] = '0' + Fr[1];
			if(String(Fr[2]).length == 1) Fr[2] = '0' + Fr[2];
			return Fr.join(':');
		}
	}
}
