Set-Location c:\repos
$repo_folder_ = Get-ChildItem | Sort-Object LastWriteTime -Descending | Select-Object -First 1
$repo_folder = $repo_folder_.name

$app_name_ = Get-ChildItem -Path ..\repos\$repo_folder | Where-Object { $_.Name -notmatch 'manual' -and $_.Name -notmatch ".vscode"}
$app_name = $app_name_.name

Set-Location C:\repos\$repo_folder\$app_name

try {
    dotnet add package AutoMapper.Extensions.Microsoft.DependencyInjection
    dotnet add package Microsoft.EntityFrameworkCore
    dotnet add package Microsoft.EntityFrameworkCore.Design
    dotnet add package Microsoft.EntityFrameworkCore.InMemory
    dotnet add package Microsoft.EntityFrameworkCore.SqlServer
}
catch {
    "Installations fehlgeschlagen, try: 'dotnet nuget add source --name nuget.org https://api.nuget.org/v3/index.json
                                         dotnet restore'"
    
}
#This files are only examples and can be removed.
Remove-Item -path ..\$app_name\WeatherForecast.cs
Remove-Item -path ..\$app_name\Controllers\WeatherForecastController.cs
