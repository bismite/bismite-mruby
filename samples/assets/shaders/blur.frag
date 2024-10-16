
in vec2 uv;
flat in int _texture_index;
in vec4 _tint;
in vec4 _modulate;
uniform sampler2D sampler[16];
uniform float time;
uniform vec2 resolution;
uniform float scale;
uniform mat4 layer_extra_data;
out vec4 output_color;

vec4 getTextureColor(int samplerID,vec2 xy) {
  if(samplerID==0){ return texture(sampler[0], xy); }
  if(samplerID==1){ return texture(sampler[1], xy); }
  if(samplerID==2){ return texture(sampler[2], xy); }
  if(samplerID==3){ return texture(sampler[3], xy); }
  if(samplerID==4){ return texture(sampler[4], xy); }
  if(samplerID==5){ return texture(sampler[5], xy); }
  if(samplerID==6){ return texture(sampler[6], xy); }
  if(samplerID==7){ return texture(sampler[7], xy); }
  if(samplerID==8){ return texture(sampler[8], xy); }
  if(samplerID==9){ return texture(sampler[9], xy); }
  if(samplerID==10){ return texture(sampler[10], xy); }
  if(samplerID==11){ return texture(sampler[11], xy); }
  if(samplerID==12){ return texture(sampler[12], xy); }
  if(samplerID==13){ return texture(sampler[13], xy); }
  if(samplerID==14){ return texture(sampler[14], xy); }
  if(samplerID==15){ return texture(sampler[15], xy); }
  return vec4(0);
}

vec4 blur(int i, vec2 direction,float power)
{
  vec4 c = vec4(0.0);
  vec2 s = direction/resolution;
  float d = power / 110.0;
  for(float q=1.0; q<=10.0; q+=1.0) {
    c += getTextureColor(i, uv.xy + s*q ) * d*(11.0-q);
    c += getTextureColor(i, uv.xy - s*q ) * d*(11.0-q);
  }
  return c;
}

void main()
{
  float power = cos(time*3.0)*0.5 + 0.5;
  vec4 c = getTextureColor(_texture_index, uv) * (1.0-power);
  output_color = c + blur( _texture_index, vec2(1.0,0.0), power );;
}
