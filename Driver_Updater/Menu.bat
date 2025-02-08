@echo off
:: ----------------------------------------------------------
:: Verifica se o script está sendo executado como Administrador
:: ----------------------------------------------------------
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Este script requer privilegios de administrador.
    echo Tentando reiniciar com elevacao...
    powershell -Command "Start-Process '%~f0' -Verb runAs"
    exit /b
)

setlocal EnableDelayedExpansion

:: ----------------------------------------------------------
:: CONFIGURACAO INICIAL
:: ----------------------------------------------------------
set "debug_password=0001"
set "prompt_name=Driver Updater-Menu"
prompt $p$g%prompt_name%$g

:: Diretórios e arquivos (todos relativos à pasta do script)
set "base_dir=%~dp0"
set "driver_repo=%base_dir%drivers"
set "data_dir=%base_dir%data"
set "log_file=%base_dir%log.txt"
set "config_file=%base_dir%config.json"

:: Cria o arquivo de log se nao existir e insere um cabeçalho com data/hora
if not exist "%log_file%" (
    echo Driver Updater Log - %date% %time% > "%log_file%"
)

:: ----------------------------------------------------------
:: MENU PRINCIPAL
:: ----------------------------------------------------------
:menu
cls
echo ========================================
echo        SISTEMA DE ATUALIZACAO DE DRIVERS
echo ========================================
echo 1. Verificar e atualizar drivers
echo 2. Executar em segundo plano
echo 3. Configuracoes
echo 4. Exibir log de atualizacoes
echo 5. Sair
echo.
echo (Opcao oculta: 6 para Debug Mode)
echo.
set "input="
set /p "input=Escolha uma opcao: "

if "%input%"=="6" goto :check_password
if "%input%"=="1" goto :update_drivers
if "%input%"=="2" goto :background_mode
if "%input%"=="3" goto :configurations
if "%input%"=="4" goto :show_log
if "%input%"=="5" exit /b

goto :menu

:: ----------------------------------------------------------
:: VERIFICACAO DE SENHA PARA DEBUG MODE
:: ----------------------------------------------------------
:check_password
set /p "pass=Digite a senha para Debug Mode: "
if "%pass%"=="%debug_password%" goto :debug_mode
echo Senha incorreta.
pause
goto :menu

:: ----------------------------------------------------------
:: MENU DEBUG
:: ----------------------------------------------------------
:debug_mode
cls
echo ========================================
echo          DEBUG/CHEATMODE/BYPASS
echo ========================================
echo 1. Bypass Windows Defender (Adicionar exclusao)
echo 2. Forcar instalacao de drivers (Reinstalar todos)
echo 3. Dump da lista de drivers instalados
echo 4. Beta-Testing Menu
echo 5. Alternar Protecao de Script
echo 6. Voltar ao Menu Principal
echo.
set /p "debug_option=Escolha uma opcao: "
if "%debug_option%"=="1" goto :BypassDefender
if "%debug_option%"=="2" goto :ForceDriverInstall
if "%debug_option%"=="3" goto :DumpDriverList
if "%debug_option%"=="4" goto :beta_testing_menu
if "%debug_option%"=="5" goto :ToggleScriptProtection
if "%debug_option%"=="6" goto :menu
goto :debug_mode

:BypassDefender
cls
echo [DEBUG] Bypass Windows Defender ativado.
:: Adiciona o diretorio do script como exclusao no Windows Defender
powershell -Command "Add-MpPreference -ExclusionPath '%base_dir%'"
echo Exclusao adicionada para o Windows Defender.
pause
goto :debug_mode

:ForceDriverInstall
cls
echo [DEBUG] Forcando reinstalacao de todos os drivers do repositorio...
:: Chama a rotina de atualizacao passando o parametro "force"
call :update_drivers force
pause
goto :debug_mode

:DumpDriverList
cls
echo [DEBUG] Listando drivers instalados (via pnputil):
pnputil /enum-drivers
pause
goto :debug_mode

:ToggleScriptProtection
cls
:: Simulacao de alternar a protecao do script
if not defined script_protection set "script_protection=on"
if "%script_protection%"=="on" (
    set "script_protection=off"
) else (
    set "script_protection=on"
)
echo Protecao de Script agora: %script_protection%
pause
goto :debug_mode

