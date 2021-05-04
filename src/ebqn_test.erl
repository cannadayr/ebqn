-module(ebqn_test).

-include("schema.hrl").

-import(ebqn,[run/2,char/1,str/1]).
-export([test/2,bc/0,layer0/2,layer1/2,layer2/2,layer3/2,layer4/2,layer5/2,layer6/2]).
-export([undo/2,identity/2,under/2]).

test(St0,Rt) ->
    ebqn_test:bc(),
    ebqn_test:undo(St0,Rt),
    ebqn_test:identity(St0,Rt),
    ebqn_test:under(St0,Rt),
    ebqn_test:layer0(St0,Rt),
    ebqn_test:layer1(St0,Rt),
    ebqn_test:layer2(St0,Rt),
    ebqn_test:layer3(St0,Rt),
    ebqn_test:layer4(St0,Rt),
    ebqn_test:layer5(St0,Rt),
    ebqn_test:layer6(St0,Rt).

bc() ->
    % bytecode tests
    {_,5} = run(ebqn:init_st(),[[0,0,25],[5],[[0,1,0,0]]]), % 5
    {_,3} = run(ebqn:init_st(),[[0,0,14,0,1,25],[4,3],[[0,1,0,0]]]), % 4⋄3
    {_,5} = run(ebqn:init_st(),[[0,0,22,0,0,11,25],[5],[[0,1,0,1]]]), % a←5
    {_,4} = run(ebqn:init_st(),[[0,0,22,0,0,11,14,0,1,22,0,0,12,25],[5,4],[[0,1,0,1]]]), % a←5⋄a↩4
    {_,2} = run(ebqn:init_st(),[[0,0,22,0,0,11,14,0,1,22,0,1,11,14,21,0,0,25],[2,3],[[0,1,0,2]]]), % a←2⋄b←3⋄a
    {_,1} = run(ebqn:init_st(),[[0,0,22,0,0,11,14,0,1,21,0,0,16,25],[1,4],[[0,1,0,1]]]), % a←1⋄A 4
    {_,2} = run(ebqn:init_st(),[[0,0,22,0,0,11,14,0,2,21,0,0,0,1,17,25],[2,3,4],[[0,1,0,1]]]), % a←2⋄3 A 4
    {_,6} = run(ebqn:init_st(),[[0,0,15,1,16,25,21,0,1,25],[6],[[0,1,0,0],[0,0,6,3]]]), % {𝕩}6
    {_,3} = run(ebqn:init_st(),[[15,1,22,0,0,11,14,0,1,21,0,0,0,0,17,25,21,0,2,25],[3,4],[[0,1,0,1],[0,0,16,3]]]), % A←{𝕨}⋄3 A 4
    {_,7} = run(ebqn:init_st(),[[0,0,0,1,3,2,22,0,0,22,0,1,4,2,11,14,21,0,0,25],[7,2],[[0,1,0,2]]]), % a‿b←7‿2⋄a
    {_,4} = run(ebqn:init_st(),[[0,1,15,1,0,0,7,16,25,21,0,1,25],[4,6],[[0,1,0,0],[1,1,9,2]]]), % "4{𝔽}6"
    {_,6} = run(ebqn:init_st(),[[0,1,15,1,0,0,7,16,25,21,0,4,14,21,0,1,25],[4,6],[[0,1,0,0],[1,0,9,5]]]), % "4{𝔽⋄𝕩}6"
    {_,1} = run(ebqn:init_st(),[[0,1,15,1,15,2,0,0,8,16,25,21,0,1,25,21,0,2,25],[3,1],[[0,1,0,0],[0,0,11,3],[2,1,15,3]]]), % "3{𝔾}{𝕩} 1 "
    {_,2} = run(ebqn:init_st(),[[0,1,15,1,15,2,0,0,7,9,16,25,21,0,1,25,21,0,1,25],[2,3],[[0,1,0,0],[0,0,12,3],[1,1,16,2]]]), % "(2{𝔽}{𝕩})3 "
    {_,3} = run(ebqn:init_st(),[[0,1,15,1,15,2,9,0,0,17,25,21,0,2,21,0,1,3,2,25,21,0,1,22,0,3,22,0,4,4,2,11,14,21,0,3,25],[3,4],[[0,1,0,0],[0,0,11,3],[0,0,20,5]]]), % "3({a‿b←𝕩⋄a}{𝕨‿𝕩})4 "
    {_,4} = run(ebqn:init_st(),[[0,1,15,1,15,2,15,3,19,0,0,17,25,21,0,2,25,21,0,1,25,21,0,2,21,0,1,3,2,25],[4,5],[[0,1,0,0],[0,0,13,3],[0,0,17,3],[0,0,21,3]]]), % "4({𝕨‿𝕩}{𝕩}{𝕨})5"
    {_,2} = run(ebqn:init_st(),[[0,1,15,1,15,2,0,0,19,16,22,0,0,22,0,1,4,2,11,14,21,0,0,25,21,0,1,25,21,0,2,21,0,1,3,2,25],[2,5],[[0,1,0,2],[0,0,24,3],[0,0,28,3]]]), % "a‿b←(2{𝕨‿𝕩}{𝕩})5⋄a "
    {_,2} = run(ebqn:init_st(),[[0,2,22,0,0,11,15,1,15,2,15,3,19,16,25,0,1,22,1,0,12,14,21,0,1,25,21,0,1,14,21,1,0,25,0,0,22,1,0,12,14,21,0,1,25],[2,3,4],[[0,1,0,1],[0,0,15,3],[0,0,26,3],[0,0,34,3]]]), % "({a↩2⋄𝕩}{𝕩⋄a}{a↩3⋄𝕩})a←4 "
    {_,8} = run(ebqn:init_st(),[[0,0,22,0,0,11,14,0,1,15,1,22,0,0,13,14,21,0,0,25,21,0,1,25],[3,8],[[0,1,0,1],[0,0,20,3]]]), % "a←3⋄a{𝕩}↩8⋄a  "
    {_,4} = run(ebqn:init_st(),[[0,0,0,1,3,2,22,0,0,22,0,1,4,2,11,14,0,2,15,1,22,0,0,22,0,1,4,2,13,14,21,0,0,25,21,0,1,21,0,2,3,2,25],[2,1,4],[[0,1,0,2],[0,0,34,3]]]), % "a‿b←2‿1⋄a‿b{𝕩‿𝕨}↩4⋄a "
    {_,1} = run(ebqn:init_st(),[[0,0,22,0,0,11,14,15,1,14,21,0,0,25,0,1,22,0,0,11,25],[1,2],[[0,1,0,1],[0,1,14,1]]]), % "a←1⋄{a←2}⋄a"
    {_,2} = run(ebqn:init_st(),[[0,0,22,0,0,11,14,15,1,14,21,0,0,25,0,1,22,1,0,12,25],[1,2],[[0,1,0,1],[0,1,14,0]]]), % "a←1⋄{a↩2}⋄a"
    {_,6} = run(ebqn:init_st(),[[15,1,22,0,0,22,0,1,4,2,11,14,0,1,21,0,0,16,14,0,2,21,0,1,16,25,0,0,22,0,0,11,14,15,2,15,3,3,2,25,21,0,1,22,1,0,12,25,21,0,1,14,21,1,0,25],[2,6,0],[[0,1,0,2],[0,1,26,1],[0,0,40,3],[0,0,48,3]]]), % "f‿g←{a←2⋄{a↩𝕩}‿{𝕩⋄a}}⋄F 6⋄G 0"
    {_,5} = run(ebqn:init_st(),[[15,1,22,0,0,11,14,0,0,21,0,0,16,21,0,0,16,21,0,0,16,15,2,16,25,15,3,21,0,1,7,25,21,0,0,21,0,1,16,25,21,0,4,21,0,1,16,25],[5],[[0,1,0,1],[0,0,25,3],[0,0,32,3],[1,0,40,5]]]), % "L←{𝕩{𝕏𝕗}}⋄{𝕏𝕤}L L L 5"
    {_,3} = run(ebqn:init_st(),[[15,1,22,0,0,11,14,0,1,21,0,0,0,0,7,16,21,0,0,15,2,7,16,15,3,16,25,21,0,4,15,4,21,0,1,7,9,25,21,0,1,25,21,0,0,21,0,1,16,25,21,0,4,21,0,1,16,25],[3,5],[[0,1,0,1],[1,0,27,5],[0,0,38,3],[0,0,42,3],[1,0,50,5]]]), % "_l←{𝕩{𝕏𝕗} 𝔽}⋄{𝕏𝕤} {𝕩}_l 3 _l 5"
    {_,1} = run(ebqn:init_st(),[[0,1,15,1,15,2,15,3,8,0,0,17,25,21,0,1,25,21,0,1,21,0,2,15,4,21,0,1,7,19,25,21,0,2,25,21,0,2,21,0,4,21,0,1,17,25],[1,0],[[0,1,0,0],[0,0,13,3],[2,1,17,3],[0,0,31,3],[1,0,35,5]]]), % "1{𝕨}{𝔽{𝕩𝔽𝕨}𝔾𝔽}{𝕩}0 "
    {_,2} = run(ebqn:init_st(),[[0,0,0,1,0,2,0,3,0,4,15,1,3,2,3,2,3,2,3,2,3,2,15,2,0,0,0,0,15,3,3,2,3,2,7,16,25,21,0,1,25,21,0,1,15,4,16,25,21,0,1,25,21,0,1,22,0,3,22,0,4,4,2,11,14,21,0,0,22,0,5,11,14,0,0,15,5,15,6,7,16,14,15,7,21,0,4,21,0,5,16,7,25,21,0,1,21,1,4,16,25,21,0,0,14,15,8,22,1,5,12,25,21,0,1,22,0,5,22,0,6,4,2,11,14,21,0,6,21,0,4,16,25,21,0,0,14,15,9,25,21,0,1,22,0,3,22,0,4,4,2,11,14,21,0,3,25],[0,1,2,3,4],[[0,1,0,0],[0,0,37,3],[1,1,41,2],[0,0,48,3],[0,0,52,6],[1,1,93,2],[0,0,101,3],[1,0,112,7],[0,0,133,3],[0,0,140,5]]]), % "0‿(0‿{𝕩}){{a‿b←𝕩⋄t←𝕤⋄{𝕤⋄T↩{𝕤⋄{a‿b←𝕩⋄a}}}{B𝕗}0⋄(T b){a‿b←𝕩⋄𝔽b}}𝕗} 0‿(1‿(2‿(3‿(4‿{𝕩}))))"
    ok.

