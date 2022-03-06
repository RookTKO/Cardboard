gpu_set_ztestenable(true);
gpu_set_zwriteenable(true);
gpu_set_cullmode(cull_noculling);
gpu_set_alphatestenable(true);
gpu_set_alphatestref(254);

var _oldWorld      = matrix_get(matrix_world); 
var _oldView       = matrix_get(matrix_view); 
var _oldProjection = matrix_get(matrix_projection);

var _yaw = point_direction(camFromX, camFromY, camToX, camToY) - 90;

matrix_set(matrix_view, CardboardViewMatrix(camFromX, camFromY, camFromZ,    camToX, camToY, camToZ));
matrix_set(matrix_projection, matrix_build_projection_ortho(room_width, room_height, -3000, 3000));

CardboardSpriteFloorExt(sprHi, 0, 320,   0,   0, 5, 5, 0, c_red,   1);
CardboardSpriteFloorExt(sprHi, 0, -320,   0,   0, 5, 5, 0, c_yellow,   1);
CardboardSpriteFloorExt(sprHi, 0,   0, 320,   0, 5, 5, 0, c_lime,  1);
CardboardSpriteFloorExt(sprHi, 0,   0,   0, 320, 5, 5, 0, c_blue,  1);
CardboardSpriteExt(sprHi, 0, 0, 160, 160, 5, 5, 0, 0, c_white, 1);
CardboardSpriteExt(sprHi, 0, 160, 0, 160, 5, 5, 0, 90, c_white, 1);
CardboardSpriteExt(sprHi, 0, -160, 0, 160, 5, 5, 0, -90, c_white, 1);

CardboardSpriteExt(sprTest, 0,
                   160, 0, 0,
                    2.5, 2.5,
                   0, _yaw,
                   c_white, 1);

CardboardSpriteExt(sprTest, 0,
                   0, 160, 0,
                   2.5, 2.5,
                   0, _yaw,
                   c_white, 1);

CardboardSpriteExt(sprCrosshair, 0, camToX, camToY, camToZ, 1, 1, 0, _yaw, c_white, 1);
CardboardBatchSubmit();

CardboardBatchSubmit();

matrix_set(matrix_world, _oldWorld);
matrix_set(matrix_view, _oldView);
matrix_set(matrix_projection, _oldProjection);
gpu_set_ztestenable(false);
gpu_set_zwriteenable(false);
gpu_set_cullmode(cull_noculling);
gpu_set_alphatestenable(false);