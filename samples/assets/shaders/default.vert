
uniform mat4 camera;
in vec2 vertex;
in vec4 texture_uv;
in vec4 transform_a;
in vec4 transform_b;
in vec4 transform_c;
in vec4 transform_d;
in int texture_index;
in float opacity;
in vec4 tint_color;
out vec2 uv;
flat out int _texture_index;
out vec4 _tint_color;
out float _opacity;
void main()
{
  gl_Position = camera * mat4(transform_a,transform_b,transform_c,transform_d) * vec4(vertex,0.0,1.0);
  // vertex = [ left-top, left-bottom, right-top, right-bottom ]
  // texture_uv = [ x:left, y:top, z:right, w:bottom ]
  if( gl_VertexID == 0 ){
    uv = vec2(texture_uv.x,texture_uv.y); // left-top
  }else if( gl_VertexID == 1 ){
    uv = vec2(texture_uv.x,texture_uv.w); // left-bottom
  }else if( gl_VertexID == 2 ){
    uv = vec2(texture_uv.z,texture_uv.y); // right-top
  }else if( gl_VertexID == 3 ){
    uv = vec2(texture_uv.z,texture_uv.w); // right-bottom
  }
  _texture_index = texture_index;
  _tint_color = tint_color;
  _opacity = opacity;
}
