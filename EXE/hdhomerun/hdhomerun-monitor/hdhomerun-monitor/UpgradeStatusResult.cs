using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using HdHomeRun.Monitor.Converters;
using Newtonsoft.Json;

namespace HdHomeRun.Monitor {
	public class UpgradeStatusResult {
		[JsonProperty("UpgradeInProgress")]
		[JsonConverter(typeof( BooleanConverter ))]
		public bool? UpgradeInProgress { get; set; }
		[JsonProperty ( "UpgradeAvailable" )]
		[JsonConverter ( typeof ( BooleanConverter ) )]
		public bool? UpgradeAvailable { get; set; }
	}
}
