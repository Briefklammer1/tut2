#7 create Dtos and dependencies

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