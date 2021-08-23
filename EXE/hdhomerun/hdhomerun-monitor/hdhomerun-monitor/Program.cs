using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Text;
using System.Threading.Tasks;
using Camalot.Common.Extensions;
using Camalot.Common.Serialization;
using Newtonsoft.Json;

namespace HdHomeRun.Monitor {
	class Program {
		static int Main ( string[] arguments ) {
			try {
				var args = new Camalot.Common.Arguments ( arguments );
				var wait = args.ContainsKey("w","wait");
				var host = "tv.bit13.local";
				if ( args.ContainsKey ( "h", "host", "hostname" ) ) {
					host = args["h", "host", "hostname"];
				}
				var action = "upgrade";
				if ( args.ContainsKey ( "a", "action" ) ) {
					action = args["a", "action"];
				}
				var ssl = args.ContainsKey ( "ssl", "useSSL", "s" );
				var scheme = ssl ? "https" : "http";

				ServicePointManager.ServerCertificateValidationCallback = delegate { return true; };
				var result = 0;
				switch ( action ) {
					case "tuners":
						result = TunerStatus ( scheme, host );
						break;
					case "upgrade":
						result =  UpgradeStatus ( scheme, host );
						break;
					case "channels":
						result = GetChannels ( scheme, host );
						break;
					default:
						Console.WriteLine ( $"1:Unknown Action '{action}'" );
						result = 1;
						break;
				}
				if(wait) {
					Console.Write ( "{PRESS ENTER TO EXIT}" );
					Console.Read ( );
				}
				return result;
			} catch ( Exception ex ) {
				Console.WriteLine ( $"99:{ex.Message}" );
				return 1;
			}
		}

		private static int GetChannels(string scheme, string host) {
			var url = $"{scheme}://{host}/lineup.json?show=found";
			var result = JsonRetriever.Get<List<GuideChannel>> ( url );
			Console.WriteLine ( result.Count == 0 ? "0:No Channels Found." : $"{result.Count}:{result.Count} Channels Found" );
			return result.Count == 0 ? 1 : 0;
		}

		private static int UpgradeStatus ( string scheme, string host ) {
			var url = $"{scheme}://{host}/upgrade_status.json";
			var result = JsonRetriever.Get<UpgradeStatusResult> ( url );
			if ( result.UpgradeAvailable.HasValue ) {
				Console.WriteLine ( result.UpgradeAvailable.Value ? "1:Firmware Update Available" : "0:Firmware up to date" );
				return result.UpgradeAvailable.Value ? 1 : 0;
			}
			Console.WriteLine ( "0:Firmware up to date" );
			return 0;
		}

		private static int TunerStatus ( string scheme, string host ) {
			var url = $"{scheme}://{host}/tuners.html";
			var result = WebRetriever.Get ( url );
			var pattern = @"<tr>\s*<td>([^<]+)</td>\s*<td>([^<]+)</td></tr>";
			var inUse = 0;
			var totalTuners = 0;
			result.Match ( pattern ).ForEach ( x => {
				if ( x.Groups[2].Value != "none" && x.Groups[2].Value != "not in use" ) {
					inUse++;
				}
				totalTuners++;
			} );
			var available = totalTuners - inUse;
			var tunersString = available == 1 ? "tuner" : "tuners";
			Console.WriteLine ( $"{inUse}:{inUse} of {totalTuners} {tunersString} in use." );
			return available > 0 ? 0 : 1;
		}
	}
}
