-compile([nowarn_unused_function,nowarn_unused_vars]).

-define(MEM,7833228).           % total memory in Kb. Used temporarily for GC.
-record(st,{root,heap,an,rtn}). % program state
-record(bl,{t,i,st,l}).         % block (type, immediacy, start, locals)
-record(bi,{b,o,s,t,d,args,e}). % block instance (bytecode, objs, sections, type, definition, args, env)
-record(tr,{f,g,h}).            % train (f-fn, g-fn, h-fn)
-record(a,{sh,r}).              % array (shape, ravel)
-record(c,{p}).                 % character (point)
-record(m1,{f}).                % 1-modifier (f-fn)
-record(m2,{f}).                % 2-modifier (f-fn)
-record(r1,{m,f}).              % raw 1-modifier (m-fn, f-fn)
-record(r2,{m,f,g}).            % raw 2-modifier (m-fn, f-fn, g-fn)
-record(m,{f}).                 % modifier (f-fn)
