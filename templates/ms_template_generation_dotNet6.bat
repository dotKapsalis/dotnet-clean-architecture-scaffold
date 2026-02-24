@ECHO OFF
SETLOCAL EnableDelayedExpansion
SET argC=0
for %%x in (%*) do SET /A argC+=1
if %argC% NEQ 4 (@ECHO "Invalid argument count, First argument ms_name Second argument root_path")
if %argC% NEQ 4 GOTO :END
SET ms_name=%1
SET root_path=%2

@ECHO.
@ECHO Creating the Solution with name %ms_name% at %root_path%\%ms_name%
dotnet new sln -n %ms_name% -o %root_path%\%ms_name%
@ECHO Solution Created

@ECHO.
@ECHO Creating relative projects
dotnet new classlib -n %ms_name%.Application -o %root_path%\%ms_name%\%ms_name%.Application -f net6.0
dotnet new classlib -n %ms_name%.Infrastructure -o %root_path%\%ms_name%\%ms_name%.Infrastructure -f net6.0
dotnet new classlib -n %ms_name%.Contracts -o %root_path%\%ms_name%\%ms_name%.Contracts -f net6.0
dotnet new classlib -n %ms_name%.Domain -o %root_path%\%ms_name%\%ms_name%.Domain -f net6.0
dotnet new webapi -n %ms_name%.API -o %root_path%\%ms_name%\%ms_name%.API --no-https -f net6.0
@ECHO Created relative projects

@ECHO.
@ECHO Adding Projects to solution
dotnet sln %root_path%\%ms_name%\%ms_name%.sln add  %root_path%\%ms_name%\%ms_name%.Application
dotnet sln %root_path%\%ms_name%\%ms_name%.sln add  %root_path%\%ms_name%\%ms_name%.Infrastructure
dotnet sln %root_path%\%ms_name%\%ms_name%.sln add  %root_path%\%ms_name%\%ms_name%.Contracts
dotnet sln %root_path%\%ms_name%\%ms_name%.sln add  %root_path%\%ms_name%\%ms_name%.Domain
dotnet sln %root_path%\%ms_name%\%ms_name%.sln add  %root_path%\%ms_name%\%ms_name%.API
@ECHO Added Projects to solution

@ECHO.
@ECHO Adding dependencies
dotnet add %root_path%\%ms_name%\%ms_name%.API\%ms_name%.API.csproj reference %root_path%\%ms_name%\%ms_name%.Infrastructure\%ms_name%.Infrastructure.csproj
dotnet add %root_path%\%ms_name%\%ms_name%.Application\%ms_name%.Application.csproj reference %root_path%\%ms_name%\%ms_name%.Domain\%ms_name%.Domain.csproj
dotnet add %root_path%\%ms_name%\%ms_name%.Application\%ms_name%.Application.csproj reference %root_path%\%ms_name%\%ms_name%.Contracts\%ms_name%.Contracts.csproj
dotnet add %root_path%\%ms_name%\%ms_name%.Infrastructure\%ms_name%.Infrastructure.csproj reference %root_path%\%ms_name%\%ms_name%.Application\%ms_name%.Application.csproj
@ECHO Added dependencies


@ECHO.
@ECHO Should I create folder for the database pipelines?[y/n]
set choice=
set /P c=

if /I "%c%" EQU "n" goto:DoNotCreateSubFoldersFlow
if /I "%c%" EQU "y" goto:CreateSubFoldersFlow
goto:choice

:CreateSubFoldersFlow
set tmpfoldername=SqlScripts
@ECHO Create physical folder %root_path%\%ms_name%\%tmpfoldername%
mkdir %root_path%\%ms_name%\%tmpfoldername%

set tmpfoldername=PostDeployment
@ECHO Create physical folder %root_path%\%ms_name%\SqlScripts\%tmpfoldername%
mkdir %root_path%\%ms_name%\SqlScripts\%tmpfoldername%

set tmpfoldername=EnsureErrorCodes.sql
@ECHO Create physical file %root_path%\%ms_name%\SqlScripts\PostDeployment\%tmpfoldername%
type nul > %root_path%\%ms_name%\SqlScripts\PostDeployment\%tmpfoldername%


:DoNotCreateSubFoldersFlow
@ECHO.
@ECHO Process completed


ENDLOCAL
:END




