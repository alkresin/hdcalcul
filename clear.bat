@call setenv
@del src\%PACKAGE_PATH%\R.java
@del /q assets\*.*
@del /q *.out
@rmdir /s /q bin
@md bin
@rmdir /s /q obj
@md obj
@rmdir /s /q lib
@md lib
@rmdir /s /q libs
@md libs