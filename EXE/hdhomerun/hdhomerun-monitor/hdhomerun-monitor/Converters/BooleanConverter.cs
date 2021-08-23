using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Camalot.Common.Extensions;
using Newtonsoft.Json;

namespace HdHomeRun.Monitor.Converters {
	public class BooleanConverter : JsonConverter{
		public override void WriteJson ( JsonWriter writer, object value, JsonSerializer serializer ) {

			if(value == null) {
				writer.WriteNull ( );
				return;
			}

			writer.WriteValue ( ( (bool)value ) ? 1 : 0 );
		}

		public override object ReadJson ( JsonReader reader, Type objectType, object existingValue, JsonSerializer serializer ) {
			if(objectType.Is<bool?>()) {
				if(reader.Value == null ) {
					return null;
				}
			}
			return reader.Value.ToString ( ) == "1";
		}

		public override bool CanConvert ( Type objectType ) {
			return objectType.Is<bool>() || objectType.Is<bool?>();
		}
	}
}
