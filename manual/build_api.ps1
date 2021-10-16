$repo_folder = Read-Host "Please enter your the repository folder name: "
$app_name = Read-Host "Please enter your the app/service name: "

New-Item -ItemType "directory" -Path C:\repos\$repo_folder
New-Item -ItemType "directory" -Path C:\repos\$repo_folder\manual

Set-Location C:\repos\$repo_folder
dotnet nuget add source --name nuget.org https://api.nuget.org/v3/index.json
dotnet new webapi -n $app_name

Copy-Item -Path "C:\microservices_steps\*" -Destination "C:\repos\$repo_folder\manual" -Recurse

#1 add_packages

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

#2 add_models

new-item -ItemType "directory" -path ..\$app_name\Models
$model_name = Read-Host "Please enter your the model class name"
$columns = @()
do {

$input_ = (Read-Host "Please enter your Columns of the form 'col1 type1'")
if ($input_ -ne '') {$columns += $input_}
}
until ($input_ -eq 'end')

$col_content = @()

foreach ($col in $columns[0..($columns.count-2)]) {
     
$col_content += "public " + $col.Split(' ')[1] + " " + $col.Split(' ')[0] + " " + "{ get; set;}`n`t   "

}

$model_file_name = $model_name + ".cs"

$models_content = "using System.ComponentModel.DataAnnotations;

namespace $app_name.Models
{
    public class $model_name
    {
        [Key]
        public int Id { get; set;}

        $col_content
    }
}"
Add-Content -Path ..\$app_name\Models\$model_file_name -value $models_content

#3 create DbContext

New-Item -ItemType "directory" ..\$app_name\Data
$dbcontext_class_name = $model_name + "DbContext"
$dbcontext_file_name = $dbcontext_class_name + ".cs"
$dbset_name = $model_name + "s"

$DbContext_content = "using Microsoft.EntityFrameworkCore;

namespace $app_name.Data
{   
    using $app_name.Models;

    public class $dbcontext_class_name : DbContext
    {
        public $dbcontext_class_name(DbContextOptions<$dbcontext_class_name> options) : base(options) {}

        public DbSet<$model_name> $dbset_name { get; set;}
    }
}"
Add-Content -Path ..\$app_name\Data\$dbcontext_file_name -value $DbContext_content

# add DbContext to startup

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
            "using $app_name.Data;"
        }
    } | Set-Content $fileName

# add interaces and repository

$interface_name = "I" + $model_name + "Repo"
$interface_file_name = $interface_name + ".cs"

$model_name_lower = $model_name.ToLower()

$interface_content = "using System.Collections.Generic;

namespace $app_name.Data
{  
    using $app_name.Models; 

    public interface $interface_name
    {
        bool SaveChanges();

        IEnumerable<$model_name> GetAll();
        $model_name GetById(int id);
        void Create($model_name $model_name_lower);
    }
}"
Add-Content -Path ..\$app_name\Data\$interface_file_name -value $interface_content

$repo_name = $model_name + "Repo"
$repo_file_name = $repo_name + ".cs"

$repo_content = "namespace $app_name.Data
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using $app_name.Models;

    public class $repo_name : $interface_name
    {
        private readonly $dbcontext_class_name _context;

        public $repo_name($dbcontext_class_name context)
        {
            _context = context;
        }

        public void Create($model_name $model_name_lower)
        {
            if($model_name_lower == null)
            {
                throw new ArgumentNullException(nameof($model_name_lower));
            }

            _context.$dbset_name.Add($model_name_lower);
        }

        public IEnumerable<$model_name> GetAll()
        {
            return _context.$dbset_name.ToList();
        }

        public $model_name GetById(int id)
        {
            return _context.$dbset_name.FirstOrDefault(p => p.Id == id);
        }

        public bool SaveChanges()
        {
            return (_context.SaveChanges() >= 0);
        }
    }
}"


Add-Content -Path ..\$app_name\Data\$repo_file_name -value $repo_content

# add to services in Startup.cs

(Get-Content ..\$app_name\Startup.cs) | 
    Foreach-Object {
        $_ # send the current line to output
        if ($_ -match "services.AddControllers") 
        {
            #Add Lines after the selected pattern 
            "`t `t `tservices.AddScoped<$interface_name, $repo_name>();"
        }
    } | Set-Content ..\$app_name\Startup.cs

# create PrepDb

$params_content = @()
foreach ($col in $columns[0..($columns.count-2)]) {
if($col.Split(' ')[1] -eq "int") {
    $random = Get-Random
} 
else {
    $random_ = [char[]](65..90) | Get-Random -Count 5
    $random = '"' + $random_ + '"'
}
$params_content += $col.Split(' ')[0] + "=" + $random + ","
}

$seeding_str = '"--> Seeding data..."'
$havedata_str = '"--> We already have data"'

$prebDb_content = "using System;
using System.Linq;
using Microsoft.AspNetCore.Builder;
using Microsoft.Extensions.DependencyInjection;
using $app_name.Models;

