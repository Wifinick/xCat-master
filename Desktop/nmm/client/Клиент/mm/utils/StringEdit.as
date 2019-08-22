package mm.utils {
	
	public class StringEdit {

		public function String() {
			// constructor code
		}
		
		private static const _TRIM_PATTERN:RegExp = /^\s*|\s*$/g;
 
		public static function trim(text:String):String {
			return text.replace(_TRIM_PATTERN, "");
		}

	}
	
}
