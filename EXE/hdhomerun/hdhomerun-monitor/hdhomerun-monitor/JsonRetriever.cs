using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Text;
using System.Threading.Tasks;
using Camalot.Common.Serialization;
using Newtonsoft.Json;

namespace HdHomeRun.Monitor {
	public class JsonRetriever {

		public static T Get<T> ( string url ) {
			var req = WebRequest.CreateHttp ( url );


			req.Timeout = 5 * 1000;
			using ( var resp = req.GetResponse ( ) ) {
				using ( var strm = resp.GetResponseStream ( ) ) {
					using ( var sr = new StreamReader ( strm ) ) {
						var jsr = new JsonTextReader ( sr );
						//Console.WriteLine ( sr.ReadToEnd ( ) );
						var result = JsonSerializationBuilder.Build ( ).Create ( ).Deserialize<T> ( jsr );

						return result;
					}
				}
			}
		}
	}

	public class WebRetriever {

		public static string Get ( string url ) {
			var req = WebRequest.CreateHttp ( url );


			req.Timeout = 5 * 1000;
			using ( var resp = req.GetResponse ( ) ) {
				using ( var strm = resp.GetResponseStream ( ) ) {
					using ( var sr = new StreamReader ( strm ) ) {
						return sr.ReadToEnd ( );
					}
				}
			}
		}
	}
}
