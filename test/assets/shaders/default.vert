uniform mat4 camera;
in vec2 node_size;
in mat4 transform;
in vec2 vertex;
in vec4 texture_uv;
in vec4 texture_crop_uv;
in int texture_index;
in vec4 tint;
in vec4 modulate;
in mat4 node_extra_data;
out vec2 uv;
out vec4 crop;
flat out int _texture_index;
out vec4 _tint;
out vec4 _modulate;
out mat4 _node_extra_data;
out vec2 _node_size;
out vec2 local_xy;
void main()
{
  gl_Position = camera * transform * vec4(vertex,0.0,1.0);
  if( gl_VertexID == 0 ){ // left-top
    uv = vec2(texture_uv[0], texture_uv[3]);
    local_xy = vec2(0.0,1.0);
  }else if( gl_VertexID == 1 ){ // left-bottom
    uv = vec2(texture_uv[0], texture_uv[1]);
    local_xy = vec2(0.0,0.0);
  }else if( gl_VertexID == 2 ){ // right-top
    uv = vec2(texture_uv[2], texture_uv[3]);
    local_xy = vec2(1.0,1.0);
  }else if( gl_VertexID == 3 ){ // right-bottom
    uv = vec2(texture_uv[2], texture_uv[1]);
    local_xy = vec2(1.0,0.0);
  }
  crop = texture_crop_uv;
  _texture_index = texture_index;
  _tint = tint / 255.0;
  _modulate = modulate / 255.0;
  _node_extra_data = node_extra_data;
  _node_size = node_size;
}
