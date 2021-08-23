#!/usr/bin/env bash
# get_opts() {
#         while getopts ":u" opt; do
#           case $opt in
#                         u) export opt_upload="1";
#                         ;;
#                         \?) echo "Invalid option -$OPTARG" >&2;
#                         exit 1;
#                         ;;
#                 esac;
#         done;

#         return 0;
# };

# get_opts "$@";


DATA=$(docker run --rm camalot/speedtest-cli --simple);
EXIT_CODE="$?";
# (>&2 echo "$DATA");
DOWNLOAD=$(awk '/^(Download:\s+)([0-9]+\.[0-9]+)\s+Mbit\/s$/ {print $2}' <<< "${DATA}");
# (>&2 echo "Download: $DOWNLOAD Mbit/s");
UPLOAD=$(awk '/^(Upload:\s+)([0-9]+\.[0-9]+)\s+Mbit\/s$/ {print $2}' <<< "${DATA}");
# (>&2 echo "Upload: $UPLOAD Mbit/s");
PING=$(awk '/^(Ping:\s+)([0-9]+\.[0-9]+)\s+ms$/ {print $2}' <<< "${DATA}");
# (>&2 echo "Ping: $PING ms");

if [ "$EXIT_CODE" -ne "0" ]; then
  echo "<prtg>";
  echo "<error>$EXIT_CODE</error>";
  echo "<text>ERROR: $DATA</text>";
  echo "</prtg>";
  return;
fi

DLOW=100;
DMID=400;

ULOW=5;
UMID=25;

PHIGH=50;
PMID=25;


echo "<prtg>";
echo "<text></text>";
echo "<result>";
echo "<channel>Download Speed</channel>";
echo "<value>$DOWNLOAD</value>";
echo "<unit>Custom</unit>";
echo "<customunit>Mbps</customunit>";
echo "<limitminwarning>$DMID</limitminwarning>";
echo "<limitminerror>$DLOW</limitminerror>";
echo "<float>1</float>";
echo "</result>";
echo "<result>";
echo "<channel>Upload Speed</channel>";
echo "<value>$UPLOAD</value>";
echo "<limitminwarning>$UMID</limitminwarning>"
echo "<limitminerror>$ULOW</limitminerror>";
echo "<unit>Custom</unit>";
echo "<customunit>Mbps</customunit>";
echo "<float>1</float>";
echo "</result>";
echo "<result>";
echo "<channel>Ping</channel>";
echo "<value>$PING</value>";
echo "<unit>Custom</unit>";
echo "<customunit>ms</customunit>";
echo "<limitmaxwarning>$PMID</limitmaxwarning>";
echo "<limitmaxerror>$PHIGH</limitmaxerror>";
echo "<float>1</float>";
echo "</result>";
echo "</prtg>";

exit 0;