% # LAYER 0
layer0(St0,Rt) ->
    {_,1} = ebqn:run(St0,[[0,4,0,0,0,3,17,0,1,0,2,17,25],[ebqn_array:get(0,Rt#a.r),ebqn_array:get(18,Rt#a.r),0,-2,2],[[0,1,0,0]]]), %0≡¯2+2
    {_,1} = ebqn:run(St0,[[0,3,0,0,0,3,17,0,1,0,2,17,25],[ebqn_array:get(0,Rt#a.r),ebqn_array:get(18,Rt#a.r),10000,5000],[[0,1,0,0]]]), %1e4≡5e3+5e3
    {_,1} = ebqn:run(St0,[[0,2,0,0,0,4,17,0,1,0,3,17,25],[ebqn_array:get(0,Rt#a.r),ebqn_array:get(18,Rt#a.r),2,ebqn:char("c"),ebqn:char("a")],[[0,1,0,0]]]), %'c'≡'a'+2
    {_,1} = ebqn:run(St0,[[0,4,0,0,0,2,17,0,1,0,3,17,25],[ebqn_array:get(0,Rt#a.r),ebqn_array:get(18,Rt#a.r),-2,ebqn:char("a"),ebqn:char("c")],[[0,1,0,0]]]), %'a'≡¯2+'c'
    ok = try ebqn:run(St0,[[0,2,0,0,0,1,17,25],[ebqn_array:get(0,Rt#a.r),ebqn:char("a"),ebqn:char("c")],[[0,1,0,0]]]) % 'a'+'c'
        catch _ -> ok
    end,
    ok = try ebqn:run(St0,[[0,1,22,0,0,11,14,0,2,0,0,31,0,0,17,25],[ebqn_array:get(0,Rt#a.r),ebqn_array:get(1,Rt#a.r),2],[[0,1,0,1]]]) % F←-⋄f+2
        catch _ -> ok
    end,
    {_,1} = ebqn:run(St0,[[0,4,0,0,0,3,17,0,1,0,2,17,25],[ebqn_array:get(1,Rt#a.r),ebqn_array:get(18,Rt#a.r),ninf,1000000,inf],[[0,1,0,0]]]), %¯∞≡1e6-∞
    {_,1} = ebqn:run(St0,[[0,3,0,0,16,0,1,0,2,17,25],[ebqn_array:get(1,Rt#a.r),ebqn_array:get(18,Rt#a.r),4,-4],[[0,1,0,0]]]), %4≡-¯4
    {_,1} = ebqn:run(St0,[[0,3,0,0,16,0,1,0,2,17,25],[ebqn_array:get(1,Rt#a.r),ebqn_array:get(18,Rt#a.r),ninf,inf],[[0,1,0,0]]]), %¯∞≡-∞
    {_,1} = ebqn:run(St0,[[0,3,0,0,16,0,1,0,2,17,25],[ebqn_array:get(1,Rt#a.r),ebqn_array:get(18,Rt#a.r),inf,ninf],[[0,1,0,0]]]), %∞≡-¯∞
    {_,1} = ebqn:run(St0,[[0,4,0,0,0,3,17,0,1,0,2,17,25],[ebqn_array:get(1,Rt#a.r),ebqn_array:get(18,Rt#a.r),4,9,5],[[0,1,0,0]]]), %4≡9-5
    {_,1} = ebqn:run(St0,[[0,2,0,0,0,4,17,0,1,0,3,17,25],[ebqn_array:get(1,Rt#a.r),ebqn_array:get(18,Rt#a.r),97,ebqn:char("\0"),ebqn:char("a")],[[0,1,0,0]]]), %@≡'a'-97
    {_,1} = ebqn:run(St0,[[0,4,0,0,0,3,17,0,1,0,2,17,25],[ebqn_array:get(1,Rt#a.r),ebqn_array:get(18,Rt#a.r),3,ebqn:char("d"),ebqn:char("a")],[[0,1,0,0]]]), %3≡'d'-'a'
    {_,1} = ebqn:run(St0,[[0,6,0,1,0,5,17,0,0,0,4,17,0,2,0,3,17,25],[ebqn_array:get(0,Rt#a.r),ebqn_array:get(1,Rt#a.r),ebqn_array:get(18,Rt#a.r),ebqn:char("Q"),ebqn:char("q"),ebqn:char("A"),ebqn:char("a")],[[0,1,0,0]]]), %'Q'≡'q'+'A'-'a'
    ok = try ebqn:run(St0,[[0,2,0,0,0,1,17,25],[ebqn_array:get(1,Rt#a.r),97,ebqn:char("a")],[[0,1,0,0]]]) % 97-'a'
        catch _ -> ok
    end,
    ok = try ebqn:run(St0,[[0,1,0,0,0,2,17,25],[ebqn_array:get(1,Rt#a.r),1,ebqn:char("\0")],[[0,1,0,0]]]) % @-1
        catch _ -> ok
    end,
    ok = try ebqn:run(St0,[[0,1,0,0,16,25],[ebqn_array:get(1,Rt#a.r),ebqn:char("a")],[[0,1,0,0]]]) % -'a'
        catch _ -> ok
    end,
    ok = try ebqn:run(St0,[[0,1,22,0,0,11,14,31,0,0,0,0,16,25],[ebqn_array:get(1,Rt#a.r),ebqn_array:get(3,Rt#a.r)],[[0,1,0,1]]]) % F←÷⋄-f
        catch _ -> ok
    end,
    {_,1} = ebqn:run(St0,[[0,4,0,0,0,3,17,0,1,0,2,17,25],[ebqn_array:get(2,Rt#a.r),ebqn_array:get(18,Rt#a.r),1.5,3,0.5],[[0,1,0,0]]]), %1.5≡3×0.5
    ok = try ebqn:run(St0,[[0,2,0,0,0,1,17,25],[ebqn_array:get(2,Rt#a.r),2,ebqn:char("a")],[[0,1,0,0]]]) % 2×'a'
        catch _ -> ok
    end,
    {_,1} = ebqn:run(St0,[[0,3,0,0,16,0,1,0,2,17,25],[ebqn_array:get(3,Rt#a.r),ebqn_array:get(18,Rt#a.r),4,0.25],[[0,1,0,0]]]), %4≡÷0.25
    {_,1} = ebqn:run(St0,[[0,3,0,0,16,0,1,0,2,17,25],[ebqn_array:get(3,Rt#a.r),ebqn_array:get(18,Rt#a.r),inf,0],[[0,1,0,0]]]), %∞≡÷0
    {_,1} = ebqn:run(St0,[[0,3,0,0,16,0,1,0,2,17,25],[ebqn_array:get(3,Rt#a.r),ebqn_array:get(18,Rt#a.r),0,inf],[[0,1,0,0]]]), %0≡÷∞
    ok = try ebqn:run(St0,[[0,1,0,0,16,25],[ebqn_array:get(3,Rt#a.r),ebqn:char("b")],[[0,1,0,0]]]) % ÷'b'
        catch _ -> ok
    end,
    ok = try ebqn:run(St0,[[0,0,0,2,9,22,0,0,11,14,31,0,0,0,1,16,25],[ebqn_array:get(1,Rt#a.r),ebqn_array:get(3,Rt#a.r),ebqn_array:get(5,Rt#a.r)],[[0,1,0,1]]]) % F←√-⋄÷f
        catch _ -> ok
    end,
    {_,1} = ebqn:run(St0,[[0,3,0,0,16,0,1,0,2,17,25],[ebqn_array:get(4,Rt#a.r),ebqn_array:get(18,Rt#a.r),1,0],[[0,1,0,0]]]), %1≡⋆0
    {_,1} = ebqn:run(St0,[[0,3,0,0,0,2,17,0,1,0,2,17,25],[ebqn_array:get(4,Rt#a.r),ebqn_array:get(18,Rt#a.r),-1,5],[[0,1,0,0]]]), %¯1≡¯1⋆5
    {_,1} = ebqn:run(St0,[[0,4,0,0,0,3,17,0,1,0,2,17,25],[ebqn_array:get(4,Rt#a.r),ebqn_array:get(18,Rt#a.r),1,-1,-6],[[0,1,0,0]]]), %1≡¯1⋆¯6
    ok = try ebqn:run(St0,[[0,1,0,0,16,25],[ebqn_array:get(4,Rt#a.r),ebqn:char("π")],[[0,1,0,0]]]) % ⋆'π'
        catch _ -> ok
    end,
    ok = try ebqn:run(St0,[[0,2,0,0,0,1,17,25],[ebqn_array:get(4,Rt#a.r),ebqn:char("e"),ebqn:char("π")],[[0,1,0,0]]]) % 'e'⋆'π'
        catch _ -> ok
    end,
    {_,1} = ebqn:run(St0,[[0,3,0,0,16,0,1,0,2,17,25],[ebqn_array:get(6,Rt#a.r),ebqn_array:get(18,Rt#a.r),3,3.9],[[0,1,0,0]]]), %3≡⌊3.9
    {_,1} = ebqn:run(St0,[[0,3,0,0,16,0,1,0,2,17,25],[ebqn_array:get(6,Rt#a.r),ebqn_array:get(18,Rt#a.r),-4,-3.9],[[0,1,0,0]]]), %¯4≡⌊¯3.9
    {_,1} = ebqn:run(St0,[[0,2,0,0,16,0,1,0,2,17,25],[ebqn_array:get(6,Rt#a.r),ebqn_array:get(18,Rt#a.r),inf],[[0,1,0,0]]]), %∞≡⌊∞
    {_,1} = ebqn:run(St0,[[0,2,0,0,16,0,1,0,2,17,25],[ebqn_array:get(6,Rt#a.r),ebqn_array:get(18,Rt#a.r),ninf],[[0,1,0,0]]]), %¯∞≡⌊¯∞
    {_,1} = ebqn:run(St0,[[0,2,0,0,16,0,1,0,2,17,25],[ebqn_array:get(6,Rt#a.r),ebqn_array:get(18,Rt#a.r),-1.0E30],[[0,1,0,0]]]), %¯1e30≡⌊¯1e30
    ok = try ebqn:run(St0,[[0,1,22,0,0,11,14,31,0,0,0,0,16,25],[ebqn_array:get(6,Rt#a.r),ebqn_array:get(7,Rt#a.r)],[[0,1,0,1]]]) % F←⌈⋄⌊f
        catch _ -> ok
    end,
    {_,1} = ebqn:run(St0,[[0,2,0,0,0,2,17,0,1,0,2,17,25],[ebqn_array:get(15,Rt#a.r),ebqn_array:get(18,Rt#a.r),1],[[0,1,0,0]]]), %1≡1=1
    {_,1} = ebqn:run(St0,[[0,4,0,0,0,3,17,0,1,0,2,17,25],[ebqn_array:get(15,Rt#a.r),ebqn_array:get(18,Rt#a.r),0,-1,inf],[[0,1,0,0]]]), %0≡¯1=∞
    {_,1} = ebqn:run(St0,[[0,3,0,0,0,3,17,0,1,0,2,17,25],[ebqn_array:get(15,Rt#a.r),ebqn_array:get(18,Rt#a.r),1,ebqn:char("a")],[[0,1,0,0]]]), %1≡'a'='a'
    {_,1} = ebqn:run(St0,[[0,4,0,0,0,3,17,0,1,0,2,17,25],[ebqn_array:get(15,Rt#a.r),ebqn_array:get(18,Rt#a.r),0,ebqn:char("a"),ebqn:char("A")],[[0,1,0,0]]]), %0≡'a'='A'
    {_,1} = ebqn:run(St0,[[15,1,0,2,0,3,17,25,0,0,22,0,0,11,14,21,0,0,0,1,31,0,0,17,25],[ebqn_array:get(0,Rt#a.r),ebqn_array:get(15,Rt#a.r),ebqn_array:get(18,Rt#a.r),1],[[0,1,0,0],[0,1,8,1]]]), %1≡{F←+⋄f=f}
    {_,1} = ebqn:run(St0,[[15,1,0,2,0,4,17,25,0,3,0,0,7,0,3,0,0,7,3,2,22,0,0,22,0,1,4,2,11,14,31,0,1,0,1,31,0,0,17,25],[ebqn_array:get(0,Rt#a.r),ebqn_array:get(15,Rt#a.r),ebqn_array:get(18,Rt#a.r),ebqn_array:get(49,Rt#a.r),1],[[0,1,0,0],[0,1,8,2]]]), %1≡{a‿b←⟨+´,+´⟩⋄a=b}
    {_,1} = ebqn:run(St0,[[15,1,0,1,0,2,17,25,15,2,22,0,0,11,14,0,3,0,0,31,0,0,17,25,21,0,1,25],[ebqn_array:get(15,Rt#a.r),ebqn_array:get(18,Rt#a.r),0,ebqn:char("o")],[[0,1,0,0],[0,1,8,1],[1,1,24,2]]]), %0≡{_op←{𝕗}⋄op='o'}
    {_,1} = ebqn:run(St0,[[15,1,0,1,0,2,17,25,15,2,22,0,0,11,14,15,3,22,0,1,11,14,31,0,1,0,0,31,0,0,17,25,21,0,1,25,21,0,1,25],[ebqn_array:get(15,Rt#a.r),ebqn_array:get(18,Rt#a.r),0],[[0,1,0,0],[0,1,8,2],[0,0,32,3],[0,0,36,3]]]), %0≡{F←{𝕩}⋄G←{𝕩}⋄f=g}
    {_,1} = ebqn:run(St0,[[15,1,0,1,0,2,17,25,15,2,22,0,0,11,14,21,0,0,0,0,31,0,0,17,25,21,0,1,25],[ebqn_array:get(15,Rt#a.r),ebqn_array:get(18,Rt#a.r),1],[[0,1,0,0],[0,1,8,1],[0,0,25,3]]]), %1≡{F←{𝕩}⋄f=f}
    {_,1} = ebqn:run(St0,[[0,2,0,0,0,2,17,0,1,0,2,17,25],[ebqn_array:get(16,Rt#a.r),ebqn_array:get(18,Rt#a.r),1],[[0,1,0,0]]]), %1≡1≤1
    {_,1} = ebqn:run(St0,[[0,4,0,0,0,3,17,0,1,0,2,17,25],[ebqn_array:get(16,Rt#a.r),ebqn_array:get(18,Rt#a.r),1,ninf,-1000],[[0,1,0,0]]]), %1≡¯∞≤¯1e3
    {_,1} = ebqn:run(St0,[[0,4,0,0,0,3,17,0,1,0,2,17,25],[ebqn_array:get(16,Rt#a.r),ebqn_array:get(18,Rt#a.r),0,inf,ninf],[[0,1,0,0]]]), %0≡∞≤¯∞
    {_,1} = ebqn:run(St0,[[0,4,0,0,0,3,17,0,1,0,2,17,25],[ebqn_array:get(16,Rt#a.r),ebqn_array:get(18,Rt#a.r),1,inf,ebqn:char("\0")],[[0,1,0,0]]]), %1≡∞≤@
    {_,1} = ebqn:run(St0,[[0,3,0,0,0,4,17,0,1,0,2,17,25],[ebqn_array:get(16,Rt#a.r),ebqn_array:get(18,Rt#a.r),0,-0.5,ebqn:char("z")],[[0,1,0,0]]]), %0≡'z'≤¯0.5
    {_,1} = ebqn:run(St0,[[0,3,0,0,0,3,17,0,1,0,2,17,25],[ebqn_array:get(16,Rt#a.r),ebqn_array:get(18,Rt#a.r),1,ebqn:char("a")],[[0,1,0,0]]]), %1≡'a'≤'a'
    {_,1} = ebqn:run(St0,[[0,4,0,0,0,3,17,0,1,0,2,17,25],[ebqn_array:get(16,Rt#a.r),ebqn_array:get(18,Rt#a.r),0,ebqn:char("c"),ebqn:char("a")],[[0,1,0,0]]]), %0≡'c'≤'a'
    ok = try ebqn:run(St0,[[0,0,22,0,0,11,14,0,1,22,0,1,11,14,31,0,1,0,2,31,0,0,17,25],[ebqn_array:get(0,Rt#a.r),ebqn_array:get(1,Rt#a.r),ebqn_array:get(16,Rt#a.r)],[[0,1,0,2]]]) % F←+⋄G←-⋄f≤g
        catch _ -> ok
    end,
    {_,1} = ebqn:run(St0,[[0,3,0,0,16,0,2,16,0,1,3,0,17,25],[ebqn_array:get(12,Rt#a.r),ebqn_array:get(18,Rt#a.r),ebqn_array:get(19,Rt#a.r),2],[[0,1,0,0]]]), %⟨⟩≡≢<2
    {_,1} = ebqn:run(St0,[[0,3,0,1,16,0,0,0,2,3,1,17,25],[ebqn_array:get(18,Rt#a.r),ebqn_array:get(19,Rt#a.r),3,ebqn:str("abc")],[[0,1,0,0]]]), %⟨3⟩≡≢"abc"
    {_,1} = ebqn:run(St0,[[0,5,0,6,3,2,0,0,16,0,2,16,0,1,0,3,0,4,3,2,17,25],[ebqn_array:get(13,Rt#a.r),ebqn_array:get(18,Rt#a.r),ebqn_array:get(19,Rt#a.r),2,3,ebqn:str("abc"),ebqn:str("fed")],[[0,1,0,0]]]), %⟨2,3⟩≡≢>"abc"‿"fed"
    {_,1} = ebqn:run(St0,[[0,8,0,3,16,0,2,0,4,0,5,0,6,0,7,3,4,17,0,1,16,0,0,0,4,0,5,0,6,0,7,3,4,17,25],[ebqn_array:get(18,Rt#a.r),ebqn_array:get(19,Rt#a.r),ebqn_array:get(22,Rt#a.r),ebqn_array:get(27,Rt#a.r),2,3,4,5,120],[[0,1,0,0]]]), %⟨2,3,4,5⟩≡≢2‿3‿4‿5⥊↕120
    {_,1} = ebqn:run(St0,[[0,5,0,6,3,2,0,0,16,0,3,16,0,2,16,0,1,0,4,3,1,17,25],[ebqn_array:get(13,Rt#a.r),ebqn_array:get(18,Rt#a.r),ebqn_array:get(19,Rt#a.r),ebqn_array:get(22,Rt#a.r),6,ebqn:str("abc"),ebqn:str("fed")],[[0,1,0,0]]]), %⟨6⟩≡≢⥊>"abc"‿"fed"
    {_,1} = ebqn:run(St0,[[0,3,0,4,3,2,0,1,0,2,17,0,0,0,3,17,25],[ebqn_array:get(18,Rt#a.r),ebqn_array:get(36,Rt#a.r),0,ebqn:str("abc"),ebqn:str("de")],[[0,1,0,0]]]), %"abc"≡0⊑"abc"‿"de"
    {_,1} = ebqn:run(St0,[[0,4,0,3,3,2,0,1,0,2,17,0,0,0,3,17,25],[ebqn_array:get(18,Rt#a.r),ebqn_array:get(36,Rt#a.r),1,ebqn:str("de"),ebqn:str("abc")],[[0,1,0,0]]]), %"de"≡1⊑"abc"‿"de"
    {_,1} = ebqn:run(St0,[[0,2,0,1,16,0,0,3,0,17,25],[ebqn_array:get(18,Rt#a.r),ebqn_array:get(27,Rt#a.r),0],[[0,1,0,0]]]), %⟨⟩≡↕0
    {_,1} = ebqn:run(St0,[[0,3,0,1,16,0,0,0,2,3,1,17,25],[ebqn_array:get(18,Rt#a.r),ebqn_array:get(27,Rt#a.r),0,1],[[0,1,0,0]]]), %⟨0⟩≡↕1
    {_,1} = ebqn:run(St0,[[0,9,0,1,16,0,0,0,2,0,3,0,4,0,5,0,6,0,7,0,8,3,7,17,25],[ebqn_array:get(18,Rt#a.r),ebqn_array:get(27,Rt#a.r),0,1,2,3,4,5,6,7],[[0,1,0,0]]]), %⟨0,1,2,3,4,5,6⟩≡↕7
    {_,1} = ebqn:run(St0,[[0,2,0,1,16,0,0,0,2,17,25],[ebqn_array:get(18,Rt#a.r),ebqn_array:get(42,Rt#a.r),1],[[0,1,0,0]]]), %1≡!1
    {_,1} = ebqn:run(St0,[[0,2,0,1,0,3,17,0,0,0,2,17,25],[ebqn_array:get(18,Rt#a.r),ebqn_array:get(42,Rt#a.r),1,ebqn:char("e")],[[0,1,0,0]]]), %1≡'e'!1
    ok = try ebqn:run(St0,[[0,1,0,0,16,25],[ebqn_array:get(42,Rt#a.r),0],[[0,1,0,0]]]) % !0
        catch _ -> ok
    end,
    ok = try ebqn:run(St0,[[0,2,0,0,0,1,17,25],[ebqn_array:get(42,Rt#a.r),ebqn:str("error"),ebqn:str("abc")],[[0,1,0,0]]]) % "error"!"abc"
        catch _ -> ok
    end,
    ok.

layer1(St0,Rt) ->
    {_,1} = ebqn:run(St0,[[0,7,0,0,0,1,3,2,0,4,0,2,8,0,6,17,0,3,0,5,17,25],[ebqn_array:get(0,Rt#a.r),ebqn_array:get(1,Rt#a.r),ebqn_array:get(13,Rt#a.r),ebqn_array:get(18,Rt#a.r),ebqn_array:get(58,Rt#a.r),3,4,1],[[0,1,0,0]]]), %3≡4>◶+‿-1
    {_,1} = ebqn:run(St0,[[0,7,0,0,0,1,3,2,0,4,0,3,8,0,6,17,0,2,0,5,17,25],[ebqn_array:get(0,Rt#a.r),ebqn_array:get(1,Rt#a.r),ebqn_array:get(18,Rt#a.r),ebqn_array:get(21,Rt#a.r),ebqn_array:get(58,Rt#a.r),3,4,1],[[0,1,0,0]]]), %3≡4⊢◶+‿-1
    {_,1} = ebqn:run(St0,[[0,6,0,0,0,1,3,2,0,3,0,6,8,0,5,17,0,2,0,4,17,25],[ebqn_array:get(0,Rt#a.r),ebqn_array:get(1,Rt#a.r),ebqn_array:get(18,Rt#a.r),ebqn_array:get(58,Rt#a.r),3,4,1],[[0,1,0,0]]]), %3≡4 1◶+‿-1
    {_,1} = ebqn:run(St0,[[0,7,0,0,0,1,3,2,0,4,0,2,8,0,6,17,0,3,0,5,17,25],[ebqn_array:get(0,Rt#a.r),ebqn_array:get(1,Rt#a.r),ebqn_array:get(12,Rt#a.r),ebqn_array:get(18,Rt#a.r),ebqn_array:get(58,Rt#a.r),5,4,1],[[0,1,0,0]]]), %5≡4<◶+‿-1
    {_,1} = ebqn:run(St0,[[0,7,0,0,0,1,3,2,0,3,0,6,8,0,5,17,0,2,0,4,17,25],[ebqn_array:get(0,Rt#a.r),ebqn_array:get(1,Rt#a.r),ebqn_array:get(18,Rt#a.r),ebqn_array:get(58,Rt#a.r),5,4,0,1],[[0,1,0,0]]]), %5≡4 0◶+‿-1
    {_,1} = ebqn:run(St0,[[0,5,0,4,0,2,0,0,8,16,0,1,0,3,17,25],[ebqn_array:get(1,Rt#a.r),ebqn_array:get(18,Rt#a.r),ebqn_array:get(57,Rt#a.r),1,0,-1],[[0,1,0,0]]]), %1≡-⊘0 ¯1
    {_,1} = ebqn:run(St0,[[0,6,0,0,0,3,0,1,8,0,5,17,0,2,0,4,17,25],[ebqn_array:get(0,Rt#a.r),ebqn_array:get(1,Rt#a.r),ebqn_array:get(18,Rt#a.r),ebqn_array:get(57,Rt#a.r),1,-1,2],[[0,1,0,0]]]), %1≡¯1-⊘+2
    {_,1} = ebqn:run(St0,[[0,2,0,1,16,0,0,0,2,17,25],[ebqn_array:get(18,Rt#a.r),ebqn_array:get(21,Rt#a.r),ebqn:str("abc")],[[0,1,0,0]]]), %"abc"≡⊢"abc"
    {_,1} = ebqn:run(St0,[[0,3,0,1,0,2,17,0,0,0,3,17,25],[ebqn_array:get(18,Rt#a.r),ebqn_array:get(21,Rt#a.r),3,ebqn:str("")],[[0,1,0,0]]]), %""≡3⊢""
    {_,1} = ebqn:run(St0,[[3,0,0,1,16,0,0,3,0,17,25],[ebqn_array:get(18,Rt#a.r),ebqn_array:get(20,Rt#a.r)],[[0,1,0,0]]]), %⟨⟩≡⊣⟨⟩
    {_,1} = ebqn:run(St0,[[3,0,0,1,0,2,17,0,0,0,2,17,25],[ebqn_array:get(18,Rt#a.r),ebqn_array:get(20,Rt#a.r),ebqn:str("ab")],[[0,1,0,0]]]), %"ab"≡"ab"⊣⟨⟩
    {_,1} = ebqn:run(St0,[[0,4,0,2,0,0,7,16,0,1,0,3,17,25],[ebqn_array:get(0,Rt#a.r),ebqn_array:get(18,Rt#a.r),ebqn_array:get(44,Rt#a.r),4,2],[[0,1,0,0]]]), %4≡+˜2
    {_,1} = ebqn:run(St0,[[0,5,0,2,0,0,7,0,4,17,0,1,0,3,17,25],[ebqn_array:get(1,Rt#a.r),ebqn_array:get(18,Rt#a.r),ebqn_array:get(44,Rt#a.r),3,1,4],[[0,1,0,0]]]), %3≡1-˜4
    {_,1} = ebqn:run(St0,[[0,5,0,1,0,3,0,0,8,16,0,2,0,4,17,25],[ebqn_array:get(1,Rt#a.r),ebqn_array:get(2,Rt#a.r),ebqn_array:get(18,Rt#a.r),ebqn_array:get(52,Rt#a.r),1,-6],[[0,1,0,0]]]), %1≡-∘×¯6
    {_,1} = ebqn:run(St0,[[0,6,0,1,0,3,0,0,8,0,5,17,0,2,0,4,17,25],[ebqn_array:get(1,Rt#a.r),ebqn_array:get(2,Rt#a.r),ebqn_array:get(18,Rt#a.r),ebqn_array:get(52,Rt#a.r),-6,2,3],[[0,1,0,0]]]), %¯6≡2-∘×3
    {_,1} = ebqn:run(St0,[[0,5,0,1,0,3,0,0,8,16,0,2,0,4,17,25],[ebqn_array:get(1,Rt#a.r),ebqn_array:get(2,Rt#a.r),ebqn_array:get(18,Rt#a.r),ebqn_array:get(53,Rt#a.r),1,-7],[[0,1,0,0]]]), %1≡-○×¯7
    {_,1} = ebqn:run(St0,[[0,6,0,1,0,3,0,0,8,0,5,17,0,2,0,4,17,25],[ebqn_array:get(1,Rt#a.r),ebqn_array:get(2,Rt#a.r),ebqn_array:get(18,Rt#a.r),ebqn_array:get(53,Rt#a.r),2,5,-7],[[0,1,0,0]]]), %2≡5-○×¯7
    {_,1} = ebqn:run(St0,[[0,6,0,1,0,3,0,0,0,3,0,5,8,8,16,0,2,0,4,17,25],[ebqn_array:get(1,Rt#a.r),ebqn_array:get(2,Rt#a.r),ebqn_array:get(18,Rt#a.r),ebqn_array:get(54,Rt#a.r),-20,1,5],[[0,1,0,0]]]), %¯20≡1⊸-⊸×5
    {_,1} = ebqn:run(St0,[[0,11,0,5,16,0,4,0,7,0,3,8,0,12,0,13,3,2,0,1,16,17,0,2,0,8,0,10,3,2,0,6,0,0,7,0,8,0,9,3,2,17,17,25],[ebqn_array:get(0,Rt#a.r),ebqn_array:get(13,Rt#a.r),ebqn_array:get(18,Rt#a.r),ebqn_array:get(19,Rt#a.r),ebqn_array:get(22,Rt#a.r),ebqn_array:get(27,Rt#a.r),ebqn_array:get(47,Rt#a.r),ebqn_array:get(54,Rt#a.r),0,2,1,4,ebqn:str("ab"),ebqn:str("cd")],[[0,1,0,0]]]), %(0‿2+⌜0‿1)≡(>⟨"ab","cd"⟩)≢⊸⥊↕4
    {_,1} = ebqn:run(St0,[[0,6,0,5,0,3,0,0,8,0,3,0,1,8,16,0,2,0,4,17,25],[ebqn_array:get(1,Rt#a.r),ebqn_array:get(2,Rt#a.r),ebqn_array:get(18,Rt#a.r),ebqn_array:get(55,Rt#a.r),20,1,5],[[0,1,0,0]]]), %20≡×⟜(-⟜1)5
    {_,1} = ebqn:run(St0,[[0,6,0,1,0,3,0,0,8,0,5,17,0,2,0,4,17,25],[ebqn_array:get(0,Rt#a.r),ebqn_array:get(2,Rt#a.r),ebqn_array:get(18,Rt#a.r),ebqn_array:get(55,Rt#a.r),4,5,-3],[[0,1,0,0]]]), %4≡5+⟜×¯3
    {_,1} = ebqn:run(St0,[[0,6,0,5,0,2,0,0,8,0,4,17,0,1,0,3,17,25],[ebqn_array:get(0,Rt#a.r),ebqn_array:get(18,Rt#a.r),ebqn_array:get(55,Rt#a.r),7,5,2,-3],[[0,1,0,0]]]), %7≡5+⟜2 ¯3
    {_,1} = ebqn:run(St0,[[0,3,0,0,16,0,1,0,2,17,25],[ebqn_array:get(5,Rt#a.r),ebqn_array:get(18,Rt#a.r),2,4],[[0,1,0,0]]]), %2≡√4
    {_,1} = ebqn:run(St0,[[0,3,0,0,0,2,17,0,1,0,2,17,25],[ebqn_array:get(5,Rt#a.r),ebqn_array:get(18,Rt#a.r),3,27],[[0,1,0,0]]]), %3≡3√27
    ok = try ebqn:run(St0,[[0,1,0,0,16,25],[ebqn_array:get(5,Rt#a.r),ebqn:char("x")],[[0,1,0,0]]]) % √'x'
        catch _ -> ok
    end,
    {_,1} = ebqn:run(St0,[[0,4,0,0,0,3,17,0,1,0,2,17,25],[ebqn_array:get(10,Rt#a.r),ebqn_array:get(18,Rt#a.r),6,2,3],[[0,1,0,0]]]), %6≡2∧3
    {_,1} = ebqn:run(St0,[[0,2,0,0,0,3,17,0,1,0,2,17,25],[ebqn_array:get(10,Rt#a.r),ebqn_array:get(18,Rt#a.r),0,-2],[[0,1,0,0]]]), %0≡¯2∧0
    ok = try ebqn:run(St0,[[0,1,0,0,0,2,17,25],[ebqn_array:get(10,Rt#a.r),-1,ebqn:char("a")],[[0,1,0,0]]]) % 'a'∧¯1
        catch _ -> ok
    end,
    {_,1} = ebqn:run(St0,[[0,4,0,2,0,0,7,16,0,1,0,3,17,25],[ebqn_array:get(11,Rt#a.r),ebqn_array:get(18,Rt#a.r),ebqn_array:get(44,Rt#a.r),0.75,0.5],[[0,1,0,0]]]), %0.75≡∨˜0.5
    {_,1} = ebqn:run(St0,[[0,4,0,0,0,3,17,0,1,0,2,17,25],[ebqn_array:get(11,Rt#a.r),ebqn_array:get(18,Rt#a.r),1.75,2,0.25],[[0,1,0,0]]]), %1.75≡2∨0.25
    ok = try ebqn:run(St0,[[0,0,22,0,0,11,14,31,0,0,0,1,0,2,17,25],[ebqn_array:get(1,Rt#a.r),ebqn_array:get(11,Rt#a.r),2],[[0,1,0,1]]]) % F←-⋄2∨f
        catch _ -> ok
    end,
    {_,1} = ebqn:run(St0,[[0,3,0,0,16,0,1,0,2,17,25],[ebqn_array:get(9,Rt#a.r),ebqn_array:get(18,Rt#a.r),0,1],[[0,1,0,0]]]), %0≡¬1
    {_,1} = ebqn:run(St0,[[0,3,0,0,16,0,1,0,2,17,25],[ebqn_array:get(9,Rt#a.r),ebqn_array:get(18,Rt#a.r),1,0],[[0,1,0,0]]]), %1≡¬0
    {_,1} = ebqn:run(St0,[[0,3,0,0,16,0,1,0,2,17,25],[ebqn_array:get(9,Rt#a.r),ebqn_array:get(18,Rt#a.r),2,-1],[[0,1,0,0]]]), %2≡¬¯1
    ok = try ebqn:run(St0,[[0,1,0,0,16,25],[ebqn_array:get(9,Rt#a.r),ebqn:char("a")],[[0,1,0,0]]]) % ¬'a'
        catch _ -> ok
    end,
    {_,1} = ebqn:run(St0,[[0,4,0,0,0,3,17,0,1,0,2,17,25],[ebqn_array:get(9,Rt#a.r),ebqn_array:get(18,Rt#a.r),0,3,4],[[0,1,0,0]]]), %0≡3¬4
    {_,1} = ebqn:run(St0,[[0,4,0,0,0,3,17,0,1,0,2,17,25],[ebqn_array:get(9,Rt#a.r),ebqn_array:get(18,Rt#a.r),2,4,3],[[0,1,0,0]]]), %2≡4¬3
    {_,1} = ebqn:run(St0,[[0,4,0,0,0,3,17,0,1,0,2,17,25],[ebqn_array:get(9,Rt#a.r),ebqn_array:get(18,Rt#a.r),4,5,2],[[0,1,0,0]]]), %4≡5¬2
    ok = try ebqn:run(St0,[[15,1,22,0,0,11,14,31,0,0,0,0,0,1,17,25,21,0,1,25],[ebqn_array:get(9,Rt#a.r),0],[[0,1,0,1],[0,0,16,3]]]) % F←{𝕩}⋄0¬f
        catch _ -> ok
    end,
    {_,1} = ebqn:run(St0,[[0,2,0,0,16,0,1,0,2,17,25],[ebqn_array:get(8,Rt#a.r),ebqn_array:get(18,Rt#a.r),0],[[0,1,0,0]]]), %0≡|0
    {_,1} = ebqn:run(St0,[[0,3,0,0,16,0,1,0,2,17,25],[ebqn_array:get(8,Rt#a.r),ebqn_array:get(18,Rt#a.r),5,-5],[[0,1,0,0]]]), %5≡|¯5
    {_,1} = ebqn:run(St0,[[0,2,0,0,16,0,1,0,2,17,25],[ebqn_array:get(8,Rt#a.r),ebqn_array:get(18,Rt#a.r),6],[[0,1,0,0]]]), %6≡|6
    {_,1} = ebqn:run(St0,[[0,3,0,0,16,0,1,0,2,17,25],[ebqn_array:get(8,Rt#a.r),ebqn_array:get(18,Rt#a.r),inf,ninf],[[0,1,0,0]]]), %∞≡|¯∞
    ok = try ebqn:run(St0,[[0,1,0,0,9,22,0,0,11,14,31,0,0,0,2,16,25],[ebqn_array:get(0,Rt#a.r),ebqn_array:get(1,Rt#a.r),ebqn_array:get(8,Rt#a.r)],[[0,1,0,1]]]) % F←+-⋄|f
        catch _ -> ok
    end,
    {_,1} = ebqn:run(St0,[[0,4,0,0,0,3,17,0,1,0,2,17,25],[ebqn_array:get(8,Rt#a.r),ebqn_array:get(18,Rt#a.r),2,3,8],[[0,1,0,0]]]), %2≡3|8
    {_,1} = ebqn:run(St0,[[0,4,0,0,0,3,17,0,1,0,2,17,25],[ebqn_array:get(8,Rt#a.r),ebqn_array:get(18,Rt#a.r),2,3,-7],[[0,1,0,0]]]), %2≡3|¯7
    {_,1} = ebqn:run(St0,[[0,4,0,0,0,3,17,0,1,0,2,17,25],[ebqn_array:get(8,Rt#a.r),ebqn_array:get(18,Rt#a.r),-1,-3,8],[[0,1,0,0]]]), %¯1≡¯3|8
    ok = try ebqn:run(St0,[[0,2,0,0,0,1,17,25],[ebqn_array:get(8,Rt#a.r),26,ebqn:char("A")],[[0,1,0,0]]]) % 26|'A'
        catch _ -> ok
    end,
    {_,1} = ebqn:run(St0,[[0,3,0,0,16,0,2,16,0,1,0,4,17,25],[ebqn_array:get(12,Rt#a.r),ebqn_array:get(18,Rt#a.r),ebqn_array:get(22,Rt#a.r),ebqn:char("a"),ebqn:str("a")],[[0,1,0,0]]]), %"a"≡⥊<'a'
    {_,1} = ebqn:run(St0,[[0,3,0,0,16,0,2,16,0,1,0,3,17,25],[ebqn_array:get(12,Rt#a.r),ebqn_array:get(18,Rt#a.r),ebqn_array:get(36,Rt#a.r),ebqn:str("abcd")],[[0,1,0,0]]]), %"abcd"≡⊑<"abcd"
    {_,1} = ebqn:run(St0,[[0,3,0,4,0,5,3,2,3,2,0,0,16,0,2,16,0,1,3,0,17,25],[ebqn_array:get(12,Rt#a.r),ebqn_array:get(18,Rt#a.r),ebqn_array:get(19,Rt#a.r),2,3,4],[[0,1,0,0]]]), %⟨⟩≡≢<⟨2,⟨3,4⟩⟩
    {_,1} = ebqn:run(St0,[[0,4,0,0,0,3,17,0,1,0,2,17,25],[ebqn_array:get(12,Rt#a.r),ebqn_array:get(18,Rt#a.r),0,4,2],[[0,1,0,0]]]), %0≡4<2
    {_,1} = ebqn:run(St0,[[0,3,0,0,0,3,17,0,1,0,2,17,25],[ebqn_array:get(13,Rt#a.r),ebqn_array:get(18,Rt#a.r),0,5],[[0,1,0,0]]]), %0≡5>5
    {_,1} = ebqn:run(St0,[[0,4,0,0,0,3,17,0,1,0,2,17,25],[ebqn_array:get(17,Rt#a.r),ebqn_array:get(18,Rt#a.r),0,3,4],[[0,1,0,0]]]), %0≡3≥4
    {_,1} = ebqn:run(St0,[[0,3,0,0,16,0,1,0,2,17,25],[ebqn_array:get(14,Rt#a.r),ebqn_array:get(18,Rt#a.r),0,ebqn:str("")],[[0,1,0,0]]]), %0≡≠""
    {_,1} = ebqn:run(St0,[[0,3,0,0,16,0,1,0,2,17,25],[ebqn_array:get(14,Rt#a.r),ebqn_array:get(18,Rt#a.r),1,ebqn:str("a")],[[0,1,0,0]]]), %1≡≠"a"
    {_,1} = ebqn:run(St0,[[0,3,0,0,16,0,1,0,2,17,25],[ebqn_array:get(14,Rt#a.r),ebqn_array:get(18,Rt#a.r),1,ebqn:char("a")],[[0,1,0,0]]]), %1≡≠'a'
    {_,1} = ebqn:run(St0,[[0,3,0,0,16,0,1,0,2,17,25],[ebqn_array:get(14,Rt#a.r),ebqn_array:get(18,Rt#a.r),2,ebqn:str("ab")],[[0,1,0,0]]]), %2≡≠"ab"
    {_,1} = ebqn:run(St0,[[0,3,0,2,16,0,0,16,0,1,0,3,17,25],[ebqn_array:get(14,Rt#a.r),ebqn_array:get(18,Rt#a.r),ebqn_array:get(27,Rt#a.r),25],[[0,1,0,0]]]), %25≡≠↕25
    {_,1} = ebqn:run(St0,[[0,3,0,0,16,0,1,0,2,17,25],[ebqn_array:get(2,Rt#a.r),ebqn_array:get(18,Rt#a.r),1,5],[[0,1,0,0]]]), %1≡×5
    {_,1} = ebqn:run(St0,[[0,3,0,0,16,0,1,0,2,17,25],[ebqn_array:get(2,Rt#a.r),ebqn_array:get(18,Rt#a.r),-1,-2.5],[[0,1,0,0]]]), %¯1≡×¯2.5
    {_,1} = ebqn:run(St0,[[0,3,0,0,0,2,17,0,1,0,2,17,25],[ebqn_array:get(6,Rt#a.r),ebqn_array:get(18,Rt#a.r),3,4],[[0,1,0,0]]]), %3≡3⌊4
    {_,1} = ebqn:run(St0,[[0,3,0,0,0,2,17,0,1,0,2,17,25],[ebqn_array:get(6,Rt#a.r),ebqn_array:get(18,Rt#a.r),-3,inf],[[0,1,0,0]]]), %¯3≡¯3⌊∞
    {_,1} = ebqn:run(St0,[[0,2,0,0,0,3,17,0,1,0,2,17,25],[ebqn_array:get(7,Rt#a.r),ebqn_array:get(18,Rt#a.r),4,3],[[0,1,0,0]]]), %4≡3⌈4
    {_,1} = ebqn:run(St0,[[0,3,0,0,0,2,17,0,1,0,2,17,25],[ebqn_array:get(7,Rt#a.r),ebqn_array:get(18,Rt#a.r),1,-1],[[0,1,0,0]]]), %1≡1⌈¯1
    {_,1} = ebqn:run(St0,[[0,3,0,0,16,0,1,0,2,17,25],[ebqn_array:get(7,Rt#a.r),ebqn_array:get(18,Rt#a.r),5,4.01],[[0,1,0,0]]]), %5≡⌈4.01
    {_,1} = ebqn:run(St0,[[0,2,0,1,16,0,0,3,0,17,25],[ebqn_array:get(18,Rt#a.r),ebqn_array:get(19,Rt#a.r),ebqn:char("a")],[[0,1,0,0]]]), %⟨⟩≡≢'a'
    {_,1} = ebqn:run(St0,[[0,2,0,1,16,0,0,3,0,17,25],[ebqn_array:get(18,Rt#a.r),ebqn_array:get(19,Rt#a.r),0],[[0,1,0,0]]]), %⟨⟩≡≢0
    {_,1} = ebqn:run(St0,[[0,7,0,2,16,0,3,0,1,7,16,0,0,0,4,3,1,0,5,3,1,0,6,3,1,3,3,17,25],[ebqn_array:get(18,Rt#a.r),ebqn_array:get(22,Rt#a.r),ebqn_array:get(27,Rt#a.r),ebqn_array:get(46,Rt#a.r),0,1,2,3],[[0,1,0,0]]]), %⟨0⟩‿⟨1⟩‿⟨2⟩≡⥊¨↕3
    {_,1} = ebqn:run(St0,[[3,0,0,11,0,12,0,13,0,14,0,15,0,16,3,7,0,2,0,6,0,9,0,10,3,2,8,0,5,0,4,0,0,7,0,7,0,1,8,8,0,8,0,3,16,17,25],[ebqn_array:get(14,Rt#a.r),ebqn_array:get(18,Rt#a.r),ebqn_array:get(22,Rt#a.r),ebqn_array:get(27,Rt#a.r),ebqn_array:get(46,Rt#a.r),ebqn_array:get(53,Rt#a.r),ebqn_array:get(54,Rt#a.r),ebqn_array:get(55,Rt#a.r),6,2,3,ebqn:str("a"),ebqn:str("ab"),ebqn:str("abc"),ebqn:str("abcd"),ebqn:str("abcde"),ebqn:str("abcdef")],[[0,1,0,0]]]), %(↕6)≡⟜(≠¨)○(2‿3⊸⥊)⟨⟩‿"a"‿"ab"‿"abc"‿"abcd"‿"abcde"‿"abcdef"
    {_,1} = ebqn:run(St0,[[0,7,0,3,16,0,2,0,6,0,7,0,8,3,3,17,0,4,0,0,7,0,5,0,1,8,16,25],[ebqn_array:get(14,Rt#a.r),ebqn_array:get(18,Rt#a.r),ebqn_array:get(22,Rt#a.r),ebqn_array:get(27,Rt#a.r),ebqn_array:get(46,Rt#a.r),ebqn_array:get(55,Rt#a.r),4,0,2],[[0,1,0,0]]]), %≡⟜(≠¨)4‿0‿2⥊↕0
    {_,1} = ebqn:run(St0,[[0,5,0,2,16,0,3,0,0,7,16,0,1,0,4,17,25],[ebqn_array:get(0,Rt#a.r),ebqn_array:get(18,Rt#a.r),ebqn_array:get(27,Rt#a.r),ebqn_array:get(49,Rt#a.r),6,4],[[0,1,0,0]]]), %6≡+´↕4
    {_,1} = ebqn:run(St0,[[0,6,0,4,0,5,0,7,3,2,3,3,0,3,0,1,7,0,0,0,2,19,16,25],[ebqn_array:get(18,Rt#a.r),ebqn_array:get(20,Rt#a.r),ebqn_array:get(36,Rt#a.r),ebqn_array:get(49,Rt#a.r),2,3,ebqn:str("a"),ebqn:str("d")],[[0,1,0,0]]]), %(⊑≡⊣´)"a"‿2‿(3‿"d")
    {_,1} = ebqn:run(St0,[[0,7,0,5,0,6,0,8,3,2,3,3,0,3,0,1,7,0,0,0,2,19,0,4,17,25],[ebqn_array:get(18,Rt#a.r),ebqn_array:get(20,Rt#a.r),ebqn_array:get(36,Rt#a.r),ebqn_array:get(49,Rt#a.r),0,2,3,ebqn:str("a"),ebqn:str("d")],[[0,1,0,0]]]), %0(⊑≡⊣´)"a"‿2‿(3‿"d")
    {_,1} = ebqn:run(St0,[[0,7,0,5,0,6,0,8,3,2,3,3,0,3,0,1,7,0,0,0,2,0,4,0,5,8,19,16,25],[ebqn_array:get(18,Rt#a.r),ebqn_array:get(21,Rt#a.r),ebqn_array:get(36,Rt#a.r),ebqn_array:get(49,Rt#a.r),ebqn_array:get(54,Rt#a.r),2,3,ebqn:str("a"),ebqn:str("d")],[[0,1,0,0]]]), %(2⊸⊑≡⊢´)"a"‿2‿(3‿"d")
    {_,1} = ebqn:run(St0,[[0,6,0,4,0,5,0,7,3,2,3,3,0,3,0,2,7,0,0,0,1,19,0,4,17,25],[ebqn_array:get(18,Rt#a.r),ebqn_array:get(20,Rt#a.r),ebqn_array:get(21,Rt#a.r),ebqn_array:get(49,Rt#a.r),2,3,ebqn:str("a"),ebqn:str("d")],[[0,1,0,0]]]), %2(⊣≡⊢´)"a"‿2‿(3‿"d")
    {_,1} = ebqn:run(St0,[[0,6,0,7,3,2,0,8,0,4,3,2,3,2,0,3,0,2,0,0,7,7,16,0,1,0,4,0,5,3,2,17,25],[ebqn_array:get(0,Rt#a.r),ebqn_array:get(18,Rt#a.r),ebqn_array:get(46,Rt#a.r),ebqn_array:get(49,Rt#a.r),7,10,2,3,5],[[0,1,0,0]]]), %7‿10≡+¨´⟨⟨2,3⟩,⟨5,7⟩⟩
    ok = try ebqn:run(St0,[[0,2,0,1,0,0,7,16,25],[ebqn_array:get(0,Rt#a.r),ebqn_array:get(49,Rt#a.r),11],[[0,1,0,0]]]) % +´11
        catch _ -> ok
    end,
    ok = try ebqn:run(St0,[[0,3,0,1,16,0,2,0,0,7,16,25],[ebqn_array:get(1,Rt#a.r),ebqn_array:get(12,Rt#a.r),ebqn_array:get(49,Rt#a.r),ebqn:char("a")],[[0,1,0,0]]]) % -´<'a'
        catch _ -> ok
    end,
    ok = try ebqn:run(St0,[[0,5,0,1,0,3,0,4,3,2,17,0,2,0,0,7,16,25],[ebqn_array:get(2,Rt#a.r),ebqn_array:get(22,Rt#a.r),ebqn_array:get(49,Rt#a.r),3,1,ebqn:str("abc")],[[0,1,0,0]]]) % ×´3‿1⥊"abc"
        catch _ -> ok
    end,
    ok.

layer2(St0,#a{r=Runtime}) ->
    {_,1} = ebqn:run(St0,[[0,2,0,1,3,0,17,0,0,3,0,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(23,Runtime),str("")],[[0,1,0,0]]]), %⟨⟩≡⟨⟩∾""
    {_,1} = ebqn:run(St0,[[0,2,0,1,3,0,17,0,0,0,2,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(23,Runtime),str("a")],[[0,1,0,0]]]), %"a"≡⟨⟩∾"a"
    {_,1} = ebqn:run(St0,[[3,0,0,1,0,2,17,0,0,0,2,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(23,Runtime),str("a")],[[0,1,0,0]]]), %"a"≡"a"∾⟨⟩
    {_,1} = ebqn:run(St0,[[0,4,0,1,0,3,17,0,0,0,2,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(23,Runtime),str("aBCD"),str("a"),str("BCD")],[[0,1,0,0]]]), %"aBCD"≡"a"∾"BCD"
    {_,1} = ebqn:run(St0,[[0,9,0,7,0,8,3,2,0,10,3,3,0,4,0,6,0,3,7,7,0,5,0,1,7,9,0,2,0,5,0,1,7,0,4,0,6,0,0,7,7,9,19,16,25],[ebqn_array:get(0,Runtime),ebqn_array:get(14,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(23,Runtime),ebqn_array:get(44,Runtime),ebqn_array:get(46,Runtime),ebqn_array:get(47,Runtime),2,3,str(""),str("abcde")],[[0,1,0,0]]]), %((+⌜˜≠¨)≡(≠¨∾⌜˜))""‿⟨2,3⟩‿"abcde"
    {_,1} = ebqn:run(St0,[[0,11,0,10,3,2,0,6,0,4,0,7,0,5,0,0,7,0,8,0,10,0,9,0,1,8,8,8,7,0,2,0,6,0,1,7,0,4,9,0,9,0,3,8,19,16,25],[ebqn_array:get(0,Runtime),ebqn_array:get(2,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(47,Runtime),ebqn_array:get(49,Runtime),ebqn_array:get(53,Runtime),ebqn_array:get(54,Runtime),ebqn_array:get(55,Runtime),4,3],[[0,1,0,0]]]), %(⥊⟜(↕×´)≡(×⟜4)⊸(+⌜)○↕´)3‿4
    {_,1} = ebqn:run(St0,[[0,11,0,10,3,2,0,6,0,4,0,7,0,5,0,0,7,0,8,0,10,0,9,0,1,8,8,8,7,0,2,0,6,0,1,7,0,4,9,0,9,0,3,8,19,16,25],[ebqn_array:get(0,Runtime),ebqn_array:get(2,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(47,Runtime),ebqn_array:get(49,Runtime),ebqn_array:get(53,Runtime),ebqn_array:get(54,Runtime),ebqn_array:get(55,Runtime),4,0],[[0,1,0,0]]]), %(⥊⟜(↕×´)≡(×⟜4)⊸(+⌜)○↕´)0‿4
    {_,1} = ebqn:run(St0,[[0,9,0,4,0,0,7,0,8,0,3,16,0,2,0,5,0,6,3,2,17,17,0,1,0,9,0,2,0,5,0,6,0,7,3,3,17,17,25],[ebqn_array:get(0,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(47,Runtime),3,2,0,6,str("")],[[0,1,0,0]]]), %(3‿2‿0⥊"")≡(3‿2⥊↕6)+⌜""
    {_,1} = ebqn:run(St0,[[0,4,0,3,0,0,7,16,0,2,0,4,0,0,16,0,1,16,17,25],[ebqn_array:get(1,Runtime),ebqn_array:get(12,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(46,Runtime),2],[[0,1,0,0]]]), %(<-2)≡-¨2
    {_,1} = ebqn:run(St0,[[0,3,0,2,0,0,7,16,0,1,0,3,0,0,16,0,0,16,17,25],[ebqn_array:get(12,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(46,Runtime),2],[[0,1,0,0]]]), %(<<2)≡<¨2
    {_,1} = ebqn:run(St0,[[0,4,0,0,16,0,5,0,0,16,0,6,0,0,16,0,4,0,7,0,6,0,7,3,4,0,2,0,6,0,6,3,2,17,0,3,0,0,7,16,3,3,0,8,0,0,16,0,9,0,0,16,3,2,3,3,0,0,16,0,1,0,4,0,5,0,6,0,4,0,7,0,6,0,7,3,4,0,2,0,6,0,6,3,2,17,3,3,0,8,0,9,3,2,3,3,17,25],[ebqn_array:get(1,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(46,Runtime),1,3,2,0,5,4],[[0,1,0,0]]]), %⟨1,⟨3,2,2‿2⥊⟨1,0,2,0⟩⟩,⟨5,4⟩⟩≡-⟨-1,⟨-3,-2,-¨2‿2⥊⟨1,0,2,0⟩⟩,⟨-5,-4⟩⟩
    {_,1} = ebqn:run(St0,[[0,6,0,2,16,0,4,0,0,7,0,1,0,3,0,0,7,19,0,5,17,25],[ebqn_array:get(0,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(46,Runtime),ebqn_array:get(47,Runtime),3,6],[[0,1,0,0]]]), %3(+¨≡+⌜)↕6
    ok = try ebqn:run(St0,[[0,4,0,5,0,6,3,3,0,1,0,0,7,0,2,0,3,3,2,17,25],[ebqn_array:get(21,Runtime),ebqn_array:get(46,Runtime),2,3,4,5,6],[[0,1,0,0]]]) % 2‿3⊢¨4‿5‿6
        catch _ -> ok
    end,
    ok = try ebqn:run(St0,[[0,2,0,0,0,1,17,25],[ebqn_array:get(1,Runtime),str("abcd"),str("a")],[[0,1,0,0]]]) % "abcd"-"a"
        catch _ -> ok
    end,
    {_,1} = ebqn:run(St0,[[0,14,0,13,3,2,0,9,3,2,0,10,3,2,0,11,3,2,0,0,0,13,0,14,3,2,17,15,1,16,0,2,0,9,0,10,0,11,0,12,0,12,3,5,17,25,21,0,1,0,5,0,3,0,7,0,4,0,6,0,2,0,1,9,0,8,21,0,0,8,8,8,7,16,25],[ebqn_array:get(0,Runtime),ebqn_array:get(2,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(23,Runtime),ebqn_array:get(49,Runtime),ebqn_array:get(54,Runtime),ebqn_array:get(55,Runtime),ebqn_array:get(61,Runtime),3,4,5,6,2,1],[[0,1,0,0],[0,0,46,3]]]), %3‿4‿5‿6‿6≡{𝕊⍟(×≡)⊸∾⟜⥊´𝕩}⟨2,1⟩+⟨⟨⟨⟨1,2⟩,3⟩,4⟩,5⟩
    {_,1} = ebqn:run(St0,[[0,8,0,5,16,0,6,0,4,7,0,0,0,3,19,0,7,0,5,16,17,0,2,16,0,1,0,7,0,8,3,2,17,25],[ebqn_array:get(2,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(19,Runtime),ebqn_array:get(20,Runtime),ebqn_array:get(21,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(47,Runtime),3,2],[[0,1,0,0]]]), %3‿2≡≢(↕3)(⊣×⊢⌜)↕2
    ok = try ebqn:run(St0,[[0,6,0,2,16,0,3,0,1,7,0,5,0,2,16,17,0,0,0,4,0,2,16,17,25],[ebqn_array:get(2,Runtime),ebqn_array:get(21,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(47,Runtime),4,3,2],[[0,1,0,0]]]) % (↕4)×(↕3)⊢⌜↕2
        catch _ -> ok
    end,
    {_,1} = ebqn:run(St0,[[0,14,0,15,0,16,3,3,0,4,0,1,0,13,19,0,7,0,9,0,2,7,7,0,13,0,6,16,19,0,3,0,12,0,13,3,2,0,10,0,0,7,0,6,9,0,11,0,5,8,16,0,11,0,8,0,2,7,8,19,16,25],[ebqn_array:get(2,Runtime),ebqn_array:get(8,Runtime),ebqn_array:get(15,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(21,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(44,Runtime),ebqn_array:get(46,Runtime),ebqn_array:get(47,Runtime),ebqn_array:get(49,Runtime),ebqn_array:get(55,Runtime),3,4,1,6,8],[[0,1,0,0]]]), %(=¨⟜(⥊⟜(↕×´)3‿4)≡(↕4)=⌜˜4|⊢)1‿6‿8
    ok.

layer3(St0,#a{r=Runtime}) ->
    {_,1} = ebqn:run(St0,[[0,2,0,1,16,0,0,0,2,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(36,Runtime),2],[[0,1,0,0]]]), %2≡⊑2
    {_,1} = ebqn:run(St0,[[0,2,3,1,0,1,16,0,0,0,2,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(36,Runtime),2],[[0,1,0,0]]]), %2≡⊑⟨2⟩
    {_,1} = ebqn:run(St0,[[0,2,3,1,0,1,16,0,0,0,2,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(36,Runtime),str("ab")],[[0,1,0,0]]]), %"ab"≡⊑⟨"ab"⟩
    {_,1} = ebqn:run(St0,[[0,4,0,1,16,0,2,16,0,0,0,3,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(36,Runtime),0,20],[[0,1,0,0]]]), %0≡⊑↕20
    {_,1} = ebqn:run(St0,[[0,10,0,1,0,9,17,0,2,0,4,0,1,8,0,5,17,0,1,0,6,0,7,0,8,3,3,17,0,3,16,0,0,0,5,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(23,Runtime),ebqn_array:get(36,Runtime),ebqn_array:get(54,Runtime),4,3,2,1,5,0],[[0,1,0,0]]]), %4≡⊑3‿2‿1⥊4⥊⊸∾5⥊0
    {_,1} = ebqn:run(St0,[[0,4,0,1,0,2,17,0,0,0,3,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(36,Runtime),2,char("c"),str("abcd")],[[0,1,0,0]]]), %'c'≡2⊑"abcd"
    {_,1} = ebqn:run(St0,[[0,4,0,1,0,2,17,0,0,0,3,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(36,Runtime),-2,char("c"),str("abcd")],[[0,1,0,0]]]), %'c'≡¯2⊑"abcd"
    {_,1} = ebqn:run(St0,[[0,4,0,1,16,0,2,0,3,17,0,0,0,3,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(36,Runtime),7,10],[[0,1,0,0]]]), %7≡7⊑↕10
    {_,1} = ebqn:run(St0,[[0,4,0,1,16,0,2,0,3,3,1,17,0,0,0,3,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(36,Runtime),7,10],[[0,1,0,0]]]), %7≡⟨7⟩⊑↕10
    {_,1} = ebqn:run(St0,[[0,5,0,1,16,0,2,0,4,17,0,0,0,3,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(36,Runtime),0,-10,10],[[0,1,0,0]]]), %0≡¯10⊑↕10
    ok = try ebqn:run(St0,[[0,2,0,0,16,0,1,0,2,17,25],[ebqn_array:get(27,Runtime),ebqn_array:get(36,Runtime),10],[[0,1,0,0]]]) % 10⊑↕10
        catch _ -> ok
    end,
    ok = try ebqn:run(St0,[[0,3,0,0,16,0,1,0,2,17,25],[ebqn_array:get(27,Runtime),ebqn_array:get(36,Runtime),-11,10],[[0,1,0,0]]]) % ¯11⊑↕10
        catch _ -> ok
    end,
    ok = try ebqn:run(St0,[[0,3,0,0,16,0,1,0,2,17,25],[ebqn_array:get(27,Runtime),ebqn_array:get(36,Runtime),0.5,10],[[0,1,0,0]]]) % 0.5⊑↕10
        catch _ -> ok
    end,
    ok = try ebqn:run(St0,[[0,2,0,0,16,0,1,0,3,17,25],[ebqn_array:get(27,Runtime),ebqn_array:get(36,Runtime),10,char("x")],[[0,1,0,0]]]) % 'x'⊑↕10
        catch _ -> ok
    end,
    ok = try ebqn:run(St0,[[0,2,0,0,16,0,1,3,0,17,25],[ebqn_array:get(27,Runtime),ebqn_array:get(36,Runtime),10],[[0,1,0,0]]]) % ⟨⟩⊑↕10
        catch _ -> ok
    end,
    {_,1} = ebqn:run(St0,[[0,11,0,3,16,0,5,0,0,7,0,10,0,3,16,0,1,0,9,17,17,0,4,0,7,0,8,3,2,17,0,2,0,6,17,25],[ebqn_array:get(0,Runtime),ebqn_array:get(2,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(36,Runtime),ebqn_array:get(47,Runtime),21,2,-3,10,3,4],[[0,1,0,0]]]), %21≡2‿¯3⊑(10×↕3)+⌜↕4
    ok = try ebqn:run(St0,[[0,7,0,1,0,4,0,3,0,0,7,8,0,6,17,0,2,0,5,17,25],[ebqn_array:get(0,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(36,Runtime),ebqn_array:get(47,Runtime),ebqn_array:get(53,Runtime),2,3,4],[[0,1,0,0]]]) % 2⊑3+⌜○↕4
        catch _ -> ok
    end,
    {_,1} = ebqn:run(St0,[[0,15,0,3,16,0,5,0,0,7,0,8,0,3,16,0,1,0,14,17,17,0,4,0,9,0,10,3,2,0,11,0,9,3,2,0,12,0,13,3,2,3,3,17,0,2,0,6,0,7,0,8,3,3,17,25],[ebqn_array:get(0,Runtime),ebqn_array:get(2,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(36,Runtime),ebqn_array:get(47,Runtime),21,12,3,2,-3,1,0,-1,10,4],[[0,1,0,0]]]), %21‿12‿03≡⟨2‿¯3,1‿2,0‿¯1⟩⊑(10×↕3)+⌜↕4
    ok = try ebqn:run(St0,[[0,15,0,3,16,0,5,0,0,7,0,8,0,3,16,0,1,0,14,17,17,0,4,0,9,0,10,0,11,3,3,0,12,0,9,3,2,0,11,0,13,3,2,3,3,17,0,2,0,6,0,7,0,8,3,3,17,25],[ebqn_array:get(0,Runtime),ebqn_array:get(2,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(36,Runtime),ebqn_array:get(47,Runtime),21,12,3,2,-3,0,1,-1,10,4],[[0,1,0,0]]]) % 21‿12‿03≡⟨2‿¯3‿0,1‿2,0‿¯1⟩⊑(10×↕3)+⌜↕4
        catch _ -> ok
    end,
    ok = try ebqn:run(St0,[[0,4,0,0,16,0,1,0,2,0,3,3,1,3,2,17,25],[ebqn_array:get(27,Runtime),ebqn_array:get(36,Runtime),2,3,4],[[0,1,0,0]]]) % ⟨2,⟨3⟩⟩⊑↕4
        catch _ -> ok
    end,
    ok = try ebqn:run(St0,[[0,4,0,1,16,0,2,0,3,0,0,16,17,25],[ebqn_array:get(12,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(36,Runtime),2,4],[[0,1,0,0]]]) % (<2)⊑↕4
        catch _ -> ok
    end,
    ok = try ebqn:run(St0,[[0,4,0,1,16,0,2,0,3,0,0,16,0,0,16,17,25],[ebqn_array:get(24,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(36,Runtime),2,4],[[0,1,0,0]]]) % (≍≍2)⊑↕4
        catch _ -> ok
    end,
    {_,1} = ebqn:run(St0,[[0,10,0,3,0,5,0,6,0,7,0,8,3,4,0,0,16,0,4,0,2,7,16,17,0,1,0,9,17,25],[ebqn_array:get(1,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(36,Runtime),ebqn_array:get(46,Runtime),3,1,2,5,str("dfeb"),str("abcdef")],[[0,1,0,0]]]), %"dfeb"≡(⥊¨-⟨3,1,2,5⟩)⊑"abcdef"
    {_,1} = ebqn:run(St0,[[0,3,0,0,16,0,2,3,0,17,0,1,0,3,17,25],[ebqn_array:get(12,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(36,Runtime),str("abc")],[[0,1,0,0]]]), %"abc"≡⟨⟩⊑<"abc"
    {_,1} = ebqn:run(St0,[[0,2,0,1,3,0,17,0,0,0,2,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(36,Runtime),char("a")],[[0,1,0,0]]]), %'a'≡⟨⟩⊑'a'
    {_,1} = ebqn:run(St0,[[0,3,0,0,16,0,2,3,0,3,0,3,0,3,2,3,0,3,3,17,0,1,0,3,0,3,0,3,3,2,0,3,3,3,17,25],[ebqn_array:get(12,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(36,Runtime),7],[[0,1,0,0]]]), %⟨7,7‿7,7⟩≡⟨⟨⟩,⟨⟨⟩,⟨⟩⟩,⟨⟩⟩⊑<7
    {_,1} = ebqn:run(St0,[[0,3,0,2,3,0,3,0,3,0,0,0,16,3,2,3,2,17,0,1,0,3,0,3,0,3,0,0,16,3,2,3,2,17,25],[ebqn_array:get(12,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(36,Runtime),7],[[0,1,0,0]]]), %⟨7,⟨7,<7⟩⟩≡⟨⟨⟩,⟨⟨⟩,<⟨⟩⟩⟩⊑7
    {_,1} = ebqn:run(St0,[[0,8,0,1,0,6,0,6,3,2,17,0,3,0,4,0,5,3,2,0,2,16,17,0,1,16,0,0,0,7,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(36,Runtime),2,3,5,str("abcfab"),str("abcdef")],[[0,1,0,0]]]), %"abcfab"≡⥊(↕2‿3)⊑5‿5⥊"abcdef"
    {_,1} = ebqn:run(St0,[[0,9,0,2,0,7,0,7,3,2,17,0,4,0,5,0,6,3,2,0,3,16,0,0,16,17,0,2,16,0,1,0,8,17,25],[ebqn_array:get(1,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(36,Runtime),2,3,5,str("aedcaf"),str("abcdef")],[[0,1,0,0]]]), %"aedcaf"≡⥊(-↕2‿3)⊑5‿5⥊"abcdef"
    ok = try ebqn:run(St0,[[0,1,0,0,16,25],[ebqn_array:get(27,Runtime),char("\0")],[[0,1,0,0]]]) % ↕@
        catch _ -> ok
    end,
    ok = try ebqn:run(St0,[[0,1,0,0,16,25],[ebqn_array:get(27,Runtime),2.4],[[0,1,0,0]]]) % ↕2.4
        catch _ -> ok
    end,
    ok = try ebqn:run(St0,[[0,2,0,0,16,0,1,16,25],[ebqn_array:get(12,Runtime),ebqn_array:get(27,Runtime),6],[[0,1,0,0]]]) % ↕<6
        catch _ -> ok
    end,
    ok = try ebqn:run(St0,[[0,2,0,3,3,2,0,0,16,0,1,16,25],[ebqn_array:get(24,Runtime),ebqn_array:get(27,Runtime),2,3],[[0,1,0,0]]]) % ↕≍2‿3
        catch _ -> ok
    end,
    ok = try ebqn:run(St0,[[0,1,0,2,3,2,0,0,16,25],[ebqn_array:get(27,Runtime),-1,2],[[0,1,0,0]]]) % ↕¯1‿2
        catch _ -> ok
    end,
    {_,1} = ebqn:run(St0,[[0,9,0,3,0,8,0,3,0,6,17,17,0,2,0,5,0,4,0,5,0,0,8,8,0,1,0,4,19,0,7,0,3,0,6,17,0,0,16,17,25],[ebqn_array:get(12,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(21,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(36,Runtime),ebqn_array:get(52,Runtime),6,0,1,5],[[0,1,0,0]]]), %(<6⥊0)(⊑≡<∘⊑∘⊢)(6⥊1)⥊5
    {_,1} = ebqn:run(St0,[[0,8,0,6,0,6,0,0,0,6,3,4,0,2,0,7,0,7,3,2,17,0,3,0,5,0,6,3,2,8,16,0,1,0,4,17,25],[ebqn_array:get(1,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(58,Runtime),-6,1,0,2,6],[[0,1,0,0]]]), %¯6≡1‿0◶(2‿2⥊0‿0‿-‿0)6
    ok = try ebqn:run(St0,[[0,5,0,2,0,1,3,2,0,4,0,3,0,0,7,8,16,25],[ebqn_array:get(1,Runtime),ebqn_array:get(2,Runtime),ebqn_array:get(3,Runtime),ebqn_array:get(43,Runtime),ebqn_array:get(58,Runtime),4],[[0,1,0,0]]]) % -˙◶÷‿× 4
        catch _ -> ok
    end,
    {_,1} = ebqn:run(St0,[[0,2,0,1,16,0,0,0,2,3,1,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),3],[[0,1,0,0]]]), %⟨3⟩≡⥊3
    {_,1} = ebqn:run(St0,[[0,4,0,0,0,1,0,2,0,3,3,0,8,19,16,25],[ebqn_array:get(12,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(54,Runtime),3],[[0,1,0,0]]]), %(⟨⟩⊸⥊≡<)3
    {_,1} = ebqn:run(St0,[[0,2,0,1,0,2,17,0,0,0,2,0,2,0,2,3,3,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),3],[[0,1,0,0]]]), %⟨3,3,3⟩≡3⥊3
    {_,1} = ebqn:run(St0,[[0,4,0,2,0,3,0,0,8,0,4,17,0,1,0,4,0,4,0,4,3,3,17,25],[ebqn_array:get(12,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(54,Runtime),3],[[0,1,0,0]]]), %⟨3,3,3⟩≡3<⊸⥊3
    ok = try ebqn:run(St0,[[0,2,0,0,0,1,17,25],[ebqn_array:get(22,Runtime),-3,3],[[0,1,0,0]]]) % ¯3⥊3
        catch _ -> ok
    end,
    ok = try ebqn:run(St0,[[0,4,0,1,16,0,0,0,2,0,3,3,2,17,25],[ebqn_array:get(22,Runtime),ebqn_array:get(27,Runtime),1.6,2.5,4],[[0,1,0,0]]]) % 1.6‿2.5⥊↕4
        catch _ -> ok
    end,
    ok = try ebqn:run(St0,[[0,4,0,2,16,0,0,0,3,0,4,3,2,0,1,16,17,25],[ebqn_array:get(22,Runtime),ebqn_array:get(24,Runtime),ebqn_array:get(27,Runtime),2,3],[[0,1,0,0]]]) % (≍2‿3)⥊↕3
        catch _ -> ok
    end,
    {_,1} = ebqn:run(St0,[[0,9,0,5,0,7,0,2,0,3,0,1,0,7,0,4,8,19,0,0,0,6,0,2,7,19,8,0,8,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(19,Runtime),ebqn_array:get(21,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(23,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(47,Runtime),ebqn_array:get(53,Runtime),6,3],[[0,1,0,0]]]), %6(⊢⌜≡∾○≢⥊⊢)○↕3
    {_,1} = ebqn:run(St0,[[3,0,0,2,0,1,0,0,19,16,25],[ebqn_array:get(12,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(27,Runtime)],[[0,1,0,0]]]), %(<≡↕)⟨⟩
    {_,1} = ebqn:run(St0,[[0,5,0,2,0,4,0,3,0,1,7,8,0,0,0,1,0,4,0,2,8,19,16,25],[ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(46,Runtime),ebqn_array:get(52,Runtime),9],[[0,1,0,0]]]), %(↕∘⥊≡⥊¨∘↕)9
    {_,1} = ebqn:run(St0,[[0,8,0,8,0,3,16,0,9,0,8,3,2,0,3,16,3,3,0,4,0,2,0,1,0,2,0,7,0,6,3,1,8,19,7,16,0,5,0,0,7,16,25],[ebqn_array:get(10,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(46,Runtime),ebqn_array:get(49,Runtime),ebqn_array:get(52,Runtime),ebqn_array:get(54,Runtime),4,2],[[0,1,0,0]]]), %∧´(⟨∘⟩⊸⥊≡⥊)¨ ⟨4,↕4,↕2‿4⟩
    ok = try ebqn:run(St0,[[0,4,0,1,16,0,0,0,3,0,2,3,2,17,25],[ebqn_array:get(22,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(52,Runtime),4,15],[[0,1,0,0]]]) % 4‿∘⥊↕15
        catch _ -> ok
    end,
    {_,1} = ebqn:run(St0,[[0,12,0,5,16,0,0,0,7,17,0,3,0,9,0,1,3,2,17,0,3,0,4,0,12,3,2,17,0,3,0,11,0,6,3,2,17,0,3,16,0,2,0,7,0,8,0,9,0,10,0,7,3,5,17,25],[ebqn_array:get(0,Runtime),ebqn_array:get(6,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(25,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(30,Runtime),1,2,3,0,5,4],[[0,1,0,0]]]), %1‿2‿3‿0‿1≡⥊5‿⌽⥊↑‿4⥊3‿⌊⥊1+↕4
    {_,1} = ebqn:run(St0,[[0,10,0,3,16,0,0,16,0,5,0,2,7,0,7,0,4,0,8,3,3,0,7,0,9,0,8,3,3,3,2,17,0,6,0,1,7,16,25],[ebqn_array:get(12,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(30,Runtime),ebqn_array:get(46,Runtime),ebqn_array:get(49,Runtime),2,4,3,19],[[0,1,0,0]]]), %≡´⟨2‿⌽‿4,2‿3‿4⟩⥊¨<↕19
    {_,1} = ebqn:run(St0,[[0,3,0,1,16,0,2,0,3,17,0,0,16,25],[ebqn_array:get(9,Runtime),ebqn_array:get(12,Runtime),ebqn_array:get(18,Runtime),char("a")],[[0,1,0,0]]]), %¬'a'≡<'a'
    {_,1} = ebqn:run(St0,[[0,3,0,2,16,0,1,0,3,17,0,0,16,25],[ebqn_array:get(9,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(24,Runtime),str("a")],[[0,1,0,0]]]), %¬"a"≡≍"a"
    {_,1} = ebqn:run(St0,[[0,5,0,6,0,9,0,7,3,2,0,8,3,4,0,2,0,4,0,6,0,6,3,2,8,0,3,0,1,8,0,5,0,6,0,7,0,7,3,2,0,8,3,4,17,0,0,16,25],[ebqn_array:get(9,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(53,Runtime),ebqn_array:get(54,Runtime),1,2,4,5,3],[[0,1,0,0]]]), %¬⟨1,2,⟨4,4⟩,5⟩≡○(2‿2⊸⥊)⟨1,2,⟨3,4⟩,5⟩
    {_,1} = ebqn:run(St0,[[0,2,0,3,3,2,0,1,0,2,0,3,0,4,3,3,17,0,0,16,25],[ebqn_array:get(9,Runtime),ebqn_array:get(18,Runtime),2,3,4],[[0,1,0,0]]]), %¬2‿3‿4≡2‿3
    {_,1} = ebqn:run(St0,[[0,3,0,1,0,2,17,0,0,16,25],[ebqn_array:get(9,Runtime),ebqn_array:get(18,Runtime),1.001,1.002],[[0,1,0,0]]]), %¬1.001≡1.002
    {_,1} = ebqn:run(St0,[[0,1,0,0,0,2,17,25],[ebqn_array:get(19,Runtime),2,char("a")],[[0,1,0,0]]]), %'a'≢2
    {_,1} = ebqn:run(St0,[[0,2,0,0,16,0,0,0,1,17,25],[ebqn_array:get(18,Runtime),0,char("a")],[[0,1,0,0]]]), %0≡≡'a'
    {_,1} = ebqn:run(St0,[[0,3,0,1,16,0,0,16,0,0,0,2,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(27,Runtime),1,6],[[0,1,0,0]]]), %1≡≡↕6
    {_,1} = ebqn:run(St0,[[0,2,0,3,3,2,0,1,16,0,0,16,0,0,0,2,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(27,Runtime),2,4],[[0,1,0,0]]]), %2≡≡↕2‿4
    {_,1} = ebqn:run(St0,[[0,3,0,0,16,0,0,16,0,0,16,0,1,16,0,1,0,2,17,25],[ebqn_array:get(12,Runtime),ebqn_array:get(18,Runtime),3,4],[[0,1,0,0]]]), %3≡≡<<<4
    {_,1} = ebqn:run(St0,[[0,8,3,0,0,7,3,1,0,9,0,10,0,11,3,2,3,5,0,4,0,2,0,6,0,3,0,1,0,5,0,0,8,7,8,7,0,1,0,4,0,7,7,19,16,25],[ebqn_array:get(1,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(44,Runtime),ebqn_array:get(46,Runtime),ebqn_array:get(53,Runtime),ebqn_array:get(55,Runtime),1,0,2,3,4],[[0,1,0,0]]]), %(1¨≡-○≡˜⟜↕¨)⟨0,⟨⟩,⟨1⟩,2,⟨3,4⟩⟩
    {_,1} = ebqn:run(St0,[[0,3,0,4,0,0,0,2,3,3,3,2,0,1,16,0,1,0,2,17,25],[ebqn_array:get(0,Runtime),ebqn_array:get(18,Runtime),2,5,char("c")],[[0,1,0,0]]]), %2≡≡⟨5,⟨'c',+,2⟩⟩
    {_,1} = ebqn:run(St0,[[0,0,3,1,0,2,16,0,1,16,0,1,0,3,17,25],[ebqn_array:get(1,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(36,Runtime),0],[[0,1,0,0]]]), %0≡≡⊑⟨-⟩
    ok.

layer4(St0,#a{r=Runtime}) ->
    {_,1} = ebqn:run(St0,[[0,9,0,14,0,1,16,0,10,0,1,16,0,11,0,5,16,0,13,0,4,0,11,0,12,3,2,17,3,5,0,6,0,2,0,8,0,3,8,7,16,0,7,0,0,7,16,25],[ebqn_array:get(10,Runtime),ebqn_array:get(12,Runtime),ebqn_array:get(13,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(46,Runtime),ebqn_array:get(49,Runtime),ebqn_array:get(55,Runtime),1,inf,5,3,2,char("a")],[[0,1,0,0]]]), %∧´≡⟜>¨⟨1,<'a',<∞,↕5,5‿3⥊2⟩
    {_,1} = ebqn:run(St0,[[0,4,0,5,3,2,0,3,16,0,0,16,0,2,16,0,1,0,4,0,5,0,4,3,3,17,25],[ebqn_array:get(13,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(19,Runtime),ebqn_array:get(27,Runtime),2,3],[[0,1,0,0]]]), %2‿3‿2≡≢>↕2‿3
    {_,1} = ebqn:run(St0,[[0,3,0,0,16,0,4,3,2,0,1,16,0,2,0,3,0,4,3,2,17,25],[ebqn_array:get(12,Runtime),ebqn_array:get(13,Runtime),ebqn_array:get(18,Runtime),2,3],[[0,1,0,0]]]), %2‿3≡>⟨<2,3⟩
    ok = try ebqn:run(St0,[[0,3,0,4,3,2,0,2,0,1,7,16,0,0,16,25],[ebqn_array:get(13,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(46,Runtime),2,3],[[0,1,0,0]]]) % >↕¨2‿3
        catch _ -> ok
    end,
    ok = try ebqn:run(St0,[[0,2,0,1,16,0,3,3,2,0,0,16,25],[ebqn_array:get(13,Runtime),ebqn_array:get(22,Runtime),2,3],[[0,1,0,0]]]) % >⟨⥊2,3⟩
        catch _ -> ok
    end,
    ok = try ebqn:run(St0,[[0,6,0,4,16,0,2,0,0,0,5,0,3,8,0,3,19,16,0,1,16,25],[ebqn_array:get(12,Runtime),ebqn_array:get(13,Runtime),ebqn_array:get(21,Runtime),ebqn_array:get(24,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(53,Runtime),4],[[0,1,0,0]]]) % >(≍≍○<⊢)↕4
        catch _ -> ok
    end,
    {_,1} = ebqn:run(St0,[[0,8,0,3,0,4,0,7,0,7,3,2,19,0,0,9,0,4,0,7,0,7,3,2,19,0,1,9,0,2,0,4,0,5,0,7,0,4,0,6,17,8,19,16,25],[ebqn_array:get(12,Runtime),ebqn_array:get(13,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(21,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(54,Runtime),4,2,str("abcd")],[[0,1,0,0]]]), %((4⥊2)⊸⥊≡(>2‿2⥊·<2‿2⥊⊢))"abcd"
    {_,1} = ebqn:run(St0,[[0,9,0,5,16,0,4,0,7,0,8,3,2,17,0,0,0,6,0,1,8,0,2,0,3,19,16,25],[ebqn_array:get(12,Runtime),ebqn_array:get(13,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(21,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(52,Runtime),5,3,15],[[0,1,0,0]]]), %(⊢≡>∘<)5‿3⥊↕15
    {_,1} = ebqn:run(St0,[[0,9,0,5,16,0,4,0,7,0,8,3,2,17,0,6,0,0,7,0,1,9,0,2,0,3,19,16,25],[ebqn_array:get(12,Runtime),ebqn_array:get(13,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(21,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(46,Runtime),5,3,15],[[0,1,0,0]]]), %(⊢≡(><¨))5‿3⥊↕15
    {_,1} = ebqn:run(St0,[[0,3,0,2,0,0,0,1,19,16,25],[ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(24,Runtime),char("a")],[[0,1,0,0]]]), %(⥊≡≍)'a'
    {_,1} = ebqn:run(St0,[[0,4,0,0,16,0,3,0,1,0,2,19,16,25],[ebqn_array:get(12,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(24,Runtime),char("a")],[[0,1,0,0]]]), %(⥊≡≍)<'a'
    {_,1} = ebqn:run(St0,[[0,6,0,2,0,0,0,1,0,3,0,4,0,5,3,2,8,19,16,25],[ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(24,Runtime),ebqn_array:get(54,Runtime),1,2,str("ab")],[[0,1,0,0]]]), %(1‿2⊸⥊≡≍)"ab"
    {_,1} = ebqn:run(St0,[[0,3,0,1,0,2,17,0,0,0,2,0,3,3,2,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(24,Runtime),1,2],[[0,1,0,0]]]), %1‿2≡1≍2
    {_,1} = ebqn:run(St0,[[0,6,0,7,3,2,0,2,0,1,0,4,0,4,3,2,19,0,0,0,3,19,0,4,0,5,3,2,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(23,Runtime),ebqn_array:get(24,Runtime),2,1,4,3],[[0,1,0,0]]]), %2‿1(≍≡2‿2⥊∾)4‿3
    {_,1} = ebqn:run(St0,[[0,5,0,3,0,2,7,0,1,0,0,0,4,0,2,8,19,16,25],[ebqn_array:get(12,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(24,Runtime),ebqn_array:get(44,Runtime),ebqn_array:get(55,Runtime),char("a")],[[0,1,0,0]]]), %(≍⟜<≡≍˜)'a'
    ok = try ebqn:run(St0,[[0,1,0,3,0,4,3,3,0,0,0,1,0,2,3,2,17,25],[ebqn_array:get(24,Runtime),1,0,2,3],[[0,1,0,0]]]) % 1‿0≍1‿2‿3
        catch _ -> ok
    end,
    ok = try ebqn:run(St0,[[0,3,0,1,16,0,0,0,2,0,0,8,16,25],[ebqn_array:get(24,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(55,Runtime),3],[[0,1,0,0]]]) % ≍⟜≍↕3
        catch _ -> ok
    end,
    ok = try ebqn:run(St0,[[0,4,0,0,16,0,3,0,2,0,1,8,16,25],[ebqn_array:get(27,Runtime),ebqn_array:get(30,Runtime),ebqn_array:get(59,Runtime),1.1,4],[[0,1,0,0]]]) % ⌽⎉1.1 ↕4
        catch _ -> ok
    end,
    ok = try ebqn:run(St0,[[0,3,0,0,16,0,4,0,2,0,1,8,16,25],[ebqn_array:get(27,Runtime),ebqn_array:get(30,Runtime),ebqn_array:get(59,Runtime),4,char("x")],[[0,1,0,0]]]) % ⌽⎉'x' ↕4
        catch _ -> ok
    end,
    ok = try ebqn:run(St0,[[0,5,0,1,16,0,4,0,0,16,0,0,16,0,3,0,2,8,16,25],[ebqn_array:get(12,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(30,Runtime),ebqn_array:get(59,Runtime),0,4],[[0,1,0,0]]]) % ⌽⎉(<<0) ↕4
        catch _ -> ok
    end,
    ok = try ebqn:run(St0,[[0,4,0,1,16,0,0,0,3,0,2,8,16,25],[ebqn_array:get(24,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(30,Runtime),ebqn_array:get(59,Runtime),4],[[0,1,0,0]]]) % ⌽⎉≍ ↕4
        catch _ -> ok
    end,
    {_,1} = ebqn:run(St0,[[0,17,0,16,0,13,3,3,0,9,0,1,7,0,5,9,0,11,0,3,8,16,0,0,0,10,0,16,0,12,0,6,8,8,16,0,2,0,13,0,14,0,15,3,3,0,8,0,3,7,16,0,7,0,8,0,4,7,7,16,17,25],[ebqn_array:get(0,Runtime),ebqn_array:get(2,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(24,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(30,Runtime),ebqn_array:get(44,Runtime),ebqn_array:get(45,Runtime),ebqn_array:get(49,Runtime),ebqn_array:get(54,Runtime),ebqn_array:get(55,Runtime),ebqn_array:get(59,Runtime),1,5,9,2,3],[[0,1,0,0]]]), %(≍˘˜⥊˘1‿5‿9)≡⌽⎉2⊸+⥊⟜(↕×´)3‿2‿1
    {_,1} = ebqn:run(St0,[[0,3,0,2,0,1,7,16,0,1,0,3,0,0,16,17,25],[ebqn_array:get(12,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(45,Runtime),0],[[0,1,0,0]]]), %(<0)≡≡˘0
    {_,1} = ebqn:run(St0,[[0,4,0,0,16,0,2,0,1,7,16,0,1,0,3,0,0,16,17,25],[ebqn_array:get(12,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(45,Runtime),1,0],[[0,1,0,0]]]), %(<1)≡≡˘<0
    {_,1} = ebqn:run(St0,[[0,8,0,2,16,0,6,0,7,3,2,0,4,0,0,8,0,1,0,3,0,0,7,19,0,5,0,2,16,17,25],[ebqn_array:get(2,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(47,Runtime),ebqn_array:get(59,Runtime),4,0,2,5],[[0,1,0,0]]]), %(↕4)(×⌜≡×⎉0‿2)↕5
    {_,1} = ebqn:run(St0,[[0,9,0,2,16,0,7,0,8,3,2,0,5,0,0,8,0,1,0,3,0,4,0,3,0,0,7,7,7,19,0,6,0,2,16,17,25],[ebqn_array:get(4,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(44,Runtime),ebqn_array:get(47,Runtime),ebqn_array:get(59,Runtime),4,inf,-4,5],[[0,1,0,0]]]), %(↕4)(⋆˜⌜˜≡⋆⎉∞‿¯4)↕5
    {_,1} = ebqn:run(St0,[[0,18,0,7,16,0,19,0,7,16,0,4,0,15,0,18,3,2,17,3,2,0,8,0,10,0,1,0,11,0,0,8,0,13,0,6,8,7,7,16,0,9,0,3,7,16,0,2,0,15,0,18,3,2,0,16,0,17,0,17,0,17,3,4,0,4,0,15,0,15,3,2,17,0,14,0,5,0,12,0,15,3,1,8,8,16,17,25],[ebqn_array:get(6,Runtime),ebqn_array:get(15,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(19,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(23,Runtime),ebqn_array:get(24,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(44,Runtime),ebqn_array:get(46,Runtime),ebqn_array:get(47,Runtime),ebqn_array:get(53,Runtime),ebqn_array:get(54,Runtime),ebqn_array:get(59,Runtime),ebqn_array:get(61,Runtime),2,0,1,3,6],[[0,1,0,0]]]), %(⟨2⟩⊸∾⍟(2‿2⥊0‿1‿1‿1)2‿3)≡≢¨≍⎉(⌊○=)⌜˜⟨↕3,2‿3⥊↕6⟩
    {_,1} = ebqn:run(St0,[[0,11,0,2,0,7,0,8,0,9,3,3,17,0,10,0,6,0,1,8,0,11,0,2,0,7,0,9,3,2,17,17,0,1,0,8,0,3,0,5,0,4,0,0,7,8,0,7,17,17,25],[ebqn_array:get(15,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(47,Runtime),ebqn_array:get(53,Runtime),ebqn_array:get(59,Runtime),2,3,4,1,str("abc")],[[0,1,0,0]]]), %(2=⌜○↕3)≡(2‿4⥊"abc")≡⎉1(2‿3‿4⥊"abc")
    {_,1} = ebqn:run(St0,[[0,8,0,1,0,4,0,7,0,5,3,3,17,0,6,0,2,0,0,8,0,8,0,1,0,4,0,5,3,2,17,17,0,0,0,3,0,3,3,2,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(59,Runtime),0,2,4,-1,3,str("abc")],[[0,1,0,0]]]), %⟨0,0⟩≡(2‿4⥊"abc")≡⎉¯1(2‿3‿4⥊"abc")
    ok = try ebqn:run(St0,[[0,5,0,0,16,0,3,0,4,3,2,0,2,0,1,8,16,25],[ebqn_array:get(27,Runtime),ebqn_array:get(30,Runtime),ebqn_array:get(60,Runtime),2,2.5,3],[[0,1,0,0]]]) % ⌽⚇2‿2.5 ↕3
        catch _ -> ok
    end,
    {_,1} = ebqn:run(St0,[[0,4,0,3,0,2,0,0,8,0,1,0,0,19,16,25],[ebqn_array:get(1,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(60,Runtime),-1,5],[[0,1,0,0]]]), %(-≡-⚇¯1)5
    {_,1} = ebqn:run(St0,[[0,7,0,8,3,2,0,9,0,4,0,10,3,3,0,6,3,1,3,2,3,2,0,6,0,3,0,2,0,0,7,8,16,0,1,0,4,0,5,0,6,3,2,3,2,17,25],[ebqn_array:get(0,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(49,Runtime),ebqn_array:get(60,Runtime),5,15,1,3,2,4,6],[[0,1,0,0]]]), %⟨5,⟨15,1⟩⟩≡+´⚇1⟨⟨3,2⟩,⟨⟨4,5,6⟩,⟨1⟩⟩⟩
    {_,1} = ebqn:run(St0,[[0,13,0,14,3,2,0,15,0,7,0,8,3,3,3,2,0,12,0,10,3,2,0,6,0,3,0,5,0,2,8,8,0,11,0,10,3,2,3,0,3,1,3,2,17,0,10,0,6,0,4,0,0,7,8,16,0,4,0,3,7,16,0,1,0,7,0,8,0,9,3,3,17,25],[ebqn_array:get(0,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(23,Runtime),ebqn_array:get(49,Runtime),ebqn_array:get(54,Runtime),ebqn_array:get(60,Runtime),5,6,15,1,0,-2,2,3,4],[[0,1,0,0]]]), %5‿6‿15≡∾´+´⚇1⟨⟨0,1⟩,⟨⟨⟩⟩⟩⥊⊸∾⚇¯2‿1⟨⟨2,3⟩,⟨4,5,6⟩⟩
    ok = try ebqn:run(St0,[[0,4,0,3,0,5,3,2,0,1,0,0,8,0,2,17,25],[ebqn_array:get(0,Runtime),ebqn_array:get(61,Runtime),2,1,4,char("c")],[[0,1,0,0]]]) % 2+⍟1‿'c'4
        catch _ -> ok
    end,
    ok = try ebqn:run(St0,[[0,3,0,2,0,1,0,0,8,16,25],[ebqn_array:get(4,Runtime),ebqn_array:get(61,Runtime),1.5,2],[[0,1,0,0]]]) % ⋆⍟1.5 2
        catch _ -> ok
    end,
    {_,1} = ebqn:run(St0,[[0,6,0,5,0,2,0,0,8,0,4,17,0,1,0,3,17,25],[ebqn_array:get(0,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(61,Runtime),4,2,-1,6],[[0,1,0,0]]]), %4≡2+⍟¯1 6
    {_,1} = ebqn:run(St0,[[0,8,0,6,0,3,16,0,0,0,7,17,0,4,0,0,8,0,5,17,0,2,0,6,0,3,16,0,1,0,5,17,17,25],[ebqn_array:get(0,Runtime),ebqn_array:get(2,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(61,Runtime),2,7,-3,6],[[0,1,0,0]]]), %(2×↕7)≡2+⍟(¯3+↕7)6
    {_,1} = ebqn:run(St0,[[0,8,15,1,16,0,2,0,7,0,4,16,0,1,0,6,17,17,25,0,8,22,0,3,11,14,21,0,1,0,10,0,4,16,0,5,15,2,8,16,22,0,4,11,14,21,0,3,0,3,21,0,4,17,25,0,9,0,0,22,1,3,13,14,21,0,1,0,0,0,9,17,25],[ebqn_array:get(0,Runtime),ebqn_array:get(6,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(23,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(61,Runtime),3,5,0,1,4],[[0,1,0,0],[0,0,19,5],[0,0,55,3]]]), %(3⌊↕5)≡{i←0⋄r←{i+↩1⋄1+𝕩}⍟(↕4)𝕩⋄r∾i}0
    {_,1} = ebqn:run(St0,[[0,9,0,4,16,0,3,0,3,0,7,0,0,8,0,8,19,0,1,9,0,2,0,5,0,6,0,0,7,7,19,16,25],[ebqn_array:get(0,Runtime),ebqn_array:get(13,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(21,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(44,Runtime),ebqn_array:get(47,Runtime),ebqn_array:get(61,Runtime),1,5],[[0,1,0,0]]]), %(+⌜˜≡·>1+⍟⊢⊢)↕5
    {_,1} = ebqn:run(St0,[[0,9,0,2,16,0,3,0,0,7,16,0,1,0,4,0,5,0,6,0,7,0,8,3,5,17,25],[ebqn_array:get(0,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(51,Runtime),0,1,3,6,10,5],[[0,1,0,0]]]), %0‿1‿3‿6‿10≡+`↕5
    {_,1} = ebqn:run(St0,[[0,9,0,2,16,0,3,0,0,7,16,0,1,0,4,0,5,0,6,0,7,0,8,3,5,0,0,16,17,25],[ebqn_array:get(1,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(51,Runtime),0,1,3,6,10,5],[[0,1,0,0]]]), %(-0‿1‿3‿6‿10)≡-`↕5
    {_,1} = ebqn:run(St0,[[0,9,0,8,3,2,0,4,16,0,6,0,0,7,16,0,0,0,7,0,1,0,8,17,0,3,0,8,0,4,16,0,5,0,2,7,0,7,17,17,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(23,Runtime),ebqn_array:get(24,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(46,Runtime),ebqn_array:get(51,Runtime),0,3,2],[[0,1,0,0]]]), %((0∾¨↕3)≍3⥊0)≡≡`↕2‿3
    {_,1} = ebqn:run(St0,[[3,0,0,2,0,0,7,16,0,1,3,0,17,25],[ebqn_array:get(2,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(51,Runtime)],[[0,1,0,0]]]), %⟨⟩≡×`⟨⟩
    {_,1} = ebqn:run(St0,[[0,9,0,1,0,7,0,6,0,8,3,3,17,0,3,0,6,0,4,0,2,8,7,0,5,0,0,8,16,25],[ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(42,Runtime),ebqn_array:get(51,Runtime),ebqn_array:get(52,Runtime),ebqn_array:get(55,Runtime),0,3,2,str("")],[[0,1,0,0]]]), %≡⟜(!∘0`)3‿0‿2⥊""
    ok = try ebqn:run(St0,[[0,2,0,1,0,0,7,16,25],[ebqn_array:get(0,Runtime),ebqn_array:get(51,Runtime),4],[[0,1,0,0]]]) % +`4
        catch _ -> ok
    end,
    ok = try ebqn:run(St0,[[0,3,0,1,16,0,2,0,0,7,16,25],[ebqn_array:get(0,Runtime),ebqn_array:get(12,Runtime),ebqn_array:get(51,Runtime),char("c")],[[0,1,0,0]]]) % +`<'c'
        catch _ -> ok
    end,
    {_,1} = ebqn:run(St0,[[0,6,0,2,16,0,3,0,0,7,0,4,17,0,1,0,4,0,5,0,6,0,7,0,8,3,5,17,25],[ebqn_array:get(0,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(51,Runtime),2,3,5,8,12],[[0,1,0,0]]]), %2‿3‿5‿8‿12≡2+`↕5
    ok = try ebqn:run(St0,[[0,5,0,1,0,4,0,2,0,0,7,8,0,6,17,0,3,0,0,7,0,5,0,6,3,2,17,25],[ebqn_array:get(0,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(47,Runtime),ebqn_array:get(51,Runtime),ebqn_array:get(53,Runtime),3,4],[[0,1,0,0]]]) % 3‿4+`4+⌜○↕3
        catch _ -> ok
    end,
    {_,1} = ebqn:run(St0,[[0,8,0,4,0,7,0,5,0,0,7,8,0,12,17,0,6,0,2,7,0,12,0,13,3,2,17,0,3,0,11,0,8,3,2,0,5,0,1,7,0,9,0,8,0,10,3,3,17,0,2,0,8,17,17,25],[ebqn_array:get(0,Runtime),ebqn_array:get(2,Runtime),ebqn_array:get(4,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(47,Runtime),ebqn_array:get(51,Runtime),ebqn_array:get(53,Runtime),2,1,6,0,3,4],[[0,1,0,0]]]), %(2⋆1‿2‿6×⌜0‿2)≡3‿4⋆`3+⌜○↕2
    ok.

layer5(St0,#a{r=Runtime}) ->
    {_,1} = ebqn:run(St0,[[0,4,0,2,16,0,1,0,3,0,0,16,17,25],[ebqn_array:get(12,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(35,Runtime),char("a"),str("abc")],[[0,1,0,0]]]), %(<'a')≡⊏"abc"
    ok = try ebqn:run(St0,[[0,1,0,0,16,25],[ebqn_array:get(35,Runtime),str("")],[[0,1,0,0]]]) % ⊏""
        catch _ -> ok
    end,
    {_,1} = ebqn:run(St0,[[0,5,0,3,0,1,7,16,0,2,16,0,0,0,4,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(35,Runtime),ebqn_array:get(45,Runtime),str("a"),str("abc")],[[0,1,0,0]]]), %"a"≡⊏⥊˘"abc"
    ok = try ebqn:run(St0,[[0,4,0,0,0,2,0,3,3,2,17,0,1,16,25],[ebqn_array:get(22,Runtime),ebqn_array:get(35,Runtime),0,3,str("")],[[0,1,0,0]]]) % ⊏0‿3⥊""
        catch _ -> ok
    end,
    {_,1} = ebqn:run(St0,[[0,5,0,2,0,3,17,0,1,0,4,0,0,16,17,25],[ebqn_array:get(12,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(35,Runtime),2,char("c"),str("abc")],[[0,1,0,0]]]), %(<'c')≡2⊏"abc"
    ok = try ebqn:run(St0,[[0,2,0,0,0,1,17,25],[ebqn_array:get(35,Runtime),3,str("abc")],[[0,1,0,0]]]) % 3⊏"abc"
        catch _ -> ok
    end,
    ok = try ebqn:run(St0,[[0,2,0,0,0,1,17,25],[ebqn_array:get(35,Runtime),1.5,str("abc")],[[0,1,0,0]]]) % 1.5⊏"abc"
        catch _ -> ok
    end,
    ok = try ebqn:run(St0,[[0,2,0,0,0,1,17,25],[ebqn_array:get(35,Runtime),char("x"),str("abc")],[[0,1,0,0]]]) % 'x'⊏"abc"
        catch _ -> ok
    end,
    {_,1} = ebqn:run(St0,[[0,5,0,2,0,3,17,0,1,0,4,0,0,16,17,25],[ebqn_array:get(12,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(35,Runtime),-1,char("c"),str("abc")],[[0,1,0,0]]]), %(<'c')≡¯1⊏"abc"
    {_,1} = ebqn:run(St0,[[0,5,0,1,0,2,0,3,0,2,3,3,17,0,0,0,4,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(35,Runtime),2,-1,str("ccc"),str("abc")],[[0,1,0,0]]]), %"ccc"≡2‿¯1‿2⊏"abc"
    ok = try ebqn:run(St0,[[0,5,0,1,16,0,2,0,3,0,0,16,0,4,3,2,17,25],[ebqn_array:get(22,Runtime),ebqn_array:get(24,Runtime),ebqn_array:get(35,Runtime),0,1,str("abc")],[[0,1,0,0]]]) % ⟨⥊0,1⟩⊏≍"abc"
        catch _ -> ok
    end,
    {_,1} = ebqn:run(St0,[[0,8,0,9,3,2,0,2,16,0,3,0,6,0,9,8,0,1,0,4,0,6,0,8,0,2,16,0,5,0,0,7,0,7,17,8,19,16,25],[ebqn_array:get(1,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(30,Runtime),ebqn_array:get(35,Runtime),ebqn_array:get(44,Runtime),ebqn_array:get(54,Runtime),3,5,2],[[0,1,0,0]]]), %((3-˜↕5)⊸⊏≡2⊸⌽)↕5‿2
    {_,1} = ebqn:run(St0,[[0,7,0,2,16,0,1,0,6,0,5,3,2,17,0,3,3,0,17,0,0,0,4,0,1,0,4,0,5,3,2,17,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(35,Runtime),0,3,2,6],[[0,1,0,0]]]), %(0‿3⥊0)≡⟨⟩⊏2‿3⥊↕6
    {_,1} = ebqn:run(St0,[[0,17,0,16,3,2,0,8,0,1,7,0,5,9,0,11,0,4,8,16,0,6,0,2,0,3,0,9,0,8,0,7,0,0,0,10,0,16,0,11,0,1,8,8,7,7,8,19,0,12,0,13,3,2,0,14,0,15,0,14,3,3,3,2,17,25],[ebqn_array:get(0,Runtime),ebqn_array:get(2,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(20,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(35,Runtime),ebqn_array:get(47,Runtime),ebqn_array:get(49,Runtime),ebqn_array:get(52,Runtime),ebqn_array:get(54,Runtime),ebqn_array:get(55,Runtime),3,0,2,1,5,6],[[0,1,0,0]]]), %⟨3‿0,2‿1‿2⟩(×⟜5⊸+⌜´∘⊣≡⊏)⥊⟜(↕×´)6‿5
    ok = try ebqn:run(St0,[[0,5,0,1,0,3,0,2,0,0,7,8,0,4,0,4,3,2,17,25],[ebqn_array:get(12,Runtime),ebqn_array:get(35,Runtime),ebqn_array:get(46,Runtime),ebqn_array:get(54,Runtime),0,str("abc")],[[0,1,0,0]]]) % 0‿0<¨⊸⊏"abc"
        catch _ -> ok
    end,
    {_,1} = ebqn:run(St0,[[0,4,0,1,0,7,0,5,3,2,17,0,2,0,5,0,6,3,2,3,0,3,2,17,0,0,0,4,0,1,0,3,0,4,3,2,17,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(35,Runtime),2,0,3,-1,4],[[0,1,0,0]]]), %(2‿0⥊0)≡⟨3‿¯1,⟨⟩⟩⊏4‿3⥊0
    ok = try ebqn:run(St0,[[0,5,0,0,0,4,0,2,3,2,17,0,1,0,2,0,3,3,2,3,0,3,2,17,25],[ebqn_array:get(22,Runtime),ebqn_array:get(35,Runtime),3,ninf,4,0],[[0,1,0,0]]]) % ⟨3‿¯∞,⟨⟩⟩⊏4‿3⥊0
        catch _ -> ok
    end,
    {_,1} = ebqn:run(St0,[[0,7,0,8,3,2,0,2,16,0,3,0,1,0,3,0,4,0,0,8,19,0,5,0,6,3,2,17,25],[ebqn_array:get(12,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(35,Runtime),ebqn_array:get(54,Runtime),5,1,6,2],[[0,1,0,0]]]), %5‿1(<⊸⊏≡⊏)↕6‿2
    ok = try ebqn:run(St0,[[0,6,0,7,3,2,0,2,16,0,3,0,4,0,5,3,2,0,0,16,0,1,16,0,1,16,17,25],[ebqn_array:get(12,Runtime),ebqn_array:get(24,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(35,Runtime),5,1,6,2],[[0,1,0,0]]]) % (≍≍<5‿1)⊏↕6‿2
        catch _ -> ok
    end,
    {_,1} = ebqn:run(St0,[[0,15,0,3,16,0,5,0,6,0,0,7,7,16,0,5,0,6,0,1,7,7,0,9,0,4,8,0,2,0,6,0,1,7,0,8,0,7,0,6,0,0,7,7,8,19,0,10,0,11,3,2,0,12,0,13,0,14,0,13,0,12,0,11,3,6,3,2,17,25],[ebqn_array:get(0,Runtime),ebqn_array:get(2,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(35,Runtime),ebqn_array:get(44,Runtime),ebqn_array:get(47,Runtime),ebqn_array:get(49,Runtime),ebqn_array:get(54,Runtime),ebqn_array:get(55,Runtime),4,0,1,2,3,5],[[0,1,0,0]]]), %⟨4‿0,1‿2‿3‿2‿1‿0⟩(+⌜´⊸(×⌜)≡⊏⟜(×⌜˜))+⌜˜↕5
    {_,1} = ebqn:run(St0,[[0,13,0,0,0,13,0,2,16,0,12,0,8,16,3,4,0,9,0,7,7,0,5,0,9,0,6,7,19,3,0,0,2,16,17,0,9,0,4,7,16,0,3,0,11,17,0,10,0,1,7,16,25],[ebqn_array:get(0,Runtime),ebqn_array:get(10,Runtime),ebqn_array:get(12,Runtime),ebqn_array:get(15,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(23,Runtime),ebqn_array:get(25,Runtime),ebqn_array:get(26,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(46,Runtime),ebqn_array:get(49,Runtime),1,3,char("\0")],[[0,1,0,0]]]), %∧´1=≡¨(<⟨⟩)(↑¨∾↓¨)⟨@,+,<@,↕3⟩
    {_,1} = ebqn:run(St0,[[0,4,0,1,0,2,17,0,0,0,3,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(25,Runtime),3,str("abc"),str("abce")],[[0,1,0,0]]]), %"abc"≡3↑"abce"
    {_,1} = ebqn:run(St0,[[0,4,0,1,0,2,17,0,0,0,3,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(25,Runtime),-1,str("e"),str("abce")],[[0,1,0,0]]]), %"e"≡¯1↑"abce"
    {_,1} = ebqn:run(St0,[[0,4,0,1,0,2,17,0,0,0,3,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(25,Runtime),0,str(""),str("ab")],[[0,1,0,0]]]), %""≡0↑"ab"
    ok = try ebqn:run(St0,[[0,2,0,0,0,1,17,25],[ebqn_array:get(25,Runtime),2.5,str("abce")],[[0,1,0,0]]]) % 2.5↑"abce"
        catch _ -> ok
    end,
    {_,1} = ebqn:run(St0,[[0,7,0,4,16,0,3,0,8,17,0,2,0,8,0,4,16,0,0,0,5,0,7,0,6,0,1,8,8,16,17,25],[ebqn_array:get(2,Runtime),ebqn_array:get(12,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(25,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(54,Runtime),ebqn_array:get(55,Runtime),3,5],[[0,1,0,0]]]), %(<⟜3⊸×↕5)≡5↑↕3
    {_,1} = ebqn:run(St0,[[0,5,0,3,16,0,2,0,6,17,0,0,0,5,0,1,0,4,17,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(25,Runtime),ebqn_array:get(27,Runtime),6,0,-6],[[0,1,0,0]]]), %(6⥊0)≡¯6↑↕0
    {_,1} = ebqn:run(St0,[[0,8,0,4,16,0,1,0,7,0,5,3,2,17,0,3,0,6,17,0,0,0,5,0,4,16,0,2,16,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(24,Runtime),ebqn_array:get(25,Runtime),ebqn_array:get(27,Runtime),3,1,2,6],[[0,1,0,0]]]), %(≍↕3)≡1↑2‿3⥊↕6
    {_,1} = ebqn:run(St0,[[0,7,0,3,16,0,6,0,4,0,1,8,0,0,0,5,0,4,0,2,8,19,16,25],[ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(25,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(55,Runtime),4,0,3],[[0,1,0,0]]]), %(↑⟜4≡⥊⟜0)↕3
    {_,1} = ebqn:run(St0,[[0,8,0,3,0,5,0,6,3,2,17,0,3,0,4,0,0,16,17,0,1,0,7,0,2,16,17,25],[ebqn_array:get(12,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(24,Runtime),ebqn_array:get(25,Runtime),1,2,3,str("abc"),str("abcd")],[[0,1,0,0]]]), %(≍"abc")≡(<1)↑2‿3↑"abcd"
    ok = try ebqn:run(St0,[[0,3,0,0,0,1,0,2,3,2,17,25],[ebqn_array:get(25,Runtime),2,char("c"),str("abcd")],[[0,1,0,0]]]) % 2‿'c'↑"abcd"
        catch _ -> ok
    end,
    ok = try ebqn:run(St0,[[0,4,0,1,0,2,0,3,3,2,0,0,16,17,25],[ebqn_array:get(24,Runtime),ebqn_array:get(25,Runtime),2,3,str("abcd")],[[0,1,0,0]]]) % (≍2‿3)↑"abcd"
        catch _ -> ok
    end,
    {_,1} = ebqn:run(St0,[[0,6,0,3,16,0,1,0,8,0,9,3,2,17,0,4,0,5,0,1,8,0,0,0,2,19,0,7,0,1,0,6,17,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(25,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(36,Runtime),ebqn_array:get(55,Runtime),6,1,2,3],[[0,1,0,0]]]), %(6⥊1)(↑≡⥊⟜⊑)2‿3⥊↕6
    {_,1} = ebqn:run(St0,[[0,8,0,3,0,5,0,2,8,0,1,0,0,0,6,0,7,8,0,5,0,3,0,5,0,4,0,3,7,8,8,19,16,25],[ebqn_array:get(0,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(25,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(46,Runtime),ebqn_array:get(52,Runtime),ebqn_array:get(54,Runtime),1,5],[[0,1,0,0]]]), %(↕¨∘↕∘(1⊸+)≡↑∘↕)5
    {_,1} = ebqn:run(St0,[[0,10,0,2,0,9,0,8,3,2,17,0,0,0,6,0,2,7,0,8,0,6,0,3,7,0,7,0,5,16,17,19,0,1,0,4,19,16,25],[ebqn_array:get(12,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(24,Runtime),ebqn_array:get(25,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(46,Runtime),4,2,3,str("abcdef")],[[0,1,0,0]]]), %(↑≡((↕4)≍¨2)⥊¨<)3‿2⥊"abcdef"
    {_,1} = ebqn:run(St0,[[0,4,0,1,0,2,17,0,0,0,3,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(26,Runtime),3,str("d"),str("abcd")],[[0,1,0,0]]]), %"d"≡3↓"abcd"
    ok = try ebqn:run(St0,[[0,2,0,0,0,1,17,25],[ebqn_array:get(26,Runtime),0.1,str("abcd")],[[0,1,0,0]]]) % 0.1↓"abcd"
        catch _ -> ok
    end,
    ok = try ebqn:run(St0,[[0,2,0,0,0,1,3,1,17,25],[ebqn_array:get(26,Runtime),ebqn_array:get(52,Runtime),str("abcd")],[[0,1,0,0]]]) % ⟨∘⟩↓"abcd"
        catch _ -> ok
    end,
    {_,1} = ebqn:run(St0,[[0,9,0,7,3,2,0,2,0,3,0,1,0,4,0,8,8,0,5,0,0,8,8,0,6,0,7,3,2,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(26,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(53,Runtime),ebqn_array:get(54,Runtime),ebqn_array:get(55,Runtime),1,2,-3,4],[[0,1,0,0]]]), %1‿2≡⟜(¯3⊸↓)○↕4‿2
    {_,1} = ebqn:run(St0,[[0,6,0,7,0,5,3,3,0,4,16,0,3,0,9,0,2,0,8,17,17,0,1,16,0,0,0,5,0,5,0,6,0,7,0,5,3,5,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(19,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(26,Runtime),ebqn_array:get(27,Runtime),1,3,2,5,0],[[0,1,0,0]]]), %1‿1‿3‿2‿1≡≢(5⥊0)↓↕3‿2‿1
    {_,1} = ebqn:run(St0,[[0,10,0,4,0,6,0,2,8,0,5,0,8,0,0,8,0,0,0,7,0,9,8,0,6,0,4,8,19,0,1,0,4,0,6,0,3,8,19,16,25],[ebqn_array:get(0,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(25,Runtime),ebqn_array:get(26,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(30,Runtime),ebqn_array:get(52,Runtime),ebqn_array:get(54,Runtime),ebqn_array:get(55,Runtime),1,5],[[0,1,0,0]]]), %(↓∘↕≡↕∘(1⊸+)+⟜⌽↑∘↕)5
    {_,1} = ebqn:run(St0,[[0,8,0,5,0,6,3,3,0,2,16,0,3,16,0,4,0,1,7,0,7,17,0,0,0,5,0,6,3,2,0,2,16,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(26,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(35,Runtime),ebqn_array:get(46,Runtime),3,4,1,2],[[0,1,0,0]]]), %(↕3‿4)≡1↓¨⊏↕2‿3‿4
    {_,1} = ebqn:run(St0,[[0,7,0,2,16,0,2,0,6,17,0,1,0,6,0,2,0,4,0,3,0,0,7,8,0,5,17,17,25],[ebqn_array:get(0,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(47,Runtime),ebqn_array:get(53,Runtime),4,2,5],[[0,1,0,0]]]), %(4+⌜○↕2)≡2↕↕5
    ok = try ebqn:run(St0,[[0,1,0,0,16,0,0,0,2,17,25],[ebqn_array:get(27,Runtime),5,char("\0")],[[0,1,0,0]]]) % @↕↕5
        catch _ -> ok
    end,
    ok = try ebqn:run(St0,[[0,3,0,0,16,0,0,0,1,0,2,3,2,17,25],[ebqn_array:get(27,Runtime),2,1,5],[[0,1,0,0]]]) % 2‿1↕↕5
        catch _ -> ok
    end,
    ok = try ebqn:run(St0,[[0,2,0,0,16,0,0,0,1,17,25],[ebqn_array:get(27,Runtime),-1,5],[[0,1,0,0]]]) % ¯1↕↕5
        catch _ -> ok
    end,
    ok = try ebqn:run(St0,[[0,2,0,0,16,0,0,0,1,17,25],[ebqn_array:get(27,Runtime),7,5],[[0,1,0,0]]]) % 7↕↕5
        catch _ -> ok
    end,
    {_,1} = ebqn:run(St0,[[0,6,0,2,0,4,0,5,3,2,17,0,1,0,0,0,3,19,3,0,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(21,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(27,Runtime),4,3,str("abcd")],[[0,1,0,0]]]), %⟨⟩(↕≡⊢)4‿3⥊"abcd"
    {_,1} = ebqn:run(St0,[[0,10,0,5,16,0,3,0,7,0,1,0,0,0,9,19,0,6,0,4,7,0,8,19,8,0,2,0,5,0,7,0,8,8,19,16,25],[ebqn_array:get(0,Runtime),ebqn_array:get(14,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(24,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(44,Runtime),ebqn_array:get(54,Runtime),0,1,6],[[0,1,0,0]]]), %(0⊸↕≡(0≍˜1+≠)⊸⥊)↕6
    {_,1} = ebqn:run(St0,[[0,6,0,1,0,5,0,3,0,5,3,3,17,0,0,0,6,0,1,0,4,0,5,3,2,17,0,2,0,3,17,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(27,Runtime),7,6,0,str("")],[[0,1,0,0]]]), %(7↕6‿0⥊"")≡0‿7‿0⥊""
    ok = try ebqn:run(St0,[[0,2,0,0,0,1,17,25],[ebqn_array:get(28,Runtime),char("a"),char("b")],[[0,1,0,0]]]) % 'a'«'b'
        catch _ -> ok
    end,
    ok = try ebqn:run(St0,[[0,1,0,0,0,2,17,25],[ebqn_array:get(29,Runtime),char("b"),str("a")],[[0,1,0,0]]]) % "a"»'b'
        catch _ -> ok
    end,
    ok = try ebqn:run(St0,[[0,3,0,1,0,2,0,0,8,16,25],[ebqn_array:get(24,Runtime),ebqn_array:get(29,Runtime),ebqn_array:get(54,Runtime),str("abc")],[[0,1,0,0]]]) % ≍⊸»"abc"
        catch _ -> ok
    end,
    {_,1} = ebqn:run(St0,[[0,6,0,1,0,5,0,4,0,2,7,8,0,0,0,1,0,5,0,4,0,3,7,8,19,16,25],[ebqn_array:get(10,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(28,Runtime),ebqn_array:get(29,Runtime),ebqn_array:get(44,Runtime),ebqn_array:get(54,Runtime),str("")],[[0,1,0,0]]]), %(»˜⊸≡∧«˜⊸≡)""
    {_,1} = ebqn:run(St0,[[0,2,0,1,3,0,17,0,0,0,2,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(29,Runtime),str("a")],[[0,1,0,0]]]), %"a"≡⟨⟩»"a"
    {_,1} = ebqn:run(St0,[[3,0,0,1,0,2,17,0,0,3,0,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(29,Runtime),str("a")],[[0,1,0,0]]]), %⟨⟩≡"a"»⟨⟩
    {_,1} = ebqn:run(St0,[[0,4,0,1,0,3,17,0,0,0,2,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(29,Runtime),str("aBC"),str("a"),str("BCD")],[[0,1,0,0]]]), %"aBC"≡"a"»"BCD"
    {_,1} = ebqn:run(St0,[[0,4,0,1,0,3,17,0,0,0,2,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(28,Runtime),str("CDa"),str("a"),str("BCD")],[[0,1,0,0]]]), %"CDa"≡"a"«"BCD"
    {_,1} = ebqn:run(St0,[[0,2,3,1,0,1,0,4,17,0,0,0,3,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(28,Runtime),4,str("d"),str("abcd")],[[0,1,0,0]]]), %"d"≡"abcd"«⟨4⟩
    {_,1} = ebqn:run(St0,[[0,9,0,7,0,8,3,2,0,10,3,3,0,4,0,6,0,3,7,7,0,5,0,0,7,9,0,1,0,5,0,0,7,0,4,0,6,0,2,7,7,9,19,16,25],[ebqn_array:get(14,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(21,Runtime),ebqn_array:get(28,Runtime),ebqn_array:get(44,Runtime),ebqn_array:get(46,Runtime),ebqn_array:get(47,Runtime),2,3,str(""),str("abcde")],[[0,1,0,0]]]), %((⊢⌜˜≠¨)≡(≠¨«⌜˜))""‿⟨2,3⟩‿"abcde"
    {_,1} = ebqn:run(St0,[[0,5,0,6,0,7,3,3,0,2,0,1,7,0,4,17,0,0,0,3,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(28,Runtime),ebqn_array:get(49,Runtime),str("Zcab"),str("WXYZ"),str("ab"),str("c"),str("")],[[0,1,0,0]]]), %"Zcab"≡"WXYZ"«´"ab"‿"c"‿""
    {_,1} = ebqn:run(St0,[[0,4,0,1,0,2,17,0,0,0,3,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(29,Runtime),char("d"),str("dab"),str("abc")],[[0,1,0,0]]]), %"dab"≡'d'»"abc"
    {_,1} = ebqn:run(St0,[[0,6,0,2,0,3,0,0,8,0,4,17,0,1,0,5,17,25],[ebqn_array:get(12,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(29,Runtime),ebqn_array:get(54,Runtime),char("d"),str("dab"),str("abc")],[[0,1,0,0]]]), %"dab"≡'d'<⊸»"abc"
    {_,1} = ebqn:run(St0,[[0,12,0,13,3,2,0,8,0,1,7,0,4,9,0,10,0,3,8,16,0,0,0,14,17,0,5,0,9,0,7,8,0,2,0,6,0,9,0,11,8,19,16,25],[ebqn_array:get(0,Runtime),ebqn_array:get(2,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(28,Runtime),ebqn_array:get(30,Runtime),ebqn_array:get(35,Runtime),ebqn_array:get(49,Runtime),ebqn_array:get(54,Runtime),ebqn_array:get(55,Runtime),1,4,2,char("a")],[[0,1,0,0]]]), %(1⊸⌽≡⊏⊸«)'a'+⥊⟜(↕×´)4‿2
    {_,1} = ebqn:run(St0,[[0,12,0,13,3,2,0,9,0,1,7,0,6,9,0,10,0,4,8,16,0,0,0,14,17,0,3,0,7,0,5,19,0,2,0,8,19,0,11,17,25],[ebqn_array:get(0,Runtime),ebqn_array:get(2,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(21,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(25,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(29,Runtime),ebqn_array:get(30,Runtime),ebqn_array:get(49,Runtime),ebqn_array:get(55,Runtime),-2,4,2,char("a")],[[0,1,0,0]]]), %¯2(⌽≡↑»⊢)'a'+⥊⟜(↕×´)4‿2
    {_,1} = ebqn:run(St0,[[0,9,0,3,16,0,5,0,8,0,6,0,1,8,0,6,0,4,8,7,0,0,0,2,19,0,7,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(25,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(29,Runtime),ebqn_array:get(44,Runtime),ebqn_array:get(55,Runtime),6,0,4],[[0,1,0,0]]]), %6(↑≡»⟜(⥊⟜0)˜)↕4
    {_,1} = ebqn:run(St0,[[0,7,0,1,0,5,0,6,3,2,17,0,0,0,4,0,3,0,2,7,8,16,25],[ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(28,Runtime),ebqn_array:get(44,Runtime),ebqn_array:get(54,Runtime),2,3,str("abcdef")],[[0,1,0,0]]]), %«˜⊸≡2‿3⥊"abcdef"
    {_,1} = ebqn:run(St0,[[0,8,0,3,16,0,7,0,5,0,0,8,0,1,0,6,19,0,2,0,4,19,16,25],[ebqn_array:get(1,Runtime),ebqn_array:get(7,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(29,Runtime),ebqn_array:get(55,Runtime),0,1,6],[[0,1,0,0]]]), %(»≡0⌈-⟜1)↕6
    {_,1} = ebqn:run(St0,[[0,6,0,1,16,0,3,0,4,0,5,8,0,0,0,2,19,16,25],[ebqn_array:get(18,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(28,Runtime),ebqn_array:get(30,Runtime),ebqn_array:get(54,Runtime),1,6],[[0,1,0,0]]]), %(«≡1⊸⌽)↕6
    {_,1} = ebqn:run(St0,[[0,11,0,10,3,2,0,7,0,1,7,0,5,9,0,8,0,4,8,16,0,10,0,8,0,0,8,0,2,0,9,19,0,3,0,6,19,16,25],[ebqn_array:get(1,Runtime),ebqn_array:get(2,Runtime),ebqn_array:get(7,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(29,Runtime),ebqn_array:get(49,Runtime),ebqn_array:get(55,Runtime),0,2,5],[[0,1,0,0]]]), %(»≡0⌈-⟜2)⥊⟜(↕×´)5‿2
    {_,1} = ebqn:run(St0,[[0,11,0,12,3,2,0,7,0,0,7,0,4,9,0,9,0,3,8,16,0,0,0,8,0,1,0,8,0,10,8,8,0,6,0,10,19,0,2,0,5,19,16,25],[ebqn_array:get(2,Runtime),ebqn_array:get(12,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(28,Runtime),ebqn_array:get(30,Runtime),ebqn_array:get(49,Runtime),ebqn_array:get(54,Runtime),ebqn_array:get(55,Runtime),1,5,2],[[0,1,0,0]]]), %(«≡1⌽1⊸<⊸×)⥊⟜(↕×´)5‿2
    ok = try ebqn:run(St0,[[0,1,0,0,16,25],[ebqn_array:get(30,Runtime),char("a")],[[0,1,0,0]]]) % ⌽'a'
        catch _ -> ok
    end,
    ok = try ebqn:run(St0,[[0,2,0,0,16,0,1,16,25],[ebqn_array:get(12,Runtime),ebqn_array:get(30,Runtime),inf],[[0,1,0,0]]]) % ⌽<∞
        catch _ -> ok
    end,
    {_,1} = ebqn:run(St0,[[3,0,0,1,0,2,0,0,8,16,25],[ebqn_array:get(18,Runtime),ebqn_array:get(30,Runtime),ebqn_array:get(55,Runtime)],[[0,1,0,0]]]), %≡⟜⌽⟨⟩
    {_,1} = ebqn:run(St0,[[0,3,0,1,0,2,0,0,8,16,25],[ebqn_array:get(18,Runtime),ebqn_array:get(30,Runtime),ebqn_array:get(55,Runtime),str("a")],[[0,1,0,0]]]), %≡⟜⌽"a"
    {_,1} = ebqn:run(St0,[[0,4,0,1,0,2,0,0,8,0,3,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(30,Runtime),ebqn_array:get(55,Runtime),str("ba"),str("ab")],[[0,1,0,0]]]), %"ba"≡⟜⌽"ab"
    {_,1} = ebqn:run(St0,[[0,13,0,14,0,15,3,3,0,6,16,0,3,0,12,0,11,0,3,0,5,0,12,19,0,4,0,8,0,10,0,0,8,19,8,0,1,0,9,0,0,7,0,12,19,19,0,2,0,7,19,16,25],[ebqn_array:get(1,Runtime),ebqn_array:get(14,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(21,Runtime),ebqn_array:get(23,Runtime),ebqn_array:get(26,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(30,Runtime),ebqn_array:get(36,Runtime),ebqn_array:get(44,Runtime),ebqn_array:get(53,Runtime),ebqn_array:get(60,Runtime),1,3,2,4],[[0,1,0,0]]]), %(⌽≡(1-˜≠)(-○⊑∾1↓⊢)⚇1⊢)↕3‿2‿4
    {_,1} = ebqn:run(St0,[[0,4,0,1,16,0,1,16,0,2,0,3,0,0,8,16,25],[ebqn_array:get(18,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(30,Runtime),ebqn_array:get(55,Runtime),3],[[0,1,0,0]]]), %≡⟜⌽↕↕3
    ok = try ebqn:run(St0,[[0,2,0,0,0,1,17,25],[ebqn_array:get(30,Runtime),2,char("a")],[[0,1,0,0]]]) % 2⌽'a'
        catch _ -> ok
    end,
    ok = try ebqn:run(St0,[[0,4,0,0,16,0,1,0,2,0,3,3,2,17,25],[ebqn_array:get(27,Runtime),ebqn_array:get(30,Runtime),1,2,4],[[0,1,0,0]]]) % 1‿2⌽↕4
        catch _ -> ok
    end,
    ok = try ebqn:run(St0,[[0,7,0,1,0,4,0,3,0,0,7,8,0,6,17,0,2,0,2,0,5,3,2,17,25],[ebqn_array:get(0,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(30,Runtime),ebqn_array:get(47,Runtime),ebqn_array:get(53,Runtime),2,3,4],[[0,1,0,0]]]) % ⌽‿2⌽3+⌜○↕4
        catch _ -> ok
    end,
    ok = try ebqn:run(St0,[[0,4,0,1,16,0,2,0,3,0,0,16,0,0,16,17,25],[ebqn_array:get(12,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(30,Runtime),3,4],[[0,1,0,0]]]) % (<<3)⌽↕4
        catch _ -> ok
    end,
    {_,1} = ebqn:run(St0,[[0,14,0,9,0,3,16,0,8,0,4,16,0,10,0,11,3,2,0,4,16,0,14,0,3,0,12,0,10,0,13,3,3,17,3,5,0,6,0,2,0,1,0,5,19,7,0,8,17,0,7,0,0,7,16,25],[ebqn_array:get(10,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(21,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(30,Runtime),ebqn_array:get(46,Runtime),ebqn_array:get(49,Runtime),5,inf,0,4,2,3,str("")],[[0,1,0,0]]]), %∧´5(⌽≡⊢)¨⟨"",⥊∞,↕5,↕0‿4,2‿0‿3⥊""⟩
    {_,1} = ebqn:run(St0,[[0,10,0,11,0,12,0,13,0,8,0,14,0,15,3,7,0,1,0,9,17,0,0,0,8,17,0,5,0,17,0,7,0,4,8,0,3,0,16,19,7,16,0,6,0,2,7,16,25],[ebqn_array:get(0,Runtime),ebqn_array:get(2,Runtime),ebqn_array:get(10,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(30,Runtime),ebqn_array:get(46,Runtime),ebqn_array:get(49,Runtime),ebqn_array:get(55,Runtime),1,5,-10,-2,-1,0,6,61,str("bcdea"),str("abcde")],[[0,1,0,0]]]), %∧´("bcdea"≡⌽⟜"abcde")¨1+5×¯10‿¯2‿¯1‿0‿1‿6‿61
    {_,1} = ebqn:run(St0,[[0,17,0,2,0,12,0,14,0,16,3,3,17,0,13,0,15,3,2,0,9,0,5,0,8,0,3,0,8,0,14,8,8,0,1,0,4,0,7,0,5,8,19,8,0,10,0,11,0,12,3,2,0,13,0,10,0,14,3,3,3,3,17,0,6,0,0,7,16,25],[ebqn_array:get(10,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(25,Runtime),ebqn_array:get(30,Runtime),ebqn_array:get(36,Runtime),ebqn_array:get(49,Runtime),ebqn_array:get(52,Runtime),ebqn_array:get(54,Runtime),ebqn_array:get(60,Runtime),1,0,2,-1,3,inf,5,str("abcdef")],[[0,1,0,0]]]), %∧´⟨1,0‿2,¯1‿1‿3⟩(⊑∘⌽≡(3⊸↑)⊸⊑)⚇¯1‿∞ 2‿3‿5⥊"abcdef"
    {_,1} = ebqn:run(St0,[[0,4,0,0,0,1,0,2,0,3,3,0,8,19,16,25],[ebqn_array:get(12,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(30,Runtime),ebqn_array:get(54,Runtime),char("a")],[[0,1,0,0]]]), %(⟨⟩⊸⌽≡<)'a'
    ok = try ebqn:run(St0,[[0,1,0,0,16,25],[ebqn_array:get(32,Runtime),2],[[0,1,0,0]]]) % /2
        catch _ -> ok
    end,
    ok = try ebqn:run(St0,[[0,1,0,2,0,3,3,3,0,0,16,25],[ebqn_array:get(32,Runtime),1,-1,0],[[0,1,0,0]]]) % /1‿¯1‿0
        catch _ -> ok
    end,
    ok = try ebqn:run(St0,[[0,5,0,1,16,0,3,0,4,0,0,7,7,16,0,2,16,25],[ebqn_array:get(15,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(32,Runtime),ebqn_array:get(44,Runtime),ebqn_array:get(47,Runtime),2],[[0,1,0,0]]]) % /=⌜˜↕2
        catch _ -> ok
    end,
    {_,1} = ebqn:run(St0,[[0,4,0,2,0,2,0,2,0,4,0,2,3,6,0,1,16,0,0,0,2,0,3,3,2,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(32,Runtime),0,4,1],[[0,1,0,0]]]), %0‿4≡/1‿0‿0‿0‿1‿0
    {_,1} = ebqn:run(St0,[[0,4,0,3,0,2,3,3,0,1,16,0,0,0,2,0,2,0,3,3,3,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(32,Runtime),1,2,0],[[0,1,0,0]]]), %1‿1‿2≡/0‿2‿1
    {_,1} = ebqn:run(St0,[[3,0,0,1,0,2,0,0,8,16,25],[ebqn_array:get(18,Runtime),ebqn_array:get(32,Runtime),ebqn_array:get(55,Runtime)],[[0,1,0,0]]]), %≡⟜/⟨⟩
    ok = try ebqn:run(St0,[[0,2,0,0,16,0,1,0,2,17,25],[ebqn_array:get(12,Runtime),ebqn_array:get(32,Runtime),2],[[0,1,0,0]]]) % 2/<2
        catch _ -> ok
    end,
    ok = try ebqn:run(St0,[[0,3,0,0,0,1,0,2,3,2,17,25],[ebqn_array:get(32,Runtime),0,1,str("abc")],[[0,1,0,0]]]) % 0‿1/"abc"
        catch _ -> ok
    end,
    ok = try ebqn:run(St0,[[0,3,0,1,0,2,0,0,16,0,2,0,0,16,3,2,17,25],[ebqn_array:get(27,Runtime),ebqn_array:get(32,Runtime),3,str("abc")],[[0,1,0,0]]]) % ⟨↕3,↕3⟩/"abc"
        catch _ -> ok
    end,
    ok = try ebqn:run(St0,[[0,5,0,0,0,2,0,1,8,0,3,0,4,3,2,17,25],[ebqn_array:get(24,Runtime),ebqn_array:get(32,Runtime),ebqn_array:get(53,Runtime),1,2,str("ab")],[[0,1,0,0]]]) % 1‿2/○≍"ab"
        catch _ -> ok
    end,
    ok = try ebqn:run(St0,[[0,3,0,0,0,1,0,2,3,2,17,25],[ebqn_array:get(32,Runtime),-1,2,str("ab")],[[0,1,0,0]]]) % ¯1‿2/"ab"
        catch _ -> ok
    end,
    {_,1} = ebqn:run(St0,[[0,4,0,1,0,2,17,0,0,0,3,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(32,Runtime),2,str("aabbcc"),str("abc")],[[0,1,0,0]]]), %"aabbcc"≡2/"abc"
    {_,1} = ebqn:run(St0,[[0,3,0,1,0,2,17,0,0,0,3,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(32,Runtime),4,str("")],[[0,1,0,0]]]), %""≡4/""
    {_,1} = ebqn:run(St0,[[0,8,0,1,0,7,0,4,3,2,17,0,2,0,5,0,6,3,2,3,0,3,2,17,0,0,0,8,0,1,0,3,0,4,3,2,17,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(32,Runtime),6,0,5,1,2,str("")],[[0,1,0,0]]]), %(6‿0⥊"")≡⟨5,1⟩‿⟨⟩/2‿0⥊""
    {_,1} = ebqn:run(St0,[[0,3,0,4,0,5,3,3,0,2,0,1,7,16,0,0,0,3,0,3,0,3,0,4,0,4,0,5,3,6,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(32,Runtime),ebqn_array:get(44,Runtime),3,2,1],[[0,1,0,0]]]), %3‿3‿3‿2‿2‿1≡/˜3‿2‿1
    {_,1} = ebqn:run(St0,[[0,4,0,5,0,6,3,3,0,2,0,3,0,0,8,16,0,1,0,4,0,4,0,4,0,5,0,5,0,6,3,6,17,25],[ebqn_array:get(12,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(32,Runtime),ebqn_array:get(54,Runtime),3,2,1],[[0,1,0,0]]]), %3‿3‿3‿2‿2‿1≡<⊸/3‿2‿1
    {_,1} = ebqn:run(St0,[[0,7,0,8,3,2,0,3,0,4,0,5,0,3,7,19,16,0,0,0,6,0,7,0,7,3,3,0,5,0,1,7,0,6,17,0,2,16,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(23,Runtime),ebqn_array:get(24,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(32,Runtime),ebqn_array:get(46,Runtime),1,2,3],[[0,1,0,0]]]), %(≍1∾¨1‿2‿2)≡(↕¨/↕)2‿3
    {_,1} = ebqn:run(St0,[[0,4,0,0,0,1,0,2,0,3,3,0,8,19,16,25],[ebqn_array:get(12,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(32,Runtime),ebqn_array:get(54,Runtime),char("a")],[[0,1,0,0]]]), %(⟨⟩⊸/≡<)'a'
    {_,1} = ebqn:run(St0,[[0,4,0,2,16,0,1,0,0,0,3,19,3,0,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(21,Runtime),ebqn_array:get(24,Runtime),ebqn_array:get(32,Runtime),str("ab")],[[0,1,0,0]]]), %⟨⟩(/≡⊢)≍"ab"
    {_,1} = ebqn:run(St0,[[0,14,0,6,16,0,5,0,13,0,11,3,2,17,0,0,0,15,17,0,4,0,7,0,3,0,10,0,9,0,8,0,5,7,7,8,19,0,2,0,7,19,0,11,0,12,0,1,16,3,2,17,25],[ebqn_array:get(0,Runtime),ebqn_array:get(12,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(19,Runtime),ebqn_array:get(21,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(32,Runtime),ebqn_array:get(44,Runtime),ebqn_array:get(46,Runtime),ebqn_array:get(55,Runtime),2,3,4,8,char("a")],[[0,1,0,0]]]), %⟨2,<3⟩(/≡⥊˜¨⟜≢/⊢)'a'+4‿2⥊↕8
    ok.

layer6(St0,#a{r=Runtime}) ->
    ok = try ebqn:run(St0,[[0,1,0,0,16,25],[ebqn_array:get(23,Runtime),char("c")],[[0,1,0,0]]]) % ∾'c'
        catch _ -> ok
    end,
    {_,1} = ebqn:run(St0,[[0,5,0,3,0,1,7,0,2,9,0,4,0,0,8,16,25],[ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(23,Runtime),ebqn_array:get(46,Runtime),ebqn_array:get(55,Runtime),str("abc")],[[0,1,0,0]]]), %≡⟜(∾⥊¨)"abc"
    {_,1} = ebqn:run(St0,[[0,3,0,4,0,5,3,3,0,1,0,0,0,2,0,1,7,19,16,25],[ebqn_array:get(18,Runtime),ebqn_array:get(23,Runtime),ebqn_array:get(49,Runtime),str("ab"),str("cde"),str("")],[[0,1,0,0]]]), %(∾´≡∾)"ab"‿"cde"‿""
    ok = try ebqn:run(St0,[[0,1,0,0,16,25],[ebqn_array:get(23,Runtime),str("abc")],[[0,1,0,0]]]) % ∾"abc"
        catch _ -> ok
    end,
    ok = try ebqn:run(St0,[[0,2,0,3,0,4,3,3,0,1,16,0,0,16,25],[ebqn_array:get(23,Runtime),ebqn_array:get(24,Runtime),str("ab"),str("cde"),str("")],[[0,1,0,0]]]) % ∾≍"ab"‿"cde"‿""
        catch _ -> ok
    end,
    ok = try ebqn:run(St0,[[0,2,0,1,0,3,3,3,0,0,16,25],[ebqn_array:get(23,Runtime),char("c"),str("ab"),str("")],[[0,1,0,0]]]) % ∾"ab"‿'c'‿""
        catch _ -> ok
    end,
    {_,1} = ebqn:run(St0,[[0,11,0,8,16,0,0,0,9,17,0,7,0,6,0,2,19,0,1,0,4,19,16,0,5,16,0,3,0,9,0,10,0,11,0,12,0,13,0,14,3,6,17,25],[ebqn_array:get(0,Runtime),ebqn_array:get(2,Runtime),ebqn_array:get(14,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(21,Runtime),ebqn_array:get(23,Runtime),ebqn_array:get(25,Runtime),ebqn_array:get(26,Runtime),ebqn_array:get(27,Runtime),1,2,3,4,6,9],[[0,1,0,0]]]), %1‿2‿3‿4‿6‿9≡∾(⊢×≠↑↓)1+↕3
    {_,1} = ebqn:run(St0,[[0,5,0,1,16,0,1,0,3,9,0,4,0,2,8,0,0,0,3,0,4,0,2,8,19,16,25],[ebqn_array:get(10,Runtime),ebqn_array:get(12,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(23,Runtime),ebqn_array:get(55,Runtime),4],[[0,1,0,0]]]), %(≡⟜∾∧≡⟜(∾<))<4
    {_,1} = ebqn:run(St0,[[0,8,0,9,0,7,3,3,3,0,0,10,0,2,16,3,3,0,3,0,5,0,4,0,0,7,8,0,1,0,4,0,4,0,0,7,7,0,3,9,19,0,6,0,7,3,2,0,8,0,2,16,3,2,17,25],[ebqn_array:get(4,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(23,Runtime),ebqn_array:get(47,Runtime),ebqn_array:get(53,Runtime),1,4,2,3,5],[[0,1,0,0]]]), %⟨1‿4,⥊2⟩((∾⋆⌜⌜)≡⋆⌜○∾)⟨2‿3‿4,⟨⟩,⥊5⟩
    ok = try ebqn:run(St0,[[0,5,0,2,0,0,7,0,3,0,4,3,2,0,4,0,4,0,4,3,2,3,3,17,0,1,16,25],[ebqn_array:get(22,Runtime),ebqn_array:get(23,Runtime),ebqn_array:get(46,Runtime),2,3,0],[[0,1,0,0]]]) % ∾⟨2‿3,3,3‿3⟩⥊¨0
        catch _ -> ok
    end,
    ok = try ebqn:run(St0,[[0,6,0,2,0,0,7,0,3,0,4,3,2,0,5,0,4,3,2,0,3,0,3,3,2,3,3,17,0,1,16,25],[ebqn_array:get(22,Runtime),ebqn_array:get(23,Runtime),ebqn_array:get(46,Runtime),2,3,1,0],[[0,1,0,0]]]) % ∾⟨2‿3,1‿3,2‿2⟩⥊¨0
        catch _ -> ok
    end,
    {_,1} = ebqn:run(St0,[[0,2,0,1,0,4,17,0,0,0,3,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(23,Runtime),char("d"),str("abcd"),str("abc")],[[0,1,0,0]]]), %"abcd"≡"abc"∾'d'
    {_,1} = ebqn:run(St0,[[0,3,0,0,16,0,2,0,5,17,0,1,0,4,17,25],[ebqn_array:get(12,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(23,Runtime),char("d"),str("abcd"),str("abc")],[[0,1,0,0]]]), %"abcd"≡"abc"∾<'d'
    {_,1} = ebqn:run(St0,[[0,5,0,2,16,0,3,0,1,7,0,5,17,0,1,0,5,0,5,3,2,0,2,16,17,0,0,0,4,0,5,3,2,0,2,16,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(23,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(46,Runtime),4,3],[[0,1,0,0]]]), %(↕4‿3)≡(↕3‿3)∾3∾¨↕3
    {_,1} = ebqn:run(St0,[[0,15,0,3,0,13,0,14,3,2,17,0,8,0,5,7,0,3,0,11,0,2,0,10,0,6,0,4,0,7,0,10,0,9,0,0,7,8,19,0,11,0,12,8,8,8,9,0,1,0,8,0,4,7,19,16,25],[ebqn_array:get(2,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(19,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(23,Runtime),ebqn_array:get(24,Runtime),ebqn_array:get(25,Runtime),ebqn_array:get(26,Runtime),ebqn_array:get(44,Runtime),ebqn_array:get(49,Runtime),ebqn_array:get(52,Runtime),ebqn_array:get(54,Runtime),-1,2,3,str("abcdef")],[[0,1,0,0]]]), %(∾˜≡·¯1⊸(×´∘↓∾↑)∘≢⊸⥊≍˜)2‿3⥊"abcdef"
    {_,1} = ebqn:run(St0,[[0,11,0,4,16,0,0,16,0,5,0,2,7,0,7,0,8,0,9,3,3,0,10,0,8,0,9,3,3,3,2,17,0,3,0,1,0,6,0,3,7,19,16,25],[ebqn_array:get(12,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(23,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(46,Runtime),ebqn_array:get(49,Runtime),3,2,1,0,6],[[0,1,0,0]]]), %(∾´≡∾)⟨3‿2‿1,0‿2‿1⟩⥊¨<↕6
    ok = try ebqn:run(St0,[[0,3,0,1,16,0,0,0,2,17,25],[ebqn_array:get(23,Runtime),ebqn_array:get(24,Runtime),char("a"),str("abc")],[[0,1,0,0]]]) % 'a'∾≍"abc"
        catch _ -> ok
    end,
    ok = try ebqn:run(St0,[[0,4,0,1,0,2,0,0,8,0,3,17,25],[ebqn_array:get(23,Runtime),ebqn_array:get(24,Runtime),ebqn_array:get(53,Runtime),str("ab"),str("cde")],[[0,1,0,0]]]) % "ab"∾○≍"cde"
        catch _ -> ok
    end,
    ok = try ebqn:run(St0,[[0,3,0,2,16,0,1,0,5,0,2,16,0,0,0,3,0,4,3,2,17,17,25],[ebqn_array:get(22,Runtime),ebqn_array:get(23,Runtime),ebqn_array:get(27,Runtime),2,3,6],[[0,1,0,0]]]) % (2‿3⥊↕6)∾↕2
        catch _ -> ok
    end,
    {_,1} = ebqn:run(St0,[[0,3,0,5,0,5,0,4,3,4,0,2,16,0,0,0,3,0,4,3,2,0,5,0,1,16,0,6,0,1,16,3,3,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(41,Runtime),1,2,0,3],[[0,1,0,0]]]), %⟨1‿2,⥊0,⥊3⟩≡⊔1‿0‿0‿2
    {_,1} = ebqn:run(St0,[[0,4,0,1,0,3,17,0,2,16,0,0,3,0,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(41,Runtime),5,-1],[[0,1,0,0]]]), %⟨⟩≡⊔5⥊¯1
    {_,1} = ebqn:run(St0,[[3,0,0,1,0,2,0,0,8,16,25],[ebqn_array:get(18,Runtime),ebqn_array:get(41,Runtime),ebqn_array:get(55,Runtime)],[[0,1,0,0]]]), %≡⟜⊔⟨⟩
    ok = try ebqn:run(St0,[[0,1,0,0,16,25],[ebqn_array:get(41,Runtime),3],[[0,1,0,0]]]) % ⊔3
        catch _ -> ok
    end,
    ok = try ebqn:run(St0,[[0,2,0,0,16,0,1,16,25],[ebqn_array:get(12,Runtime),ebqn_array:get(41,Runtime),3],[[0,1,0,0]]]) % ⊔<3
        catch _ -> ok
    end,
    ok = try ebqn:run(St0,[[0,3,0,1,16,0,0,16,0,2,16,25],[ebqn_array:get(24,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(41,Runtime),3],[[0,1,0,0]]]) % ⊔≍↕3
        catch _ -> ok
    end,
    ok = try ebqn:run(St0,[[0,1,0,2,0,3,3,3,0,0,16,25],[ebqn_array:get(41,Runtime),1.5,0,2],[[0,1,0,0]]]) % ⊔1.5‿0‿2
        catch _ -> ok
    end,
    ok = try ebqn:run(St0,[[0,1,0,2,3,2,0,0,16,25],[ebqn_array:get(41,Runtime),1,-2],[[0,1,0,0]]]) % ⊔1‿¯2
        catch _ -> ok
    end,
    {_,1} = ebqn:run(St0,[[0,6,0,7,0,7,0,8,3,4,3,1,0,2,0,5,0,3,0,5,0,4,0,4,0,1,7,7,8,8,0,0,0,3,19,16,25],[ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(36,Runtime),ebqn_array:get(41,Runtime),ebqn_array:get(46,Runtime),ebqn_array:get(52,Runtime),1,0,2],[[0,1,0,0]]]), %(⊔≡⥊¨¨∘⊔∘⊑)⟨1‿0‿0‿2⟩
    {_,1} = ebqn:run(St0,[[0,9,0,11,0,12,3,3,0,12,0,11,3,2,3,2,0,5,16,0,1,0,10,0,9,3,2,0,3,16,0,4,16,0,6,0,0,0,7,0,9,0,8,0,2,8,8,7,16,17,25],[ebqn_array:get(12,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(24,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(30,Runtime),ebqn_array:get(41,Runtime),ebqn_array:get(46,Runtime),ebqn_array:get(52,Runtime),ebqn_array:get(61,Runtime),2,3,1,0],[[0,1,0,0]]]), %(≍⍟2∘<¨⌽↕3‿2)≡⊔⟨2‿1‿0,0‿1⟩
    {_,1} = ebqn:run(St0,[[3,0,3,0,3,2,0,2,16,0,0,0,3,0,3,3,2,0,1,16,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(41,Runtime),0],[[0,1,0,0]]]), %(↕0‿0)≡⊔⟨⟩‿⟨⟩
    {_,1} = ebqn:run(St0,[[0,14,0,15,0,14,0,14,3,4,0,15,0,14,0,14,3,3,3,2,0,7,0,1,0,11,0,14,8,0,10,0,5,8,7,0,9,0,8,0,3,7,7,9,0,0,0,10,0,13,0,12,0,4,8,8,9,0,2,0,6,19,16,25],[ebqn_array:get(12,Runtime),ebqn_array:get(15,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(23,Runtime),ebqn_array:get(24,Runtime),ebqn_array:get(32,Runtime),ebqn_array:get(41,Runtime),ebqn_array:get(46,Runtime),ebqn_array:get(47,Runtime),ebqn_array:get(49,Runtime),ebqn_array:get(52,Runtime),ebqn_array:get(54,Runtime),ebqn_array:get(61,Runtime),2,0,-1],[[0,1,0,0]]]), %(⊔≡·≍⍟2∘<·∾⌜´/∘(0⊸=)¨)⟨0‿¯1‿0‿0,¯1‿0‿0⟩
    {_,1} = ebqn:run(St0,[[0,12,0,11,0,10,3,2,3,2,0,5,16,0,1,0,11,0,10,3,2,0,6,0,2,0,8,0,0,0,8,0,12,0,9,0,3,8,8,8,7,16,0,7,0,4,7,0,10,0,10,0,11,3,3,17,17,25],[ebqn_array:get(12,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(24,Runtime),ebqn_array:get(25,Runtime),ebqn_array:get(41,Runtime),ebqn_array:get(46,Runtime),ebqn_array:get(47,Runtime),ebqn_array:get(52,Runtime),ebqn_array:get(61,Runtime),0,1,2],[[0,1,0,0]]]), %(0‿0‿1↑⌜≍⍟2∘<∘⥊¨1‿0)≡⊔⟨2,1‿0⟩
    {_,1} = ebqn:run(St0,[[0,14,0,13,0,12,3,2,3,2,0,7,0,5,0,10,0,12,0,12,3,2,8,7,16,0,6,16,0,1,0,13,0,12,3,2,0,7,0,2,0,10,0,12,0,12,0,12,3,3,8,0,0,9,0,9,0,14,0,11,0,3,8,8,7,16,0,8,0,4,7,0,12,0,12,0,13,3,3,17,17,25],[ebqn_array:get(12,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(23,Runtime),ebqn_array:get(24,Runtime),ebqn_array:get(25,Runtime),ebqn_array:get(26,Runtime),ebqn_array:get(41,Runtime),ebqn_array:get(46,Runtime),ebqn_array:get(47,Runtime),ebqn_array:get(52,Runtime),ebqn_array:get(54,Runtime),ebqn_array:get(61,Runtime),0,1,2],[[0,1,0,0]]]), %(0‿0‿1↑⌜≍⍟2∘(<0‿0‿0⊸∾)¨1‿0)≡⊔0‿0⊸↓¨⟨2,1‿0⟩
    {_,1} = ebqn:run(St0,[[0,13,0,6,0,9,0,5,8,0,3,0,0,0,8,0,4,8,0,7,0,1,7,19,9,0,2,0,0,0,8,0,4,8,19,0,10,0,11,0,12,3,3,17,25],[ebqn_array:get(12,Runtime),ebqn_array:get(14,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(23,Runtime),ebqn_array:get(24,Runtime),ebqn_array:get(32,Runtime),ebqn_array:get(41,Runtime),ebqn_array:get(46,Runtime),ebqn_array:get(53,Runtime),ebqn_array:get(54,Runtime),4,3,2,str("abcdefghi")],[[0,1,0,0]]]), %4‿3‿2(≍○<≡·(≠¨≍○<∾)/⊸⊔)"abcdefghi"
    {_,1} = ebqn:run(St0,[[0,5,0,2,0,4,0,1,0,3,17,17,0,0,3,0,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(41,Runtime),3,-1,str("abc")],[[0,1,0,0]]]), %⟨⟩≡(3⥊¯1)⊔"abc"
    ok = try ebqn:run(St0,[[0,4,0,2,0,3,3,3,0,1,0,0,7,16,25],[ebqn_array:get(41,Runtime),ebqn_array:get(44,Runtime),1,0,char("a")],[[0,1,0,0]]]) % ⊔˜'a'‿1‿0
        catch _ -> ok
    end,
    ok = try ebqn:run(St0,[[0,4,0,0,0,2,0,1,8,0,3,17,25],[ebqn_array:get(27,Runtime),ebqn_array:get(41,Runtime),ebqn_array:get(53,Runtime),4,2],[[0,1,0,0]]]) % 4⊔○↕2
        catch _ -> ok
    end,
    {_,1} = ebqn:run(St0,[[0,19,0,6,16,0,3,0,15,0,16,0,13,3,3,17,0,7,0,16,0,15,3,2,0,17,0,18,0,17,3,3,3,2,17,0,5,0,15,17,0,2,0,13,0,6,16,0,9,0,0,7,0,14,0,13,3,2,17,0,12,0,11,0,3,0,10,0,1,8,8,0,12,0,12,0,13,3,3,17,0,8,0,4,7,16,17,25],[ebqn_array:get(0,Runtime),ebqn_array:get(12,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(24,Runtime),ebqn_array:get(26,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(41,Runtime),ebqn_array:get(45,Runtime),ebqn_array:get(47,Runtime),ebqn_array:get(52,Runtime),ebqn_array:get(59,Runtime),1,4,16,2,3,-1,0,24],[[0,1,0,0]]]), %(≍˘1‿1‿4<∘⥊⎉1 16‿4+⌜↕4)≡2↓⟨3‿2,¯1‿0‿¯1⟩⊔2‿3‿4⥊↕24
    {_,1} = ebqn:run(St0,[[0,9,0,10,0,10,0,11,0,8,3,5,0,0,0,2,9,0,6,0,3,0,4,0,1,0,5,0,8,0,7,0,2,8,8,8,8,16,25],[ebqn_array:get(12,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(41,Runtime),ebqn_array:get(53,Runtime),ebqn_array:get(54,Runtime),ebqn_array:get(55,Runtime),ebqn_array:get(60,Runtime),0,1,2,-1],[[0,1,0,0]]]), %⥊⚇0⊸≡○⊔⟜(⥊<)1‿2‿2‿¯1‿0
    {_,1} = ebqn:run(St0,[[0,12,0,4,16,0,2,0,9,0,10,0,11,3,3,17,0,0,0,8,0,5,0,8,0,1,0,7,0,6,0,4,7,8,8,0,3,9,8,16,25],[ebqn_array:get(18,Runtime),ebqn_array:get(19,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(23,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(41,Runtime),ebqn_array:get(46,Runtime),ebqn_array:get(52,Runtime),ebqn_array:get(54,Runtime),3,2,4,24],[[0,1,0,0]]]), %(∾↕¨∘≢⊸⊔)⊸≡ 3‿2‿4⥊↕24
    {_,1} = ebqn:run(St0,[[0,10,0,3,0,9,17,0,2,0,5,0,4,8,0,1,0,4,19,0,6,0,8,0,7,0,0,8,8,16,25],[ebqn_array:get(1,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(24,Runtime),ebqn_array:get(41,Runtime),ebqn_array:get(53,Runtime),ebqn_array:get(54,Runtime),ebqn_array:get(55,Runtime),char("a"),str("acc"),str("bac")],[[0,1,0,0]]]), %-⟜'a'⊸(⊔≡⊔○⥊)"acc"≍"bac"
    {_,1} = ebqn:run(St0,[[0,8,0,1,16,0,4,0,5,17,0,0,0,7,0,6,3,2,0,2,16,0,8,0,1,0,6,0,6,3,2,17,3,2,0,3,0,5,0,6,3,2,17,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(32,Runtime),ebqn_array:get(41,Runtime),2,1,0,3],[[0,1,0,0]]]), %(2‿1/⟨↕0‿1,1‿1⥊3⟩)≡2⊔⥊3
    {_,1} = ebqn:run(St0,[[0,11,0,10,0,12,3,3,0,13,0,1,16,0,9,0,6,0,8,0,7,0,1,7,8,8,0,7,0,4,7,9,0,3,0,0,0,8,0,10,8,0,5,9,0,2,0,1,19,19,16,25],[ebqn_array:get(0,Runtime),ebqn_array:get(12,Runtime),ebqn_array:get(15,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(19,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(41,Runtime),ebqn_array:get(46,Runtime),ebqn_array:get(54,Runtime),ebqn_array:get(55,Runtime),1,2,3,char("\0")],[[0,1,0,0]]]), %((<=·↕1⊸+)≡·≢¨<¨⊸⊔⟜(<@))2‿1‿3
    ok = try ebqn:run(St0,[[0,5,0,0,0,3,0,4,3,2,17,0,1,0,2,0,3,3,2,0,4,0,2,3,2,3,2,17,25],[ebqn_array:get(22,Runtime),ebqn_array:get(41,Runtime),1,2,3,0],[[0,1,0,0]]]) % ⟨1‿2,3‿1⟩⊔2‿3⥊0
        catch _ -> ok
    end,
    ok = try ebqn:run(St0,[[0,9,0,0,0,3,0,4,3,2,17,0,1,0,2,0,3,3,2,0,4,0,5,0,6,3,3,0,7,0,8,3,2,3,3,17,25],[ebqn_array:get(22,Runtime),ebqn_array:get(41,Runtime),1,2,3,4,5,6,7,0],[[0,1,0,0]]]) % ⟨1‿2,3‿4‿5,6‿7⟩⊔2‿3⥊0
        catch _ -> ok
    end,
    ok = try ebqn:run(St0,[[0,5,0,1,16,0,3,0,0,7,16,0,2,0,4,0,0,8,16,25],[ebqn_array:get(24,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(41,Runtime),ebqn_array:get(45,Runtime),ebqn_array:get(54,Runtime),3],[[0,1,0,0]]]) % ≍⊸⊔≍˘↕3
        catch _ -> ok
    end,
    ok = try ebqn:run(St0,[[0,9,0,2,16,0,1,0,5,0,4,0,8,3,3,17,0,3,0,4,0,0,16,0,5,3,2,0,6,0,7,0,6,3,3,3,2,17,25],[ebqn_array:get(12,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(41,Runtime),3,2,-1,0,4,24],[[0,1,0,0]]]) % ⟨⟨<3,2⟩,¯1‿0‿¯1⟩⊔2‿3‿4⥊↕24
        catch _ -> ok
    end,
    {_,1} = ebqn:run(St0,[[0,10,0,2,0,5,0,6,0,7,3,3,17,0,0,0,8,0,9,3,2,0,1,0,3,0,4,3,2,17,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(32,Runtime),ebqn_array:get(41,Runtime),1,3,0,-1,4,str("a"),str(""),str("ab")],[[0,1,0,0]]]), %(1‿3/⟨"a",""⟩)≡0‿¯1‿4⊔"ab"
    {_,1} = ebqn:run(St0,[[0,11,0,3,0,8,0,7,0,8,0,9,3,3,3,2,17,0,0,0,10,0,4,0,1,0,6,0,2,0,5,0,1,8,8,7,0,7,0,7,0,8,3,3,17,0,1,16,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(24,Runtime),ebqn_array:get(32,Runtime),ebqn_array:get(41,Runtime),ebqn_array:get(46,Runtime),ebqn_array:get(52,Runtime),ebqn_array:get(55,Runtime),1,0,3,str("bac"),str("ab")],[[0,1,0,0]]]), %(≍1‿1‿0≍∘/⟜≍¨"bac")≡⟨0,1‿0‿3⟩⊔"ab"
    ok = try ebqn:run(St0,[[0,3,0,3,3,2,0,1,16,0,2,0,5,0,1,16,0,0,0,3,0,4,3,2,17,17,25],[ebqn_array:get(22,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(41,Runtime),2,3,4],[[0,1,0,0]]]) % (2‿3⥊↕4)⊔↕2‿2
        catch _ -> ok
    end,
    ok = try ebqn:run(St0,[[0,5,0,5,3,2,0,1,16,0,2,0,4,0,1,16,0,0,0,3,0,3,3,2,17,17,25],[ebqn_array:get(22,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(41,Runtime),3,4,2],[[0,1,0,0]]]) % (3‿3⥊↕4)⊔↕2‿2
        catch _ -> ok
    end,
    ok = try ebqn:run(St0,[[0,2,0,1,0,0,7,16,25],[ebqn_array:get(37,Runtime),ebqn_array:get(44,Runtime),char("a")],[[0,1,0,0]]]) % ⊐˜'a'
        catch _ -> ok
    end,
    ok = try ebqn:run(St0,[[0,3,0,1,0,2,0,0,8,16,25],[ebqn_array:get(35,Runtime),ebqn_array:get(37,Runtime),ebqn_array:get(54,Runtime),str("abc")],[[0,1,0,0]]]) % ⊏⊸⊐"abc"
        catch _ -> ok
    end,
    ok = try ebqn:run(St0,[[0,6,0,0,0,4,17,0,1,0,5,0,0,0,2,0,3,0,4,3,3,17,17,25],[ebqn_array:get(22,Runtime),ebqn_array:get(37,Runtime),3,2,4,0,1],[[0,1,0,0]]]) % (3‿2‿4⥊0)⊐4⥊1
        catch _ -> ok
    end,
    {_,1} = ebqn:run(St0,[[0,6,0,1,0,5,17,0,0,0,2,0,3,0,4,3,3,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(37,Runtime),2,0,4,str("abcd"),str("cae")],[[0,1,0,0]]]), %2‿0‿4≡"abcd"⊐"cae"
    {_,1} = ebqn:run(St0,[[0,4,0,1,0,3,17,0,0,0,2,3,1,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(37,Runtime),1,str("abcd"),str("b")],[[0,1,0,0]]]), %⟨1⟩≡"abcd"⊐"b"
    {_,1} = ebqn:run(St0,[[0,7,0,2,0,4,0,6,8,0,5,0,3,8,16,0,1,0,6,0,0,16,17,25],[ebqn_array:get(12,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(35,Runtime),ebqn_array:get(37,Runtime),ebqn_array:get(54,Runtime),ebqn_array:get(55,Runtime),3,str("abcd")],[[0,1,0,0]]]), %(<3)≡⊐⟜(3⊸⊏)"abcd"
    {_,1} = ebqn:run(St0,[[0,8,0,12,0,11,3,3,0,4,16,0,3,0,11,0,7,0,0,8,0,9,0,10,0,10,3,3,19,0,6,0,5,8,16,0,2,0,8,0,4,16,0,0,0,9,17,0,1,0,8,17,17,25],[ebqn_array:get(0,Runtime),ebqn_array:get(6,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(21,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(37,Runtime),ebqn_array:get(55,Runtime),ebqn_array:get(60,Runtime),5,3,0,1,2],[[0,1,0,0]]]), %(5⌊3+↕5)≡⊐⟜(3‿0‿0+⚇1⊢)↕5‿2‿1
    ok = try ebqn:run(St0,[[0,3,0,2,0,0,7,16,0,1,16,25],[ebqn_array:get(0,Runtime),ebqn_array:get(37,Runtime),ebqn_array:get(43,Runtime),char("\0")],[[0,1,0,0]]]) % ⊐+˙@
        catch _ -> ok
    end,
    {_,1} = ebqn:run(St0,[[0,5,0,1,16,0,0,0,2,0,2,0,3,0,2,0,4,3,5,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(37,Runtime),0,1,2,str("ccacb")],[[0,1,0,0]]]), %0‿0‿1‿0‿2≡⊐"ccacb"
    {_,1} = ebqn:run(St0,[[0,8,0,4,0,3,0,1,7,7,16,0,2,16,0,0,0,5,0,5,0,6,0,5,0,7,3,5,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(24,Runtime),ebqn_array:get(37,Runtime),ebqn_array:get(44,Runtime),ebqn_array:get(45,Runtime),0,1,2,str("ccacb")],[[0,1,0,0]]]), %0‿0‿1‿0‿2≡⊐≍˜˘"ccacb"
    {_,1} = ebqn:run(St0,[[3,0,0,1,0,2,0,0,8,16,25],[ebqn_array:get(18,Runtime),ebqn_array:get(37,Runtime),ebqn_array:get(55,Runtime)],[[0,1,0,0]]]), %≡⟜⊐⟨⟩
    ok = try ebqn:run(St0,[[0,3,0,1,0,2,0,0,16,17,25],[ebqn_array:get(27,Runtime),ebqn_array:get(39,Runtime),5,1],[[0,1,0,0]]]) % (↕5)∊1
        catch _ -> ok
    end,
    ok = try ebqn:run(St0,[[0,5,0,1,16,0,3,0,0,7,16,0,2,0,4,17,25],[ebqn_array:get(24,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(39,Runtime),ebqn_array:get(45,Runtime),2,4],[[0,1,0,0]]]) % 2∊≍˘↕4
        catch _ -> ok
    end,
    {_,1} = ebqn:run(St0,[[0,5,0,1,0,4,17,0,0,0,2,0,3,0,3,0,2,3,4,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(39,Runtime),1,0,str("acef"),str("adf")],[[0,1,0,0]]]), %1‿0‿0‿1≡"acef"∊"adf"
    {_,1} = ebqn:run(St0,[[0,10,0,3,0,6,0,5,0,0,7,8,0,9,17,0,8,0,7,0,1,8,0,2,0,8,0,3,16,0,7,0,4,8,19,16,25],[ebqn_array:get(4,Runtime),ebqn_array:get(12,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(39,Runtime),ebqn_array:get(47,Runtime),ebqn_array:get(53,Runtime),ebqn_array:get(55,Runtime),2,3,5],[[0,1,0,0]]]), %(∊⟜(↕2)≡<⟜2)3⋆⌜○↕5
    {_,1} = ebqn:run(St0,[[0,8,0,3,0,6,0,5,0,0,7,8,0,9,17,0,4,0,8,0,9,0,10,3,3,17,0,2,0,7,0,1,16,17,25],[ebqn_array:get(0,Runtime),ebqn_array:get(12,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(39,Runtime),ebqn_array:get(47,Runtime),ebqn_array:get(53,Runtime),1,3,4,5],[[0,1,0,0]]]), %(<1)≡3‿4‿5∊4+⌜○↕3
    ok = try ebqn:run(St0,[[0,2,0,0,16,0,1,16,25],[ebqn_array:get(12,Runtime),ebqn_array:get(39,Runtime),4],[[0,1,0,0]]]) % ∊<4
        catch _ -> ok
    end,
    {_,1} = ebqn:run(St0,[[0,5,0,2,16,0,1,0,4,0,0,0,3,17,17,25],[ebqn_array:get(14,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(39,Runtime),char("0"),str("11010001"),str("abacbacd")],[[0,1,0,0]]]), %('0'≠"11010001")≡∊"abacbacd"
    {_,1} = ebqn:run(St0,[[0,7,0,6,0,4,0,1,8,0,3,0,4,0,0,8,0,5,0,4,0,2,8,19,16,25],[ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(25,Runtime),ebqn_array:get(39,Runtime),ebqn_array:get(55,Runtime),1,inf,9],[[0,1,0,0]]]), %(↑⟜1≡⟜∊⥊⟜∞)9
    {_,1} = ebqn:run(St0,[[0,7,0,2,0,4,0,3,8,0,0,0,6,0,5,0,1,8,19,16,25],[ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(39,Runtime),ebqn_array:get(52,Runtime),ebqn_array:get(55,Runtime),1,6],[[0,1,0,0]]]), %(⥊⟜1≡∊∘↕)6
    {_,1} = ebqn:run(St0,[[3,0,0,1,0,2,0,0,8,16,25],[ebqn_array:get(18,Runtime),ebqn_array:get(39,Runtime),ebqn_array:get(55,Runtime)],[[0,1,0,0]]]), %≡⟜∊⟨⟩
    {_,1} = ebqn:run(St0,[[0,7,0,4,0,3,0,1,7,7,0,6,0,2,0,5,0,0,8,8,16,25],[ebqn_array:get(18,Runtime),ebqn_array:get(24,Runtime),ebqn_array:get(39,Runtime),ebqn_array:get(44,Runtime),ebqn_array:get(45,Runtime),ebqn_array:get(53,Runtime),ebqn_array:get(55,Runtime),str("abcadbba")],[[0,1,0,0]]]), %≡○∊⟜(≍˜˘)"abcadbba"
    ok = try ebqn:run(St0,[[0,1,0,0,16,25],[ebqn_array:get(40,Runtime),char("a")],[[0,1,0,0]]]) % ⍷'a'
        catch _ -> ok
    end,
    {_,1} = ebqn:run(St0,[[3,0,0,1,0,2,0,0,8,16,25],[ebqn_array:get(18,Runtime),ebqn_array:get(40,Runtime),ebqn_array:get(55,Runtime)],[[0,1,0,0]]]), %≡⟜⍷⟨⟩
    {_,1} = ebqn:run(St0,[[0,3,0,1,16,0,0,0,2,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(40,Runtime),str("ba"),str("baa")],[[0,1,0,0]]]), %"ba"≡⍷"baa"
    ok = try ebqn:run(St0,[[0,3,0,1,0,2,0,0,8,16,25],[ebqn_array:get(24,Runtime),ebqn_array:get(40,Runtime),ebqn_array:get(54,Runtime),str("abc")],[[0,1,0,0]]]) % ≍⊸⍷"abc"
        catch _ -> ok
    end,
    {_,1} = ebqn:run(St0,[[0,5,0,1,0,4,17,0,0,0,2,0,3,0,2,0,2,3,4,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(40,Runtime),0,1,str("abc"),str("aabcba")],[[0,1,0,0]]]), %0‿1‿0‿0≡"abc"⍷"aabcba"
    {_,1} = ebqn:run(St0,[[0,11,0,3,16,0,1,0,10,0,10,3,2,17,0,4,0,8,0,9,3,2,0,2,0,6,0,7,3,2,17,17,0,0,0,5,0,5,3,2,0,2,0,5,0,6,3,2,17,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(24,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(40,Runtime),0,1,2,4,5,3,9],[[0,1,0,0]]]), %(0‿1≍0‿0)≡(1‿2≍4‿5)⍷3‿3⥊↕9
    {_,1} = ebqn:run(St0,[[0,8,0,4,0,1,7,0,5,0,3,8,16,0,0,0,6,0,7,3,2,0,2,16,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(24,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(40,Runtime),ebqn_array:get(45,Runtime),ebqn_array:get(55,Runtime),3,0,str("abc")],[[0,1,0,0]]]), %(↕3‿0)≡⍷⟜(≍˘)"abc"
    {_,1} = ebqn:run(St0,[[0,4,0,2,0,1,0,0,19,0,3,17,25],[ebqn_array:get(15,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(40,Runtime),char("a"),str("abc")],[[0,1,0,0]]]), %'a'(=≡⍷)"abc"
    {_,1} = ebqn:run(St0,[[0,7,0,1,0,6,17,0,2,16,0,4,0,0,0,5,0,3,7,19,16,25],[ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(30,Runtime),ebqn_array:get(31,Runtime),ebqn_array:get(46,Runtime),2,3],[[0,1,0,0]]]), %(⌽¨≡⍉)↕2⥊3
    {_,1} = ebqn:run(St0,[[0,3,0,0,0,1,0,2,19,16,25],[ebqn_array:get(12,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(31,Runtime),char("a")],[[0,1,0,0]]]), %(⍉≡<)'a'
    {_,1} = ebqn:run(St0,[[0,7,0,1,16,0,8,0,9,0,10,3,4,0,4,0,2,0,6,0,3,8,7,16,0,5,0,0,7,16,25],[ebqn_array:get(10,Runtime),ebqn_array:get(12,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(31,Runtime),ebqn_array:get(46,Runtime),ebqn_array:get(49,Runtime),ebqn_array:get(54,Runtime),char("a"),str("a"),str("abc"),str("")],[[0,1,0,0]]]), %∧´⍉⊸≡¨⟨<'a',"a","abc",""⟩
    {_,1} = ebqn:run(St0,[[0,7,0,8,3,2,0,2,16,0,5,0,0,7,0,3,9,0,1,0,4,0,5,0,4,0,0,7,7,7,19,0,6,0,2,16,17,25],[ebqn_array:get(1,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(31,Runtime),ebqn_array:get(44,Runtime),ebqn_array:get(47,Runtime),4,3,2],[[0,1,0,0]]]), %(↕4)(-˜⌜˜≡·⍉-⌜)↕3‿2
    ok = try ebqn:run(St0,[[0,4,0,0,0,4,0,0,0,5,17,17,0,1,0,2,0,3,0,4,3,3,17,25],[ebqn_array:get(22,Runtime),ebqn_array:get(31,Runtime),0,-1,1,3],[[0,1,0,0]]]) % 0‿¯1‿1⍉(3⥊1)⥊1
        catch _ -> ok
    end,
    ok = try ebqn:run(St0,[[0,7,0,0,0,6,17,0,1,0,3,0,2,0,0,7,8,0,4,0,5,3,2,17,25],[ebqn_array:get(24,Runtime),ebqn_array:get(31,Runtime),ebqn_array:get(45,Runtime),ebqn_array:get(54,Runtime),1,0,str("ab"),str("cd")],[[0,1,0,0]]]) % 1‿0≍˘⊸⍉"ab"≍"cd"
        catch _ -> ok
    end,
    ok = try ebqn:run(St0,[[0,7,0,1,16,0,3,0,4,0,0,7,7,16,0,2,0,5,0,6,3,2,17,25],[ebqn_array:get(0,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(31,Runtime),ebqn_array:get(44,Runtime),ebqn_array:get(47,Runtime),0,2,3],[[0,1,0,0]]]) % 0‿2⍉+⌜˜↕3
        catch _ -> ok
    end,
    ok = try ebqn:run(St0,[[0,4,0,0,16,0,0,16,0,1,0,2,0,3,0,3,3,3,17,25],[ebqn_array:get(27,Runtime),ebqn_array:get(31,Runtime),2,0,3],[[0,1,0,0]]]) % 2‿0‿0⍉↕↕3
        catch _ -> ok
    end,
    ok = try ebqn:run(St0,[[0,2,0,0,16,0,0,16,0,1,0,2,17,25],[ebqn_array:get(27,Runtime),ebqn_array:get(31,Runtime),3],[[0,1,0,0]]]) % 3⍉↕↕3
        catch _ -> ok
    end,
    {_,1} = ebqn:run(St0,[[0,8,0,3,0,6,0,5,0,0,7,8,0,10,17,0,4,0,9,0,9,3,2,17,0,2,0,8,0,3,16,0,1,0,7,17,17,25],[ebqn_array:get(0,Runtime),ebqn_array:get(2,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(31,Runtime),ebqn_array:get(47,Runtime),ebqn_array:get(53,Runtime),2,3,0,6],[[0,1,0,0]]]), %(2×↕3)≡0‿0⍉6+⌜○↕3
    {_,1} = ebqn:run(St0,[[0,4,0,0,0,1,0,2,0,3,3,0,8,19,16,25],[ebqn_array:get(12,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(31,Runtime),ebqn_array:get(54,Runtime),4],[[0,1,0,0]]]), %(⟨⟩⊸⍉≡<)4
    {_,1} = ebqn:run(St0,[[0,4,0,0,16,0,2,0,1,0,3,19,3,0,17,25],[ebqn_array:get(12,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(21,Runtime),ebqn_array:get(31,Runtime),4],[[0,1,0,0]]]), %⟨⟩(⍉≡⊢)<4
    {_,1} = ebqn:run(St0,[[0,7,0,2,16,0,2,16,0,3,0,6,0,4,0,5,0,6,3,4,17,0,0,3,0,0,1,0,4,0,5,0,6,3,3,17,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(31,Runtime),2,0,1,4],[[0,1,0,0]]]), %(2‿0‿1⥊⟨⟩)≡1‿2‿0‿1⍉↕↕4
    {_,1} = ebqn:run(St0,[[0,9,0,2,16,0,2,16,0,3,0,4,0,0,8,0,6,17,0,1,0,5,0,6,0,7,0,8,3,4,0,2,16,17,25],[ebqn_array:get(12,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(31,Runtime),ebqn_array:get(54,Runtime),1,2,0,3,4],[[0,1,0,0]]]), %(↕1‿2‿0‿3)≡2<⊸⍉↕↕4
    {_,1} = ebqn:run(St0,[[0,8,0,2,16,0,1,0,6,0,7,3,2,17,0,0,0,4,0,3,0,4,0,5,8,8,16,25],[ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(31,Runtime),ebqn_array:get(54,Runtime),0,2,3,6],[[0,1,0,0]]]), %0⊸⍉⊸≡2‿3⥊↕6
    ok = try ebqn:run(St0,[[0,1,0,0,16,25],[ebqn_array:get(33,Runtime),char("a")],[[0,1,0,0]]]) % ⍋'a'
        catch _ -> ok
    end,
    ok = try ebqn:run(St0,[[0,2,0,1,3,2,0,0,16,25],[ebqn_array:get(33,Runtime),ebqn_array:get(52,Runtime),char("a")],[[0,1,0,0]]]) % ⍋'a'‿∘
        catch _ -> ok
    end,
    ok = try ebqn:run(St0,[[0,1,0,0,16,25],[ebqn_array:get(34,Runtime),2],[[0,1,0,0]]]) % ⍒2
        catch _ -> ok
    end,
    {_,1} = ebqn:run(St0,[[0,7,0,1,16,0,0,0,2,0,3,0,4,0,5,0,6,3,5,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(33,Runtime),2,0,3,1,4,str("bdace")],[[0,1,0,0]]]), %2‿0‿3‿1‿4≡⍋"bdace"
    {_,1} = ebqn:run(St0,[[0,9,0,1,16,0,2,16,0,0,0,3,0,4,0,5,0,6,0,7,0,8,3,6,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(26,Runtime),ebqn_array:get(33,Runtime),5,2,4,3,0,1,str("deabb")],[[0,1,0,0]]]), %5‿2‿4‿3‿0‿1≡⍋↓"deabb"
    {_,1} = ebqn:run(St0,[[0,7,0,6,0,3,16,0,8,0,0,16,0,2,0,6,17,3,3,0,5,0,1,0,4,19,16,25],[ebqn_array:get(12,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(25,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(33,Runtime),ebqn_array:get(34,Runtime),0,str(""),str("abc")],[[0,1,0,0]]]), %(⍋≡⍒)⟨"",↕0,0↑<"abc"⟩
    {_,1} = ebqn:run(St0,[[0,6,0,7,0,8,0,9,0,10,0,11,0,12,3,7,0,0,0,5,0,2,0,5,0,3,8,8,0,1,0,4,19,16,25],[ebqn_array:get(14,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(30,Runtime),ebqn_array:get(34,Runtime),ebqn_array:get(52,Runtime),ninf,-1.5,3.141592653589793,inf,char("A"),char("a"),char("b")],[[0,1,0,0]]]), %(⍒≡⌽∘↕∘≠)⟨¯∞,¯1.5,π,∞,'A','a','b'⟩
    {_,1} = ebqn:run(St0,[[0,8,0,4,16,0,9,0,10,0,10,0,11,3,2,0,10,0,8,3,2,0,10,0,8,0,8,3,3,0,10,0,12,3,2,0,8,0,8,0,3,0,13,17,0,14,0,15,0,16,0,0,0,15,17,3,12,0,1,0,7,0,4,0,7,0,5,8,8,0,2,0,6,19,16,25],[ebqn_array:get(0,Runtime),ebqn_array:get(14,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(30,Runtime),ebqn_array:get(34,Runtime),ebqn_array:get(52,Runtime),0,-1.1,-1,ninf,inf,6,1.0E-20,1,1.0E-15],[[0,1,0,0]]]), %(⍒≡⌽∘↕∘≠)⟨↕0,¯1.1,¯1,¯1‿¯∞,¯1‿0,¯1‿0‿0,¯1‿∞,0,6⥊0,1e¯20,1,1+1e¯15⟩
    {_,1} = ebqn:run(St0,[[0,14,0,0,0,8,0,3,7,0,10,0,5,16,0,11,0,11,0,11,3,2,0,12,0,11,0,11,3,3,0,12,0,11,3,2,0,12,0,11,0,12,3,2,0,12,0,12,3,2,0,13,3,9,19,0,4,0,0,19,16,0,1,0,9,0,5,0,9,0,6,8,8,0,2,0,7,19,16,25],[ebqn_array:get(12,Runtime),ebqn_array:get(14,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(23,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(30,Runtime),ebqn_array:get(34,Runtime),ebqn_array:get(46,Runtime),ebqn_array:get(52,Runtime),0,1,2,3,char("a")],[[0,1,0,0]]]), %(⍒≡⌽∘↕∘≠)(<∾⟨↕0,1,1‿1,2‿1‿1,2‿1,2,1‿2,2‿2,3⟩⥊¨<)'a'
    {_,1} = ebqn:run(St0,[[0,11,0,12,3,2,0,6,0,2,0,8,0,11,0,9,0,2,8,8,7,0,10,0,3,16,17,0,4,16,0,2,16,0,0,0,7,0,3,8,0,1,0,5,19,16,25],[ebqn_array:get(14,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(31,Runtime),ebqn_array:get(33,Runtime),ebqn_array:get(47,Runtime),ebqn_array:get(52,Runtime),ebqn_array:get(54,Runtime),ebqn_array:get(55,Runtime),5,1,char("b")],[[0,1,0,0]]]), %(⍋≡↕∘≠)⥊⍉(↕5)⥊⟜1⊸⥊⌜1‿'b'
    {_,1} = ebqn:run(St0,[[0,9,0,10,0,8,0,11,3,4,0,3,0,4,0,1,0,0,0,7,0,8,3,2,19,19,0,5,0,6,0,2,8,0,3,19,16,25],[ebqn_array:get(0,Runtime),ebqn_array:get(14,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(21,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(33,Runtime),ebqn_array:get(53,Runtime),0,1,-2,char("a"),char("f")],[[0,1,0,0]]]), %(⊢≡○⍋(0‿1+≠)⥊⊢)⟨¯2,'a',1,'f'⟩
    {_,1} = ebqn:run(St0,[[0,25,0,8,16,0,12,0,24,0,8,16,0,19,0,3,0,16,0,15,0,0,7,8,8,7,0,19,0,13,0,6,7,8,0,6,0,9,9,0,17,0,4,8,0,13,0,2,0,18,0,14,0,1,7,8,0,7,0,5,0,7,0,2,19,0,18,0,10,0,18,0,23,8,8,19,0,11,0,7,7,0,5,0,16,0,3,8,19,0,18,0,6,8,7,19,0,20,0,21,0,22,0,20,0,21,3,2,0,21,0,20,3,2,0,20,0,22,3,2,0,21,0,21,3,2,0,22,0,20,3,2,3,8,17,25],[ebqn_array:get(0,Runtime),ebqn_array:get(2,Runtime),ebqn_array:get(6,Runtime),ebqn_array:get(14,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(20,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(23,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(33,Runtime),ebqn_array:get(36,Runtime),ebqn_array:get(44,Runtime),ebqn_array:get(46,Runtime),ebqn_array:get(47,Runtime),ebqn_array:get(49,Runtime),ebqn_array:get(51,Runtime),ebqn_array:get(52,Runtime),ebqn_array:get(53,Runtime),ebqn_array:get(54,Runtime),ebqn_array:get(55,Runtime),1,2,3,-1,6,4],[[0,1,0,0]]]), %⟨1,2,3,1‿2,2‿1,1‿3,2‿2,3‿1⟩(⥊⊸(≠∘⊣∾˜¯1⊸⊑⊸(⌊∾⊣)∾×´⊸⌊)⌜≡○(⍋⥊)⥊⌜⟜(+`∘≠⟜(↕6)¨))↕4
    {_,1} = ebqn:run(St0,[[0,14,0,5,16,0,6,0,12,17,0,8,0,0,0,7,19,0,3,0,2,0,10,0,12,0,13,3,2,0,11,0,4,8,0,1,0,9,0,4,7,19,8,19,16,25],[ebqn_array:get(0,Runtime),ebqn_array:get(1,Runtime),ebqn_array:get(14,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(32,Runtime),ebqn_array:get(33,Runtime),ebqn_array:get(34,Runtime),ebqn_array:get(44,Runtime),ebqn_array:get(52,Runtime),ebqn_array:get(55,Runtime),2,0,5],[[0,1,0,0]]]), %((⥊˜-⥊⟜2‿0)∘≠≡⍋+⍒)2/↕5
    ok = try ebqn:run(St0,[[0,0,3,1,0,2,16,0,1,16,25],[ebqn_array:get(0,Runtime),ebqn_array:get(10,Runtime),ebqn_array:get(35,Runtime)],[[0,1,0,0]]]) % ∧⊏⟨+⟩
        catch _ -> ok
    end,
    ok = try ebqn:run(St0,[[0,0,0,1,3,2,0,2,16,25],[ebqn_array:get(0,Runtime),ebqn_array:get(1,Runtime),ebqn_array:get(10,Runtime)],[[0,1,0,0]]]) % ∧+‿-
        catch _ -> ok
    end,
    ok = try ebqn:run(St0,[[0,1,0,0,16,25],[ebqn_array:get(11,Runtime),char("c")],[[0,1,0,0]]]) % ∨'c'
        catch _ -> ok
    end,
    {_,1} = ebqn:run(St0,[[0,3,0,0,16,0,1,0,2,17,25],[ebqn_array:get(11,Runtime),ebqn_array:get(18,Runtime),str("edcba"),str("bdace")],[[0,1,0,0]]]), %"edcba"≡∨"bdace"
    {_,1} = ebqn:run(St0,[[0,8,0,4,16,0,0,0,9,17,0,5,0,7,0,1,8,16,0,6,16,0,2,16,0,3,0,8,0,4,16,17,25],[ebqn_array:get(0,Runtime),ebqn_array:get(8,Runtime),ebqn_array:get(10,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(30,Runtime),ebqn_array:get(33,Runtime),ebqn_array:get(55,Runtime),7,1],[[0,1,0,0]]]), %(↕7)≡∧⍋|⟜⌽1+↕7
    ok = try ebqn:run(St0,[[0,2,0,1,0,0,7,16,25],[ebqn_array:get(33,Runtime),ebqn_array:get(44,Runtime),6],[[0,1,0,0]]]) % ⍋˜6
        catch _ -> ok
    end,
    ok = try ebqn:run(St0,[[0,3,0,0,0,2,0,1,8,16,25],[ebqn_array:get(27,Runtime),ebqn_array:get(34,Runtime),ebqn_array:get(55,Runtime),4],[[0,1,0,0]]]) % ⍒⟜↕4
        catch _ -> ok
    end,
    ok = try ebqn:run(St0,[[0,6,0,0,0,4,17,0,1,0,5,0,0,0,2,0,3,0,4,3,3,17,17,25],[ebqn_array:get(22,Runtime),ebqn_array:get(33,Runtime),3,2,4,0,1],[[0,1,0,0]]]) % (3‿2‿4⥊0)⍋4⥊1
        catch _ -> ok
    end,
    ok = try ebqn:run(St0,[[0,6,0,1,0,5,0,0,0,2,0,3,0,4,3,3,17,17,25],[ebqn_array:get(22,Runtime),ebqn_array:get(34,Runtime),3,2,4,0,1],[[0,1,0,0]]]) % (3‿2‿4⥊0)⍒1
        catch _ -> ok
    end,
    ok = try ebqn:run(St0,[[0,3,0,1,16,0,2,0,0,3,1,17,25],[ebqn_array:get(0,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(33,Runtime),6],[[0,1,0,0]]]) % ⟨+⟩⍋↕6
        catch _ -> ok
    end,
    ok = try ebqn:run(St0,[[0,1,0,2,15,1,3,3,3,1,0,0,0,1,0,2,0,1,3,3,0,1,0,2,0,3,3,3,3,2,17,25,21,0,1,25],[ebqn_array:get(34,Runtime),1,3,2],[[0,1,0,0],[0,0,32,3]]]) % ⟨1‿3‿1,1‿3‿2⟩⍒⟨1‿3‿{𝕩}⟩
        catch _ -> ok
    end,
    {_,1} = ebqn:run(St0,[[0,23,0,7,0,20,0,9,16,0,12,0,1,7,0,19,17,17,0,7,0,14,0,10,8,0,2,0,14,0,13,0,0,7,8,0,11,0,15,0,10,8,0,6,19,0,8,0,5,19,0,5,0,14,0,3,8,19,0,4,0,10,19,0,16,0,17,0,18,0,21,0,22,3,5,17,25],[ebqn_array:get(0,Runtime),ebqn_array:get(3,Runtime),ebqn_array:get(13,Runtime),ebqn_array:get(14,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(20,Runtime),ebqn_array:get(21,Runtime),ebqn_array:get(23,Runtime),ebqn_array:get(26,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(33,Runtime),ebqn_array:get(35,Runtime),ebqn_array:get(44,Runtime),ebqn_array:get(51,Runtime),ebqn_array:get(52,Runtime),ebqn_array:get(54,Runtime),1,3,inf,2,8,char("e"),char("i"),str("aegz")],[[0,1,0,0]]]), %⟨1,3,∞,'e','i'⟩ (⍋≡≠∘⊣(⊣↓⊢⍋⊸⊏+`∘>)⍋∘∾) (2÷˜↕8)∾"aegz"
    {_,1} = ebqn:run(St0,[[0,23,0,7,0,20,0,9,16,0,13,0,1,7,0,19,17,17,0,7,0,15,0,11,8,0,2,0,15,0,14,0,0,7,8,0,12,0,16,0,10,8,0,6,19,0,8,0,5,19,0,5,0,15,0,3,8,19,0,4,0,11,19,0,21,0,22,0,17,0,18,3,2,0,18,3,4,17,25],[ebqn_array:get(0,Runtime),ebqn_array:get(3,Runtime),ebqn_array:get(13,Runtime),ebqn_array:get(14,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(20,Runtime),ebqn_array:get(21,Runtime),ebqn_array:get(23,Runtime),ebqn_array:get(26,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(33,Runtime),ebqn_array:get(34,Runtime),ebqn_array:get(35,Runtime),ebqn_array:get(44,Runtime),ebqn_array:get(51,Runtime),ebqn_array:get(52,Runtime),ebqn_array:get(54,Runtime),1,0,2,8,char("z"),char("d"),str("aegz")],[[0,1,0,0]]]), %⟨'z','d',1‿0,0⟩ (⍒≡≠∘⊣(⊣↓⊢⍋⊸⊏+`∘>)⍒∘∾) (2÷˜↕8)∾"aegz"
    {_,1} = ebqn:run(St0,[[0,8,0,4,0,6,0,7,0,3,16,8,0,2,0,0,0,5,0,1,8,19,16,25],[ebqn_array:get(7,Runtime),ebqn_array:get(12,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(33,Runtime),ebqn_array:get(52,Runtime),ebqn_array:get(54,Runtime),6,2.5],[[0,1,0,0]]]), %(<∘⌈≡(↕6)⊸⍋)2.5
    {_,1} = ebqn:run(St0,[[0,7,0,3,16,0,0,0,5,17,0,4,0,6,0,7,3,2,0,3,16,17,0,2,0,5,0,1,16,17,25],[ebqn_array:get(0,Runtime),ebqn_array:get(12,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(33,Runtime),1,2,3],[[0,1,0,0]]]), %(<1)≡(↕2‿3)⍋1+↕3
    {_,1} = ebqn:run(St0,[[0,9,0,3,16,0,0,0,5,0,4,0,6,0,2,8,8,0,8,17,0,1,0,7,0,0,16,17,25],[ebqn_array:get(12,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(24,Runtime),ebqn_array:get(34,Runtime),ebqn_array:get(53,Runtime),ebqn_array:get(54,Runtime),0,str("abc"),str("acc")],[[0,1,0,0]]]), %(<0)≡"abc"⥊⊸⍒○<≍"acc"
    ok.

undo(St0,Rt) ->
    % # Data
    {_,1} = ebqn:run(St0,[[0,6,0,7,0,9,0,10,0,8,0,2,16,3,5,0,3,15,1,7,16,0,5,0,0,7,16,25,21,0,1,0,4,21,0,1,7,16,0,1,21,0,1,17,25],[ebqn_array:get(10,Rt#a.r),ebqn_array:get(18,Rt#a.r),ebqn_array:get(27,Rt#a.r),ebqn_array:get(46,Rt#a.r),ebqn_array:get(48,Rt#a.r),ebqn_array:get(49,Rt#a.r),ninf,3,4,ebqn:char("\0"),ebqn:char("⁼")],[[0,1,0,0],[0,0,28,3]]]), %∧´{𝕩≡𝕩⁼𝕩}¨⟨¯∞,3,@,'⁼',↕4⟩
    ok = try ebqn:run(St0,[[0,2,0,0,0,1,7,16,25],[ebqn_array:get(48,Rt#a.r),3,4],[[0,1,0,0]]]) % 3⁼4
        catch _ -> ok
    end,
    ok = try ebqn:run(St0,[[0,1,0,3,3,2,0,0,0,1,0,2,3,2,7,16,25],[ebqn_array:get(48,Rt#a.r),2,3,3.1],[[0,1,0,0]]]) % 2‿3⁼2‿3.1
        catch _ -> ok
    end,
    %
    % # Primitives
    {_,1} = ebqn:run(St0,[[0,0,0,1,0,2,0,3,0,7,0,6,0,8,3,7,0,9,0,13,0,14,0,15,3,3,0,12,15,1,8,7,16,0,11,0,4,7,16,25,21,0,1,0,10,21,0,2,7,0,5,21,0,2,19,16,25],[ebqn_array:get(0,Rt#a.r),ebqn_array:get(1,Rt#a.r),ebqn_array:get(3,Rt#a.r),ebqn_array:get(9,Rt#a.r),ebqn_array:get(10,Rt#a.r),ebqn_array:get(18,Rt#a.r),ebqn_array:get(20,Rt#a.r),ebqn_array:get(21,Rt#a.r),ebqn_array:get(30,Rt#a.r),ebqn_array:get(46,Rt#a.r),ebqn_array:get(48,Rt#a.r),ebqn_array:get(49,Rt#a.r),ebqn_array:get(55,Rt#a.r),-0.3,0,8],[[0,1,0,0],[0,0,40,3]]]), %∧´ {(𝕎≡𝕎⁼)𝕩}⟜¯0.3‿0‿8¨ +‿-‿÷‿¬‿⊢‿⊣‿⌽
    ok = try ebqn:run(St0,[[0,2,0,1,0,0,7,16,25],[ebqn_array:get(1,Rt#a.r),ebqn_array:get(48,Rt#a.r),ebqn:char("a")],[[0,1,0,0]]]) % -⁼ 'a'
        catch _ -> ok
    end,
    {_,1} = ebqn:run(St0,[[0,4,0,5,0,6,0,7,0,8,3,5,0,1,0,3,0,2,0,0,7,0,0,9,8,16,25],[ebqn_array:get(5,Rt#a.r),ebqn_array:get(18,Rt#a.r),ebqn_array:get(48,Rt#a.r),ebqn_array:get(54,Rt#a.r),0,0.4,3.141592653589793,1.0E9,inf],[[0,1,0,0]]]), %(√√⁼)⊸≡ 0‿0.4‿π‿1e9‿∞
    {_,1} = ebqn:run(St0,[[0,5,0,2,16,0,1,0,4,0,0,0,3,0,0,7,9,8,16,25],[ebqn_array:get(4,Rt#a.r),ebqn_array:get(18,Rt#a.r),ebqn_array:get(27,Rt#a.r),ebqn_array:get(48,Rt#a.r),ebqn_array:get(54,Rt#a.r),4],[[0,1,0,0]]]), %(⋆⁼⋆)⊸≡ ↕4
    {_,1} = ebqn:run(St0,[[0,13,0,7,16,0,0,0,12,17,0,8,0,2,0,6,19,0,12,17,0,9,0,3,7,16,0,10,0,0,7,16,0,3,16,0,1,0,12,17,0,4,16,0,5,0,11,17,25],[ebqn_array:get(0,Rt#a.r),ebqn_array:get(1,Rt#a.r),ebqn_array:get(3,Rt#a.r),ebqn_array:get(4,Rt#a.r),ebqn_array:get(8,Rt#a.r),ebqn_array:get(13,Rt#a.r),ebqn_array:get(21,Rt#a.r),ebqn_array:get(27,Rt#a.r),ebqn_array:get(28,Rt#a.r),ebqn_array:get(48,Rt#a.r),ebqn_array:get(49,Rt#a.r),1.0E-14,1,11],[[0,1,0,0]]]), %1e¯14>|1-⋆+´⋆⁼1(⊢÷«)1+↕11
    {_,1} = ebqn:run(St0,[[0,0,0,1,0,2,0,3,0,4,0,6,0,5,0,8,3,8,0,9,0,14,0,15,0,16,3,3,0,12,15,1,8,7,16,0,11,0,6,7,16,25,21,0,1,0,10,21,0,2,7,0,13,17,21,0,2,0,13,17,0,7,21,0,1,17,25],[ebqn_array:get(0,Rt#a.r),ebqn_array:get(1,Rt#a.r),ebqn_array:get(2,Rt#a.r),ebqn_array:get(3,Rt#a.r),ebqn_array:get(5,Rt#a.r),ebqn_array:get(9,Rt#a.r),ebqn_array:get(10,Rt#a.r),ebqn_array:get(18,Rt#a.r),ebqn_array:get(21,Rt#a.r),ebqn_array:get(46,Rt#a.r),ebqn_array:get(48,Rt#a.r),ebqn_array:get(49,Rt#a.r),ebqn_array:get(55,Rt#a.r),6,1,2,3],[[0,1,0,0],[0,0,42,3]]]), %∧´ {𝕩≡6𝕎6𝕎⁼𝕩}⟜1‿2‿3¨ +‿-‿×‿÷‿√‿∧‿¬‿⊢
    {_,1} = ebqn:run(St0,[[0,5,0,2,0,0,7,0,3,17,0,1,0,4,17,25],[ebqn_array:get(0,Rt#a.r),ebqn_array:get(18,Rt#a.r),ebqn_array:get(48,Rt#a.r),3,ebqn:char("a"),ebqn:char("d")],[[0,1,0,0]]]), %'a' ≡ 3+⁼'d'
    {_,3} = ebqn:run(St0,[[0,3,0,1,0,0,7,0,2,17,25],[ebqn_array:get(1,Rt#a.r),ebqn_array:get(48,Rt#a.r),ebqn:char("d"),ebqn:char("a")],[[0,1,0,0]]]), % 'd'-⁼'a'
    {_,1} = ebqn:run(St0,[[0,10,0,11,0,12,0,13,3,4,0,5,0,1,7,0,6,0,4,0,3,0,0,7,7,8,0,2,0,4,0,5,0,1,7,7,19,0,7,0,8,0,9,3,3,17,25],[ebqn_array:get(3,Rt#a.r),ebqn_array:get(4,Rt#a.r),ebqn_array:get(18,Rt#a.r),ebqn_array:get(44,Rt#a.r),ebqn_array:get(47,Rt#a.r),ebqn_array:get(48,Rt#a.r),ebqn_array:get(53,Rt#a.r),0.3,1.01,3.141592653589793,0,2,5.6,inf],[[0,1,0,0]]]), %0.3‿1.01‿π(⋆⁼⌜≡÷˜⌜○(⋆⁼))0‿2‿5.6‿∞
    {_,1} = ebqn:run(St0,[[0,5,0,3,0,4,0,1,7,7,0,0,0,2,19,16,25],[ebqn_array:get(18,Rt#a.r),ebqn_array:get(20,Rt#a.r),ebqn_array:get(21,Rt#a.r),ebqn_array:get(44,Rt#a.r),ebqn_array:get(48,Rt#a.r),ebqn:str("abcd")],[[0,1,0,0]]]), %(⊢≡⊣⁼˜)"abcd"
    ok = try ebqn:run(St0,[[0,3,0,1,0,0,7,0,2,17,25],[ebqn_array:get(20,Rt#a.r),ebqn_array:get(48,Rt#a.r),ebqn:str("ab"),ebqn:str("ac")],[[0,1,0,0]]]) % "ab"⊣⁼"ac"
        catch _ -> ok
    end,
    {_,1} = ebqn:run(St0,[[0,5,3,0,0,6,3,3,0,1,0,4,0,2,0,0,0,3,0,0,7,9,7,8,16,25],[ebqn_array:get(12,Rt#a.r),ebqn_array:get(18,Rt#a.r),ebqn_array:get(46,Rt#a.r),ebqn_array:get(48,Rt#a.r),ebqn_array:get(54,Rt#a.r),0,ebqn:str("abc")],[[0,1,0,0]]]), %(<⁼<)¨⊸≡⟨0,⟨⟩,"abc"⟩
    {_,1} = ebqn:run(St0,[[0,4,0,5,0,6,0,7,3,4,0,0,0,3,0,1,0,2,0,1,7,9,8,16,25],[ebqn_array:get(18,Rt#a.r),ebqn_array:get(32,Rt#a.r),ebqn_array:get(48,Rt#a.r),ebqn_array:get(54,Rt#a.r),1,0,2,4],[[0,1,0,0]]]), %(/⁼/)⊸≡1‿0‿2‿4
    {_,1} = ebqn:run(St0,[[3,0,0,2,0,1,7,16,0,0,3,0,17,25],[ebqn_array:get(18,Rt#a.r),ebqn_array:get(32,Rt#a.r),ebqn_array:get(48,Rt#a.r)],[[0,1,0,0]]]), %⟨⟩≡/⁼⟨⟩
    {_,1} = ebqn:run(St0,[[0,8,0,2,16,0,1,0,4,0,3,7,0,7,19,0,0,0,3,0,5,0,6,8,19,16,25],[ebqn_array:get(18,Rt#a.r),ebqn_array:get(21,Rt#a.r),ebqn_array:get(27,Rt#a.r),ebqn_array:get(30,Rt#a.r),ebqn_array:get(48,Rt#a.r),ebqn_array:get(54,Rt#a.r),3,2,5],[[0,1,0,0]]]), %(3⊸⌽≡2⌽⁼⊢)↕5
    {_,1} = ebqn:run(St0,[[0,7,0,2,16,0,2,16,0,1,0,3,0,6,19,0,0,0,5,0,4,7,0,1,9,19,16,25],[ebqn_array:get(18,Rt#a.r),ebqn_array:get(19,Rt#a.r),ebqn_array:get(27,Rt#a.r),ebqn_array:get(30,Rt#a.r),ebqn_array:get(31,Rt#a.r),ebqn_array:get(48,Rt#a.r),-1,4],[[0,1,0,0]]]), %((≢⍉⁼)≡¯1⌽≢)↕↕4
    {_,1} = ebqn:run(St0,[[0,9,0,10,0,10,3,3,0,5,0,0,7,0,3,9,0,6,0,2,8,16,0,8,0,9,3,2,0,7,0,4,8,16,0,5,0,1,7,16,25],[ebqn_array:get(2,Rt#a.r),ebqn_array:get(18,Rt#a.r),ebqn_array:get(22,Rt#a.r),ebqn_array:get(27,Rt#a.r),ebqn_array:get(31,Rt#a.r),ebqn_array:get(49,Rt#a.r),ebqn_array:get(55,Rt#a.r),ebqn_array:get(61,Rt#a.r),-1,2,3],[[0,1,0,0]]]), %≡´⍉⍟¯1‿2⥊⟜(↕×´)2‿3‿3
    {_,1} = ebqn:run(St0,[[0,10,0,12,0,11,0,13,3,4,0,8,0,0,7,0,5,9,0,9,0,4,8,16,0,7,0,6,7,0,6,0,2,19,0,1,0,3,19,0,10,0,11,3,2,17,25],[ebqn_array:get(2,Rt#a.r),ebqn_array:get(18,Rt#a.r),ebqn_array:get(20,Rt#a.r),ebqn_array:get(21,Rt#a.r),ebqn_array:get(22,Rt#a.r),ebqn_array:get(27,Rt#a.r),ebqn_array:get(31,Rt#a.r),ebqn_array:get(48,Rt#a.r),ebqn_array:get(49,Rt#a.r),ebqn_array:get(55,Rt#a.r),2,1,3,4],[[0,1,0,0]]]), %2‿1(⊢≡⊣⍉⍉⁼)⥊⟜(↕×´)2‿3‿1‿4
    %
    % # Self/Swap
    {_,1} = ebqn:run(St0,[[0,0,0,1,0,2,3,3,0,5,0,10,0,11,0,12,3,3,0,8,15,1,8,7,16,0,7,0,2,7,16,25,21,0,1,0,6,21,0,2,7,0,3,0,6,0,4,21,0,2,7,7,19,0,9,17,25],[ebqn_array:get(0,Rt#a.r),ebqn_array:get(2,Rt#a.r),ebqn_array:get(10,Rt#a.r),ebqn_array:get(18,Rt#a.r),ebqn_array:get(44,Rt#a.r),ebqn_array:get(46,Rt#a.r),ebqn_array:get(48,Rt#a.r),ebqn_array:get(49,Rt#a.r),ebqn_array:get(55,Rt#a.r),6,-0.8,0,3],[[0,1,0,0],[0,0,32,3]]]), %∧´ {6(𝕎˜⁼≡𝕎⁼)𝕩}⟜¯0.8‿0‿3¨ +‿×‿∧
    {_,3.5} = ebqn:run(St0,[[0,3,0,2,0,1,0,0,7,7,16,25],[ebqn_array:get(0,Rt#a.r),ebqn_array:get(44,Rt#a.r),ebqn_array:get(48,Rt#a.r),7],[[0,1,0,0]]]), % +˜⁼7
    {_,0.5} = ebqn:run(St0,[[0,3,0,2,0,1,0,0,7,7,16,25],[ebqn_array:get(11,Rt#a.r),ebqn_array:get(44,Rt#a.r),ebqn_array:get(48,Rt#a.r),0.75],[[0,1,0,0]]]), % ∨˜⁼0.75
    {_,1} = ebqn:run(St0,[[0,9,0,10,0,11,3,3,0,6,15,1,7,0,2,0,7,0,5,0,1,7,7,0,7,0,5,0,3,7,7,3,3,17,0,4,16,0,8,0,0,7,16,25,21,0,1,21,0,2,16,25],[ebqn_array:get(0,Rt#a.r),ebqn_array:get(2,Rt#a.r),ebqn_array:get(5,Rt#a.r),ebqn_array:get(10,Rt#a.r),ebqn_array:get(39,Rt#a.r),ebqn_array:get(44,Rt#a.r),ebqn_array:get(47,Rt#a.r),ebqn_array:get(48,Rt#a.r),ebqn_array:get(49,Rt#a.r),0,2,inf],[[0,1,0,0],[0,0,44,3]]]), % +´∊⟨√,×˜⁼,∧˜⁼⟩{𝕎𝕩}⌜0‿2‿∞
    {_,1} = ebqn:run(St0,[[0,0,0,2,0,5,3,3,0,10,15,1,7,0,1,0,3,0,4,3,3,17,0,12,0,6,7,16,25,0,14,0,4,16,0,8,0,14,0,15,3,2,17,21,0,1,0,7,0,11,0,9,21,0,2,7,7,19,0,13,17,25],[ebqn_array:get(0,Rt#a.r),ebqn_array:get(1,Rt#a.r),ebqn_array:get(2,Rt#a.r),ebqn_array:get(3,Rt#a.r),ebqn_array:get(4,Rt#a.r),ebqn_array:get(5,Rt#a.r),ebqn_array:get(10,Rt#a.r),ebqn_array:get(18,Rt#a.r),ebqn_array:get(23,Rt#a.r),ebqn_array:get(44,Rt#a.r),ebqn_array:get(46,Rt#a.r),ebqn_array:get(48,Rt#a.r),ebqn_array:get(49,Rt#a.r),3,2,3.141592653589793],[[0,1,0,0],[0,0,29,3]]]), %∧´ -‿÷‿⋆ {3(𝕎˜⁼≡𝕏)2‿π∾⋆2}¨ +‿×‿√
    {_,4.0} = ebqn:run(St0,[[0,4,0,2,0,1,0,0,7,7,0,3,17,25],[ebqn_array:get(5,Rt#a.r),ebqn_array:get(44,Rt#a.r),ebqn_array:get(48,Rt#a.r),16,2],[[0,1,0,0]]]), % 16√˜⁼2
    {_,1} = ebqn:run(St0,[[0,9,0,6,0,10,3,3,0,0,0,0,0,8,19,0,2,0,4,0,3,0,1,7,7,19,0,5,0,6,0,7,3,3,17,25],[ebqn_array:get(0,Rt#a.r),ebqn_array:get(9,Rt#a.r),ebqn_array:get(18,Rt#a.r),ebqn_array:get(44,Rt#a.r),ebqn_array:get(48,Rt#a.r),4,2,0,-1,1,9],[[0,1,0,0]]]), %4‿2‿0(¬˜⁼≡¯1++)1‿2‿9
    %
    % # Mapping and scan
    ok = try ebqn:run(St0,[[0,3,0,2,0,1,0,0,7,7,16,25],[ebqn_array:get(1,Rt#a.r),ebqn_array:get(46,Rt#a.r),ebqn_array:get(48,Rt#a.r),2],[[0,1,0,0]]]) % -¨⁼ 2
        catch _ -> ok
    end,
    ok = try ebqn:run(St0,[[0,3,0,2,0,1,0,0,7,7,16,25],[ebqn_array:get(1,Rt#a.r),ebqn_array:get(47,Rt#a.r),ebqn_array:get(48,Rt#a.r),2],[[0,1,0,0]]]) % -⌜⁼ 2
        catch _ -> ok
    end,
    ok = try ebqn:run(St0,[[0,3,0,2,0,1,0,0,7,7,16,25],[ebqn_array:get(1,Rt#a.r),ebqn_array:get(45,Rt#a.r),ebqn_array:get(48,Rt#a.r),2],[[0,1,0,0]]]) % -˘⁼ 2
        catch _ -> ok
    end,
    ok = try ebqn:run(St0,[[0,4,0,1,16,0,3,0,2,0,0,7,7,16,25],[ebqn_array:get(1,Rt#a.r),ebqn_array:get(12,Rt#a.r),ebqn_array:get(45,Rt#a.r),ebqn_array:get(48,Rt#a.r),2],[[0,1,0,0]]]) % -˘⁼ <2
        catch _ -> ok
    end,
    ok = try ebqn:run(St0,[[0,3,0,1,0,2,0,0,7,7,16,25],[ebqn_array:get(1,Rt#a.r),ebqn_array:get(48,Rt#a.r),ebqn_array:get(51,Rt#a.r),2],[[0,1,0,0]]]) % -`⁼ 2
        catch _ -> ok
    end,
    ok = try ebqn:run(St0,[[0,4,0,1,0,2,0,0,7,7,0,3,17,25],[ebqn_array:get(1,Rt#a.r),ebqn_array:get(48,Rt#a.r),ebqn_array:get(49,Rt#a.r),0,2],[[0,1,0,0]]]) % 0-´⁼ 2
        catch _ -> ok
    end,
    {_,1} = ebqn:run(St0,[[0,7,0,4,0,0,7,0,6,0,4,0,0,7,7,0,2,0,6,0,5,0,0,7,7,19,9,0,1,0,3,0,2,7,19,16,25],[ebqn_array:get(12,Rt#a.r),ebqn_array:get(18,Rt#a.r),ebqn_array:get(23,Rt#a.r),ebqn_array:get(44,Rt#a.r),ebqn_array:get(46,Rt#a.r),ebqn_array:get(47,Rt#a.r),ebqn_array:get(48,Rt#a.r),ebqn:str("abcd")],[[0,1,0,0]]]), %(∾˜ ≡ ·(<⌜⁼∾<¨⁼)<¨) "abcd"
    {_,1} = ebqn:run(St0,[[0,7,0,8,3,2,0,2,0,3,0,1,7,7,0,4,17,0,0,0,5,0,6,3,2,17,25],[ebqn_array:get(18,Rt#a.r),ebqn_array:get(30,Rt#a.r),ebqn_array:get(46,Rt#a.r),ebqn_array:get(48,Rt#a.r),1,ebqn:str("ab"),ebqn:str("abc"),ebqn:str("ba"),ebqn:str("bca")],[[0,1,0,0]]]), %"ab"‿"abc"≡1⌽⁼¨"ba"‿"bca"
    {_,1} = ebqn:run(St0,[[0,11,0,11,0,12,3,3,0,3,0,11,0,12,0,12,3,3,17,0,9,0,7,0,5,7,7,16,0,2,0,10,0,4,16,0,6,0,8,0,1,7,7,16,0,0,0,10,17,17,25],[ebqn_array:get(1,Rt#a.r),ebqn_array:get(15,Rt#a.r),ebqn_array:get(18,Rt#a.r),ebqn_array:get(24,Rt#a.r),ebqn_array:get(27,Rt#a.r),ebqn_array:get(32,Rt#a.r),ebqn_array:get(44,Rt#a.r),ebqn_array:get(45,Rt#a.r),ebqn_array:get(47,Rt#a.r),ebqn_array:get(48,Rt#a.r),2,0,1],[[0,1,0,0]]]), %(2-=⌜˜↕2)≡/˘⁼0‿1‿1≍0‿0‿1
    {_,1} = ebqn:run(St0,[[0,8,0,1,16,0,3,0,6,0,5,0,2,7,8,0,3,9,0,0,0,5,0,4,0,2,7,7,19,0,7,17,25],[ebqn_array:get(18,Rt#a.r),ebqn_array:get(24,Rt#a.r),ebqn_array:get(30,Rt#a.r),ebqn_array:get(31,Rt#a.r),ebqn_array:get(45,Rt#a.r),ebqn_array:get(48,Rt#a.r),ebqn_array:get(55,Rt#a.r),2,ebqn:str("abcde")],[[0,1,0,0]]]), %2(⌽˘⁼≡·⍉⌽⁼⟜⍉)≍"abcde"
    {_,1} = ebqn:run(St0,[[0,6,0,3,16,0,0,0,7,17,0,4,0,5,0,0,7,7,16,0,1,0,7,0,2,0,6,17,17,25],[ebqn_array:get(0,Rt#a.r),ebqn_array:get(18,Rt#a.r),ebqn_array:get(22,Rt#a.r),ebqn_array:get(27,Rt#a.r),ebqn_array:get(48,Rt#a.r),ebqn_array:get(51,Rt#a.r),4,1],[[0,1,0,0]]]), %(4⥊1) ≡ +`⁼ 1+↕4
    {_,1} = ebqn:run(St0,[[3,0,0,2,0,3,0,1,7,7,16,0,0,3,0,17,25],[ebqn_array:get(18,Rt#a.r),ebqn_array:get(42,Rt#a.r),ebqn_array:get(48,Rt#a.r),ebqn_array:get(51,Rt#a.r)],[[0,1,0,0]]]), %⟨⟩ ≡ !`⁼⟨⟩
    {_,1} = ebqn:run(St0,[[0,15,0,6,16,0,0,0,14,17,0,8,0,9,0,2,7,7,16,0,3,16,0,4,0,13,17,0,10,0,11,0,0,7,7,0,5,0,7,0,12,0,1,8,19,16,25],[ebqn_array:get(0,Rt#a.r),ebqn_array:get(1,Rt#a.r),ebqn_array:get(2,Rt#a.r),ebqn_array:get(6,Rt#a.r),ebqn_array:get(8,Rt#a.r),ebqn_array:get(18,Rt#a.r),ebqn_array:get(27,Rt#a.r),ebqn_array:get(29,Rt#a.r),ebqn_array:get(44,Rt#a.r),ebqn_array:get(47,Rt#a.r),ebqn_array:get(48,Rt#a.r),ebqn_array:get(51,Rt#a.r),ebqn_array:get(55,Rt#a.r),2,3.141592653589793,5],[[0,1,0,0]]]), %(-⟜» ≡ +`⁼) 2|⌊×⌜˜π+↕5
    {_,1} = ebqn:run(St0,[[0,8,0,5,16,0,0,16,0,2,0,9,17,0,6,0,7,0,1,7,7,0,9,17,0,3,0,9,0,4,0,8,17,17,25],[ebqn_array:get(1,Rt#a.r),ebqn_array:get(3,Rt#a.r),ebqn_array:get(4,Rt#a.r),ebqn_array:get(18,Rt#a.r),ebqn_array:get(22,Rt#a.r),ebqn_array:get(27,Rt#a.r),ebqn_array:get(48,Rt#a.r),ebqn_array:get(51,Rt#a.r),5,2],[[0,1,0,0]]]), %(5⥊2)≡2÷`⁼2⋆-↕5
    {_,1} = ebqn:run(St0,[[0,13,0,4,16,0,3,0,12,0,11,3,2,17,0,7,0,8,0,0,7,7,0,11,0,4,16,17,0,2,0,11,0,5,0,3,7,16,0,6,0,1,7,0,9,0,10,0,10,3,3,17,17,25],[ebqn_array:get(0,Rt#a.r),ebqn_array:get(2,Rt#a.r),ebqn_array:get(18,Rt#a.r),ebqn_array:get(22,Rt#a.r),ebqn_array:get(27,Rt#a.r),ebqn_array:get(44,Rt#a.r),ebqn_array:get(47,Rt#a.r),ebqn_array:get(48,Rt#a.r),ebqn_array:get(51,Rt#a.r),0,1,4,3,12],[[0,1,0,0]]]), %(0‿1‿1×⌜⥊˜4)≡(↕4)+`⁼3‿4⥊↕12
    ok = try ebqn:run(St0,[[0,7,0,2,16,0,1,0,5,0,6,3,2,17,0,3,0,4,0,0,7,7,0,5,0,2,16,17,25],[ebqn_array:get(0,Rt#a.r),ebqn_array:get(22,Rt#a.r),ebqn_array:get(27,Rt#a.r),ebqn_array:get(48,Rt#a.r),ebqn_array:get(51,Rt#a.r),3,4,12],[[0,1,0,0]]]) % (↕3)+`⁼3‿4⥊↕12
        catch _ -> ok
    end,
    %
    % # Composition
    {_,0.75} = ebqn:run(St0,[[0,3,0,2,0,1,0,0,9,7,16,25],[ebqn_array:get(3,Rt#a.r),ebqn_array:get(9,Rt#a.r),ebqn_array:get(48,Rt#a.r),4],[[0,1,0,0]]]), % (÷¬)⁼ 4
    {_,4} = ebqn:run(St0,[[0,4,0,2,0,0,0,3,0,1,8,7,16,25],[ebqn_array:get(5,Rt#a.r),ebqn_array:get(21,Rt#a.r),ebqn_array:get(48,Rt#a.r),ebqn_array:get(52,Rt#a.r),2],[[0,1,0,0]]]), % ⊢∘√⁼ 2
    {_,1} = ebqn:run(St0,[[0,9,0,2,16,0,5,0,3,0,6,0,0,7,9,7,16,0,1,0,7,0,8,3,2,0,4,16,0,3,16,17,25],[ebqn_array:get(0,Rt#a.r),ebqn_array:get(18,Rt#a.r),ebqn_array:get(27,Rt#a.r),ebqn_array:get(30,Rt#a.r),ebqn_array:get(32,Rt#a.r),ebqn_array:get(48,Rt#a.r),ebqn_array:get(51,Rt#a.r),1,3,4],[[0,1,0,0]]]), %(⌽/1‿3)≡(·+`⌽)⁼↕4
    {_,1} = ebqn:run(St0,[[0,10,0,2,16,0,5,0,3,0,6,0,0,7,9,0,3,9,7,16,0,1,0,8,0,9,3,2,0,4,0,7,0,3,8,16,17,25],[ebqn_array:get(1,Rt#a.r),ebqn_array:get(18,Rt#a.r),ebqn_array:get(27,Rt#a.r),ebqn_array:get(30,Rt#a.r),ebqn_array:get(32,Rt#a.r),ebqn_array:get(48,Rt#a.r),ebqn_array:get(51,Rt#a.r),ebqn_array:get(54,Rt#a.r),1,3,4],[[0,1,0,0]]]), %(⌽⊸/1‿3)≡(⌽·-`⌽)⁼↕4
    {_,1} = ebqn:run(St0,[[0,13,0,2,0,10,0,11,3,2,17,0,6,0,4,0,3,0,9,19,7,16,0,1,0,12,0,5,0,0,7,0,7,0,8,3,2,17,17,25],[ebqn_array:get(0,Rt#a.r),ebqn_array:get(18,Rt#a.r),ebqn_array:get(22,Rt#a.r),ebqn_array:get(30,Rt#a.r),ebqn_array:get(31,Rt#a.r),ebqn_array:get(47,Rt#a.r),ebqn_array:get(48,Rt#a.r),-1,0,1,3,2,ebqn:str("BQN"),ebqn:str("PQMNAB")],[[0,1,0,0]]]), %(¯1‿0+⌜"BQN")≡(1⌽⍉)⁼3‿2⥊"PQMNAB"
    {_,-1.0} = ebqn:run(St0,[[0,7,0,4,0,3,0,0,0,6,19,0,2,9,0,1,0,5,19,7,16,25],[ebqn_array:get(0,Rt#a.r),ebqn_array:get(2,Rt#a.r),ebqn_array:get(5,Rt#a.r),ebqn_array:get(9,Rt#a.r),ebqn_array:get(48,Rt#a.r),3,2,6],[[0,1,0,0]]]), % (3×·√2+¬)⁼6
    {_,1.0} = ebqn:run(St0,[[0,7,0,2,0,6,0,4,0,0,8,0,1,0,3,0,5,8,9,7,16,25],[ebqn_array:get(0,Rt#a.r),ebqn_array:get(5,Rt#a.r),ebqn_array:get(48,Rt#a.r),ebqn_array:get(54,Rt#a.r),ebqn_array:get(55,Rt#a.r),3,7,2],[[0,1,0,0]]]), % (3⊸√+⟜7)⁼2
    {_,-1.0} = ebqn:run(St0,[[0,5,0,2,0,1,0,3,0,0,8,7,0,4,17,25],[ebqn_array:get(2,Rt#a.r),ebqn_array:get(9,Rt#a.r),ebqn_array:get(48,Rt#a.r),ebqn_array:get(55,Rt#a.r),5,10],[[0,1,0,0]]]), % 5×⟜¬⁼10
    {_,9} = ebqn:run(St0,[[0,4,0,2,15,1,0,3,7,0,0,0,1,19,7,16,25,21,0,1,25],[ebqn_array:get(1,Rt#a.r),ebqn_array:get(5,Rt#a.r),ebqn_array:get(48,Rt#a.r),2,1],[[0,1,0,0],[1,1,17,2]]]), % (√-2{𝔽})⁼1
    {_,9} = ebqn:run(St0,[[0,5,0,3,0,2,0,4,7,0,0,0,1,19,7,16,25],[ebqn_array:get(1,Rt#a.r),ebqn_array:get(5,Rt#a.r),ebqn_array:get(43,Rt#a.r),ebqn_array:get(48,Rt#a.r),2,1],[[0,1,0,0]]]), % (√-2˙)⁼1
    {_,3.0} = ebqn:run(St0,[[0,5,0,2,0,1,0,0,0,4,19,7,0,3,17,25],[ebqn_array:get(0,Rt#a.r),ebqn_array:get(3,Rt#a.r),ebqn_array:get(48,Rt#a.r),21,1,8],[[0,1,0,0]]]), % 21(1+÷)⁼8
    {_,1} = ebqn:run(St0,[[0,6,0,3,0,2,0,4,0,0,8,0,4,0,5,8,7,0,1,0,2,0,4,0,5,8,19,16,25],[ebqn_array:get(1,Rt#a.r),ebqn_array:get(18,Rt#a.r),ebqn_array:get(30,Rt#a.r),ebqn_array:get(48,Rt#a.r),ebqn_array:get(54,Rt#a.r),2,ebqn:str("abcde")],[[0,1,0,0]]]), %(2⊸⌽ ≡ 2⊸(-⊸⌽)⁼)"abcde"
    {_,4} = ebqn:run(St0,[[0,6,0,3,0,1,0,4,0,2,0,0,7,8,7,0,5,17,25],[ebqn_array:get(3,Rt#a.r),ebqn_array:get(9,Rt#a.r),ebqn_array:get(44,Rt#a.r),ebqn_array:get(48,Rt#a.r),ebqn_array:get(53,Rt#a.r),-2,-1],[[0,1,0,0]]]), % ¯2 ÷˜○¬⁼ ¯1
    {_,1} = ebqn:run(St0,[[0,11,0,6,0,6,0,2,7,0,7,0,5,0,1,7,8,7,0,10,17,0,0,0,9,17,0,3,16,0,4,0,8,17,25],[ebqn_array:get(1,Rt#a.r),ebqn_array:get(3,Rt#a.r),ebqn_array:get(4,Rt#a.r),ebqn_array:get(8,Rt#a.r),ebqn_array:get(13,Rt#a.r),ebqn_array:get(44,Rt#a.r),ebqn_array:get(48,Rt#a.r),ebqn_array:get(53,Rt#a.r),1.0E-12,16,2,4],[[0,1,0,0]]]), %1e¯12>|16- 2 ÷˜○(⋆⁼)⁼ 4
    {_,1} = ebqn:run(St0,[[0,7,0,2,16,0,3,0,6,0,4,0,5,0,0,7,7,8,0,1,0,4,0,3,0,6,0,5,0,0,7,8,7,19,16,25],[ebqn_array:get(0,Rt#a.r),ebqn_array:get(18,Rt#a.r),ebqn_array:get(27,Rt#a.r),ebqn_array:get(30,Rt#a.r),ebqn_array:get(48,Rt#a.r),ebqn_array:get(51,Rt#a.r),ebqn_array:get(56,Rt#a.r),4],[[0,1,0,0]]]), %(+`⌾⌽⁼≡+`⁼⌾⌽) ↕4
    {_,2.0} = ebqn:run(St0,[[0,5,0,2,0,4,0,3,0,1,0,0,7,8,7,16,25],[ebqn_array:get(2,Rt#a.r),ebqn_array:get(44,Rt#a.r),ebqn_array:get(48,Rt#a.r),ebqn_array:get(61,Rt#a.r),3,256],[[0,1,0,0]]]), % ×˜⍟3⁼256
    {_,1} = ebqn:run(St0,[[0,7,0,8,3,2,15,1,0,0,0,5,0,1,8,7,16,25,0,3,0,4,21,0,1,7,0,6,19,0,2,0,4,21,0,1,7,19,25],[ebqn_array:get(1,Rt#a.r),ebqn_array:get(5,Rt#a.r),ebqn_array:get(18,Rt#a.r),ebqn_array:get(21,Rt#a.r),ebqn_array:get(48,Rt#a.r),ebqn_array:get(57,Rt#a.r),6,-3,2],[[0,1,0,0],[1,1,18,2]]]), %√⊘-{𝕗⁼≡6𝕗⁼⊢} ¯3‿2
    {_,1} = ebqn:run(St0,[[0,4,0,3,0,1,3,3,0,5,0,9,0,10,0,11,3,3,0,8,15,1,8,7,16,0,7,0,0,7,16,25,21,0,1,0,6,0,6,21,0,2,7,7,0,2,21,0,2,19,16,25],[ebqn_array:get(10,Rt#a.r),ebqn_array:get(12,Rt#a.r),ebqn_array:get(18,Rt#a.r),ebqn_array:get(30,Rt#a.r),ebqn_array:get(32,Rt#a.r),ebqn_array:get(46,Rt#a.r),ebqn_array:get(48,Rt#a.r),ebqn_array:get(49,Rt#a.r),ebqn_array:get(55,Rt#a.r),2,4,1],[[0,1,0,0],[0,0,32,3]]]), %∧´ {(𝕎≡𝕎⁼⁼)𝕩}⟜2‿4‿1¨ /‿⌽‿<
    ok = try ebqn:run(St0,[[0,2,0,3,0,4,3,3,0,1,0,1,0,0,7,7,16,25],[ebqn_array:get(32,Rt#a.r),ebqn_array:get(48,Rt#a.r),2,3,0],[[0,1,0,0]]]) % /⁼⁼2‿3‿0
        catch _ -> ok
    end,
    ok = try ebqn:run(St0,[[0,4,0,5,0,6,3,3,0,1,0,3,0,2,0,0,8,7,16,25],[ebqn_array:get(32,Rt#a.r),ebqn_array:get(48,Rt#a.r),ebqn_array:get(61,Rt#a.r),-1,2,3,0],[[0,1,0,0]]]) % /⍟¯1⁼2‿3‿0
        catch _ -> ok
    end,
    ok.

identity(St0,Rt) ->
    % # Fold
    {_,1} = ebqn:run(St0,[[0,0,0,9,3,2,0,1,0,9,3,2,0,2,0,10,3,2,0,3,0,10,3,2,0,5,0,9,3,2,0,4,0,10,3,2,3,6,0,7,0,8,15,1,7,7,16,0,8,0,4,7,16,25,3,0,0,8,21,0,2,7,16,0,6,21,0,1,17,25],[ebqn_array:get(0,Rt#a.r),ebqn_array:get(1,Rt#a.r),ebqn_array:get(2,Rt#a.r),ebqn_array:get(3,Rt#a.r),ebqn_array:get(10,Rt#a.r),ebqn_array:get(11,Rt#a.r),ebqn_array:get(18,Rt#a.r),ebqn_array:get(46,Rt#a.r),ebqn_array:get(49,Rt#a.r),0,1],[[0,1,0,0],[0,0,54,3]]]), %∧´ {𝕩≡𝕎´⟨⟩}´¨ ⟨+‿0,-‿0,×‿1,÷‿1,∨‿0,∧‿1⟩
    {_,1} = ebqn:run(St0,[[0,0,0,8,3,2,0,3,0,8,3,2,0,1,0,9,3,2,0,2,0,10,3,2,3,4,0,6,0,7,15,1,7,7,16,0,7,0,4,7,16,25,3,0,0,7,21,0,2,7,16,0,5,21,0,1,17,25],[ebqn_array:get(4,Rt#a.r),ebqn_array:get(6,Rt#a.r),ebqn_array:get(7,Rt#a.r),ebqn_array:get(9,Rt#a.r),ebqn_array:get(10,Rt#a.r),ebqn_array:get(18,Rt#a.r),ebqn_array:get(46,Rt#a.r),ebqn_array:get(49,Rt#a.r),1,inf,ninf],[[0,1,0,0],[0,0,42,3]]]), %∧´ {𝕩≡𝕎´⟨⟩}´¨ ⟨⋆‿1,¬‿1,⌊‿∞,⌈‿¯∞⟩
    {_,1} = ebqn:run(St0,[[0,2,0,8,3,2,0,3,0,9,3,2,0,1,0,8,3,2,0,4,0,9,3,2,3,4,0,6,0,7,15,1,7,7,16,0,7,0,0,7,16,25,3,0,0,7,21,0,2,7,16,0,5,21,0,1,17,25],[ebqn_array:get(10,Rt#a.r),ebqn_array:get(13,Rt#a.r),ebqn_array:get(14,Rt#a.r),ebqn_array:get(15,Rt#a.r),ebqn_array:get(17,Rt#a.r),ebqn_array:get(18,Rt#a.r),ebqn_array:get(46,Rt#a.r),ebqn_array:get(49,Rt#a.r),0,1],[[0,1,0,0],[0,0,42,3]]]), %∧´ {𝕩≡𝕎´⟨⟩}´¨ ⟨≠‿0,=‿1,>‿0,≥‿1⟩
    ok = try ebqn:run(St0,[[0,3,0,1,16,0,2,0,0,7,16,25],[ebqn_array:get(5,Rt#a.r),ebqn_array:get(27,Rt#a.r),ebqn_array:get(49,Rt#a.r),0],[[0,1,0,0]]]) % √´↕0
        catch _ -> ok
    end,
    ok = try ebqn:run(St0,[[0,3,0,1,16,0,2,0,0,7,16,25],[ebqn_array:get(8,Rt#a.r),ebqn_array:get(27,Rt#a.r),ebqn_array:get(49,Rt#a.r),0],[[0,1,0,0]]]) % |´↕0
        catch _ -> ok
    end,
    ok = try ebqn:run(St0,[[0,2,0,1,0,0,7,16,25],[ebqn_array:get(21,Rt#a.r),ebqn_array:get(49,Rt#a.r),ebqn:str("")],[[0,1,0,0]]]) % ⊢´""
        catch _ -> ok
    end,
    ok = try ebqn:run(St0,[[0,2,0,1,0,0,7,16,25],[ebqn_array:get(20,Rt#a.r),ebqn_array:get(49,Rt#a.r),ebqn:str("")],[[0,1,0,0]]]) % ⊣´""
        catch _ -> ok
    end,
    ok = try ebqn:run(St0,[[3,0,0,1,0,0,7,16,25],[ebqn_array:get(23,Rt#a.r),ebqn_array:get(49,Rt#a.r)],[[0,1,0,0]]]) % ∾´⟨⟩
        catch _ -> ok
    end,
    ok = try ebqn:run(St0,[[3,0,0,1,0,0,7,16,25],[ebqn_array:get(24,Rt#a.r),ebqn_array:get(49,Rt#a.r)],[[0,1,0,0]]]) % ≍´⟨⟩
        catch _ -> ok
    end,
    %
    % # Insert
    {_,1} = ebqn:run(St0,[[0,0,0,21,3,2,0,1,0,21,3,2,0,2,0,20,3,2,0,3,0,20,3,2,0,9,0,21,3,2,0,8,0,20,3,2,0,4,0,20,3,2,0,7,0,20,3,2,0,5,0,22,3,2,0,6,0,23,3,2,0,11,0,21,3,2,0,12,0,20,3,2,0,10,0,21,3,2,0,13,0,20,3,2,3,14,0,16,0,17,15,1,7,7,16,0,17,0,8,7,16,25,0,24,0,15,0,21,0,19,0,20,3,3,17,0,18,21,0,2,7,16,0,14,21,0,1,0,15,0,19,0,20,3,2,17,17,25],[ebqn_array:get(0,Rt#a.r),ebqn_array:get(1,Rt#a.r),ebqn_array:get(2,Rt#a.r),ebqn_array:get(3,Rt#a.r),ebqn_array:get(4,Rt#a.r),ebqn_array:get(6,Rt#a.r),ebqn_array:get(7,Rt#a.r),ebqn_array:get(9,Rt#a.r),ebqn_array:get(10,Rt#a.r),ebqn_array:get(11,Rt#a.r),ebqn_array:get(13,Rt#a.r),ebqn_array:get(14,Rt#a.r),ebqn_array:get(15,Rt#a.r),ebqn_array:get(17,Rt#a.r),ebqn_array:get(18,Rt#a.r),ebqn_array:get(22,Rt#a.r),ebqn_array:get(46,Rt#a.r),ebqn_array:get(49,Rt#a.r),ebqn_array:get(50,Rt#a.r),3,1,0,inf,ninf,ebqn:str("")],[[0,1,0,0],[0,0,102,3]]]), %∧´ {(3‿1⥊𝕩)≡𝕎˝0‿3‿1⥊""}´¨ ⟨+‿0,-‿0,×‿1,÷‿1,∨‿0,∧‿1,⋆‿1,¬‿1,⌊‿∞,⌈‿¯∞,≠‿0,=‿1,>‿0,≥‿1⟩
    ok = try ebqn:run(St0,[[0,2,0,1,0,0,7,16,25],[ebqn_array:get(23,Rt#a.r),ebqn_array:get(50,Rt#a.r),ebqn:str("")],[[0,1,0,0]]]) % ∾˝""
        catch _ -> ok
    end,
    {_,1} = ebqn:run(St0,[[0,11,0,2,0,9,0,4,16,0,5,0,7,0,10,0,8,0,0,8,8,16,17,0,1,0,11,0,2,0,9,0,4,16,17,0,6,0,3,7,16,17,25],[ebqn_array:get(14,Rt#a.r),ebqn_array:get(18,Rt#a.r),ebqn_array:get(22,Rt#a.r),ebqn_array:get(23,Rt#a.r),ebqn_array:get(27,Rt#a.r),ebqn_array:get(32,Rt#a.r),ebqn_array:get(50,Rt#a.r),ebqn_array:get(54,Rt#a.r),ebqn_array:get(55,Rt#a.r),5,1,ebqn:str("")],[[0,1,0,0]]]), %(∾˝(↕5)⥊"") ≡ (≠⟜1⊸/↕5)⥊""
    {_,1} = ebqn:run(St0,[[0,9,0,10,0,11,3,3,0,5,0,7,0,4,0,9,7,0,1,0,3,19,7,7,16,0,6,0,1,7,0,0,0,6,0,8,0,2,7,7,19,16,25],[ebqn_array:get(18,Rt#a.r),ebqn_array:get(22,Rt#a.r),ebqn_array:get(23,Rt#a.r),ebqn_array:get(24,Rt#a.r),ebqn_array:get(43,Rt#a.r),ebqn_array:get(44,Rt#a.r),ebqn_array:get(46,Rt#a.r),ebqn_array:get(47,Rt#a.r),ebqn_array:get(50,Rt#a.r),0,2,5],[[0,1,0,0]]]), %(∾˝¨≡⥊¨) (≍⥊0˙)⌜˜0‿2‿5
    ok = try ebqn:run(St0,[[3,0,0,0,0,3,0,4,3,2,17,0,2,0,1,7,16,25],[ebqn_array:get(22,Rt#a.r),ebqn_array:get(30,Rt#a.r),ebqn_array:get(50,Rt#a.r),0,3],[[0,1,0,0]]]) % ⌽˝0‿3⥊⟨⟩
        catch _ -> ok
    end,
    ok.

under(St0,Rt) ->
    % # Invertible
    {_,1} = ebqn:run(St0,[[0,6,0,3,16,0,7,0,8,0,0,16,3,3,0,2,0,5,0,4,8,0,1,0,4,19,16,25],[ebqn_array:get(12,Rt#a.r),ebqn_array:get(18,Rt#a.r),ebqn_array:get(21,Rt#a.r),ebqn_array:get(27,Rt#a.r),ebqn_array:get(36,Rt#a.r),ebqn_array:get(56,Rt#a.r),3,2,ebqn:str("abc")],[[0,1,0,0]]]), %(⊑≡⊑⌾⊢) ⟨↕3,2,<"abc"⟩
    {_,1} = ebqn:run(St0,[[0,5,0,2,0,3,0,0,8,0,1,0,0,19,0,4,17,25],[ebqn_array:get(0,Rt#a.r),ebqn_array:get(18,Rt#a.r),ebqn_array:get(20,Rt#a.r),ebqn_array:get(56,Rt#a.r),3,4],[[0,1,0,0]]]), %3 (+≡+⌾⊣) 4
    {_,1} = ebqn:run(St0,[[0,8,0,2,16,0,3,0,5,0,1,0,4,0,7,8,8,0,0,0,1,0,4,0,6,8,19,16,25],[ebqn_array:get(18,Rt#a.r),ebqn_array:get(26,Rt#a.r),ebqn_array:get(27,Rt#a.r),ebqn_array:get(30,Rt#a.r),ebqn_array:get(54,Rt#a.r),ebqn_array:get(56,Rt#a.r),-2,2,6],[[0,1,0,0]]]), %(¯2⊸↓ ≡ 2⊸↓⌾⌽) ↕6
    {_,1} = ebqn:run(St0,[[0,8,0,8,3,2,0,2,16,0,4,0,1,0,5,0,7,8,7,0,0,0,3,0,6,0,1,0,5,0,7,8,8,19,16,25],[ebqn_array:get(18,Rt#a.r),ebqn_array:get(26,Rt#a.r),ebqn_array:get(27,Rt#a.r),ebqn_array:get(31,Rt#a.r),ebqn_array:get(45,Rt#a.r),ebqn_array:get(54,Rt#a.r),ebqn_array:get(56,Rt#a.r),1,3],[[0,1,0,0]]]), %(1⊸↓⌾⍉ ≡ 1⊸↓˘) ↕3‿3
    {_,1} = ebqn:run(St0,[[0,10,0,3,16,0,2,0,9,0,9,3,2,17,0,4,0,0,7,0,6,0,2,8,0,5,0,4,0,0,7,7,9,0,1,0,4,0,0,7,0,7,0,2,8,19,0,8,17,25],[ebqn_array:get(12,Rt#a.r),ebqn_array:get(18,Rt#a.r),ebqn_array:get(22,Rt#a.r),ebqn_array:get(27,Rt#a.r),ebqn_array:get(45,Rt#a.r),ebqn_array:get(48,Rt#a.r),ebqn_array:get(55,Rt#a.r),ebqn_array:get(56,Rt#a.r),7,3,9],[[0,1,0,0]]]), %7(⥊⌾(<˘)≡·<˘⁼⥊⟜(<˘))3‿3⥊↕9
    {_,1} = ebqn:run(St0,[[0,6,0,3,16,0,2,0,5,0,4,8,0,0,0,1,19,0,7,17,25],[ebqn_array:get(18,Rt#a.r),ebqn_array:get(20,Rt#a.r),ebqn_array:get(24,Rt#a.r),ebqn_array:get(27,Rt#a.r),ebqn_array:get(29,Rt#a.r),ebqn_array:get(56,Rt#a.r),4,ebqn:str("abcd")],[[0,1,0,0]]]), %"abcd" (⊣≡»⌾≍) ↕4
    ok = try ebqn:run(St0,[[0,3,0,0,0,2,0,1,8,16,25],[ebqn_array:get(24,Rt#a.r),ebqn_array:get(31,Rt#a.r),ebqn_array:get(56,Rt#a.r),ebqn:str("abc")],[[0,1,0,0]]]) % ⍉⌾≍ "abc"
        catch _ -> ok
    end,
    {_,1} = ebqn:run(St0,[[0,13,0,4,16,0,5,0,8,0,12,8,0,9,0,0,0,8,0,2,0,7,0,4,8,8,8,16,0,3,0,10,0,11,3,2,0,6,0,8,0,1,0,7,0,5,8,8,16,17,25],[ebqn_array:get(1,Rt#a.r),ebqn_array:get(8,Rt#a.r),ebqn_array:get(14,Rt#a.r),ebqn_array:get(18,Rt#a.r),ebqn_array:get(27,Rt#a.r),ebqn_array:get(30,Rt#a.r),ebqn_array:get(32,Rt#a.r),ebqn_array:get(52,Rt#a.r),ebqn_array:get(54,Rt#a.r),ebqn_array:get(56,Rt#a.r),4,-3,3,7],[[0,1,0,0]]]), %(⌽∘|⊸/4‿¯3) ≡ ↕∘≠⊸-⌾(3⊸⌽)↕7
    %
    % # Structural
    % # Monad
    {_,1} = ebqn:run(St0,[[0,7,0,2,0,4,0,0,0,3,0,5,8,8,16,0,1,0,6,17,25],[ebqn_array:get(0,Rt#a.r),ebqn_array:get(18,Rt#a.r),ebqn_array:get(36,Rt#a.r),ebqn_array:get(54,Rt#a.r),ebqn_array:get(56,Rt#a.r),1,ebqn:str("bbcd"),ebqn:str("abcd")],[[0,1,0,0]]]), %"bbcd" ≡ 1⊸+⌾⊑ "abcd"
    {_,1} = ebqn:run(St0,[[0,6,0,3,0,5,0,0,8,0,2,0,0,0,4,0,1,8,19,16,25],[ebqn_array:get(1,Rt#a.r),ebqn_array:get(12,Rt#a.r),ebqn_array:get(18,Rt#a.r),ebqn_array:get(36,Rt#a.r),ebqn_array:get(52,Rt#a.r),ebqn_array:get(56,Rt#a.r),4],[[0,1,0,0]]]), %(<∘- ≡ -⌾⊑) 4
    {_,1} = ebqn:run(St0,[[0,8,0,1,0,7,17,0,4,0,1,0,5,0,2,8,7,0,0,0,3,0,6,0,2,8,19,16,25],[ebqn_array:get(18,Rt#a.r),ebqn_array:get(24,Rt#a.r),ebqn_array:get(30,Rt#a.r),ebqn_array:get(35,Rt#a.r),ebqn_array:get(50,Rt#a.r),ebqn_array:get(54,Rt#a.r),ebqn_array:get(56,Rt#a.r),ebqn:str("abc"),ebqn:str("def")],[[0,1,0,0]]]), %(⌽⌾⊏ ≡ ⌽⊸≍˝) "abc"≍"def"
    ok = try ebqn:run(St0,[[0,3,0,1,0,2,0,0,8,16,25],[ebqn_array:get(1,Rt#a.r),ebqn_array:get(35,Rt#a.r),ebqn_array:get(56,Rt#a.r),4],[[0,1,0,0]]]) % -⌾⊏ 4
        catch _ -> ok
    end,
    {_,1} = ebqn:run(St0,[[0,7,0,0,0,4,0,2,0,3,0,6,0,7,3,2,8,8,16,0,1,0,5,17,25],[ebqn_array:get(12,Rt#a.r),ebqn_array:get(18,Rt#a.r),ebqn_array:get(37,Rt#a.r),ebqn_array:get(54,Rt#a.r),ebqn_array:get(56,Rt#a.r),1,ebqn:str("cd"),ebqn:str("ab")],[[0,1,0,0]]]), %1 ≡ "cd"‿"ab"⊸⊐⌾< "ab"
    {_,1} = ebqn:run(St0,[[0,13,0,3,0,12,17,0,2,0,7,0,4,0,6,0,4,8,8,16,0,1,0,8,0,10,0,11,3,3,0,5,0,0,7,0,8,0,9,3,2,17,17,25],[ebqn_array:get(0,Rt#a.r),ebqn_array:get(18,Rt#a.r),ebqn_array:get(22,Rt#a.r),ebqn_array:get(24,Rt#a.r),ebqn_array:get(33,Rt#a.r),ebqn_array:get(47,Rt#a.r),ebqn_array:get(52,Rt#a.r),ebqn_array:get(56,Rt#a.r),0,1,4,2,ebqn:str("apl"),ebqn:str("bqn")],[[0,1,0,0]]]), %(0‿1+⌜0‿4‿2) ≡ ⍋∘⍋⌾⥊ "apl"≍"bqn"
    {_,1} = ebqn:run(St0,[[0,12,0,10,3,2,0,7,0,1,7,0,5,9,0,8,0,4,8,16,0,0,0,2,0,11,19,0,3,0,4,0,9,0,6,8,19,0,10,17,25],[ebqn_array:get(0,Rt#a.r),ebqn_array:get(2,Rt#a.r),ebqn_array:get(8,Rt#a.r),ebqn_array:get(18,Rt#a.r),ebqn_array:get(22,Rt#a.r),ebqn_array:get(27,Rt#a.r),ebqn_array:get(30,Rt#a.r),ebqn_array:get(49,Rt#a.r),ebqn_array:get(55,Rt#a.r),ebqn_array:get(56,Rt#a.r),2,12,6],[[0,1,0,0]]]), %2 (⌽⌾⥊ ≡ 12|+) ⥊⟜(↕×´)6‿2
    {_,1} = ebqn:run(St0,[[0,9,15,1,0,0,0,7,0,1,0,6,0,4,8,8,7,16,25,0,3,0,8,0,5,21,0,1,7,8,0,2,21,0,1,19,25],[ebqn_array:get(0,Rt#a.r),ebqn_array:get(14,Rt#a.r),ebqn_array:get(18,Rt#a.r),ebqn_array:get(25,Rt#a.r),ebqn_array:get(27,Rt#a.r),ebqn_array:get(46,Rt#a.r),ebqn_array:get(52,Rt#a.r),ebqn_array:get(54,Rt#a.r),ebqn_array:get(56,Rt#a.r),ebqn:str("abcde")],[[0,1,0,0],[1,1,19,2]]]), %↕∘≠⊸+{𝔽≡𝔽¨⌾↑} "abcde"
    {_,1} = ebqn:run(St0,[[0,7,15,1,0,0,0,4,0,6,8,7,16,25,0,2,0,5,0,3,21,0,1,7,8,0,1,21,0,1,19,25],[ebqn_array:get(0,Rt#a.r),ebqn_array:get(18,Rt#a.r),ebqn_array:get(26,Rt#a.r),ebqn_array:get(46,Rt#a.r),ebqn_array:get(54,Rt#a.r),ebqn_array:get(56,Rt#a.r),2,ebqn:str("abcde")],[[0,1,0,0],[1,1,14,2]]]), %2⊸+{𝔽≡𝔽¨⌾↓} "abcde"
    % # Dyad
    ok = try ebqn:run(St0,[[0,8,0,3,16,0,2,0,5,0,7,8,0,6,0,0,0,5,0,1,0,4,0,3,8,8,8,16,25],[ebqn_array:get(0,Rt#a.r),ebqn_array:get(14,Rt#a.r),ebqn_array:get(22,Rt#a.r),ebqn_array:get(27,Rt#a.r),ebqn_array:get(52,Rt#a.r),ebqn_array:get(54,Rt#a.r),ebqn_array:get(56,Rt#a.r),10,6],[[0,1,0,0]]]) % ↕∘≠⊸+⌾(10⊸⥊)↕6
        catch _ -> ok
    end,
    {_,1} = ebqn:run(St0,[[0,12,0,5,16,0,3,0,4,0,1,0,11,3,2,19,0,10,0,9,0,6,7,8,16,0,2,0,12,0,5,16,0,8,0,0,7,0,11,17,0,1,16,0,7,16,0,6,16,17,25],[ebqn_array:get(3,Rt#a.r),ebqn_array:get(6,Rt#a.r),ebqn_array:get(18,Rt#a.r),ebqn_array:get(21,Rt#a.r),ebqn_array:get(22,Rt#a.r),ebqn_array:get(27,Rt#a.r),ebqn_array:get(30,Rt#a.r),ebqn_array:get(34,Rt#a.r),ebqn_array:get(44,Rt#a.r),ebqn_array:get(45,Rt#a.r),ebqn_array:get(56,Rt#a.r),2,7],[[0,1,0,0]]]), %(⌽⍒⌊2÷˜↕7) ≡ ⌽˘⌾(⌊‿2⥊⊢)↕7
    {_,1} = ebqn:run(St0,[[0,15,0,6,16,0,5,0,8,0,14,8,0,10,0,3,0,2,0,7,0,0,7,19,0,9,0,1,8,8,16,0,4,0,11,0,12,0,13,0,14,3,4,17,25],[ebqn_array:get(0,Rt#a.r),ebqn_array:get(1,Rt#a.r),ebqn_array:get(3,Rt#a.r),ebqn_array:get(14,Rt#a.r),ebqn_array:get(18,Rt#a.r),ebqn_array:get(25,Rt#a.r),ebqn_array:get(27,Rt#a.r),ebqn_array:get(49,Rt#a.r),ebqn_array:get(54,Rt#a.r),ebqn_array:get(55,Rt#a.r),ebqn_array:get(56,Rt#a.r),-1,0,1,3,4],[[0,1,0,0]]]), %¯1‿0‿1‿3 ≡ -⟜(+´÷≠)⌾(3⊸↑)↕4
    {_,1} = ebqn:run(St0,[[0,7,0,1,0,3,0,5,8,0,4,0,2,8,16,0,0,0,6,17,25],[ebqn_array:get(18,Rt#a.r),ebqn_array:get(26,Rt#a.r),ebqn_array:get(30,Rt#a.r),ebqn_array:get(54,Rt#a.r),ebqn_array:get(56,Rt#a.r),1,ebqn:str("adcb"),ebqn:str("abcd")],[[0,1,0,0]]]), %"adcb" ≡ ⌽⌾(1⊸↓)"abcd"
    {_,1} = ebqn:run(St0,[[0,13,0,4,16,0,0,0,15,17,0,15,0,17,3,2,0,10,0,1,0,7,0,6,0,0,7,8,8,0,14,0,3,0,16,0,13,3,2,17,0,5,0,8,0,14,0,14,3,2,8,0,9,0,11,0,13,0,15,3,3,8,16,17,0,2,0,11,0,12,0,13,0,14,3,4,17,25],[ebqn_array:get(0,Rt#a.r),ebqn_array:get(2,Rt#a.r),ebqn_array:get(18,Rt#a.r),ebqn_array:get(22,Rt#a.r),ebqn_array:get(27,Rt#a.r),ebqn_array:get(31,Rt#a.r),ebqn_array:get(49,Rt#a.r),ebqn_array:get(52,Rt#a.r),ebqn_array:get(54,Rt#a.r),ebqn_array:get(56,Rt#a.r),ebqn_array:get(59,Rt#a.r),5,6,3,0,1,4,inf],[[0,1,0,0]]]), %5‿6‿3‿0 ≡ (5‿3‿1⌾(0‿0⊸⍉)4‿3⥊0) +´∘×⎉1‿∞ 1+↕3
    {_,1} = ebqn:run(St0,[[0,11,0,3,0,4,0,6,0,7,0,7,0,6,3,4,8,0,5,0,0,0,4,0,9,0,1,0,8,17,8,8,16,0,2,0,10,17,25],[ebqn_array:get(0,Rt#a.r),ebqn_array:get(1,Rt#a.r),ebqn_array:get(18,Rt#a.r),ebqn_array:get(32,Rt#a.r),ebqn_array:get(54,Rt#a.r),ebqn_array:get(56,Rt#a.r),1,0,ebqn:char("A"),ebqn:char("a"),ebqn:str("AbcD"),ebqn:str("abcd")],[[0,1,0,0]]]), %"AbcD" ≡ ('A'-'a')⊸+⌾(1‿0‿0‿1⊸/)"abcd"
    {_,1} = ebqn:run(St0,[[0,9,0,2,0,3,0,5,0,6,0,6,0,5,3,4,8,0,4,0,1,8,0,8,17,0,0,0,7,17,25],[ebqn_array:get(18,Rt#a.r),ebqn_array:get(20,Rt#a.r),ebqn_array:get(32,Rt#a.r),ebqn_array:get(54,Rt#a.r),ebqn_array:get(56,Rt#a.r),1,0,ebqn:str("AbcD"),ebqn:str("ABCD"),ebqn:str("abcd")],[[0,1,0,0]]]), %"AbcD" ≡ "ABCD"⊣⌾(1‿0‿0‿1⊸/)"abcd"
    ok = try ebqn:run(St0,[[0,8,0,2,16,0,3,0,5,0,7,8,0,6,0,0,0,5,0,1,0,4,0,2,8,8,8,16,25],[ebqn_array:get(0,Rt#a.r),ebqn_array:get(14,Rt#a.r),ebqn_array:get(27,Rt#a.r),ebqn_array:get(32,Rt#a.r),ebqn_array:get(52,Rt#a.r),ebqn_array:get(54,Rt#a.r),ebqn_array:get(56,Rt#a.r),2,5],[[0,1,0,0]]]) % ↕∘≠⊸+⌾(2⊸/)↕5
        catch _ -> ok
    end,
    {_,1} = ebqn:run(St0,[[0,8,0,1,16,0,3,0,4,0,7,8,0,5,0,2,0,4,0,7,8,8,0,0,0,2,0,4,0,6,8,19,16,25],[ebqn_array:get(18,Rt#a.r),ebqn_array:get(27,Rt#a.r),ebqn_array:get(30,Rt#a.r),ebqn_array:get(32,Rt#a.r),ebqn_array:get(54,Rt#a.r),ebqn_array:get(56,Rt#a.r),1,2,5],[[0,1,0,0]]]), %(1⊸⌽ ≡ 2⊸⌽⌾(2⊸/)) ↕5
    {_,1} = ebqn:run(St0,[[0,9,0,2,0,3,0,5,0,6,0,7,3,3,8,0,4,0,1,0,3,0,5,8,8,16,0,0,0,8,17,25],[ebqn_array:get(18,Rt#a.r),ebqn_array:get(30,Rt#a.r),ebqn_array:get(35,Rt#a.r),ebqn_array:get(54,Rt#a.r),ebqn_array:get(56,Rt#a.r),1,3,0,ebqn:str("bdca"),ebqn:str("abcd")],[[0,1,0,0]]]), %"bdca" ≡ 1⊸⌽⌾(1‿3‿0⊸⊏)"abcd"
    ok = try ebqn:run(St0,[[0,7,0,1,0,2,0,4,0,5,0,5,0,6,3,4,8,0,3,0,0,0,2,0,4,8,8,16,25],[ebqn_array:get(30,Rt#a.r),ebqn_array:get(35,Rt#a.r),ebqn_array:get(54,Rt#a.r),ebqn_array:get(56,Rt#a.r),1,3,0,ebqn:str("abcd")],[[0,1,0,0]]]) % 1⊸⌽⌾(1‿3‿3‿0⊸⊏)"abcd"
        catch _ -> ok
    end,
    {_,1} = ebqn:run(St0,[[0,15,0,17,3,2,0,7,16,0,6,0,9,0,18,0,15,3,2,19,0,13,0,0,8,0,5,0,1,0,12,0,17,0,7,0,4,0,16,19,0,8,9,0,11,0,10,0,3,7,8,0,15,17,0,2,0,14,17,8,19,16,25],[ebqn_array:get(1,Rt#a.r),ebqn_array:get(2,Rt#a.r),ebqn_array:get(4,Rt#a.r),ebqn_array:get(10,Rt#a.r),ebqn_array:get(15,Rt#a.r),ebqn_array:get(18,Rt#a.r),ebqn_array:get(21,Rt#a.r),ebqn_array:get(27,Rt#a.r),ebqn_array:get(30,Rt#a.r),ebqn_array:get(36,Rt#a.r),ebqn_array:get(47,Rt#a.r),ebqn_array:get(53,Rt#a.r),ebqn_array:get(54,Rt#a.r),ebqn_array:get(56,Rt#a.r),-1,2,0,3,1],[[0,1,0,0]]]), %((¯1⋆2∧⌜○(⌽0=↕)3)⊸× ≡ -⌾(1‿2⊑⊢))↕2‿3
    {_,1} = ebqn:run(St0,[[0,10,0,10,3,2,0,3,16,0,4,0,5,0,9,0,7,3,2,0,9,0,9,3,2,0,7,0,9,3,2,3,2,3,2,8,0,6,0,0,0,5,0,9,0,10,0,8,3,2,3,2,8,8,0,1,0,0,0,5,0,9,0,10,3,2,0,2,0,7,0,8,3,2,17,8,19,16,25],[ebqn_array:get(0,Rt#a.r),ebqn_array:get(18,Rt#a.r),ebqn_array:get(24,Rt#a.r),ebqn_array:get(27,Rt#a.r),ebqn_array:get(36,Rt#a.r),ebqn_array:get(54,Rt#a.r),ebqn_array:get(56,Rt#a.r),0,3,1,2],[[0,1,0,0]]]), %((0‿3≍1‿2)⊸+ ≡ ⟨1,2‿3⟩⊸+⌾(⟨1‿0,⟨1‿1,0‿1⟩⟩⊸⊑))↕2‿2
    % # Compound
    {_,1} = ebqn:run(St0,[[0,11,0,5,16,0,1,0,6,9,0,3,0,12,19,0,8,0,4,0,7,0,9,8,8,16,0,2,0,10,0,5,16,0,0,0,9,17,17,25],[ebqn_array:get(0,Rt#a.r),ebqn_array:get(12,Rt#a.r),ebqn_array:get(18,Rt#a.r),ebqn_array:get(21,Rt#a.r),ebqn_array:get(26,Rt#a.r),ebqn_array:get(27,Rt#a.r),ebqn_array:get(36,Rt#a.r),ebqn_array:get(54,Rt#a.r),ebqn_array:get(56,Rt#a.r),1,3,4,ebqn:char("\0")],[[0,1,0,0]]]), %(1+↕3) ≡ 1⊸↓⌾(@⊢·⊑<)↕4
    {_,1} = ebqn:run(St0,[[0,10,0,3,0,6,0,1,0,5,0,0,7,0,8,19,8,0,7,0,4,8,16,0,2,0,9,17,25],[ebqn_array:get(3,Rt#a.r),ebqn_array:get(14,Rt#a.r),ebqn_array:get(18,Rt#a.r),ebqn_array:get(25,Rt#a.r),ebqn_array:get(30,Rt#a.r),ebqn_array:get(44,Rt#a.r),ebqn_array:get(54,Rt#a.r),ebqn_array:get(56,Rt#a.r),2,ebqn:str("210abc"),ebqn:str("012abc")],[[0,1,0,0]]]), %"210abc" ≡ ⌽⌾((2÷˜≠)⊸↑)"012abc"
    {_,1} = ebqn:run(St0,[[0,8,0,6,3,2,0,3,0,1,0,5,19,0,4,0,2,8,16,0,0,0,7,0,6,3,2,17,25],[ebqn_array:get(18,Rt#a.r),ebqn_array:get(25,Rt#a.r),ebqn_array:get(30,Rt#a.r),ebqn_array:get(36,Rt#a.r),ebqn_array:get(56,Rt#a.r),2,ebqn:char("d"),ebqn:str("bac"),ebqn:str("abc")],[[0,1,0,0]]]), %"bac"‿'d' ≡ ⌽⌾(2↑⊑)"abc"‿'d'
    {_,1} = ebqn:run(St0,[[0,9,0,3,0,5,0,7,0,8,3,2,8,0,6,0,2,8,0,1,0,3,0,5,0,7,0,8,3,2,8,0,0,9,0,6,0,4,0,2,7,8,19,16,25],[ebqn_array:get(12,Rt#a.r),ebqn_array:get(18,Rt#a.r),ebqn_array:get(30,Rt#a.r),ebqn_array:get(35,Rt#a.r),ebqn_array:get(46,Rt#a.r),ebqn_array:get(54,Rt#a.r),ebqn_array:get(56,Rt#a.r),2,3,ebqn:str("abcdef")],[[0,1,0,0]]]), %(⌽¨⌾(<2‿3⊸⊏) ≡ ⌽⌾(2‿3⊸⊏)) "abcdef"
    %
    % # Computational
    {_,3} = ebqn:run(St0,[[0,5,0,1,0,3,0,0,0,2,0,4,8,8,16,25],[ebqn_array:get(0,Rt#a.r),ebqn_array:get(1,Rt#a.r),ebqn_array:get(54,Rt#a.r),ebqn_array:get(56,Rt#a.r),1,4],[[0,1,0,0]]]), % 1⊸+⌾-4
    {_,2} = ebqn:run(St0,[[0,3,0,2,0,1,0,0,8,16,25],[ebqn_array:get(21,Rt#a.r),ebqn_array:get(56,Rt#a.r),2,3],[[0,1,0,0]]]), % ⊢⌾2 3
    {_,-2} = ebqn:run(St0,[[0,5,0,0,0,2,0,4,8,0,3,0,1,8,16,25],[ebqn_array:get(1,Rt#a.r),ebqn_array:get(21,Rt#a.r),ebqn_array:get(52,Rt#a.r),ebqn_array:get(56,Rt#a.r),2,3],[[0,1,0,0]]]), % ⊢⌾(2∘-) 3
    {_,1} = ebqn:run(St0,[[0,5,0,3,0,0,3,2,0,4,0,2,8,16,0,1,0,3,0,0,3,2,17,25],[ebqn_array:get(0,Rt#a.r),ebqn_array:get(18,Rt#a.r),ebqn_array:get(21,Rt#a.r),ebqn_array:get(52,Rt#a.r),ebqn_array:get(56,Rt#a.r),1],[[0,1,0,0]]]), %∘‿+ ≡ ⊢⌾∘‿+ 1
    ok.
