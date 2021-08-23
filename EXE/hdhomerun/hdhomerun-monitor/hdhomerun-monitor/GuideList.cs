using Newtonsoft.Json;

namespace HdHomeRun.Monitor {

	//{"GuideNumber":"2.1","GuideName":"CBS2-HD","VideoCodec":"MPEG2","AudioCodec":"AC3","HD":1,"URL":"http://192.168.2.53:5004/auto/v2.1"}
	public class GuideChannel {
		[JsonProperty( "GuideNumber" )]
		public string GuideNumber { get; set; }
		[JsonProperty ( "GuideName" )]
		public string GuideName { get; set; }
		[JsonProperty ( "VideoCodec" )]
		public string VideoCodec { get; set; }
		[JsonProperty ( "AudioCodec" )]
		public string AudioCodec { get; set; }
		[JsonProperty ( "HD" )]
		public int HD { get; set; }
		[JsonIgnore]
		public bool IsHD {
			get {
				return HD > 0;
			}
		}
		[JsonProperty ( "URL" )]
		public string URL { get; set; }
	}
}
