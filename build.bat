@call setenv
@call clear

@%HRB_BIN%\harbour src\main.prg /q /i%HDROIDGUI%\src\include /i%HRB_INC% /ojni\
@if errorlevel 1 goto end

@set NDK_LIBS_OUT=lib
@set SRC_FILES=main.c
%NDK_HOME%\prebuilt\windows-x86_64\bin\make.exe -f %NDK_HOME%/build/core/build-local.mk %* >a1.out 2>a2.out
@if exist lib\%NDK_TARGET%\libh4droid.so goto comp
@echo Errors while compiling C sources
@goto end

:comp
call %BUILD_TOOLS%/aapt.exe package -f -m -S res -J src -M AndroidManifest.xml -I %ANDROID_JAR%
@if errorlevel 1 goto end

@rem compile, convert class dex
@rem call %JAVA_HOME%/bin/javac -d obj -cp %ANDROID_JAR%;%HDROIDGUI%\hdroidgui.jar -sourcepath src src/%PACKAGE_PATH%/*.java
call %JAVA_HOME%/bin/javac -d obj -cp %ANDROID_JAR%;%HDROIDGUI%\libs -sourcepath src src/%PACKAGE_PATH%/*.java
@if errorlevel 1 goto end

call %BUILD_TOOLS%/dx.bat --dex --output=bin/classes.dex obj %HDROIDGUI%\libs
@if errorlevel 1 goto end

@rem create APK
call %BUILD_TOOLS%/aapt.exe package -f -M AndroidManifest.xml -S res -I %ANDROID_JAR% -F bin/%APPNAME%.unsigned.apk bin

call %BUILD_TOOLS%/aapt.exe add %DEV_HOME%/bin/%APPNAME%.unsigned.apk lib/%NDK_TARGET%/libharbour.so
@if errorlevel 1 goto end

call %BUILD_TOOLS%/aapt.exe add %DEV_HOME%/bin/%APPNAME%.unsigned.apk lib/%NDK_TARGET%/libh4droid.so
@rem sign APK
call %JAVA_HOME%/bin/keytool -genkey -v -keystore myrelease.keystore -alias key2 -keyalg RSA -keysize 2048 -validity 10000 -storepass calcpass -keypass calcpass -dname "CN=Alex K, O=Harbour, C=RU"
call %JAVA_HOME%/bin/jarsigner -sigalg SHA1withRSA -digestalg SHA1 -keystore myrelease.keystore -storepass calcpass -keypass calcpass -signedjar bin/%APPNAME%.signed.apk bin/%APPNAME%.unsigned.apk key2
%BUILD_TOOLS%/zipalign -v 4 bin/%APPNAME%.signed.apk bin/%APPNAME%.apk
:end

@pause