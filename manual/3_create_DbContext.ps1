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