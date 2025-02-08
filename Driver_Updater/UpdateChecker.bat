@echo off
setlocal EnableDelayedExpansion

:: ===========================================================
:: CONFIGURATION & LOG FILE SETUP
:: ===========================================================
:: Path to the configuration file
set "config_file=%~dp0config.json"

:: Path to the update log file
set "update_log=%~dp0update_log.txt"

:: Function: log_event
:: Usage: call :log_event "TYPE" "Message"
:log_event
    set "log_type=%~1"
    set "log_message=%~2"
    for /f "tokens=1-3 delims=/ " %%a in ('echo %date%') do set "curDate=%%a/%%b/%%c"
    for /f "tokens=1-2 delims=: " %%a in ('echo %time%') do set "curTime=%%a:%%b"
    echo [%curDate% %curTime%] [%log_type%] %log_message% >> "%update_log%"
goto :eof

:: ===========================================================
:: READ CONFIG VALUES FROM config.json
:: ===========================================================
:: Read the current version
for /f "tokens=2 delims=: " %%a in ('findstr /r /c:"\"version\"" "%config_file%"') do (
    set "current_version=%%a"
    set "current_version=!current_version:,=!"
    set "current_version=!current_version:"=!"
)
call :log_event INFO "Current version from config.json: !current_version!"

:: Read the update URL
for /f "tokens=2 delims=: " %%a in ('findstr /r /c:"\"update_url\"" "%config_file%"') do (
    set "update_url=%%a"
    set "update_url=!update_url:,=!"
    set "update_url=!update_url:"=!"
)
call :log_event INFO "Update URL from config.json: !update_url!"

:: Read the maximum number of retries
for /f "tokens=2 delims=: " %%a in ('findstr /r /c:"\"max_retries\"" "%config_file%"') do (
    set "max_retries=%%a"
    set "max_retries=!max_retries:,=!"
    set "max_retries=!max_retries:"=!"
)
call :log_event INFO "Max retries set to: !max_retries!"

:: Read the timeout value (in seconds)
for /f "tokens=2 delims=: " %%a in ('findstr /r /c:"\"timeout\"" "%config_file%"') do (
    set "timeout=%%a"
    set "timeout=!timeout:,=!"
    set "timeout=!timeout:"=!"
)
call :log_event INFO "Timeout set to: !timeout! seconds"

:: ===========================================================
:: DOWNLOAD UPDATE FILE WITH RETRY LOGIC
:: ===========================================================
:download_update
set "attempt=1"
:retry_download
echo Tentando baixar a atualização (Tentativa !attempt! de !max_retries!)...
call :log_event INFO "Attempt !attempt! to download update from !update_url!"
powershell -command "Invoke-WebRequest -Uri '!update_url!' -OutFile '%~dp0latest_update.zip'" >nul 2>&1
if ERRORLEVEL 1 (
    echo Erro ao baixar a atualização. Verificando tentativas...
    call :log_event ERROR "Failed to download update on attempt !attempt!."
    if !attempt! lss !max_retries! (
        set /a attempt+=1
        timeout /t !timeout! >nul
        goto retry_download
    ) else (
        echo Falha ao baixar a atualização após !max_retries! tentativas.
        call :log_event ERROR "Failed to download update after !max_retries! attempts."
        exit /b 1
    )
) else (
    call :log_event SUCCESS "Update downloaded successfully on attempt !attempt!."
)

:: ===========================================================
:: UNZIP THE DOWNLOADED UPDATE FILE
:: ===========================================================
echo Descompactando arquivos...
call :log_event INFO "Starting extraction of latest_update.zip."
powershell -command "Expand-Archive -Path '%~dp0latest_update.zip' -DestinationPath '%~dp0update' -Force" >nul 2>&1
if ERRORLEVEL 1 (
    echo Erro ao descompactar os arquivos.
    call :log_event ERROR "Failed to extract update archive."
    exit /b 1
) else (
    call :log_event SUCCESS "Files extracted successfully."
)

:: ===========================================================
:: FINAL MESSAGE
:: ===========================================================
echo Atualização para a versão !current_version! concluída com sucesso.
call :log_event SUCCESS "Update process completed successfully for version !current_version!."

endlocal


:: Registrar a atualização em um arquivo de log
echo Atualização para a versão !current_version! realizada em %date% %time% >> "%~dp0update_log.txt"

pause
