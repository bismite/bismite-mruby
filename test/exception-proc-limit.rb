
# too many irep references (RuntimeError)
# limit 65535.

procs=[]
i=0
loop do
  i+=1
  begin
    procs << proc{ p i }
  rescue => e
    p [e,i]
    exit
  end
end
