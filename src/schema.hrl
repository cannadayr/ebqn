-compile([nowarn_unused_function,nowarn_unused_vars]).

-define(MEM,7833228).                       % total memory in Kb. Used temporarily for GC.
-record(st,{root,heap,an,rtn,keys,objs}).   % program state
-record(prog,{b,o,s}).                      % program (bytecode, objects, sections)
-record(bl,{t,i,st,l}).                     % block (type, immediacy, start, locals)
-record(bi,{prog,t,d,args,e,prim}).         % block instance (bytecode, objs, sections, type, definition, args, env)
-record(tr,{f,g,h,prim}).                   % train (f-fn, g-fn, h-fn)
-record(a,{sh,r}).                          % array (shape, ravel)
-record(c,{p}).                             % character (point)
-record(m1,{f,prim}).                       % 1-modifier (f-fn)
-record(m2,{f,prim}).                       % 2-modifier (f-fn)
-record(r1,{m,f,prim}).                     % raw 1-modifier (m-fn, f-fn)
-record(r2,{m,f,g,prim}).                   % raw 2-modifier (m-fn, f-fn, g-fn)
-record(dl1,{f}).                           % derived lambda 1 (f-fn)
-record(dl2,{f}).                           % derived lambda 2 (f-fn)
-record(fn,{f,prim}).                       % function
