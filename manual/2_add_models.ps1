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