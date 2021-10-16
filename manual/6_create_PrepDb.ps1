
$params_content = @()
foreach ($col in $columns[0..($columns.count-2)]) {
if($col.Split(' ')[1] -eq "int") {
    $random = Get-Random
} 
else {
    $random_ = [char[]](65..90) | Get-Random -Count 5
    $random = "'" + $random_ + "'"
}
$params_content += $col.Split(' ')[0] + "=" + $random + ","
}
$params_content

$prebDb_content = "using System;
using System.Linq;
using Microsoft.AspNetCore.Builder;
using Microsoft.Extensions.DependencyInjection;
using $app_name.Models;

namespace $appname.Data
{
        public static claass PrepDb
        {
            public static void PrepPopulation(IApplicationBuilder app)
            {
                using( var serviceScope = app.ApplicationsServices.CreateScope())
                {
                    SeedData(serviceScope.ServiceProvider.GetService<$dbcontext_class_name>());
                }
            }

            private static void SeedData($dbcontext_class_name context)
            {
                if(!context.$dbset_name.Any())
                {
                    Console.WriteLine('--> Seeding data...')
                    context.$dbset_name.AddRange(
                        new $model_name() {$params_content}
                    )
                }
                else
                {
                    Console.WriteLine('--> We already have data');
                }
            }
        }
}
"
$prebDb_content