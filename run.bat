@call setenv

call %ADB% uninstall %PACKAGE%
call %ADB% install bin/%APPNAME%.apk

call %ADB% shell logcat -c
call %ADB% shell am start -n %PACKAGE%/%PACKAGE%.%MAIN_CLASS%
call %ADB% shell logcat Harbour:I *:S > log.txt
rem call %ADB% shell logcat > log.txt