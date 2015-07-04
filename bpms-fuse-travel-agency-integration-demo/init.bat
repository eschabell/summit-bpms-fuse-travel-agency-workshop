@ECHO OFF
setlocal

set PROJECT_HOME=%~dp0
set DEMO=JBoss BPM Suite & JBoss Fuse Travel Agency Integration Demo
set AUTHORS=Christina Lin, Eric D. Schabell
set PROJECT=git@github.com:jbossdemocentral/bpms-fuse-travel-agency-integration-demo.git
set TARGET_DIR=%PROJECT_HOME%target
set JBOSS_HOME=%PROJECT_HOME%target\jboss-eap-6.4
set SERVER_DIR=%JBOSS_HOME%\standalone\deployments\
set SERVER_CONF=%JBOSS_HOME%\standalone\configuration\
set SERVER_CONF_FUSE=%FUSE_HOME%\etc\
set SERVER_BIN=%JBOSS_HOME%\bin
set SRC_DIR=%PROJECT_HOME%installs
set PRJ_DIR=%PROJECT_HOME%projects\brms-fuse-integration
set SUPPORT_DIR=%PROJECT_HOME%\support
set FUSE=jboss-fuse-6.2.0.redhat-133
set FUSE_ZIP=jboss-fuse-full-6.2.0.redhat-133.zip
set BPMS=jboss-bpmsuite-6.1.0.GA-installer.jar
set EAP=jboss-eap-6.4.0-installer.jar
set FUSE_HOME=$DEMO_HOME/$FUSE
set FUSE_PROJECT=projects/fuseparent
set FUSE_SERVER_CONF=$FUSE_HOME/etc
set FUSE_SERVER_SYSTEM=$FUSE_HOME/system
set FUSE_SERVER_BIN=$FUSE_HOME/bin
set BPM_VERSION=6.1
set FUSE_VERSION=6.2

REM wipe screen.
cls 
exit
echo.
echo #########################################################################
echo ##                                                                     ##   
echo ##  Setting up the %DEMO%                                         ##
echo ##                                                                     ##   
echo ##                                                                     ##   
echo ##   ####   ####    #   #    ###             ####  #  #   ###  ####    ##
echo ##   #   #  #   #  # # # #  #         #      #     #  #  #     #       ##
echo ##   ####   ####   #  #  #   ##      ###     ###   #  #   ##   ###     ##
echo ##   #   #  #      #     #     #      #      #     #  #     #  #       ##
echo ##   ####   #      #     #  ###              #     ####  ###   ####    ##
echo ##                                                                     ##   
echo ##                                                                     ##   
echo ##  brought to you by,                                                 ##   
echo ##                     %AUTHORS%                     ##
echo ##                        %AUTHORS2%               ##
echo ##                                                                     ##   
echo ##  %PROJECT%            ##
echo ##                                                                     ##   
echo #########################################################################
echo.


call where mvn >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
	echo Maven Not Installed. Setup Cannot Continue
	GOTO :EOF
)

REM # make some checks first before proceeding. 
if exist %SRC_DIR%\%FUSE_ZIP% (
	echo Fuse sources are present...
	echo.
) else (
	echo Need to download %FUSE_ZIP% package from the Customer Support Portal
	echo and place it in the %SRC_DIR% directory to proceed...
	echo.
	GOTO :EOF
)

if exist %SRC_DIR%\%BPMS% (
	echo BPM sources are present...
	echo.
) else (
	echo Need to download %BPMS% package from the Customer Support Portal
	echo and place it in the %SRC_DIR% directory to proceed...
	echo.
	GOTO :EOF
)

REM Move the old JBoss instance, if it exists, to the OLD position.
if exist %TARGET_DIR% (
         echo - existing JBoss product install removed...
         echo.
         rmdir /s /q %TARGET_DIR%
 )

REM Run installer.
echo Product installer running now...
echo.
call java -jar %SRC_DIR%/%BPMS% %SUPPORT_DIR%\installation-bpms -variablefile %SUPPORT_DIR%\installation-bpms.variables

if not "%ERRORLEVEL%" == "0" (
	echo Error Occurred During %PRODUCT% Installation!
	echo.
	GOTO :EOF
)

if exist %PROJECT_HOME%\target (
	REM Unzip the JBoss FUSE instance.
	echo.
	echo Installing JBoss FUSE %FUSE_VERSION%
	echo.
	cscript /nologo %SUPPORT_DIR%\windows\unzip.vbs %SRC_DIR%\%FUSE_ZIP% %PROJECT_HOME%\target
) else (
	echo.
	echo Missing target directory, stopping installation.
	echo.
	GOTO :EOF
)

echo   - enabling demo accounts role setup in application-roles.properties file...
echo.
xcopy /Y /Q "%SUPPORT_DIR%\application-roles.properties" "%SERVER_CONF%"

echo   - setting up demo projects..."
echo.
xcopy /Y /Q /S "%SUPPORT_DIR%\bpm-suite-demo-niogit" "%SERVER_BIN%\.niogit\" 

echo   - setting up standalone.xml configuration adjustments...
echo.
xcopy /Y /Q "%SUPPORT_DIR%\standalone.xml" "%SERVER_CONF%"

echo   - enabling demo accounts logins in users.properties file...
echo.
xcopy /Y /Q "%SUPPORT_DIR%\users.properties" "%SERVER_CONF_FUSE%"


REM Optional: uncomment this to install mock data for BPM Suite.
REM
REM echo - setting up mock bpm dashboard data...
REM xcopy /Y /Q "%SUPPORT_DIR%\1000_jbpm_demo_h2.sql" "%SERVER_DIR%\dashbuilder.war\WEB-INF\etc\sql\"
REM echo.

echo Now going to build the projects...
echo.
cd "%PRJ_DIR%"
call mvn clean install

if %ERRORLEVEL% NEQ 0 (
	echo.
	echo Maven Build Failed! Setup cannot continue.
	cd "%PROJECT_HOME%"
GOTO :EOF
)

cd "%PROJECT_HOME%"

echo.
echo ===============================================================================
echo =                                                                             =
echo =  You can now start the workshop by following the rest of the                =
echo =  instructions in:                                                           =
echo =                                                                             =
echo =     Summit-Lab-Tavel-Agency-Start.odt                                       = 
echo =                                                                             =
echo =     Summit-Lab-Tavel-Agency-Start.pdf                                       =
echo =                                                                             =
echo =   %DEMO% Setup Complete.                                               =
echo ===============================================================================
echo.

