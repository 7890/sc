#!/bin/bash

#build java libraries to use soundcould api
#only javac needed - all dependencies included

#//tb/1510

#  !! needs replace with known good for bourne shell
shopt -s globstar

FULLPATH="`pwd`/$0"
DIR=`dirname "$FULLPATH"`

BUILD_="$DIR"/_build
ARCHIVE_="$DIR"/archive

####rm -rf JSON-java java-api-wrapper _build

mkdir -p "$BUILD_"

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

cp "$ARCHIVE_"/httpcomponents-client-4.5.1-bin.tar.gz "$BUILD_"
cp "$ARCHIVE_"/httpcomponents-core-4.4.3-bin.tar.gz "$BUILD_"
cp "$ARCHIVE_"/JSON-java-e7f4eb5f67048642e24634db8ec8c7e6f29c0c22.tar.gz "$BUILD_"
cp "$ARCHIVE_"/java-api-wrapper-375f17e661e640a6dde57188a2d56234f8785c7e.tar.gz "$BUILD_"

cur=`pwd`
cd "$BUILD_"
echo "===extracting"
tar xfz httpcomponents-client-4.5.1-bin.tar.gz
tar xfz httpcomponents-core-4.4.3-bin.tar.gz
tar xfz JSON-java-e7f4eb5f67048642e24634db8ec8c7e6f29c0c22.tar.gz
tar xfz java-api-wrapper-375f17e661e640a6dde57188a2d56234f8785c7e.tar.gz

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

#echo "===cloning git"
#cd "$cur"

echo "===build JSON-java"
#git clone https://github.com/douglascrockford/JSON-java
cd JSON-java-e7f4eb5f67048642e24634db8ec8c7e6f29c0c22
#git pull
#git reset --hard HEAD

chmod 644 *.java

mkdir -p src/org/json
cp *.java src/org/json
cat JSONObject.java | sed 's/IllegalArgumentException | NullPointerException e/Exception e/g' \
	> src/org/json/JSONObject.java

cat JSONArray.java | sed 's/IllegalArgumentException | NullPointerException e/Exception e/g' \
	> src/org/json/JSONArray.java

rm *.java

echo "===compiling"
echo javac -source 1.6 -target 1.6 -nowarn -classpath "$BUILD_" -sourcepath src/ -d "$BUILD_" src/org/json/*.java
javac -source 1.6 -target 1.6 -nowarn -classpath "$BUILD_" -sourcepath src/ -d "$BUILD_" src/org/json/*.java

cd "$BUILD_"
jar cf org.json.jar org/

#cd "$cur"

#git clone https://github.com/soundcloud/java-api-wrapper
echo "===build java-api-wrapper"
cd java-api-wrapper-375f17e661e640a6dde57188a2d56234f8785c7e
#echo "===updating git"
#git pull
#git reset --hard HEAD


###
echo "===applying patches"
cp "$cur"/diffs/Request.java.diff .
patch -p1 < Request.java.diff

echo "===compiling"

echo javac -source 1.6 -target 1.6 \
	-cp "$BUILD_":"$BUILD_"/httpcore-4.4.3.jar:"$BUILD_"/httpclient-4.5.1.jar:"$BUILD_"/httpmime-4.5.1.jar:"$BUILD_"/commons-logging-1.2.jar:"$BUILD_"/org.json.jar \
	-sourcepath src/main/java \
	-d "$BUILD_" src/main/java/**/*.java

javac -source 1.6 -target 1.6 \
	-cp "$BUILD_":"$BUILD_"/httpcore-4.4.3.jar:"$BUILD_"/httpclient-4.5.1.jar:"$BUILD_"/httpmime-4.5.1.jar:"$BUILD_"/commons-logging-1.2.jar:"$BUILD_"/org.json.jar \
	-sourcepath src/main/java \
	-d "$BUILD_" src/main/java/**/*.java

#find src/main/java/ -name *.java -exec javac -source 1.6 -target 1.6 \
#...
#	-d "$BUILD_" {} \;

echo javac -source 1.6 -target 1.6 \
	-cp "$BUILD_":"$BUILD_"/httpcore-4.4.3.jar:"$BUILD_"/httpclient-4.5.1.jar:"$BUILD_"/httpmime-4.5.1.jar:"$BUILD_"/commons-logging-1.2.jar:"$BUILD_"/org.json.jar \
	-sourcepath src/examples/java \
	-d "$BUILD_" src/examples/java/**/*.java

javac -source 1.6 -target 1.6 \
	-cp "$BUILD_":"$BUILD_"/httpcore-4.4.3.jar:"$BUILD_"/httpclient-4.5.1.jar:"$BUILD_"/httpcomponents-client-4.5.1/lib/httpmime-4.5.1.jar:"$BUILD_"/commons-logging-1.2.jar:"$BUILD_"/org.json.jar \
	-sourcepath src/examples/java \
	-d "$BUILD_" src/examples/java/**/*.java


cd "$BUILD_"
jar cf com.soundcloud.api.jar com/
#cp com.soundcloud.api.jar "$BUILD_"

}
#end prepare

###
for tool in java javac jar sed
        do checkAvail "$tool"; done

prepare

#echo "===compiling"
#echo javac -source 1.6 -target 1.6 -cp "$BUILD_":"$BUILD_"/httpcore-4.4.3.jar:"$BUILD_"/httpclient-4.5.1.jar:"$BUILD_"/httpmime-4.5.1.jar:"$BUILD_"/commons-logging-1.2.jar:"$BUILD_"/org.json.jar:"$BUILD_"/com.soundcloud.api.jar \
#	-sourcepath src \
#	-d "$BUILD_" src/*.java

#javac -source 1.6 -target 1.6 -cp "$BUILD_":"$BUILD_"/httpcore-4.4.3.jar:"$BUILD_"/httpclient-4.5.1.jar:"$BUILD_"/httpmime-4.5.1.jar:"$BUILD_"/org.json.jar:"$BUILD_"/commons-logging-1.2.jar:"$BUILD_"/com.soundcloud.api.jar \
#	-sourcepath src \
#	-d "$BUILD_" src/*.java

###
#rm -rf "$BUILD_"/com
#rm -rf "$BUILD_"/org

echo "======test manually"

#echo java -cp "$BUILD_":"$BUILD_"/httpcore-4.4.3.jar:"$BUILD_"/httpclient-4.5.1.jar:"$BUILD_"/httpmime-4.5.1.jar:"$BUILD_"/commons-logging-1.2.jar:"$BUILD_"/org.json.jar:"$BUILD_"/com.soundcloud.api.jar \
#	Test

echo java -cp "$BUILD_":"$BUILD_"/httpcore-4.4.3.jar:"$BUILD_"/httpclient-4.5.1.jar:"$BUILD_"/httpmime-4.5.1.jar:"$BUILD_"/commons-logging-1.2.jar:"$BUILD_"/org.json.jar:"$BUILD_"/com.soundcloud.api.jar \
	com.soundcloud.api.examples.CreateWrapper client_id client_secret username password

#echo java -cp "$BUILD_":"$BUILD_"/httpcore-4.4.3.jar:"$BUILD_"/httpclient-4.5.1.jar:"$BUILD_"/httpmime-4.5.1.jar:"$BUILD_"/commons-logging-1.2.jar:"$BUILD_"/org.json.jar:"$BUILD_"/com.soundcloud.api.jar \
#	com.soundcloud.api.examples.GetResource '/tracks?q=tango&limit=3'
