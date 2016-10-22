@echo off

:: ########################################################
:: # Setting up Environment...
:: ########################################################

set BK_ROOT=%~dp0

:: for these we need the bin dirs in PATH
set SCRIPTSDIR=%BK_ROOT%tools\scripts
set DEVKITDIR=%BK_ROOT%tools\ruby-devkit
set CONEMUDIR=%BK_ROOT%tools\conemu
set ATOMDIR=%BK_ROOT%tools\atom\resources\cli
set APMDIR=%BK_ROOT%tools\atom\resources\app\apm\bin
set PUTTYDIR=%BK_ROOT%tools\putty
set TERRAFORMDIR=%BK_ROOT%tools\terraform
set RUBYDIR=%BK_ROOT%tools\ruby
set AWSDIR=%BK_ROOT%tools\aws-cli
set GNUDIR=%BK_ROOT%tools\wget
set WINPATHS=C:\Windows\system32;C:\Windows;C:\Windows\System32\Wbem;C:\Windows\System32\WindowsPowerShell\v1.0

:: use portable git, looks for %HOME%\.gitconfig
set GITDIR=%BK_ROOT%tools\git
set HOME=%BK_ROOT%home

:: set ATOM_HOME to make it devpack-local
set ATOM_HOME=%HOME%\.atom

:: set atom as the default EDITOR
set EDITOR=atom.sh --wait

:: don't let VirtualBox use %HOME% instead of %USERPROFILE%,
:: otherwise it would become confused when W:\ is unmounted
set VBOX_USER_HOME=%USERPROFILE%

:: add recent root certificates to prevent SSL errors on Windows, see:
:: https://gist.github.com/fnichol/867550
set SSL_CERT_FILE=%HOME%\cacert.pem
:: set %RI_DEVKIT$ env var and add DEVKIT to the PATH
call %DEVKITDIR%\devkitvars.bat
set PATH=%SCRIPTSDIR%;%RUBYDIR%\bin;%TERRAFORMDIR%;%GNUDIR%;%AWSDIR%;%GITDIR%\cmd;%GITDIR%;%KDIFF3DIR%;%CONEMUDIR%;%ATOMDIR%;%APMDIR%;%PUTTYDIR%;%VBOX_MSI_INSTALL_PATH%;%VBOX_INSTALL_PATH%;%WINPATHS%

:: command aliases
@doskey vi=atom.cmd $*
@doskey be=bundle exec $*
