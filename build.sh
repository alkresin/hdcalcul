#!/bin/bash

. ./setenv.sh

./clear.sh

$HRB_BIN/harbour src/main.prg -q -i$HRB_INC -i$HDROIDGUI/src/include -i$HRB_INC -ojni/
if [ "$?" -eq 0 ]
then
export NDK_LIBS_OUT=lib
$NDK_HOME/prebuilt/linux-x86/bin/make -f $NDK_HOME/build/core/build-local.mk "$@" >a1.out 2>a2.out
  if [ "$?" -eq 0 ]
  then
    echo "compile java sources"
    $BUILD_TOOLS/aapt package -f -m -S res -J src -M AndroidManifest.xml -I $ANDROID_JAR
    javac -d obj -cp $ANDROID_JAR:$HDROIDGUI/hdroidgui.jar -sourcepath src src/$PACKAGE_PATH/*.java
    if [ "$?" -eq 0 ]
    then
      echo "convert to .dex"
      $BUILD_TOOLS/dx --dex --output=bin/classes.dex obj $HDROIDGUI/libs

      if [ "$?" -eq 0 ]
      then
        $BUILD_TOOLS/aapt package -f -M AndroidManifest.xml -S res -I $ANDROID_JAR -F bin/$APPNAME.unsigned.apk bin

        $BUILD_TOOLS/aapt add $DEV_HOME/bin/$APPNAME.unsigned.apk lib/armeabi/libharbour.so

        if [ "$?" -eq 0 ]
        then
          $BUILD_TOOLS/aapt add $DEV_HOME/bin/$APPNAME.unsigned.apk lib/armeabi/libh4droid.so

          $BUILD_TOOLS/aapt add bin/$APPNAME.unsigned.apk assets/main.hrb
          echo "sign APK"
          keytool -genkey -v -keystore myrelease.keystore -alias key2 -keyalg RSA -keysize 2048 -validity 10000 -storepass calcpass -keypass calcpass -dname "CN=Alex K, O=Harbour, C=RU"
          jarsigner -sigalg SHA1withRSA -digestalg SHA1 -keystore myrelease.keystore -storepass calcpass -keypass calcpass -signedjar bin/$APPNAME.signed.apk bin/$APPNAME.unsigned.apk key2
          $BUILD_TOOLS/zipalign -v 4 bin/$APPNAME.signed.apk bin/$APPNAME.apk
        fi
      else
        echo "error creating dex file"
      fi
    else
      echo "java sources compiling error"
    fi
  else
    echo "C sources compiling error"
  fi

fi
read -n1 -r -p "Press any key to continue..."