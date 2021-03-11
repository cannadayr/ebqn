-compile([nowarn_unused_function,nowarn_unused_vars]).

-record(bl,{t,i,st,l}).
-record(bi,{b,o,s,t,d,args,e}). % bytecode, objs, sections, type, definition, args, env
-record(tr,{f,g,h}).
-record(v,{sh,r}). % value (shape, ravel)
-record(m1,{f}).
-record(m2,{f}).
-record(r1,{m,f}). % raw 1-mod
-record(r2,{m,f,g}). % raw 2-mod
