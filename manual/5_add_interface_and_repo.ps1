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
