@echo off
setlocal EnableDelayedExpansion

:: Caminho do arquivo de configuração
set "config_file=config.json"

:: Função para ler a versão atual do config.json
for /f "tokens=2 delims=: " %%a in ('findstr /r /c:"\"version\"" "%config_file%"') do (
    set "current_version=%%a"
    set "current_version=!current_version:,=!"
    set "current_version=!current_version:"=!"
)

:: URL de atualização (lido do config.json)
for /f "tokens=2 delims=: " %%a in ('findstr /r /c:"\"update_url\"" "%config_file%"') do (
    set "update_url=%%a"
    set "update_url=!update_url:,=!"
    set "update_url=!update_url:"=!"
)

:: Lê max_retries e timeout do config.json
for /f "tokens=2 delims=: " %%a in ('findstr /r /c:"\"max_retries\"" "%config_file%"') do (
    set "max_retries=%%a"
    set "max_retries=!max_retries:,=!"
    set "max_retries=!max_retries:"=!"
)

for /f "tokens=2 delims=: " %%a in ('findstr /r /c:"\"timeout\"" "%config_file%"') do (
    set "timeout=%%a"
    set "timeout=!timeout:,=!"
    set "timeout=!timeout:"=!"
)

:: Função para baixar a última versão
:download_update
set "attempt=1"
:retry_download
echo Tentando baixar a atualização (Tentativa !attempt! de !max_retries!)...
powershell -command "Invoke-WebRequest -Uri '!update_url!' -OutFile '%~dp0latest_update.zip'"
if ERRORLEVEL 1 (
    echo Erro ao baixar a atualização. Verificando tentativas...
    if !attempt! lss !max_retries! (
        set /a attempt+=1
        timeout /t !timeout! >nul
        goto retry_download
    ) else (
        echo Falha ao baixar a atualização após !max_retries! tentativas.
        exit /b 1
    )
)

:: Descompactar e substituir os arquivos
echo Descompactando arquivos...
powershell -command "Expand-Archive -Path '%~dp0latest_update.zip' -DestinationPath '%~dp0update' -Force"
if ERRORLEVEL 1 (
    echo Erro ao descompactar os arquivos.
    exit /b 1
)

:: Exibir mensagem de atualização bem-sucedida
echo Atualização para a versão !current_version! concluída com sucesso.

:: Registrar a atualização em um arquivo de log
echo Atualização para a versão !current_version! realizada em %date% %time% >> "%~dp0update_log.txt"

pause
