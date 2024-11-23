
in vec2 uv;
in vec4 crop;
in vec2 local_xy;
flat in int _texture_index;
in vec4 _tint;
in vec4 _modulate;
uniform sampler2D sampler[16];
uniform float time;
uniform vec2 resolution;
uniform float scale;
uniform mat4 shader_extra_data;
out vec4 color;

vec4 getTextureColor(int index,vec2 xy) {
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
  vec4 noise = getTextureColor(1, uv);
  vec4 c = getTextureColor(0, uv);
  float level = sin(time*2.0) + 0.1;
  float height = noise.r;
  if( height > level ){
    if( abs(height-level) < 0.01 && c.a > 0.0 ){
      color = vec4(1.0,0.0,0.0,c.a);
    }else{
      color = c;
    }
  }else{
    discard;
  }
}
