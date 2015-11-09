#!/bin/bash

#build java libraries to use soundcould api
#only javac needed - all dependencies included

#//tb/1510

FULLPATH="`pwd`/$0"
DIR=`dirname "$FULLPATH"`

BUILD_="$DIR"/_build
ARCHIVE_="$DIR"/archive

####rm -rf JSON-java java-api-wrapper _build

mkdir -p "$BUILD_"

#linux / osx different mktemp call
TMPFILE=`mktemp 2>/dev/null || mktemp -t /tmp`

JAVAC="javac -source 1.6 -target 1.6 -nowarn"

#========================================================================
checkAvail()
{
	which "$1" >/dev/null 2>&1
	ret=$?
	if [ $ret -ne 0 ]
	then
		echo "tool \"$1\" not found. please install"
		exit 1
	fi
}

#========================================================================
prepare()
{
echo "= preparing build"
cp "$ARCHIVE_"/httpcomponents-client-4.5.1-bin.tar.gz "$BUILD_"
cp "$ARCHIVE_"/httpcomponents-core-4.4.3-bin.tar.gz "$BUILD_"
cp "$ARCHIVE_"/JSON-java-e7f4eb5f67048642e24634db8ec8c7e6f29c0c22.tar.gz "$BUILD_"
cp "$ARCHIVE_"/java-api-wrapper-375f17e661e640a6dde57188a2d56234f8785c7e.tar.gz "$BUILD_"
cp "$ARCHIVE_"/json-simple-a8b94b79b697df64b23428c27d65d6a187e9ebf9.tar.gz "$BUILD_"
cp "$ARCHIVE_"/gson-f8105f0006fb81a15be1ff8eefe7a17488a29fe8.tar.gz "$BUILD_"
cp "$ARCHIVE_"/soundcloud-java-library-ce05aac18ab5fb2a420e32a81986b67da50885a5.tar.gz "$BUILD_"

cd "$BUILD_"
tar xfz httpcomponents-client-4.5.1-bin.tar.gz
tar xfz httpcomponents-core-4.4.3-bin.tar.gz
tar xfz JSON-java-e7f4eb5f67048642e24634db8ec8c7e6f29c0c22.tar.gz
tar xfz java-api-wrapper-375f17e661e640a6dde57188a2d56234f8785c7e.tar.gz
tar xfz json-simple-a8b94b79b697df64b23428c27d65d6a187e9ebf9.tar.gz
tar xfz gson-f8105f0006fb81a15be1ff8eefe7a17488a29fe8.tar.gz
tar xfz soundcloud-java-library-ce05aac18ab5fb2a420e32a81986b67da50885a5.tar.gz

cp httpcomponents-core-4.4.3/lib/httpcore-4.4.3.jar .
cp httpcomponents-client-4.5.1/lib/httpclient-4.5.1.jar .
cp httpcomponents-client-4.5.1/lib/httpmime-4.5.1.jar .
cp httpcomponents-client-4.5.1/lib/commons-logging-1.2.jar .

rm -rf httpcomponents-core-4.4.3
rm -rf httpcomponents-client-4.5.1
rm -f httpcomponents-client-4.5.1-bin.tar.gz
rm -f httpcomponents-core-4.4.3-bin.tar.gz
rm -f JSON-java-e7f4eb5f67048642e24634db8ec8c7e6f29c0c22.tar.gz
rm -f java-api-wrapper-375f17e661e640a6dde57188a2d56234f8785c7e.tar.gz
rm -f json-simple-a8b94b79b697df64b23428c27d65d6a187e9ebf9.tar.gz
rm -f gson-f8105f0006fb81a15be1ff8eefe7a17488a29fe8.tar.gz
rm -f soundcloud-java-library-ce05aac18ab5fb2a420e32a81986b67da50885a5.tar.gz

echo "= building JSON-java"
#git clone https://github.com/douglascrockford/JSON-java
cd JSON-java-e7f4eb5f67048642e24634db8ec8c7e6f29c0c22

chmod 644 *.java

mkdir -p src/org/json
cp *.java src/org/json

echo "= patching file src/org/json/JSONObject.java"
cat JSONObject.java | sed 's/IllegalArgumentException | NullPointerException e/Exception e/g' \
	> src/org/json/JSONObject.java

echo "= patching file src/org/json/JSONArray.java"
cat JSONArray.java | sed 's/IllegalArgumentException | NullPointerException e/Exception e/g' \
	> src/org/json/JSONArray.java

rm *.java

echo "= compiling sources"
$JAVAC -classpath "$BUILD_" -sourcepath src/ -d "$BUILD_" src/org/json/*.java

cd "$BUILD_"
#echo "= creating jar org.json.jar"
#jar cf org.json.jar org/

#git clone https://github.com/soundcloud/java-api-wrapper
echo "= building java-api-wrapper"
cd java-api-wrapper-375f17e661e640a6dde57188a2d56234f8785c7e

###
cp "$DIR"/diffs/Request.java.diff .

echo -n "= "
patch -p1 < Request.java.diff

find src/main/java/ -name *.java > "$TMPFILE"
find src/examples/java/ -name *.java >> "$TMPFILE"
echo "= compiling sources"
$JAVAC \
	-cp "$BUILD_":"$BUILD_"/httpcore-4.4.3.jar:"$BUILD_"/httpclient-4.5.1.jar:"$BUILD_"/httpmime-4.5.1.jar:"$BUILD_"/commons-logging-1.2.jar \
	-sourcepath src/main/java \
	-d "$BUILD_" @"$TMPFILE" 2>&1 | grep -v "^Note: "

cd "$BUILD_"
#echo "= creating jar com.soundcloud.api.jar"
#jar cf com.soundcloud.api.jar com/

echo "= building json-simple"
#https://github.com/fangyidong/json-simple
cd json-simple-a8b94b79b697df64b23428c27d65d6a187e9ebf9

find src/main/java/ -name *.java > "$TMPFILE"
echo "= compiling sources"
$JAVAC \
	-cp "$BUILD_" \
	-sourcepath src/main/java \
	-d "$BUILD_" @"$TMPFILE" 2>&1 | grep -v "^Note: "

cd "$BUILD_"
#echo "= creating jar org.json.combined.jar"
#jar cf org.json.combined.jar org

echo "= building gson"
#https://github.com/google/gson.git
cd gson-f8105f0006fb81a15be1ff8eefe7a17488a29fe8

find gson/src/main/java/ -name *.java > "$TMPFILE"
echo "= compiling sources"
$JAVAC \
	-cp "$BUILD_" \
	-sourcepath gson/src/main/java \
	-d "$BUILD_" @"$TMPFILE" 2>&1 | grep -v "^Note: "

cd "$BUILD_"
#echo "= creating com.google.gson.jar"
#jar cf com.google.gson.jar com

echo "= building soundcloud-java-library"
#https://github.com/nok/soundcloud-java-library
cd soundcloud-java-library-ce05aac18ab5fb2a420e32a81986b67da50885a5

find src/main/java/ -name *.java > "$TMPFILE"
echo "= compiling sources"
$JAVAC \
	-cp "$BUILD_":"$BUILD_"/httpcore-4.4.3.jar:"$BUILD_"/httpclient-4.5.1.jar:"$BUILD_"/httpmime-4.5.1.jar:"$BUILD_"/commons-logging-1.2.jar \
	-sourcepath src/main/java \
	-d "$BUILD_" @"$TMPFILE" 2>&1 | grep -v "^Note: "

cd "$BUILD_"
#echo "= creating de.voidplus.soundcloud.jar"
#jar cf de.voidplus.soundcloud.jar de

#echo "= creating jar"
#jar cf combined.jar com org de

}
#end prepare

echo "= checking tools availability"
for tool in java javac jar sed
        do checkAvail "$tool"; done

prepare

cd "$DIR"

#echo "= compiling application"
#$JAVAC -cp "$BUILD_":"$BUILD_"/httpcore-4.4.3.jar:"$BUILD_"/httpclient-4.5.1.jar:"$BUILD_"/httpmime-4.5.1.jar:"$BUILD_"/org.json.jar:"$BUILD_"/commons-logging-1.2.jar:"$BUILD_"/com.soundcloud.api.jar \
#	-sourcepath src \
#	-d "$BUILD_" src/*.java

rm -f "$TMPFILE"

echo "= done"
echo ""

#echo "example call:"

#echo java -cp \"$BUILD_\":\"$BUILD_\"/httpcore-4.4.3.jar:\"$BUILD_\"/httpclient-4.5.1.jar:\"$BUILD_\"/httpmime-4.5.1.jar:\"$BUILD_\"/commons-logging-1.2.jar:\"$BUILD_\"/org.json.jar:\"$BUILD_\"/com.soundcloud.api.jar \
#	Test

#echo java -cp \"$BUILD_\":\"$BUILD_\"/httpcore-4.4.3.jar:\"$BUILD_\"/httpclient-4.5.1.jar:\"$BUILD_\"/httpmime-4.5.1.jar:\"$BUILD_\"/commons-logging-1.2.jar:\"$BUILD_\"/org.json.jar:\"$BUILD_\"/com.soundcloud.api.jar \
#	com.soundcloud.api.examples.CreateWrapper client_id client_secret username password

#echo java -cp \"$BUILD_\":\"$BUILD_\"/httpcore-4.4.3.jar:\"$BUILD_\"/httpclient-4.5.1.jar:\"$BUILD_\"/httpmime-4.5.1.jar:\"$BUILD_\"/commons-logging-1.2.jar:\"$BUILD_\"/org.json.jar:\"$BUILD_\"/com.soundcloud.api.jar \
#	com.soundcloud.api.examples.GetResource '/tracks?q=tango&limit=3'
