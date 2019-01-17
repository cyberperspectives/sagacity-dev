@echo off
set v=1.4.0

title Sagacity Development %v%

REM File: install-dev.bat
REM Author: Ryan Prather, Jeff Odegard
REM Purpose: Windows / XAMPP Installation Script
REM Created: Jan 5, 2015

REM Portions Copyright 2016-2019: CyberPerspectives, LLC, All rights reserved
REM Released under the Apache v2.0 License

REM Portions Copyright (c) 2012-2015, Salient Federal Solutions
REM Portions Copyright (c) 2008-2011, Science Applications International Corporation (SAIC)
REM Released under Modified BSD License

REM See license.txt for details

REM Change Log:
REM - Jan 5, 2015 - File created
REM - Sep 1, 2016 - Copyright updated, added comments and file header
REM - Oct 7, 2016 - Copying Windows / XAMPP config.xml
REM - Nov 14, 2016 - Converted xcopy for config file to copy
REM - Nov 18, 2016 - Changed file moves to copies, removed deleting existing *.cgi & *.pl script in the CGI_PATH and deleting CONF folder
REM - Dec 12, 2016 - Removed pthreads library because it is no longer needed.
REM				  Rename existing Apache, MySQL/mariaDB, and PHP config files to .old before copying hardened files.
REM - Dec 13, 2016 - Fixed syntax of the rename command
REM - Dec 19, 2016 - Fixed copy syntax for config.xml file
REM - Jan 30, 2017 - Fixed error with copy of config-xampp-win.xml to config.xml where it required full path
REM - Apr 5, 2017 - Added mkdir for \xampp\php\logs directory (not included when installed)
REM - Jun 27, 2017 - Removed copy cgi-bin contents
REM - Sep 19, 2018 - Deleting unnecessary C:\xampp\htdocs folder.
REM - Oct 3, 2018 - Redirected deletion of htdocs folder to nul
REM - Nov 27, 2018 - Added php-dev.ini to conf folder and added prompts to allow for development installation
REM - Jan 10, 2019 - broke out the dev installation from install.bat and streamlined the installation process.

@echo The Sagacity dev configuration installs and enables php xdebug used for troubleshooting and development work.  
@echo.
@echo NOTE: The dev configuration will *noticably* impact Sagacity's performance.
@echo       *** For a production environment, please use install.bat instead! ***
@echo.

@echo For your dev installation we also recommend installing QCacheGrindWin from
@echo.
@echo       https://sourceforge.net/projects/qcachegrindwin/
@echo.

@echo.
@echo What would you like to do?
@echo.
@echo 1 = git clone the latest development repository
@echo 2 = I've already downloaded a zip of the repo
@echo 3 = I've already downloaded the repo, just need to move it
@echo 4 = I've already downloaded the repo and it's already in the correct path (c:\xampp\www)

set /p result="Answer? "

if /i "%result%"=="1" goto gitclone
if /i "%result%"=="2" goto unziprepo
if /i "%result%"=="3" goto moverepo
if /i "%result%"=="4" goto commonexit 

:gitclone
if exist "c:\xampp\www" (
    del /S /F /Q c:\xampp\www
)

if exist "c:\program files\git\cmd\git.exe" (
	git clone -b v%v% https://github.com/cyberperspectives/sagacity c:\xampp\www
) else (
    @echo.
    @echo Unable to clone the repository, you do not have a git client installed.
    @echo             https://gitforwindows.org/ is a good option
    @echo.
)
goto commonexit

:unziprepo
set /p result="What is the absolute path to the zip file you downloaded? "
call :UnZipFile "c:\xampp" "%result%"

goto commonexit

:moverepo
set /p result="What is the absolute path to the current Sagacity source folder? "

move "%result%" c:\xampp\www 
goto commonexit

:commonexit

@echo    - Create PHP log folder
mkdir c:\xampp\php\logs

@echo    - Copy Apache, MySQL/mariaDB, and PHP configuration files
@echo    - Renaming the original config files to *.old.

rename c:\xampp\mysql\bin\my.ini my.ini.old
copy c:\xampp\www\conf\my.ini c:\xampp\mysql\bin\

@echo    - Installing MySQL service
c:\xampp\mysql\bin\mysqld --install mysql --defaults-file="c:\xampp\mysql\bin\my.ini"
net start mysql

rename c:\xampp\apache\conf\httpd.conf httpd.conf.old
copy c:\xampp\www\conf\httpd.conf c:\xampp\apache\conf
rename c:\xampp\apache\conf\extra\httpd-ssl.conf httpd-ssl.conf.old
copy c:\xampp\www\conf\httpd-ssl.conf c:\xampp\apache\conf\extra
rename c:\xampp\apache\conf\extra\httpd-xampp.conf httpd-xampp.conf.old
copy c:\xampp\www\conf\httpd-xampp.conf c:\xampp\apache\conf\extra

rename c:\xampp\php\php.ini php.ini.old

copy php-dev.ini c:\xampp\php\php.ini
copy php_xdebug-2.6.0-7.2-vc15.dll c:\xampp\php\ext\php_xdebug-2.6.0-7.2-vc15.dll

@echo    - Deleting unnecessary C:\xampp\htdocs folder.
del /F /S /Q c:\xampp\htdocs 1>nul

@echo    - Installing Apache service
c:\xampp\apache\bin\httpd -k install
net start apache2.4

@echo.
@echo Thank you for installing Sagacity.  We want to know what you think!
@echo Please contact us at https://www.cyberperspectives.com/contact_us
@echo.
@echo If you like this tool, please tell a friend or co-worker!
@echo.
@echo Press enter to continue setup with http://localhost/setup.php

pause 1>nul

start http://localhost
exit /B

:UnZipFile <ExtractTo> <newzipfile>
set vbs="%temp%\_.vbs"
if exist %vbs% del /f /q %vbs%
>%vbs%  echo Set fso = CreateObject("Scripting.FileSystemObject")
>>%vbs% echo If NOT fso.FolderExists(%1) Then
>>%vbs% echo fso.CreateFolder(%1)
>>%vbs% echo End If
>>%vbs% echo set objShell = CreateObject("Shell.Application")
>>%vbs% echo set FilesInZip=objShell.NameSpace(%2).items
>>%vbs% echo objShell.NameSpace(%1).CopyHere(FilesInZip)
>>%vbs% echo Set fso = Nothing
>>%vbs% echo Set objShell = Nothing
cscript //nologo %vbs%
if exist %vbs% del /f /q %vbs%

ren c:\xampp\sagacity-%v% www
