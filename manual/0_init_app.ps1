$repo_folder = Read-Host "Please enter your the repository folder name: "
$app_name = Read-Host "Please enter your the app/service name: "

New-Item -ItemType "directory" -Path C:\repos\$repo_folder
New-Item -ItemType "directory" -Path C:\repos\$repo_folder\manual

Set-Location C:\repos\$repo_folder
dotnet nuget add source --name nuget.org https://api.nuget.org/v3/index.json
dotnet new webapi -n $app_name

Copy-Item -Path "C:\microservices_steps\*" -Destination "C:\repos\$repo_folder\manual" -Recurse
