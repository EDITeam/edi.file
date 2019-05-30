@echo off 
echo. 运行本文件前请将本放置在与JDK里面和bin文件夹在同一个目录 
pause 
@set path=%path%;%systemroot%;%systemroot%\system32; 
@reg add "HKLM\system\controlset001\control\session manager\environment" /v JAVA_HOME /t reg_sz /d "%cd%" /f 
@reg add "HKLM\system\controlset001\control\session manager\environment" /v PATH /t reg_expand_sz /d ".;%%JAVA_HOME%%\bin;%path%" /f 
@reg add "HKLM\system\controlset001\control\session manager\environment" /v CLASSPATH /t reg_sz /d "%%JAVA_HOME%%\lib\dt.jar;%%JAVA_HOME%%\lib\tools.jar;." /f 
pause 
