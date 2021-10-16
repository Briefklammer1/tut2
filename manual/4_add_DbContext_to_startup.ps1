$lineNumber = 29
$textToAdd = "`t `t `tservices.AddDbContext<$dbcontext_class_name>" + '(options => options.UseInMemoryDatabase("InMem"));'
$filename = "C:\repos\$repo_folder\$app_name\Startup.cs"
$fileContent = Get-Content $filename
$fileContent[$lineNumber-1] += $textToAdd
$fileContent | Set-Content $filename

(Get-Content $fileName) | 
    Foreach-Object {
        $_ # send the current line to output
        if ($_ -match "using Microsoft.AspNetCore.Mvc;") 
        {
            #Add Lines after the selected pattern 
            "using Microsoft.EntityFrameworkCore;"
        }
    } | Set-Content $fileName

(Get-Content $fileName) | 
    Foreach-Object {
        $_ # send the current line to output
        if ($_ -match "using Microsoft.OpenApi.Models;") 
        {
            #Add Lines after the selected pattern 
            "using PlatformService.Data;"
        }
    } | Set-Content $fileName