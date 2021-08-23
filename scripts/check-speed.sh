#!/usr/bin/env bash
get_opts() {
        while getopts ":u" opt; do
          case $opt in
                        u) export opt_upload="1";
                        ;;
                        \?) echo "Invalid option -$OPTARG" >&2;
                        exit 1;
                        ;;
                esac;
        done;

        return 0;
};

get_opts "$@";

UPLOAD_ACTION="${opt_upload:-"0"}";

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
        MESSAGE="ERROR: $DATA";
        RESULT=2;
        echo "$RESULT:0:$MESSAGE";
        exit 0;
        return;
fi

DLOW=100;
DMID=400;

ULOW=5;
UMID=25;

PHIGH=50;
PMID=25;

if [ "$(echo $DLOW'>'${DOWNLOAD:-"0"} | bc -l)" == 1 ] && [ "$UPLOAD_ACTION" == "0" ]; then
        RESULT=2;
        MESSAGE="ERROR: Download Speed below $DLOW Mbit/s (Ping: $PING ms | Download: $DOWNLOAD Mbit/s | Upload: $UPLOAD Mbit/s)";
elif [ "$(echo $DMID'>'${DOWNLOAD:-"0"} | bc -l)" == 1 ] && [ "$UPLOAD_ACTION" == "0" ]; then
        RESULT=1;
        MESSAGE="WARNING: Download Speed below $DMID Mbit/s (Ping: $PING ms | Download: $DOWNLOAD Mbit/s | Upload: $UPLOAD Mbit/s)";
elif [ "$(echo $ULOW'>'${UPLOAD:-"0"} | bc -l)" == 1 ] && [ "$UPLOAD_ACTION" == "1" ]; then
        RESULT=2;
        MESSAGE="ERROR: Upload Speed below $ULOW Mbit/s (Ping: $PING ms | Download: $DOWNLOAD Mbit/s | Upload: $UPLOAD Mbit/s)";
elif [ "$(echo $UMID'>'${UPLOAD:-"0"} | bc -l)" == 1 ] && [ "$UPLOAD_ACTION" == "1" ]; then
        RESULT=1;
        MESSAGE="WARNING: Upload Speed below $UMID Mbit/s (Ping: $PING ms | Download: $DOWNLOAD Mbit/s | Upload: $UPLOAD Mbit/s)";
elif [ "$(echo ${PING:-"100"}'>'$PHIGH | bc -l)" == 1 ]; then
        RESULT=2;
        MESSAGE="ERROR: Ping is above $PHIGH ms (Ping: $PING ms | Download: $DOWNLOAD Mbit/s | Upload: $UPLOAD Mbit/s)";
elif [ "$(echo ${PING:-"100"}'>'$PMID | bc -l)" == 1 ]; then
        RESULT=1;
        MESSAGE="WARNING: Ping is above $PMID ms (Ping: $PING ms | Download: $DOWNLOAD Mbit/s | Upload: $UPLOAD Mbit/s)";
else
        RESULT=0;
        MESSAGE="OK: Ping: $PING ms | Download: $DOWNLOAD Mbit/s | Upload: $UPLOAD Mbit/s";
fi

if [ "$UPLOAD_ACTION" == "0" ]; then
        echo "$RESULT:$DOWNLOAD:$MESSAGE";
else
        echo "$RESULT:$UPLOAD:$MESSAGE";
fi