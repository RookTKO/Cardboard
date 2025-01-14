#macro __CARDBOARD_VERSION     "1.0.0"
#macro __CARDBOARD_DATE        "2022-03-05"
#macro __CARDBOARD_MAX_IMAGES  1024



__CardboardTrace("Welcome to Cardboard by @jujuadams! This is version " + __CARDBOARD_VERSION + ", " + __CARDBOARD_DATE);



vertex_format_begin();
vertex_format_add_position_3d(); //12 bytes
vertex_format_add_color();       // 4 bytes
vertex_format_add_texcoord();    // 8 bytes
global.__cardboardVertexFormat = vertex_format_end();



global.__cardboardBuildingModel = false;
global.__cardboardModel         = undefined;

global.__cardboardOldViewMatrix = matrix_get(matrix_view);
global.__cardboardBillboardYaw  = undefined;

global.__cardboardOldWorld      = matrix_get(matrix_world); 
global.__cardboardOldView       = matrix_get(matrix_view); 
global.__cardboardOldProjection = matrix_get(matrix_projection);

global.__cardboardAutoBatching        = false;
global.__cardboardBatchTexturePointer = undefined;
global.__cardboardBatchTextureIndex   = undefined;
global.__cardboardBatchVertexBuffer   = vertex_create_buffer();
vertex_begin(global.__cardboardBatchVertexBuffer, global.__cardboardVertexFormat);



//Cache texture page index information for every image of every sprite
global.__cardboardTexturePageIndexMap = ds_map_create();
var _sprite = 0;
while(sprite_exists(_sprite))
{
    var _framesArray = sprite_get_info(_sprite).frames;
    
    var _number = sprite_get_number(_sprite);
    if (_number > __CARDBOARD_MAX_IMAGES) __CardboardError("Image number cannot exceed 1024 (", sprite_get_name(_sprite), ")");
    
    var _image = 0;
    repeat(_number)
    {
        var _uvs = sprite_get_uvs(_sprite, _image);
        
        var _left   = -sprite_get_xoffset(_sprite) + _uvs[4];
        var _top    = -sprite_get_yoffset(_sprite) + _uvs[5];
        var _right  = _left + _uvs[6]*sprite_get_width(_sprite);
        var _bottom = _top + _uvs[7]*sprite_get_height(_sprite);
        
        global.__cardboardTexturePageIndexMap[? __CARDBOARD_MAX_IMAGES*_sprite + _image] = {
            spriteName: sprite_get_name(_sprite),
            image: _image,
            
            texturePointer: sprite_get_texture(_sprite, _image),
            textureIndex: _framesArray[_image].texture,
            
            left:   _left,
            top:    _top,
            right:  _right,
            bottom: _bottom,
            
            u0: _uvs[0],
            v0: _uvs[1],
            u1: _uvs[2],
            v1: _uvs[3],
        };
        
        ++_image;
    }
    
    ++_sprite;
}



function __CardboardTrace()
{
    var _string = "Cardboard: ";
    
    var _i = 0
    repeat(argument_count)
    {
        if (is_real(argument[_i]))
        {
            _string += string_format(argument[_i], 0, 4);
        }
        else
        {
            _string += string(argument[_i]);
        }
        
        ++_i;
    }
    
    show_debug_message(_string);
}

function __CardboardError()
{
    var _string = "";
    
    var _i = 0
    repeat(argument_count)
    {
        _string += string(argument[_i]);
        ++_i;
    }
    
    show_debug_message("Cardboard: " + string_replace_all(_string, "\n", "\n          "));
    show_error("Cardboard:\n" + _string + "\n ", true);
}



function __CardboardBatchComplete()
{
    if (global.__cardboardBuildingModel)
    {
        global.__cardboardModel.__AddBatch();
    }
    else
    {
        CardboardBatchForceSubmit();
    }
}

function __CardboardClassModel() constructor
{
    array = [];
    
    static __AddBatch = function()
    {
        if (!is_array(array)) return;
        
        //Don't do anything we know this batch is empty
        if (global.__cardboardBatchTexturePointer == undefined) return;
        
        //End the batch we have
        vertex_end(global.__cardboardBatchVertexBuffer);
        
        array_push(array, {
            vertexBuffer:   global.__cardboardBatchVertexBuffer,
            texturePointer: global.__cardboardBatchTexturePointer,
        });
        
        //Clear the batch's texture state
        global.__cardboardBatchTexturePointer = undefined;
        global.__cardboardBatchTextureIndex   = undefined;
        
        //Then start the vertex buffer again!
        global.__cardboardBatchVertexBuffer = vertex_create_buffer();
        vertex_begin(global.__cardboardBatchVertexBuffer, global.__cardboardVertexFormat);
    }
    
    static __Submit = function()
    {
        if (!is_array(array)) return;
        
        var _i = 0;
        repeat(array_length(array))
        {
            var _batch = array[_i];
            vertex_submit(_batch.vertexBuffer, pr_trianglelist, _batch.texturePointer);
            ++_i;
        }
    }
    
    static __Destroy = function()
    {
        if (!is_array(array)) return;
        
        var _i = 0;
        repeat(array_length(array))
        {
            vertex_delete_buffer(array[_i].vertexBuffer);
            ++_i;
        }
        
        array = undefined;
    }
}