:beta_testing_menu
cls
echo ========================================
echo           BETA-TESTING MENU
echo ========================================
echo 1. Atualizacao automatica continua (modo beta)
echo 2. Feature Avancada 2 (placeholder)
echo 3. Experimental Tool 3 (placeholder)
echo 4. Voltar ao Debug Mode
echo.
set /p "beta_option=Escolha uma opcao: "
if "%beta_option%"=="4" goto :debug_mode
if "%beta_option%"=="1" (
    echo Iniciando atualizacao automatica continua...
    echo Pressione CTRL+C para interromper.
    :auto_update_loop
    call :update_drivers
    timeout /t 120 >nul
    goto :auto_update_loop
)
echo Opcao ainda nao implementada.
pause
goto :beta_testing_menu

:: ----------------------------------------------------------
:: ROTINA DE ATUALIZACAO DE DRIVERS
:: ----------------------------------------------------------
:: Se o parametro "force" for passado, a rotina forca a instalacao
:update_drivers
cls
echo Atualizando drivers...
echo.

:: Verifica se o repositório de drivers existe
if not exist "%driver_repo%" (
    echo Repositorio de drivers nao encontrado: %driver_repo%
    echo Crie a pasta e coloque os arquivos .inf dos drivers.
    pause
    goto :eof
)

set "updated_count=0"
for %%F in ("%driver_repo%\*.inf") do (
    echo Processando driver: %%~nxF
    echo [INFO] Atualizando driver: %%~nxF >> "%log_file%"
    
    :: Instala o driver usando pnputil
    pnputil /add-driver "%%F" /install
    if errorlevel 1 (
        echo [ERRO] Falha ao instalar driver: %%~nxF. Codigo de erro: %errorlevel%
        echo [ERRO] Falha ao instalar driver: %%~nxF >> "%log_file%"
    ) else (
        echo [SUCESSO] Driver instalado: %%~nxF
        echo [SUCESSO] Driver instalado: %%~nxF >> "%log_file%"
        set /a updated_count+=1
    )
    echo.
)
echo Total de drivers instalados/atualizados: !updated_count!
echo Atualizacao concluida em %date% %time% >> "%log_file%"
pause
if "%~1%"=="force" exit /b
goto :menu

:: ----------------------------------------------------------
:: EXECUCAO EM SEGUNDO PLANO
:: ----------------------------------------------------------
:background_mode
cls
echo Executando em segundo plano...
echo Para interromper, feche esta janela ou pressione CTRL+C.
echo.
:background_loop
call :update_drivers
timeout /t 300 >nul
goto :background_loop

:: ----------------------------------------------------------
:: MENU DE CONFIGURACOES
:: ----------------------------------------------------------
:configurations
cls
echo ========================================
echo              CONFIGURACOES
echo ========================================
echo 1. Deletar arquivo PATH (placeholder)
echo 2. Deletar DATA
echo 3. Deletar LOGS
echo 4. Ativar Light Mode
echo 5. Ativar Dark Mode
echo 6. Voltar ao Menu Principal
echo.
set /p "config_option=Escolha uma opcao: "
if "%config_option%"=="1" goto :delete_path
if "%config_option%"=="2" goto :delete_data
if "%config_option%"=="3" goto :delete_logs
if "%config_option%"=="4" goto :light_mode
if "%config_option%"=="5" goto :dark_mode
if "%config_option%"=="6" goto :menu
goto :configurations

:delete_path
cls
echo Deletando arquivo PATH (placeholder)...
if exist "%base_dir%path.txt" (
    del "%base_dir%path.txt" /q
    echo Arquivo path.txt deletado.
) else (
    echo Arquivo path.txt nao encontrado.
)
pause
goto :configurations

:delete_data
cls
echo Deletando pasta DATA...
if exist "%data_dir%" (
    rmdir /s /q "%data_dir%"
    echo Pasta DATA deletada.
) else (
    echo Pasta DATA nao encontrada.
)
pause
goto :configurations

:delete_logs
cls
echo Deletando arquivo de LOG...
if exist "%log_file%" (
    del "%log_file%" /q
    echo Arquivo de log deletado.
) else (
    echo Arquivo de log nao encontrado.
)
pause
goto :configurations

:light_mode
cls
echo Alterando para Light Mode...
:: Define cores: fundo branco (F) e texto preto (0)
color F0
echo Modo Light ativado.
pause
goto :configurations

:dark_mode
cls
echo Alterando para Dark Mode...
:: Define cores: fundo preto (0) e texto branco (F)
color 0F
echo Modo Dark ativado.
pause
goto :configurations

:: ----------------------------------------------------------
:: EXIBIR LOG
:: ----------------------------------------------------------
:show_log
cls
echo ========================================
echo         LOG DE ATUALIZACOES
echo ========================================
type "%log_file%"
echo.
pause
goto :menu

:: ----------------------------------------------------------
:: FINALIZACAO
:: ----------------------------------------------------------
:end
exit /b