namespace $app_name.Data
{
        public static class PrepDb
        {
            public static void PrepPopulation(IApplicationBuilder app)
            {
                using( var serviceScope = app.ApplicationServices.CreateScope())
                {
                    SeedData(serviceScope.ServiceProvider.GetService<$dbcontext_class_name>());
                }
            }

            private static void SeedData($dbcontext_class_name context)
            {
                if(!context.$dbset_name.Any())
                {
                    Console.WriteLine($seeding_str);
                    context.$dbset_name.AddRange(
                        new $model_name() {$params_content}
                    );

                    context.SaveChanges();
                }
                else
                {
                    Console.WriteLine($havedata_str);
                }
            }
        }
}"
Add-Content -Path ..\$app_name\Data\PrepDb.cs -value $prebDb_content

# create Dtos and dependencies

new-item -ItemType "directory" ..\$app_name\Dtos
$dto_read_class_name = $model_name + "ReadDto"
$dto_read_content="namespace $app_name.Dtos
{
    public class $dto_read_class_name
    {
        public int Id { get; set;}
        $col_content
    }
}"

Add-Content -Path ..\$app_name\DTos\$dto_read_class_name.cs -value $dto_read_content

$dto_create_class_name = $model_name + "CreateDto"
$dto_create_content="namespace $app_name.Dtos
{
    public class $dto_create_class_name
    {
        $col_content
    }
}"

Add-Content -Path ..\$app_name\DTos\$dto_create_class_name.cs -value $dto_create_content

#model and the two dtos dont know each other, need automapper/dependency injection here and a profile

(Get-Content ..\$app_name\Startup.cs) | 
    Foreach-Object {
        $_ # send the current line to output
        if ($_ -match "services.AddControllers") 
        {
            #Add Lines after the selected pattern 
            "`t `t `tservices.AddAutoMapper(AppDomain.CurrentDomain.GetAssemblies());"
        }
    } | Set-Content ..\$app_name\Startup.cs

new-item -ItemType "directory" ..\$app_name\Profiles
$model_profil_class_name = $model_name + "Profile"

$profile_content ="namespace $app_name.Profiles
{   
    using AutoMapper;
    using $app_name.Models;
    using $app_name.Dtos;

    public class $model_profil_class_name : Profile
    {
        public $model_profil_class_name()
        {
            // source -> target here: source is the model and target the ReadDto
            CreateMap<$model_name, $dto_read_class_name>();
            CreateMap<$dto_create_class_name, $model_name>();

        }
    }
}"

Add-Content -Path ..\$app_name\Profiles\$model_profil_class_name.cs -value $profile_content

# add controller

$route_name = '"api/[controller]"'
$controller_class_name = $model_name + "Controller"
$model_item = $model_name.ToLower() + "Item"
$model_var = $model_name.ToLower() + "Model"
$read_dto_var = $dto_read_class_name.ToLower()
$create_dto_var = $dto_create_class_name.ToLower()
$getting_str = '"--> Getting..."'
$id_str = '"{id}"'
$getbyid_str = '"GetById"'
$controller_content="using System;
using System.Collections.Generic;
using AutoMapper;
using Microsoft.AspNetCore.Mvc;
using $app_name.Dtos;
using $app_name.Data;
using $app_name.Models;

namespace $app_name.Controllers
{
    [Route($route_name)]
    [ApiController]
    public class $controller_class_name : ControllerBase
    {
        private readonly $interface_name _repository;
        private readonly IMapper _mapper;

        public $controller_class_name($interface_name repository, IMapper mapper)
        {
            _repository = repository;
            _mapper = mapper;
        }
        
        [HttpGet]
        public ActionResult<IEnumerable<$dto_read_class_name>> Get()
        {
            Console.WriteLine($getting_str);

            var $model_item = _repository.GetAll();
            return Ok(_mapper.Map<IEnumerable<$dto_read_class_name>>($model_item));
        }

        [HttpGet($id_str, Name = $getbyid_str)]
        public ActionResult<$dto_read_class_name> GetById(int id)
        {
            var $model_item = _repository.GetById(id);
            if ($model_item != null)
            {
                return Ok(_mapper.Map<$dto_read_class_name>($model_item));
            }

            return NotFound();
        }

        [HttpPost]
        public ActionResult<$dto_read_class_name> Create($dto_create_class_name $create_dto_var)
        {
            var $model_var = _mapper.Map<$model_name>($create_dto_var);
            _repository.Create($model_var);
            _repository.SaveChanges();

            var $read_dto_var = _mapper.Map<$dto_read_class_name>($model_var);

            return CreatedAtRoute(nameof(GetById), new {Id=$read_dto_var.Id}, $read_dto_var);
        }
    }
}"

Add-Content -Path ..\$app_name\Controllers\$controller_class_name.cs -value $controller_content

Read-Host -Prompt "Press Enter to exit"
