
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