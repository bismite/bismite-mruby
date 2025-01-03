
in vec2 uv;
in vec4 crop;
in vec2 local_xy;
flat in int _texture_index;
in vec4 _tint;
in vec4 _modulate;
uniform sampler2D sampler[16];
uniform float time;
uniform vec2 resolution;
uniform mat4 shader_extra_data;

layout (location = 0) out vec4 color0;

vec4 getTextureColor(int index,vec2 xy,vec4 crop) {
  if( index < 0 || 16 <= index ) { return vec4(1.0); }
  float upper = crop[1] > crop[3] ? crop[1] : crop[3];
  float lower = crop[1] > crop[3] ? crop[3] : crop[1];
  if( xy.x < 0.0 || 1.0 < xy.x  ){ return vec4(0.0); }
  if( xy.y < 0.0 || 1.0 < xy.y  ){ return vec4(0.0); }
  if( xy.x < crop[0] ){ return vec4(0.0); }
  if( xy.y < lower ){ return vec4(0.0); }
  if( xy.x > crop[2] ){ return vec4(0.0); }
  if( xy.y > upper ){ return vec4(0.0); }
  if(index==0){ return texture(sampler[0], xy); }
  if(index==1){ return texture(sampler[1], xy); }
  if(index==2){ return texture(sampler[2], xy); }
  if(index==3){ return texture(sampler[3], xy); }
  if(index==4){ return texture(sampler[4], xy); }
  if(index==5){ return texture(sampler[5], xy); }
  if(index==6){ return texture(sampler[6], xy); }
  if(index==7){ return texture(sampler[7], xy); }
  if(index==8){ return texture(sampler[8], xy); }
  if(index==9){ return texture(sampler[9], xy); }
  if(index==10){ return texture(sampler[10], xy); }
  if(index==11){ return texture(sampler[11], xy); }
  if(index==12){ return texture(sampler[12], xy); }
  if(index==13){ return texture(sampler[13], xy); }
  if(index==14){ return texture(sampler[14], xy); }
  if(index==15){ return texture(sampler[15], xy); }
  return vec4(0.0);
}

void main()
{
  vec4 r = getTextureColor(0, uv, crop);
  vec4 g = getTextureColor(1, uv, crop);
  vec4 b = getTextureColor(2, uv, crop);
  vec4 c = getTextureColor(3, uv, crop);
  vec4 m = getTextureColor(4, uv, crop);
  vec4 y = getTextureColor(5, uv, crop);
  vec4 k = getTextureColor(6, uv, crop);

  if(gl_FragCoord.x > 420.0){
    color0 = k;
  }else if(gl_FragCoord.x > 360.0){
    color0 = y;
  }else if(gl_FragCoord.x > 300.0){
    color0 = m;
  }else if(gl_FragCoord.x > 240.0){
    color0 = c;
  }else if(gl_FragCoord.x > 180.0){
    color0 = b;
  }else if(gl_FragCoord.x > 120.0){
    color0 = g;
  }else if(gl_FragCoord.x > 60.0){
    color0 = r;
  }else{
    color0 = k;
  }
}
