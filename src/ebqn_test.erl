-module(ebqn_test).

-include("schema.hrl").

-import(ebqn,[run/2,char/1,str/1]).
-export([test/0,bc/0,layer0/1,layer1/1,layer2/1,layer3/1,layer4/1,layer5/1]).

test() ->
    ok.

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

% ebqn:run(ebqn:call(ebqn:run(ebqn_bc:ebqn_array:get()),ebqn_core:fns(),undefined)).
% # LAYER 0
layer0(#a{r=Runtime}) ->
    1 = ebqn:run([[0,4,0,0,0,3,17,0,1,0,2,17,25],[ebqn_array:get(0,Runtime),ebqn_array:get(18,Runtime),0,-2,2],[[0,1,0,0]]]), %0≡¯2+2
    1 = ebqn:run([[0,3,0,0,0,3,17,0,1,0,2,17,25],[ebqn_array:get(0,Runtime),ebqn_array:get(18,Runtime),10000,5000],[[0,1,0,0]]]), %1e4≡5e3+5e3
    1 = ebqn:run([[0,2,0,0,0,4,17,0,1,0,3,17,25],[ebqn_array:get(0,Runtime),ebqn_array:get(18,Runtime),2,char("c"),char("a")],[[0,1,0,0]]]), %'c'≡'a'+2
    1 = ebqn:run([[0,4,0,0,0,2,17,0,1,0,3,17,25],[ebqn_array:get(0,Runtime),ebqn_array:get(18,Runtime),-2,char("a"),char("c")],[[0,1,0,0]]]), %'a'≡¯2+'c'
    ok = try ebqn:run([[0,2,0,0,0,1,17,25],[ebqn_array:get(0,Runtime),char("a"),char("c")],[[0,1,0,0]]]) % 'a'+'c'
        catch _ -> ok
    end,
    ok = try ebqn:run([[0,1,22,0,0,11,14,0,2,0,0,21,0,0,17,25],[ebqn_array:get(0,Runtime),ebqn_array:get(1,Runtime),2],[[0,1,0,1]]]) % F←-⋄f+2
        catch _ -> ok
    end,
    1 = ebqn:run([[0,4,0,0,0,3,17,0,1,0,2,17,25],[ebqn_array:get(1,Runtime),ebqn_array:get(18,Runtime),ninf,1000000,inf],[[0,1,0,0]]]), %¯∞≡1e6-∞
    1 = ebqn:run([[0,3,0,0,16,0,1,0,2,17,25],[ebqn_array:get(1,Runtime),ebqn_array:get(18,Runtime),4,-4],[[0,1,0,0]]]), %4≡-¯4
    1 = ebqn:run([[0,3,0,0,16,0,1,0,2,17,25],[ebqn_array:get(1,Runtime),ebqn_array:get(18,Runtime),ninf,inf],[[0,1,0,0]]]), %¯∞≡-∞
    1 = ebqn:run([[0,3,0,0,16,0,1,0,2,17,25],[ebqn_array:get(1,Runtime),ebqn_array:get(18,Runtime),inf,ninf],[[0,1,0,0]]]), %∞≡-¯∞
    1 = ebqn:run([[0,4,0,0,0,3,17,0,1,0,2,17,25],[ebqn_array:get(1,Runtime),ebqn_array:get(18,Runtime),4,9,5],[[0,1,0,0]]]), %4≡9-5
    1 = ebqn:run([[0,2,0,0,0,4,17,0,1,0,3,17,25],[ebqn_array:get(1,Runtime),ebqn_array:get(18,Runtime),97,char("\0"),char("a")],[[0,1,0,0]]]), %@≡'a'-97
    1 = ebqn:run([[0,4,0,0,0,3,17,0,1,0,2,17,25],[ebqn_array:get(1,Runtime),ebqn_array:get(18,Runtime),3,char("d"),char("a")],[[0,1,0,0]]]), %3≡'d'-'a'
    ok = try ebqn:run([[0,2,0,0,0,1,17,25],[ebqn_array:get(1,Runtime),97,char("a")],[[0,1,0,0]]]) % 97-'a'
        catch _ -> ok
    end,
    ok = try ebqn:run([[0,1,0,0,0,2,17,25],[ebqn_array:get(1,Runtime),1,char("\0")],[[0,1,0,0]]]) % @-1
        catch _ -> ok
    end,
    ok = try ebqn:run([[0,1,0,0,16,25],[ebqn_array:get(1,Runtime),char("a")],[[0,1,0,0]]]) % -'a'
        catch _ -> ok
    end,
    ok = try ebqn:run([[0,1,22,0,0,11,14,21,0,0,0,0,16,25],[ebqn_array:get(1,Runtime),ebqn_array:get(3,Runtime)],[[0,1,0,1]]]) % F←÷⋄-f
        catch _ -> ok
    end,
    1 = ebqn:run([[0,4,0,0,0,3,17,0,1,0,2,17,25],[ebqn_array:get(2,Runtime),ebqn_array:get(18,Runtime),1.5,3,0.5],[[0,1,0,0]]]), %1.5≡3×0.5
    ok = try ebqn:run([[0,2,0,0,0,1,17,25],[ebqn_array:get(2,Runtime),2,char("a")],[[0,1,0,0]]]) % 2×'a'
        catch _ -> ok
    end,
    1 = ebqn:run([[0,3,0,0,16,0,1,0,2,17,25],[ebqn_array:get(3,Runtime),ebqn_array:get(18,Runtime),4,0.25],[[0,1,0,0]]]), %4≡÷0.25
    1 = ebqn:run([[0,3,0,0,16,0,1,0,2,17,25],[ebqn_array:get(3,Runtime),ebqn_array:get(18,Runtime),inf,0],[[0,1,0,0]]]), %∞≡÷0
    1 = ebqn:run([[0,3,0,0,16,0,1,0,2,17,25],[ebqn_array:get(3,Runtime),ebqn_array:get(18,Runtime),0,inf],[[0,1,0,0]]]), %0≡÷∞
    ok = try ebqn:run([[0,1,0,0,16,25],[ebqn_array:get(3,Runtime),char("b")],[[0,1,0,0]]]) % ÷'b'
        catch _ -> ok
    end,
    ok = try ebqn:run([[0,0,0,2,9,22,0,0,11,14,21,0,0,0,1,16,25],[ebqn_array:get(1,Runtime),ebqn_array:get(3,Runtime),ebqn_array:get(5,Runtime)],[[0,1,0,1]]]) % F←√-⋄÷f
        catch _ -> ok
    end,
    1 = ebqn:run([[0,3,0,0,16,0,1,0,2,17,25],[ebqn_array:get(4,Runtime),ebqn_array:get(18,Runtime),1,0],[[0,1,0,0]]]), %1≡⋆0
    1 = ebqn:run([[0,3,0,0,0,2,17,0,1,0,2,17,25],[ebqn_array:get(4,Runtime),ebqn_array:get(18,Runtime),-1,5],[[0,1,0,0]]]), %¯1≡¯1⋆5
    1 = ebqn:run([[0,4,0,0,0,3,17,0,1,0,2,17,25],[ebqn_array:get(4,Runtime),ebqn_array:get(18,Runtime),1,-1,-6],[[0,1,0,0]]]), %1≡¯1⋆¯6
    ok = try ebqn:run([[0,1,0,0,16,25],[ebqn_array:get(4,Runtime),char("π")],[[0,1,0,0]]]) % ⋆'π'
        catch _ -> ok
    end,
    ok = try ebqn:run([[0,2,0,0,0,1,17,25],[ebqn_array:get(4,Runtime),char("e"),char("π")],[[0,1,0,0]]]) % 'e'⋆'π'
        catch _ -> ok
    end,
    1 = ebqn:run([[0,3,0,0,16,0,1,0,2,17,25],[ebqn_array:get(6,Runtime),ebqn_array:get(18,Runtime),3,3.9],[[0,1,0,0]]]), %3≡⌊3.9
    1 = ebqn:run([[0,3,0,0,16,0,1,0,2,17,25],[ebqn_array:get(6,Runtime),ebqn_array:get(18,Runtime),-4,-3.9],[[0,1,0,0]]]), %¯4≡⌊¯3.9
    1 = ebqn:run([[0,2,0,0,16,0,1,0,2,17,25],[ebqn_array:get(6,Runtime),ebqn_array:get(18,Runtime),inf],[[0,1,0,0]]]), %∞≡⌊∞
    1 = ebqn:run([[0,2,0,0,16,0,1,0,2,17,25],[ebqn_array:get(6,Runtime),ebqn_array:get(18,Runtime),ninf],[[0,1,0,0]]]), %¯∞≡⌊¯∞
    1 = ebqn:run([[0,2,0,0,16,0,1,0,2,17,25],[ebqn_array:get(6,Runtime),ebqn_array:get(18,Runtime),-1.0E30],[[0,1,0,0]]]), %¯1e30≡⌊¯1e30
    ok = try ebqn:run([[0,1,22,0,0,11,14,21,0,0,0,0,16,25],[ebqn_array:get(6,Runtime),ebqn_array:get(7,Runtime)],[[0,1,0,1]]]) % F←⌈⋄⌊f
        catch _ -> ok
    end,
    1 = ebqn:run([[0,2,0,0,0,2,17,0,1,0,2,17,25],[ebqn_array:get(15,Runtime),ebqn_array:get(18,Runtime),1],[[0,1,0,0]]]), %1≡1=1
    1 = ebqn:run([[0,4,0,0,0,3,17,0,1,0,2,17,25],[ebqn_array:get(15,Runtime),ebqn_array:get(18,Runtime),0,-1,inf],[[0,1,0,0]]]), %0≡¯1=∞
    1 = ebqn:run([[0,3,0,0,0,3,17,0,1,0,2,17,25],[ebqn_array:get(15,Runtime),ebqn_array:get(18,Runtime),1,char("a")],[[0,1,0,0]]]), %1≡'a'='a'
    1 = ebqn:run([[0,4,0,0,0,3,17,0,1,0,2,17,25],[ebqn_array:get(15,Runtime),ebqn_array:get(18,Runtime),0,char("a"),char("A")],[[0,1,0,0]]]), %0≡'a'='A'
    1 = ebqn:run([[15,1,0,2,0,3,17,25,0,0,22,0,0,11,14,21,0,0,0,1,21,0,0,17,25],[ebqn_array:get(0,Runtime),ebqn_array:get(15,Runtime),ebqn_array:get(18,Runtime),1],[[0,1,0,0],[0,1,8,1]]]), %1≡{F←+⋄f=f}
    1 = ebqn:run([[15,1,0,2,0,4,17,25,0,3,0,0,7,0,3,0,0,7,3,2,22,0,0,22,0,1,4,2,11,14,21,0,1,0,1,21,0,0,17,25],[ebqn_array:get(0,Runtime),ebqn_array:get(15,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(49,Runtime),1],[[0,1,0,0],[0,1,8,2]]]), %1≡{a‿b←⟨+´,+´⟩⋄a=b}
    1 = ebqn:run([[15,1,0,1,0,2,17,25,15,2,22,0,0,11,14,0,3,0,0,21,0,0,17,25,21,0,1,25],[ebqn_array:get(15,Runtime),ebqn_array:get(18,Runtime),0,char("o")],[[0,1,0,0],[0,1,8,1],[1,1,24,2]]]), %0≡{_op←{𝕗}⋄op='o'}
    1 = ebqn:run([[15,1,0,1,0,2,17,25,15,2,22,0,0,11,14,15,3,22,0,1,11,14,21,0,1,0,0,21,0,0,17,25,21,0,1,25,21,0,1,25],[ebqn_array:get(15,Runtime),ebqn_array:get(18,Runtime),0],[[0,1,0,0],[0,1,8,2],[0,0,32,3],[0,0,36,3]]]), %0≡{F←{𝕩}⋄G←{𝕩}⋄f=g}
    1 = ebqn:run([[15,1,0,1,0,2,17,25,15,2,22,0,0,11,14,21,0,0,0,0,21,0,0,17,25,21,0,1,25],[ebqn_array:get(15,Runtime),ebqn_array:get(18,Runtime),1],[[0,1,0,0],[0,1,8,1],[0,0,25,3]]]), %1≡{F←{𝕩}⋄f=f}
    1 = ebqn:run([[0,2,0,0,0,2,17,0,1,0,2,17,25],[ebqn_array:get(16,Runtime),ebqn_array:get(18,Runtime),1],[[0,1,0,0]]]), %1≡1≤1
    1 = ebqn:run([[0,4,0,0,0,3,17,0,1,0,2,17,25],[ebqn_array:get(16,Runtime),ebqn_array:get(18,Runtime),1,ninf,-1000],[[0,1,0,0]]]), %1≡¯∞≤¯1e3
    1 = ebqn:run([[0,4,0,0,0,3,17,0,1,0,2,17,25],[ebqn_array:get(16,Runtime),ebqn_array:get(18,Runtime),0,inf,ninf],[[0,1,0,0]]]), %0≡∞≤¯∞
    1 = ebqn:run([[0,4,0,0,0,3,17,0,1,0,2,17,25],[ebqn_array:get(16,Runtime),ebqn_array:get(18,Runtime),1,inf,char("\0")],[[0,1,0,0]]]), %1≡∞≤@
    1 = ebqn:run([[0,3,0,0,0,4,17,0,1,0,2,17,25],[ebqn_array:get(16,Runtime),ebqn_array:get(18,Runtime),0,-0.5,char("z")],[[0,1,0,0]]]), %0≡'z'≤¯0.5
    1 = ebqn:run([[0,4,0,0,0,3,17,0,1,0,2,17,25],[ebqn_array:get(16,Runtime),ebqn_array:get(18,Runtime),0,char("c"),char("a")],[[0,1,0,0]]]), %0≡'c'≤'a'
    ok = try ebqn:run([[0,0,22,0,0,11,14,0,1,22,0,1,11,14,21,0,1,0,2,21,0,0,17,25],[ebqn_array:get(0,Runtime),ebqn_array:get(1,Runtime),ebqn_array:get(16,Runtime)],[[0,1,0,2]]]) % F←+⋄G←-⋄f≤g
        catch _ -> ok
    end,
    1 = ebqn:run([[0,3,0,0,16,0,2,16,0,1,3,0,17,25],[ebqn_array:get(12,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(19,Runtime),2],[[0,1,0,0]]]), %⟨⟩≡≢<2
    1 = ebqn:run([[0,3,0,1,16,0,0,0,2,3,1,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(19,Runtime),3,str("abc")],[[0,1,0,0]]]), %⟨3⟩≡≢"abc"
    1 = ebqn:run([[0,5,0,6,3,2,0,0,16,0,2,16,0,1,0,3,0,4,3,2,17,25],[ebqn_array:get(13,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(19,Runtime),2,3,str("abc"),str("fed")],[[0,1,0,0]]]), %⟨2,3⟩≡≢>"abc"‿"fed"
    1 = ebqn:run([[0,8,0,3,16,0,2,0,4,0,5,0,6,0,7,3,4,17,0,1,16,0,0,0,4,0,5,0,6,0,7,3,4,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(19,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(27,Runtime),2,3,4,5,120],[[0,1,0,0]]]), %⟨2,3,4,5⟩≡≢2‿3‿4‿5⥊↕120
    1 = ebqn:run([[0,5,0,6,3,2,0,0,16,0,3,16,0,2,16,0,1,0,4,3,1,17,25],[ebqn_array:get(13,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(19,Runtime),ebqn_array:get(22,Runtime),6,str("abc"),str("fed")],[[0,1,0,0]]]), %⟨6⟩≡≢⥊>"abc"‿"fed"
    1 = ebqn:run([[0,3,0,4,3,2,0,1,0,2,17,0,0,0,3,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(36,Runtime),0,str("abc"),str("de")],[[0,1,0,0]]]), %"abc"≡0⊑"abc"‿"de"
    1 = ebqn:run([[0,4,0,3,3,2,0,1,0,2,17,0,0,0,3,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(36,Runtime),1,str("de"),str("abc")],[[0,1,0,0]]]), %"de"≡1⊑"abc"‿"de"
    1 = ebqn:run([[0,2,0,1,16,0,0,3,0,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(27,Runtime),0],[[0,1,0,0]]]), %⟨⟩≡↕0
    1 = ebqn:run([[0,3,0,1,16,0,0,0,2,3,1,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(27,Runtime),0,1],[[0,1,0,0]]]), %⟨0⟩≡↕1
    1 = ebqn:run([[0,9,0,1,16,0,0,0,2,0,3,0,4,0,5,0,6,0,7,0,8,3,7,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(27,Runtime),0,1,2,3,4,5,6,7],[[0,1,0,0]]]), %⟨0,1,2,3,4,5,6⟩≡↕7
    1 = ebqn:run([[0,2,0,1,16,0,0,0,2,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(42,Runtime),1],[[0,1,0,0]]]), %1≡!1
    1 = ebqn:run([[0,2,0,1,0,3,17,0,0,0,2,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(42,Runtime),1,char("e")],[[0,1,0,0]]]), %1≡'e'!1
    ok = try ebqn:run([[0,1,0,0,16,25],[ebqn_array:get(42,Runtime),0],[[0,1,0,0]]]) % !0
        catch _ -> ok
    end,
    ok = try ebqn:run([[0,2,0,0,0,1,17,25],[ebqn_array:get(42,Runtime),str("error"),str("abc")],[[0,1,0,0]]]) % "error"!"abc"
        catch _ -> ok
    end,
    ok.

layer1(#a{r=Runtime}) ->
    1 = ebqn:run([[0,7,0,0,0,1,3,2,0,4,0,2,8,0,6,17,0,3,0,5,17,25],[ebqn_array:get(0,Runtime),ebqn_array:get(1,Runtime),ebqn_array:get(13,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(58,Runtime),3,4,1],[[0,1,0,0]]]), %3≡4>◶+‿-1
    1 = ebqn:run([[0,7,0,0,0,1,3,2,0,4,0,3,8,0,6,17,0,2,0,5,17,25],[ebqn_array:get(0,Runtime),ebqn_array:get(1,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(21,Runtime),ebqn_array:get(58,Runtime),3,4,1],[[0,1,0,0]]]), %3≡4⊢◶+‿-1
    1 = ebqn:run([[0,6,0,0,0,1,3,2,0,3,0,6,8,0,5,17,0,2,0,4,17,25],[ebqn_array:get(0,Runtime),ebqn_array:get(1,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(58,Runtime),3,4,1],[[0,1,0,0]]]), %3≡4 1◶+‿-1
    1 = ebqn:run([[0,7,0,0,0,1,3,2,0,4,0,2,8,0,6,17,0,3,0,5,17,25],[ebqn_array:get(0,Runtime),ebqn_array:get(1,Runtime),ebqn_array:get(12,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(58,Runtime),5,4,1],[[0,1,0,0]]]), %5≡4<◶+‿-1
    1 = ebqn:run([[0,7,0,0,0,1,3,2,0,3,0,6,8,0,5,17,0,2,0,4,17,25],[ebqn_array:get(0,Runtime),ebqn_array:get(1,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(58,Runtime),5,4,0,1],[[0,1,0,0]]]), %5≡4 0◶+‿-1
    1 = ebqn:run([[0,5,0,4,0,2,0,0,8,16,0,1,0,3,17,25],[ebqn_array:get(1,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(57,Runtime),1,0,-1],[[0,1,0,0]]]), %1≡-⊘0 ¯1
    1 = ebqn:run([[0,6,0,0,0,3,0,1,8,0,5,17,0,2,0,4,17,25],[ebqn_array:get(0,Runtime),ebqn_array:get(1,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(57,Runtime),1,-1,2],[[0,1,0,0]]]), %1≡¯1-⊘+2
    1 = ebqn:run([[0,2,0,1,16,0,0,0,2,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(21,Runtime),str("abc")],[[0,1,0,0]]]), %"abc"≡⊢"abc"
    1 = ebqn:run([[0,3,0,1,0,2,17,0,0,0,3,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(21,Runtime),3,str("")],[[0,1,0,0]]]), %""≡3⊢""
    1 = ebqn:run([[3,0,0,1,16,0,0,3,0,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(20,Runtime)],[[0,1,0,0]]]), %⟨⟩≡⊣⟨⟩
    1 = ebqn:run([[3,0,0,1,0,2,17,0,0,0,2,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(20,Runtime),str("ab")],[[0,1,0,0]]]), %"ab"≡"ab"⊣⟨⟩
    1 = ebqn:run([[0,4,0,2,0,0,7,16,0,1,0,3,17,25],[ebqn_array:get(0,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(44,Runtime),4,2],[[0,1,0,0]]]), %4≡+˜2
    1 = ebqn:run([[0,5,0,2,0,0,7,0,4,17,0,1,0,3,17,25],[ebqn_array:get(1,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(44,Runtime),3,1,4],[[0,1,0,0]]]), %3≡1-˜4
    1 = ebqn:run([[0,5,0,1,0,3,0,0,8,16,0,2,0,4,17,25],[ebqn_array:get(1,Runtime),ebqn_array:get(2,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(52,Runtime),1,-6],[[0,1,0,0]]]), %1≡-∘×¯6
    1 = ebqn:run([[0,6,0,1,0,3,0,0,8,0,5,17,0,2,0,4,17,25],[ebqn_array:get(1,Runtime),ebqn_array:get(2,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(52,Runtime),-6,2,3],[[0,1,0,0]]]), %¯6≡2-∘×3
    1 = ebqn:run([[0,5,0,1,0,3,0,0,8,16,0,2,0,4,17,25],[ebqn_array:get(1,Runtime),ebqn_array:get(2,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(53,Runtime),1,-7],[[0,1,0,0]]]), %1≡-○×¯7
    1 = ebqn:run([[0,6,0,1,0,3,0,0,8,0,5,17,0,2,0,4,17,25],[ebqn_array:get(1,Runtime),ebqn_array:get(2,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(53,Runtime),2,5,-7],[[0,1,0,0]]]), %2≡5-○×¯7
    1 = ebqn:run([[0,6,0,1,0,3,0,0,0,3,0,5,8,8,16,0,2,0,4,17,25],[ebqn_array:get(1,Runtime),ebqn_array:get(2,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(54,Runtime),-20,1,5],[[0,1,0,0]]]), %¯20≡1⊸-⊸×5
    1 = ebqn:run([[0,11,0,5,16,0,4,0,7,0,3,8,0,12,0,13,3,2,0,1,16,17,0,2,0,8,0,10,3,2,0,6,0,0,7,0,8,0,9,3,2,17,17,25],[ebqn_array:get(0,Runtime),ebqn_array:get(13,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(19,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(47,Runtime),ebqn_array:get(54,Runtime),0,2,1,4,str("ab"),str("cd")],[[0,1,0,0]]]), %(0‿2+⌜0‿1)≡(>⟨"ab","cd"⟩)≢⊸⥊↕4
    1 = ebqn:run([[0,6,0,5,0,3,0,0,8,0,3,0,1,8,16,0,2,0,4,17,25],[ebqn_array:get(1,Runtime),ebqn_array:get(2,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(55,Runtime),20,1,5],[[0,1,0,0]]]), %20≡×⟜(-⟜1)5
    1 = ebqn:run([[0,6,0,1,0,3,0,0,8,0,5,17,0,2,0,4,17,25],[ebqn_array:get(0,Runtime),ebqn_array:get(2,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(55,Runtime),4,5,-3],[[0,1,0,0]]]), %4≡5+⟜×¯3
    1 = ebqn:run([[0,6,0,5,0,2,0,0,8,0,4,17,0,1,0,3,17,25],[ebqn_array:get(0,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(55,Runtime),7,5,2,-3],[[0,1,0,0]]]), %7≡5+⟜2 ¯3
    1 = ebqn:run([[0,3,0,0,16,0,1,0,2,17,25],[ebqn_array:get(5,Runtime),ebqn_array:get(18,Runtime),2,4],[[0,1,0,0]]]), %2≡√4
    1 = ebqn:run([[0,3,0,0,0,2,17,0,1,0,2,17,25],[ebqn_array:get(5,Runtime),ebqn_array:get(18,Runtime),3,27],[[0,1,0,0]]]), %3≡3√27
    ok = try ebqn:run([[0,1,0,0,16,25],[ebqn_array:get(5,Runtime),char("x")],[[0,1,0,0]]]) % √'x'
        catch _ -> ok
    end,
    1 = ebqn:run([[0,4,0,0,0,3,17,0,1,0,2,17,25],[ebqn_array:get(10,Runtime),ebqn_array:get(18,Runtime),6,2,3],[[0,1,0,0]]]), %6≡2∧3
    1 = ebqn:run([[0,2,0,0,0,3,17,0,1,0,2,17,25],[ebqn_array:get(10,Runtime),ebqn_array:get(18,Runtime),0,-2],[[0,1,0,0]]]), %0≡¯2∧0
    ok = try ebqn:run([[0,1,0,0,0,2,17,25],[ebqn_array:get(10,Runtime),-1,char("a")],[[0,1,0,0]]]) % 'a'∧¯1
        catch _ -> ok
    end,
    1 = ebqn:run([[0,4,0,2,0,0,7,16,0,1,0,3,17,25],[ebqn_array:get(11,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(44,Runtime),0.75,0.5],[[0,1,0,0]]]), %0.75≡∨˜0.5
    1 = ebqn:run([[0,4,0,0,0,3,17,0,1,0,2,17,25],[ebqn_array:get(11,Runtime),ebqn_array:get(18,Runtime),1.75,2,0.25],[[0,1,0,0]]]), %1.75≡2∨0.25
    ok = try ebqn:run([[0,0,22,0,0,11,14,21,0,0,0,1,0,2,17,25],[ebqn_array:get(1,Runtime),ebqn_array:get(11,Runtime),2],[[0,1,0,1]]]) % F←-⋄2∨f
        catch _ -> ok
    end,
    1 = ebqn:run([[0,3,0,0,16,0,1,0,2,17,25],[ebqn_array:get(9,Runtime),ebqn_array:get(18,Runtime),0,1],[[0,1,0,0]]]), %0≡¬1
    1 = ebqn:run([[0,3,0,0,16,0,1,0,2,17,25],[ebqn_array:get(9,Runtime),ebqn_array:get(18,Runtime),1,0],[[0,1,0,0]]]), %1≡¬0
    1 = ebqn:run([[0,3,0,0,16,0,1,0,2,17,25],[ebqn_array:get(9,Runtime),ebqn_array:get(18,Runtime),2,-1],[[0,1,0,0]]]), %2≡¬¯1
    ok = try ebqn:run([[0,1,0,0,16,25],[ebqn_array:get(9,Runtime),char("a")],[[0,1,0,0]]]) % ¬'a'
        catch _ -> ok
    end,
    1 = ebqn:run([[0,4,0,0,0,3,17,0,1,0,2,17,25],[ebqn_array:get(9,Runtime),ebqn_array:get(18,Runtime),0,3,4],[[0,1,0,0]]]), %0≡3¬4
    1 = ebqn:run([[0,4,0,0,0,3,17,0,1,0,2,17,25],[ebqn_array:get(9,Runtime),ebqn_array:get(18,Runtime),2,4,3],[[0,1,0,0]]]), %2≡4¬3
    1 = ebqn:run([[0,4,0,0,0,3,17,0,1,0,2,17,25],[ebqn_array:get(9,Runtime),ebqn_array:get(18,Runtime),4,5,2],[[0,1,0,0]]]), %4≡5¬2
    ok = try ebqn:run([[15,1,22,0,0,11,14,21,0,0,0,0,0,1,17,25,21,0,1,25],[ebqn_array:get(9,Runtime),0],[[0,1,0,1],[0,0,16,3]]]) % F←{𝕩}⋄0¬f
        catch _ -> ok
    end,
    1 = ebqn:run([[0,2,0,0,16,0,1,0,2,17,25],[ebqn_array:get(8,Runtime),ebqn_array:get(18,Runtime),0],[[0,1,0,0]]]), %0≡|0
    1 = ebqn:run([[0,3,0,0,16,0,1,0,2,17,25],[ebqn_array:get(8,Runtime),ebqn_array:get(18,Runtime),5,-5],[[0,1,0,0]]]), %5≡|¯5
    1 = ebqn:run([[0,2,0,0,16,0,1,0,2,17,25],[ebqn_array:get(8,Runtime),ebqn_array:get(18,Runtime),6],[[0,1,0,0]]]), %6≡|6
    1 = ebqn:run([[0,3,0,0,16,0,1,0,2,17,25],[ebqn_array:get(8,Runtime),ebqn_array:get(18,Runtime),inf,ninf],[[0,1,0,0]]]), %∞≡|¯∞
    ok = try ebqn:run([[0,1,0,0,9,22,0,0,11,14,21,0,0,0,2,16,25],[ebqn_array:get(0,Runtime),ebqn_array:get(1,Runtime),ebqn_array:get(8,Runtime)],[[0,1,0,1]]]) % F←+-⋄|f
        catch _ -> ok
    end,
    1 = ebqn:run([[0,4,0,0,0,3,17,0,1,0,2,17,25],[ebqn_array:get(8,Runtime),ebqn_array:get(18,Runtime),2,3,8],[[0,1,0,0]]]), %2≡3|8
    1 = ebqn:run([[0,4,0,0,0,3,17,0,1,0,2,17,25],[ebqn_array:get(8,Runtime),ebqn_array:get(18,Runtime),2,3,-7],[[0,1,0,0]]]), %2≡3|¯7
    1 = ebqn:run([[0,4,0,0,0,3,17,0,1,0,2,17,25],[ebqn_array:get(8,Runtime),ebqn_array:get(18,Runtime),-1,-3,8],[[0,1,0,0]]]), %¯1≡¯3|8
    ok = try ebqn:run([[0,2,0,0,0,1,17,25],[ebqn_array:get(8,Runtime),26,char("A")],[[0,1,0,0]]]) % 26|'A'
        catch _ -> ok
    end,
    1 = ebqn:run([[0,3,0,0,16,0,2,16,0,1,0,4,17,25],[ebqn_array:get(12,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),char("a"),str("a")],[[0,1,0,0]]]), %"a"≡⥊<'a'
    1 = ebqn:run([[0,3,0,0,16,0,2,16,0,1,0,3,17,25],[ebqn_array:get(12,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(36,Runtime),str("abcd")],[[0,1,0,0]]]), %"abcd"≡⊑<"abcd"
    1 = ebqn:run([[0,3,0,4,0,5,3,2,3,2,0,0,16,0,2,16,0,1,3,0,17,25],[ebqn_array:get(12,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(19,Runtime),2,3,4],[[0,1,0,0]]]), %⟨⟩≡≢<⟨2,⟨3,4⟩⟩
    1 = ebqn:run([[0,4,0,0,0,3,17,0,1,0,2,17,25],[ebqn_array:get(12,Runtime),ebqn_array:get(18,Runtime),0,4,2],[[0,1,0,0]]]), %0≡4<2
    1 = ebqn:run([[0,3,0,0,0,3,17,0,1,0,2,17,25],[ebqn_array:get(13,Runtime),ebqn_array:get(18,Runtime),0,5],[[0,1,0,0]]]), %0≡5>5
    1 = ebqn:run([[0,4,0,0,0,3,17,0,1,0,2,17,25],[ebqn_array:get(17,Runtime),ebqn_array:get(18,Runtime),0,3,4],[[0,1,0,0]]]), %0≡3≥4
    1 = ebqn:run([[0,3,0,0,16,0,1,0,2,17,25],[ebqn_array:get(14,Runtime),ebqn_array:get(18,Runtime),0,str("")],[[0,1,0,0]]]), %0≡≠""
    1 = ebqn:run([[0,3,0,0,16,0,1,0,2,17,25],[ebqn_array:get(14,Runtime),ebqn_array:get(18,Runtime),1,str("a")],[[0,1,0,0]]]), %1≡≠"a"
    1 = ebqn:run([[0,3,0,0,16,0,1,0,2,17,25],[ebqn_array:get(14,Runtime),ebqn_array:get(18,Runtime),1,char("a")],[[0,1,0,0]]]), %1≡≠'a'
    1 = ebqn:run([[0,3,0,0,16,0,1,0,2,17,25],[ebqn_array:get(14,Runtime),ebqn_array:get(18,Runtime),2,str("ab")],[[0,1,0,0]]]), %2≡≠"ab"
    1 = ebqn:run([[0,3,0,2,16,0,0,16,0,1,0,3,17,25],[ebqn_array:get(14,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(27,Runtime),25],[[0,1,0,0]]]), %25≡≠↕25
    1 = ebqn:run([[0,3,0,0,16,0,1,0,2,17,25],[ebqn_array:get(2,Runtime),ebqn_array:get(18,Runtime),1,5],[[0,1,0,0]]]), %1≡×5
    1 = ebqn:run([[0,3,0,0,16,0,1,0,2,17,25],[ebqn_array:get(2,Runtime),ebqn_array:get(18,Runtime),-1,-2.5],[[0,1,0,0]]]), %¯1≡×¯2.5
    1 = ebqn:run([[0,3,0,0,0,2,17,0,1,0,2,17,25],[ebqn_array:get(6,Runtime),ebqn_array:get(18,Runtime),3,4],[[0,1,0,0]]]), %3≡3⌊4
    1 = ebqn:run([[0,3,0,0,0,2,17,0,1,0,2,17,25],[ebqn_array:get(6,Runtime),ebqn_array:get(18,Runtime),-3,inf],[[0,1,0,0]]]), %¯3≡¯3⌊∞
    1 = ebqn:run([[0,2,0,0,0,3,17,0,1,0,2,17,25],[ebqn_array:get(7,Runtime),ebqn_array:get(18,Runtime),4,3],[[0,1,0,0]]]), %4≡3⌈4
    1 = ebqn:run([[0,3,0,0,0,2,17,0,1,0,2,17,25],[ebqn_array:get(7,Runtime),ebqn_array:get(18,Runtime),1,-1],[[0,1,0,0]]]), %1≡1⌈¯1
    1 = ebqn:run([[0,3,0,0,16,0,1,0,2,17,25],[ebqn_array:get(7,Runtime),ebqn_array:get(18,Runtime),5,4.01],[[0,1,0,0]]]), %5≡⌈4.01
    1 = ebqn:run([[0,2,0,1,16,0,0,3,0,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(19,Runtime),char("a")],[[0,1,0,0]]]), %⟨⟩≡≢'a'
    1 = ebqn:run([[0,2,0,1,16,0,0,3,0,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(19,Runtime),0],[[0,1,0,0]]]), %⟨⟩≡≢0
    1 = ebqn:run([[0,7,0,2,16,0,3,0,1,7,16,0,0,0,4,3,1,0,5,3,1,0,6,3,1,3,3,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(46,Runtime),0,1,2,3],[[0,1,0,0]]]), %⟨0⟩‿⟨1⟩‿⟨2⟩≡⥊¨↕3
    1 = ebqn:run([[3,0,0,11,0,12,0,13,0,14,0,15,0,16,3,7,0,2,0,6,0,9,0,10,3,2,8,0,5,0,4,0,0,7,0,7,0,1,8,8,0,8,0,3,16,17,25],[ebqn_array:get(14,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(46,Runtime),ebqn_array:get(53,Runtime),ebqn_array:get(54,Runtime),ebqn_array:get(55,Runtime),6,2,3,str("a"),str("ab"),str("abc"),str("abcd"),str("abcde"),str("abcdef")],[[0,1,0,0]]]), %(↕6)≡⟜(≠¨)○(2‿3⊸⥊)⟨⟩‿"a"‿"ab"‿"abc"‿"abcd"‿"abcde"‿"abcdef"
    1 = ebqn:run([[0,7,0,3,16,0,2,0,6,0,7,0,8,3,3,17,0,4,0,0,7,0,5,0,1,8,16,25],[ebqn_array:get(14,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(46,Runtime),ebqn_array:get(55,Runtime),4,0,2],[[0,1,0,0]]]), %≡⟜(≠¨)4‿0‿2⥊↕0
    1 = ebqn:run([[0,5,0,2,16,0,3,0,0,7,16,0,1,0,4,17,25],[ebqn_array:get(0,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(49,Runtime),6,4],[[0,1,0,0]]]), %6≡+´↕4
    1 = ebqn:run([[0,6,0,4,0,5,0,7,3,2,3,3,0,3,0,1,7,0,0,0,2,19,16,25],[ebqn_array:get(18,Runtime),ebqn_array:get(20,Runtime),ebqn_array:get(36,Runtime),ebqn_array:get(49,Runtime),2,3,str("a"),str("d")],[[0,1,0,0]]]), %(⊑≡⊣´)"a"‿2‿(3‿"d")
    1 = ebqn:run([[0,7,0,5,0,6,0,8,3,2,3,3,0,3,0,1,7,0,0,0,2,19,0,4,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(20,Runtime),ebqn_array:get(36,Runtime),ebqn_array:get(49,Runtime),0,2,3,str("a"),str("d")],[[0,1,0,0]]]), %0(⊑≡⊣´)"a"‿2‿(3‿"d")
    1 = ebqn:run([[0,7,0,5,0,6,0,8,3,2,3,3,0,3,0,1,7,0,0,0,2,0,4,0,5,8,19,16,25],[ebqn_array:get(18,Runtime),ebqn_array:get(21,Runtime),ebqn_array:get(36,Runtime),ebqn_array:get(49,Runtime),ebqn_array:get(54,Runtime),2,3,str("a"),str("d")],[[0,1,0,0]]]), %(2⊸⊑≡⊢´)"a"‿2‿(3‿"d")
    1 = ebqn:run([[0,6,0,4,0,5,0,7,3,2,3,3,0,3,0,2,7,0,0,0,1,19,0,4,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(20,Runtime),ebqn_array:get(21,Runtime),ebqn_array:get(49,Runtime),2,3,str("a"),str("d")],[[0,1,0,0]]]), %2(⊣≡⊢´)"a"‿2‿(3‿"d")
    1 = ebqn:run([[0,6,0,7,3,2,0,8,0,4,3,2,3,2,0,3,0,2,0,0,7,7,16,0,1,0,4,0,5,3,2,17,25],[ebqn_array:get(0,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(46,Runtime),ebqn_array:get(49,Runtime),7,10,2,3,5],[[0,1,0,0]]]), %7‿10≡+¨´⟨⟨2,3⟩,⟨5,7⟩⟩
    ok = try ebqn:run([[0,2,0,1,0,0,7,16,25],[ebqn_array:get(0,Runtime),ebqn_array:get(49,Runtime),11],[[0,1,0,0]]]) % +´11
        catch _ -> ok
    end,
    ok = try ebqn:run([[0,3,0,1,16,0,2,0,0,7,16,25],[ebqn_array:get(1,Runtime),ebqn_array:get(12,Runtime),ebqn_array:get(49,Runtime),char("a")],[[0,1,0,0]]]) % -´<'a'
        catch _ -> ok
    end,
    ok = try ebqn:run([[0,5,0,1,0,3,0,4,3,2,17,0,2,0,0,7,16,25],[ebqn_array:get(2,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(49,Runtime),3,1,str("abc")],[[0,1,0,0]]]) % ×´3‿1⥊"abc"
        catch _ -> ok
    end,
    ok.

layer2(#a{r=Runtime}) ->
    1 = ebqn:run([[0,2,0,1,3,0,17,0,0,3,0,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(23,Runtime),str("")],[[0,1,0,0]]]), %⟨⟩≡⟨⟩∾""
    1 = ebqn:run([[0,2,0,1,3,0,17,0,0,0,2,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(23,Runtime),str("a")],[[0,1,0,0]]]), %"a"≡⟨⟩∾"a"
    1 = ebqn:run([[3,0,0,1,0,2,17,0,0,0,2,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(23,Runtime),str("a")],[[0,1,0,0]]]), %"a"≡"a"∾⟨⟩
    1 = ebqn:run([[0,4,0,1,0,3,17,0,0,0,2,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(23,Runtime),str("aBCD"),str("a"),str("BCD")],[[0,1,0,0]]]), %"aBCD"≡"a"∾"BCD"
    1 = ebqn:run([[0,9,0,7,0,8,3,2,0,10,3,3,0,4,0,6,0,3,7,7,0,5,0,1,7,9,0,2,0,5,0,1,7,0,4,0,6,0,0,7,7,9,19,16,25],[ebqn_array:get(0,Runtime),ebqn_array:get(14,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(23,Runtime),ebqn_array:get(44,Runtime),ebqn_array:get(46,Runtime),ebqn_array:get(47,Runtime),2,3,str(""),str("abcde")],[[0,1,0,0]]]), %((+⌜˜≠¨)≡(≠¨∾⌜˜))""‿⟨2,3⟩‿"abcde"
    1 = ebqn:run([[0,11,0,10,3,2,0,6,0,4,0,7,0,5,0,0,7,0,8,0,10,0,9,0,1,8,8,8,7,0,2,0,6,0,1,7,0,4,9,0,9,0,3,8,19,16,25],[ebqn_array:get(0,Runtime),ebqn_array:get(2,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(47,Runtime),ebqn_array:get(49,Runtime),ebqn_array:get(53,Runtime),ebqn_array:get(54,Runtime),ebqn_array:get(55,Runtime),4,3],[[0,1,0,0]]]), %(⥊⟜(↕×´)≡(×⟜4)⊸(+⌜)○↕´)3‿4
    1 = ebqn:run([[0,11,0,10,3,2,0,6,0,4,0,7,0,5,0,0,7,0,8,0,10,0,9,0,1,8,8,8,7,0,2,0,6,0,1,7,0,4,9,0,9,0,3,8,19,16,25],[ebqn_array:get(0,Runtime),ebqn_array:get(2,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(47,Runtime),ebqn_array:get(49,Runtime),ebqn_array:get(53,Runtime),ebqn_array:get(54,Runtime),ebqn_array:get(55,Runtime),4,0],[[0,1,0,0]]]), %(⥊⟜(↕×´)≡(×⟜4)⊸(+⌜)○↕´)0‿4
    1 = ebqn:run([[0,9,0,4,0,0,7,0,8,0,3,16,0,2,0,5,0,6,3,2,17,17,0,1,0,9,0,2,0,5,0,6,0,7,3,3,17,17,25],[ebqn_array:get(0,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(47,Runtime),3,2,0,6,str("")],[[0,1,0,0]]]), %(3‿2‿0⥊"")≡(3‿2⥊↕6)+⌜""
    1 = ebqn:run([[0,4,0,3,0,0,7,16,0,2,0,4,0,0,16,0,1,16,17,25],[ebqn_array:get(1,Runtime),ebqn_array:get(12,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(46,Runtime),2],[[0,1,0,0]]]), %(<-2)≡-¨2
    1 = ebqn:run([[0,3,0,2,0,0,7,16,0,1,0,3,0,0,16,0,0,16,17,25],[ebqn_array:get(12,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(46,Runtime),2],[[0,1,0,0]]]), %(<<2)≡<¨2
    1 = ebqn:run([[0,4,0,0,16,0,5,0,0,16,0,6,0,0,16,0,4,0,7,0,6,0,7,3,4,0,2,0,6,0,6,3,2,17,0,3,0,0,7,16,3,3,0,8,0,0,16,0,9,0,0,16,3,2,3,3,0,0,16,0,1,0,4,0,5,0,6,0,4,0,7,0,6,0,7,3,4,0,2,0,6,0,6,3,2,17,3,3,0,8,0,9,3,2,3,3,17,25],[ebqn_array:get(1,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(46,Runtime),1,3,2,0,5,4],[[0,1,0,0]]]), %⟨1,⟨3,2,2‿2⥊⟨1,0,2,0⟩⟩,⟨5,4⟩⟩≡-⟨-1,⟨-3,-2,-¨2‿2⥊⟨1,0,2,0⟩⟩,⟨-5,-4⟩⟩
    1 = ebqn:run([[0,6,0,2,16,0,4,0,0,7,0,1,0,3,0,0,7,19,0,5,17,25],[ebqn_array:get(0,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(46,Runtime),ebqn_array:get(47,Runtime),3,6],[[0,1,0,0]]]), %3(+¨≡+⌜)↕6
    ok = try ebqn:run([[0,4,0,5,0,6,3,3,0,1,0,0,7,0,2,0,3,3,2,17,25],[ebqn_array:get(21,Runtime),ebqn_array:get(46,Runtime),2,3,4,5,6],[[0,1,0,0]]]) % 2‿3⊢¨4‿5‿6
        catch _ -> ok
    end,
    ok = try ebqn:run([[0,2,0,0,0,1,17,25],[ebqn_array:get(1,Runtime),str("abcd"),str("a")],[[0,1,0,0]]]) % "abcd"-"a"
        catch _ -> ok
    end,
    1 = ebqn:run([[0,14,0,13,3,2,0,9,3,2,0,10,3,2,0,11,3,2,0,0,0,13,0,14,3,2,17,15,1,16,0,2,0,9,0,10,0,11,0,12,0,12,3,5,17,25,21,0,1,0,5,0,3,0,7,0,4,0,6,0,2,0,1,9,0,8,21,0,0,8,8,8,7,16,25],[ebqn_array:get(0,Runtime),ebqn_array:get(2,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(23,Runtime),ebqn_array:get(49,Runtime),ebqn_array:get(54,Runtime),ebqn_array:get(55,Runtime),ebqn_array:get(61,Runtime),3,4,5,6,2,1],[[0,1,0,0],[0,0,46,3]]]), %3‿4‿5‿6‿6≡{𝕊⍟(×≡)⊸∾⟜⥊´𝕩}⟨2,1⟩+⟨⟨⟨⟨1,2⟩,3⟩,4⟩,5⟩
    1 = ebqn:run([[0,8,0,5,16,0,6,0,4,7,0,0,0,3,19,0,7,0,5,16,17,0,2,16,0,1,0,7,0,8,3,2,17,25],[ebqn_array:get(2,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(19,Runtime),ebqn_array:get(20,Runtime),ebqn_array:get(21,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(47,Runtime),3,2],[[0,1,0,0]]]), %3‿2≡≢(↕3)(⊣×⊢⌜)↕2
    ok = try ebqn:run([[0,6,0,2,16,0,3,0,1,7,0,5,0,2,16,17,0,0,0,4,0,2,16,17,25],[ebqn_array:get(2,Runtime),ebqn_array:get(21,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(47,Runtime),4,3,2],[[0,1,0,0]]]) % (↕4)×(↕3)⊢⌜↕2
        catch _ -> ok
    end,
    1 = ebqn:run([[0,14,0,15,0,16,3,3,0,4,0,1,0,13,19,0,7,0,9,0,2,7,7,0,13,0,6,16,19,0,3,0,12,0,13,3,2,0,10,0,0,7,0,6,9,0,11,0,5,8,16,0,11,0,8,0,2,7,8,19,16,25],[ebqn_array:get(2,Runtime),ebqn_array:get(8,Runtime),ebqn_array:get(15,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(21,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(44,Runtime),ebqn_array:get(46,Runtime),ebqn_array:get(47,Runtime),ebqn_array:get(49,Runtime),ebqn_array:get(55,Runtime),3,4,1,6,8],[[0,1,0,0]]]), %(=¨⟜(⥊⟜(↕×´)3‿4)≡(↕4)=⌜˜4|⊢)1‿6‿8
    ok.

layer3(#a{r=Runtime}) ->
    1 = ebqn:run([[0,2,0,1,16,0,0,0,2,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(36,Runtime),2],[[0,1,0,0]]]), %2≡⊑2
    1 = ebqn:run([[0,2,3,1,0,1,16,0,0,0,2,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(36,Runtime),2],[[0,1,0,0]]]), %2≡⊑⟨2⟩
    1 = ebqn:run([[0,2,3,1,0,1,16,0,0,0,2,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(36,Runtime),str("ab")],[[0,1,0,0]]]), %"ab"≡⊑⟨"ab"⟩
    1 = ebqn:run([[0,4,0,1,16,0,2,16,0,0,0,3,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(36,Runtime),0,20],[[0,1,0,0]]]), %0≡⊑↕20
    1 = ebqn:run([[0,10,0,1,0,9,17,0,2,0,4,0,1,8,0,5,17,0,1,0,6,0,7,0,8,3,3,17,0,3,16,0,0,0,5,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(23,Runtime),ebqn_array:get(36,Runtime),ebqn_array:get(54,Runtime),4,3,2,1,5,0],[[0,1,0,0]]]), %4≡⊑3‿2‿1⥊4⥊⊸∾5⥊0
    1 = ebqn:run([[0,4,0,1,0,2,17,0,0,0,3,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(36,Runtime),2,char("c"),str("abcd")],[[0,1,0,0]]]), %'c'≡2⊑"abcd"
    1 = ebqn:run([[0,4,0,1,0,2,17,0,0,0,3,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(36,Runtime),-2,char("c"),str("abcd")],[[0,1,0,0]]]), %'c'≡¯2⊑"abcd"
    1 = ebqn:run([[0,4,0,1,16,0,2,0,3,17,0,0,0,3,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(36,Runtime),7,10],[[0,1,0,0]]]), %7≡7⊑↕10
    1 = ebqn:run([[0,4,0,1,16,0,2,0,3,3,1,17,0,0,0,3,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(36,Runtime),7,10],[[0,1,0,0]]]), %7≡⟨7⟩⊑↕10
    1 = ebqn:run([[0,5,0,1,16,0,2,0,4,17,0,0,0,3,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(36,Runtime),0,-10,10],[[0,1,0,0]]]), %0≡¯10⊑↕10
    ok = try ebqn:run([[0,2,0,0,16,0,1,0,2,17,25],[ebqn_array:get(27,Runtime),ebqn_array:get(36,Runtime),10],[[0,1,0,0]]]) % 10⊑↕10
        catch _ -> ok
    end,
    ok = try ebqn:run([[0,3,0,0,16,0,1,0,2,17,25],[ebqn_array:get(27,Runtime),ebqn_array:get(36,Runtime),-11,10],[[0,1,0,0]]]) % ¯11⊑↕10
        catch _ -> ok
    end,
    ok = try ebqn:run([[0,3,0,0,16,0,1,0,2,17,25],[ebqn_array:get(27,Runtime),ebqn_array:get(36,Runtime),0.5,10],[[0,1,0,0]]]) % 0.5⊑↕10
        catch _ -> ok
    end,
    ok = try ebqn:run([[0,2,0,0,16,0,1,0,3,17,25],[ebqn_array:get(27,Runtime),ebqn_array:get(36,Runtime),10,char("x")],[[0,1,0,0]]]) % 'x'⊑↕10
        catch _ -> ok
    end,
    ok = try ebqn:run([[0,2,0,0,16,0,1,3,0,17,25],[ebqn_array:get(27,Runtime),ebqn_array:get(36,Runtime),10],[[0,1,0,0]]]) % ⟨⟩⊑↕10
        catch _ -> ok
    end,
    1 = ebqn:run([[0,11,0,3,16,0,5,0,0,7,0,10,0,3,16,0,1,0,9,17,17,0,4,0,7,0,8,3,2,17,0,2,0,6,17,25],[ebqn_array:get(0,Runtime),ebqn_array:get(2,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(36,Runtime),ebqn_array:get(47,Runtime),21,2,-3,10,3,4],[[0,1,0,0]]]), %21≡2‿¯3⊑(10×↕3)+⌜↕4
    ok = try ebqn:run([[0,7,0,1,0,4,0,3,0,0,7,8,0,6,17,0,2,0,5,17,25],[ebqn_array:get(0,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(36,Runtime),ebqn_array:get(47,Runtime),ebqn_array:get(53,Runtime),2,3,4],[[0,1,0,0]]]) % 2⊑3+⌜○↕4
        catch _ -> ok
    end,
    1 = ebqn:run([[0,15,0,3,16,0,5,0,0,7,0,8,0,3,16,0,1,0,14,17,17,0,4,0,9,0,10,3,2,0,11,0,9,3,2,0,12,0,13,3,2,3,3,17,0,2,0,6,0,7,0,8,3,3,17,25],[ebqn_array:get(0,Runtime),ebqn_array:get(2,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(36,Runtime),ebqn_array:get(47,Runtime),21,12,3,2,-3,1,0,-1,10,4],[[0,1,0,0]]]), %21‿12‿03≡⟨2‿¯3,1‿2,0‿¯1⟩⊑(10×↕3)+⌜↕4
    ok = try ebqn:run([[0,15,0,3,16,0,5,0,0,7,0,8,0,3,16,0,1,0,14,17,17,0,4,0,9,0,10,0,11,3,3,0,12,0,9,3,2,0,11,0,13,3,2,3,3,17,0,2,0,6,0,7,0,8,3,3,17,25],[ebqn_array:get(0,Runtime),ebqn_array:get(2,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(36,Runtime),ebqn_array:get(47,Runtime),21,12,3,2,-3,0,1,-1,10,4],[[0,1,0,0]]]) % 21‿12‿03≡⟨2‿¯3‿0,1‿2,0‿¯1⟩⊑(10×↕3)+⌜↕4
        catch _ -> ok
    end,
    ok = try ebqn:run([[0,4,0,0,16,0,1,0,2,0,3,3,1,3,2,17,25],[ebqn_array:get(27,Runtime),ebqn_array:get(36,Runtime),2,3,4],[[0,1,0,0]]]) % ⟨2,⟨3⟩⟩⊑↕4
        catch _ -> ok
    end,
    ok = try ebqn:run([[0,4,0,1,16,0,2,0,3,0,0,16,17,25],[ebqn_array:get(12,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(36,Runtime),2,4],[[0,1,0,0]]]) % (<2)⊑↕4
        catch _ -> ok
    end,
    ok = try ebqn:run([[0,4,0,1,16,0,2,0,3,0,0,16,0,0,16,17,25],[ebqn_array:get(24,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(36,Runtime),2,4],[[0,1,0,0]]]) % (≍≍2)⊑↕4
        catch _ -> ok
    end,
    1 = ebqn:run([[0,10,0,3,0,5,0,6,0,7,0,8,3,4,0,0,16,0,4,0,2,7,16,17,0,1,0,9,17,25],[ebqn_array:get(1,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(36,Runtime),ebqn_array:get(46,Runtime),3,1,2,5,str("dfeb"),str("abcdef")],[[0,1,0,0]]]), %"dfeb"≡(⥊¨-⟨3,1,2,5⟩)⊑"abcdef"
    1 = ebqn:run([[0,3,0,0,16,0,2,3,0,17,0,1,0,3,17,25],[ebqn_array:get(12,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(36,Runtime),str("abc")],[[0,1,0,0]]]), %"abc"≡⟨⟩⊑<"abc"
    1 = ebqn:run([[0,2,0,1,3,0,17,0,0,0,2,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(36,Runtime),char("a")],[[0,1,0,0]]]), %'a'≡⟨⟩⊑'a'
    1 = ebqn:run([[0,3,0,0,16,0,2,3,0,3,0,3,0,3,2,3,0,3,3,17,0,1,0,3,0,3,0,3,3,2,0,3,3,3,17,25],[ebqn_array:get(12,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(36,Runtime),7],[[0,1,0,0]]]), %⟨7,7‿7,7⟩≡⟨⟨⟩,⟨⟨⟩,⟨⟩⟩,⟨⟩⟩⊑<7
    1 = ebqn:run([[0,3,0,2,3,0,3,0,3,0,0,0,16,3,2,3,2,17,0,1,0,3,0,3,0,3,0,0,16,3,2,3,2,17,25],[ebqn_array:get(12,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(36,Runtime),7],[[0,1,0,0]]]), %⟨7,⟨7,<7⟩⟩≡⟨⟨⟩,⟨⟨⟩,<⟨⟩⟩⟩⊑7
    1 = ebqn:run([[0,8,0,1,0,6,0,6,3,2,17,0,3,0,4,0,5,3,2,0,2,16,17,0,1,16,0,0,0,7,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(36,Runtime),2,3,5,str("abcfab"),str("abcdef")],[[0,1,0,0]]]), %"abcfab"≡⥊(↕2‿3)⊑5‿5⥊"abcdef"
    1 = ebqn:run([[0,9,0,2,0,7,0,7,3,2,17,0,4,0,5,0,6,3,2,0,3,16,0,0,16,17,0,2,16,0,1,0,8,17,25],[ebqn_array:get(1,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(36,Runtime),2,3,5,str("aedcaf"),str("abcdef")],[[0,1,0,0]]]), %"aedcaf"≡⥊(-↕2‿3)⊑5‿5⥊"abcdef"
    ok = try ebqn:run([[0,1,0,0,16,25],[ebqn_array:get(27,Runtime),char("\0")],[[0,1,0,0]]]) % ↕@
        catch _ -> ok
    end,
    ok = try ebqn:run([[0,1,0,0,16,25],[ebqn_array:get(27,Runtime),2.4],[[0,1,0,0]]]) % ↕2.4
        catch _ -> ok
    end,
    ok = try ebqn:run([[0,2,0,0,16,0,1,16,25],[ebqn_array:get(12,Runtime),ebqn_array:get(27,Runtime),6],[[0,1,0,0]]]) % ↕<6
        catch _ -> ok
    end,
    ok = try ebqn:run([[0,2,0,3,3,2,0,0,16,0,1,16,25],[ebqn_array:get(24,Runtime),ebqn_array:get(27,Runtime),2,3],[[0,1,0,0]]]) % ↕≍2‿3
        catch _ -> ok
    end,
    ok = try ebqn:run([[0,1,0,2,3,2,0,0,16,25],[ebqn_array:get(27,Runtime),-1,2],[[0,1,0,0]]]) % ↕¯1‿2
        catch _ -> ok
    end,
    1 = ebqn:run([[0,9,0,3,0,8,0,3,0,6,17,17,0,2,0,5,0,4,0,5,0,0,8,8,0,1,0,4,19,0,7,0,3,0,6,17,0,0,16,17,25],[ebqn_array:get(12,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(21,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(36,Runtime),ebqn_array:get(52,Runtime),6,0,1,5],[[0,1,0,0]]]), %(<6⥊0)(⊑≡<∘⊑∘⊢)(6⥊1)⥊5
    1 = ebqn:run([[0,8,0,6,0,6,0,0,0,6,3,4,0,2,0,7,0,7,3,2,17,0,3,0,5,0,6,3,2,8,16,0,1,0,4,17,25],[ebqn_array:get(1,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(58,Runtime),-6,1,0,2,6],[[0,1,0,0]]]), %¯6≡1‿0◶(2‿2⥊0‿0‿-‿0)6
    ok = try ebqn:run([[0,5,0,2,0,1,3,2,0,4,0,3,0,0,7,8,16,25],[ebqn_array:get(1,Runtime),ebqn_array:get(2,Runtime),ebqn_array:get(3,Runtime),ebqn_array:get(43,Runtime),ebqn_array:get(58,Runtime),4],[[0,1,0,0]]]) % -˙◶÷‿× 4
        catch _ -> ok
    end,
    1 = ebqn:run([[0,2,0,1,16,0,0,0,2,3,1,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),3],[[0,1,0,0]]]), %⟨3⟩≡⥊3
    1 = ebqn:run([[0,4,0,0,0,1,0,2,0,3,3,0,8,19,16,25],[ebqn_array:get(12,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(54,Runtime),3],[[0,1,0,0]]]), %(⟨⟩⊸⥊≡<)3
    1 = ebqn:run([[0,2,0,1,0,2,17,0,0,0,2,0,2,0,2,3,3,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),3],[[0,1,0,0]]]), %⟨3,3,3⟩≡3⥊3
    1 = ebqn:run([[0,4,0,2,0,3,0,0,8,0,4,17,0,1,0,4,0,4,0,4,3,3,17,25],[ebqn_array:get(12,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(54,Runtime),3],[[0,1,0,0]]]), %⟨3,3,3⟩≡3<⊸⥊3
    ok = try ebqn:run([[0,2,0,0,0,1,17,25],[ebqn_array:get(22,Runtime),-3,3],[[0,1,0,0]]]) % ¯3⥊3
        catch _ -> ok
    end,
    ok = try ebqn:run([[0,4,0,1,16,0,0,0,2,0,3,3,2,17,25],[ebqn_array:get(22,Runtime),ebqn_array:get(27,Runtime),1.6,2.5,4],[[0,1,0,0]]]) % 1.6‿2.5⥊↕4
        catch _ -> ok
    end,
    ok = try ebqn:run([[0,4,0,2,16,0,0,0,3,0,4,3,2,0,1,16,17,25],[ebqn_array:get(22,Runtime),ebqn_array:get(24,Runtime),ebqn_array:get(27,Runtime),2,3],[[0,1,0,0]]]) % (≍2‿3)⥊↕3
        catch _ -> ok
    end,
    1 = ebqn:run([[0,9,0,5,0,7,0,2,0,3,0,1,0,7,0,4,8,19,0,0,0,6,0,2,7,19,8,0,8,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(19,Runtime),ebqn_array:get(21,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(23,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(47,Runtime),ebqn_array:get(53,Runtime),6,3],[[0,1,0,0]]]), %6(⊢⌜≡∾○≢⥊⊢)○↕3
    1 = ebqn:run([[3,0,0,2,0,1,0,0,19,16,25],[ebqn_array:get(12,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(27,Runtime)],[[0,1,0,0]]]), %(<≡↕)⟨⟩
    1 = ebqn:run([[0,5,0,2,0,4,0,3,0,1,7,8,0,0,0,1,0,4,0,2,8,19,16,25],[ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(46,Runtime),ebqn_array:get(52,Runtime),9],[[0,1,0,0]]]), %(↕∘⥊≡⥊¨∘↕)9
    1 = ebqn:run([[0,8,0,8,0,3,16,0,9,0,8,3,2,0,3,16,3,3,0,4,0,2,0,1,0,2,0,7,0,6,3,1,8,19,7,16,0,5,0,0,7,16,25],[ebqn_array:get(10,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(46,Runtime),ebqn_array:get(49,Runtime),ebqn_array:get(52,Runtime),ebqn_array:get(54,Runtime),4,2],[[0,1,0,0]]]), %∧´(⟨∘⟩⊸⥊≡⥊)¨ ⟨4,↕4,↕2‿4⟩
    ok = try ebqn:run([[0,4,0,1,16,0,0,0,3,0,2,3,2,17,25],[ebqn_array:get(22,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(52,Runtime),4,15],[[0,1,0,0]]]) % 4‿∘⥊↕15
        catch _ -> ok
    end,
    1 = ebqn:run([[0,12,0,5,16,0,0,0,7,17,0,3,0,9,0,1,3,2,17,0,3,0,4,0,12,3,2,17,0,3,0,11,0,6,3,2,17,0,3,16,0,2,0,7,0,8,0,9,0,10,0,7,3,5,17,25],[ebqn_array:get(0,Runtime),ebqn_array:get(6,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(25,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(30,Runtime),1,2,3,0,5,4],[[0,1,0,0]]]), %1‿2‿3‿0‿1≡⥊5‿⌽⥊↑‿4⥊3‿⌊⥊1+↕4
    1 = ebqn:run([[0,10,0,3,16,0,0,16,0,5,0,2,7,0,7,0,4,0,8,3,3,0,7,0,9,0,8,3,3,3,2,17,0,6,0,1,7,16,25],[ebqn_array:get(12,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(30,Runtime),ebqn_array:get(46,Runtime),ebqn_array:get(49,Runtime),2,4,3,19],[[0,1,0,0]]]), %≡´⟨2‿⌽‿4,2‿3‿4⟩⥊¨<↕19
    1 = ebqn:run([[0,3,0,1,16,0,2,0,3,17,0,0,16,25],[ebqn_array:get(9,Runtime),ebqn_array:get(12,Runtime),ebqn_array:get(18,Runtime),char("a")],[[0,1,0,0]]]), %¬'a'≡<'a'
    1 = ebqn:run([[0,3,0,2,16,0,1,0,3,17,0,0,16,25],[ebqn_array:get(9,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(24,Runtime),str("a")],[[0,1,0,0]]]), %¬"a"≡≍"a"
    1 = ebqn:run([[0,5,0,6,0,9,0,7,3,2,0,8,3,4,0,2,0,4,0,6,0,6,3,2,8,0,3,0,1,8,0,5,0,6,0,7,0,7,3,2,0,8,3,4,17,0,0,16,25],[ebqn_array:get(9,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(53,Runtime),ebqn_array:get(54,Runtime),1,2,4,5,3],[[0,1,0,0]]]), %¬⟨1,2,⟨4,4⟩,5⟩≡○(2‿2⊸⥊)⟨1,2,⟨3,4⟩,5⟩
    1 = ebqn:run([[0,2,0,3,3,2,0,1,0,2,0,3,0,4,3,3,17,0,0,16,25],[ebqn_array:get(9,Runtime),ebqn_array:get(18,Runtime),2,3,4],[[0,1,0,0]]]), %¬2‿3‿4≡2‿3
    1 = ebqn:run([[0,3,0,1,0,2,17,0,0,16,25],[ebqn_array:get(9,Runtime),ebqn_array:get(18,Runtime),1.001,1.002],[[0,1,0,0]]]), %¬1.001≡1.002
    1 = ebqn:run([[0,1,0,0,0,2,17,25],[ebqn_array:get(19,Runtime),2,char("a")],[[0,1,0,0]]]), %'a'≢2
    1 = ebqn:run([[0,2,0,0,16,0,0,0,1,17,25],[ebqn_array:get(18,Runtime),0,char("a")],[[0,1,0,0]]]), %0≡≡'a'
    1 = ebqn:run([[0,3,0,1,16,0,0,16,0,0,0,2,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(27,Runtime),1,6],[[0,1,0,0]]]), %1≡≡↕6
    1 = ebqn:run([[0,2,0,3,3,2,0,1,16,0,0,16,0,0,0,2,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(27,Runtime),2,4],[[0,1,0,0]]]), %2≡≡↕2‿4
    1 = ebqn:run([[0,3,0,0,16,0,0,16,0,0,16,0,1,16,0,1,0,2,17,25],[ebqn_array:get(12,Runtime),ebqn_array:get(18,Runtime),3,4],[[0,1,0,0]]]), %3≡≡<<<4
    1 = ebqn:run([[0,8,3,0,0,7,3,1,0,9,0,10,0,11,3,2,3,5,0,4,0,2,0,6,0,3,0,1,0,5,0,0,8,7,8,7,0,1,0,4,0,7,7,19,16,25],[ebqn_array:get(1,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(44,Runtime),ebqn_array:get(46,Runtime),ebqn_array:get(53,Runtime),ebqn_array:get(55,Runtime),1,0,2,3,4],[[0,1,0,0]]]), %(1¨≡-○≡˜⟜↕¨)⟨0,⟨⟩,⟨1⟩,2,⟨3,4⟩⟩
    1 = ebqn:run([[0,3,0,4,0,0,0,2,3,3,3,2,0,1,16,0,1,0,2,17,25],[ebqn_array:get(0,Runtime),ebqn_array:get(18,Runtime),2,5,char("c")],[[0,1,0,0]]]), %2≡≡⟨5,⟨'c',+,2⟩⟩
    1 = ebqn:run([[0,0,3,1,0,2,16,0,1,16,0,1,0,3,17,25],[ebqn_array:get(1,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(36,Runtime),0],[[0,1,0,0]]]), %0≡≡⊑⟨-⟩
    ok.

layer4(#a{r=Runtime}) ->
    1 = ebqn:run([[0,9,0,14,0,1,16,0,10,0,1,16,0,11,0,5,16,0,13,0,4,0,11,0,12,3,2,17,3,5,0,6,0,2,0,8,0,3,8,7,16,0,7,0,0,7,16,25],[ebqn_array:get(10,Runtime),ebqn_array:get(12,Runtime),ebqn_array:get(13,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(46,Runtime),ebqn_array:get(49,Runtime),ebqn_array:get(55,Runtime),1,inf,5,3,2,char("a")],[[0,1,0,0]]]), %∧´≡⟜>¨⟨1,<'a',<∞,↕5,5‿3⥊2⟩
    1 = ebqn:run([[0,4,0,5,3,2,0,3,16,0,0,16,0,2,16,0,1,0,4,0,5,0,4,3,3,17,25],[ebqn_array:get(13,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(19,Runtime),ebqn_array:get(27,Runtime),2,3],[[0,1,0,0]]]), %2‿3‿2≡≢>↕2‿3
    1 = ebqn:run([[0,3,0,0,16,0,4,3,2,0,1,16,0,2,0,3,0,4,3,2,17,25],[ebqn_array:get(12,Runtime),ebqn_array:get(13,Runtime),ebqn_array:get(18,Runtime),2,3],[[0,1,0,0]]]), %2‿3≡>⟨<2,3⟩
    ok = try ebqn:run([[0,3,0,4,3,2,0,2,0,1,7,16,0,0,16,25],[ebqn_array:get(13,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(46,Runtime),2,3],[[0,1,0,0]]]) % >↕¨2‿3
        catch _ -> ok
    end,
    ok = try ebqn:run([[0,2,0,1,16,0,3,3,2,0,0,16,25],[ebqn_array:get(13,Runtime),ebqn_array:get(22,Runtime),2,3],[[0,1,0,0]]]) % >⟨⥊2,3⟩
        catch _ -> ok
    end,
    ok = try ebqn:run([[0,6,0,4,16,0,2,0,0,0,5,0,3,8,0,3,19,16,0,1,16,25],[ebqn_array:get(12,Runtime),ebqn_array:get(13,Runtime),ebqn_array:get(21,Runtime),ebqn_array:get(24,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(53,Runtime),4],[[0,1,0,0]]]) % >(≍≍○<⊢)↕4
        catch _ -> ok
    end,
    1 = ebqn:run([[0,8,0,3,0,4,0,7,0,7,3,2,19,0,0,9,0,4,0,7,0,7,3,2,19,0,1,9,0,2,0,4,0,5,0,7,0,4,0,6,17,8,19,16,25],[ebqn_array:get(12,Runtime),ebqn_array:get(13,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(21,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(54,Runtime),4,2,str("abcd")],[[0,1,0,0]]]), %((4⥊2)⊸⥊≡(>2‿2⥊·<2‿2⥊⊢))"abcd"
    1 = ebqn:run([[0,9,0,5,16,0,4,0,7,0,8,3,2,17,0,0,0,6,0,1,8,0,2,0,3,19,16,25],[ebqn_array:get(12,Runtime),ebqn_array:get(13,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(21,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(52,Runtime),5,3,15],[[0,1,0,0]]]), %(⊢≡>∘<)5‿3⥊↕15
    1 = ebqn:run([[0,9,0,5,16,0,4,0,7,0,8,3,2,17,0,6,0,0,7,0,1,9,0,2,0,3,19,16,25],[ebqn_array:get(12,Runtime),ebqn_array:get(13,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(21,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(46,Runtime),5,3,15],[[0,1,0,0]]]), %(⊢≡(><¨))5‿3⥊↕15
    1 = ebqn:run([[0,3,0,2,0,0,0,1,19,16,25],[ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(24,Runtime),char("a")],[[0,1,0,0]]]), %(⥊≡≍)'a'
    1 = ebqn:run([[0,4,0,0,16,0,3,0,1,0,2,19,16,25],[ebqn_array:get(12,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(24,Runtime),char("a")],[[0,1,0,0]]]), %(⥊≡≍)<'a'
    1 = ebqn:run([[0,6,0,2,0,0,0,1,0,3,0,4,0,5,3,2,8,19,16,25],[ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(24,Runtime),ebqn_array:get(54,Runtime),1,2,str("ab")],[[0,1,0,0]]]), %(1‿2⊸⥊≡≍)"ab"
    1 = ebqn:run([[0,3,0,1,0,2,17,0,0,0,2,0,3,3,2,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(24,Runtime),1,2],[[0,1,0,0]]]), %1‿2≡1≍2
    1 = ebqn:run([[0,6,0,7,3,2,0,2,0,1,0,4,0,4,3,2,19,0,0,0,3,19,0,4,0,5,3,2,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(23,Runtime),ebqn_array:get(24,Runtime),2,1,4,3],[[0,1,0,0]]]), %2‿1(≍≡2‿2⥊∾)4‿3
    1 = ebqn:run([[0,5,0,3,0,2,7,0,1,0,0,0,4,0,2,8,19,16,25],[ebqn_array:get(12,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(24,Runtime),ebqn_array:get(44,Runtime),ebqn_array:get(55,Runtime),char("a")],[[0,1,0,0]]]), %(≍⟜<≡≍˜)'a'
    ok = try ebqn:run([[0,1,0,3,0,4,3,3,0,0,0,1,0,2,3,2,17,25],[ebqn_array:get(24,Runtime),1,0,2,3],[[0,1,0,0]]]) % 1‿0≍1‿2‿3
        catch _ -> ok
    end,
    ok = try ebqn:run([[0,3,0,1,16,0,0,0,2,0,0,8,16,25],[ebqn_array:get(24,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(55,Runtime),3],[[0,1,0,0]]]) % ≍⟜≍↕3
        catch _ -> ok
    end,
    ok = try ebqn:run([[0,4,0,0,16,0,3,0,2,0,1,8,16,25],[ebqn_array:get(27,Runtime),ebqn_array:get(30,Runtime),ebqn_array:get(59,Runtime),1.1,4],[[0,1,0,0]]]) % ⌽⎉1.1 ↕4
        catch _ -> ok
    end,
    ok = try ebqn:run([[0,3,0,0,16,0,4,0,2,0,1,8,16,25],[ebqn_array:get(27,Runtime),ebqn_array:get(30,Runtime),ebqn_array:get(59,Runtime),4,char("x")],[[0,1,0,0]]]) % ⌽⎉'x' ↕4
        catch _ -> ok
    end,
    ok = try ebqn:run([[0,5,0,1,16,0,4,0,0,16,0,0,16,0,3,0,2,8,16,25],[ebqn_array:get(12,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(30,Runtime),ebqn_array:get(59,Runtime),0,4],[[0,1,0,0]]]) % ⌽⎉(<<0) ↕4
        catch _ -> ok
    end,
    ok = try ebqn:run([[0,4,0,1,16,0,0,0,3,0,2,8,16,25],[ebqn_array:get(24,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(30,Runtime),ebqn_array:get(59,Runtime),4],[[0,1,0,0]]]) % ⌽⎉≍ ↕4
        catch _ -> ok
    end,
    1 = ebqn:run([[0,17,0,16,0,13,3,3,0,9,0,1,7,0,5,9,0,11,0,3,8,16,0,0,0,10,0,16,0,12,0,6,8,8,16,0,2,0,13,0,14,0,15,3,3,0,8,0,3,7,16,0,7,0,8,0,4,7,7,16,17,25],[ebqn_array:get(0,Runtime),ebqn_array:get(2,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(24,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(30,Runtime),ebqn_array:get(44,Runtime),ebqn_array:get(45,Runtime),ebqn_array:get(49,Runtime),ebqn_array:get(54,Runtime),ebqn_array:get(55,Runtime),ebqn_array:get(59,Runtime),1,5,9,2,3],[[0,1,0,0]]]), %(≍˘˜⥊˘1‿5‿9)≡⌽⎉2⊸+⥊⟜(↕×´)3‿2‿1
    1 = ebqn:run([[0,3,0,2,0,1,7,16,0,1,0,3,0,0,16,17,25],[ebqn_array:get(12,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(45,Runtime),0],[[0,1,0,0]]]), %(<0)≡≡˘0
    1 = ebqn:run([[0,4,0,0,16,0,2,0,1,7,16,0,1,0,3,0,0,16,17,25],[ebqn_array:get(12,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(45,Runtime),1,0],[[0,1,0,0]]]), %(<1)≡≡˘<0
    1 = ebqn:run([[0,8,0,2,16,0,6,0,7,3,2,0,4,0,0,8,0,1,0,3,0,0,7,19,0,5,0,2,16,17,25],[ebqn_array:get(2,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(47,Runtime),ebqn_array:get(59,Runtime),4,0,2,5],[[0,1,0,0]]]), %(↕4)(×⌜≡×⎉0‿2)↕5
    1 = ebqn:run([[0,9,0,2,16,0,7,0,8,3,2,0,5,0,0,8,0,1,0,3,0,4,0,3,0,0,7,7,7,19,0,6,0,2,16,17,25],[ebqn_array:get(4,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(44,Runtime),ebqn_array:get(47,Runtime),ebqn_array:get(59,Runtime),4,inf,-4,5],[[0,1,0,0]]]), %(↕4)(⋆˜⌜˜≡⋆⎉∞‿¯4)↕5
    1 = ebqn:run([[0,18,0,7,16,0,19,0,7,16,0,4,0,15,0,18,3,2,17,3,2,0,8,0,10,0,1,0,11,0,0,8,0,13,0,6,8,7,7,16,0,9,0,3,7,16,0,2,0,15,0,18,3,2,0,16,0,17,0,17,0,17,3,4,0,4,0,15,0,15,3,2,17,0,14,0,5,0,12,0,15,3,1,8,8,16,17,25],[ebqn_array:get(6,Runtime),ebqn_array:get(15,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(19,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(23,Runtime),ebqn_array:get(24,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(44,Runtime),ebqn_array:get(46,Runtime),ebqn_array:get(47,Runtime),ebqn_array:get(53,Runtime),ebqn_array:get(54,Runtime),ebqn_array:get(59,Runtime),ebqn_array:get(61,Runtime),2,0,1,3,6],[[0,1,0,0]]]), %(⟨2⟩⊸∾⍟(2‿2⥊0‿1‿1‿1)2‿3)≡≢¨≍⎉(⌊○=)⌜˜⟨↕3,2‿3⥊↕6⟩
    1 = ebqn:run([[0,11,0,2,0,7,0,8,0,9,3,3,17,0,10,0,6,0,1,8,0,11,0,2,0,7,0,9,3,2,17,17,0,1,0,8,0,3,0,5,0,4,0,0,7,8,0,7,17,17,25],[ebqn_array:get(15,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(47,Runtime),ebqn_array:get(53,Runtime),ebqn_array:get(59,Runtime),2,3,4,1,str("abc")],[[0,1,0,0]]]), %(2=⌜○↕3)≡(2‿4⥊"abc")≡⎉1(2‿3‿4⥊"abc")
    1 = ebqn:run([[0,8,0,1,0,4,0,7,0,5,3,3,17,0,6,0,2,0,0,8,0,8,0,1,0,4,0,5,3,2,17,17,0,0,0,3,0,3,3,2,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(59,Runtime),0,2,4,-1,3,str("abc")],[[0,1,0,0]]]), %⟨0,0⟩≡(2‿4⥊"abc")≡⎉¯1(2‿3‿4⥊"abc")
    ok = try ebqn:run([[0,5,0,0,16,0,3,0,4,3,2,0,2,0,1,8,16,25],[ebqn_array:get(27,Runtime),ebqn_array:get(30,Runtime),ebqn_array:get(60,Runtime),2,2.5,3],[[0,1,0,0]]]) % ⌽⚇2‿2.5 ↕3
        catch _ -> ok
    end,
    1 = ebqn:run([[0,4,0,3,0,2,0,0,8,0,1,0,0,19,16,25],[ebqn_array:get(1,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(60,Runtime),-1,5],[[0,1,0,0]]]), %(-≡-⚇¯1)5
    1 = ebqn:run([[0,7,0,8,3,2,0,9,0,4,0,10,3,3,0,6,3,1,3,2,3,2,0,6,0,3,0,2,0,0,7,8,16,0,1,0,4,0,5,0,6,3,2,3,2,17,25],[ebqn_array:get(0,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(49,Runtime),ebqn_array:get(60,Runtime),5,15,1,3,2,4,6],[[0,1,0,0]]]), %⟨5,⟨15,1⟩⟩≡+´⚇1⟨⟨3,2⟩,⟨⟨4,5,6⟩,⟨1⟩⟩⟩
    1 = ebqn:run([[0,13,0,14,3,2,0,15,0,7,0,8,3,3,3,2,0,12,0,10,3,2,0,6,0,3,0,5,0,2,8,8,0,11,0,10,3,2,3,0,3,1,3,2,17,0,10,0,6,0,4,0,0,7,8,16,0,4,0,3,7,16,0,1,0,7,0,8,0,9,3,3,17,25],[ebqn_array:get(0,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(23,Runtime),ebqn_array:get(49,Runtime),ebqn_array:get(54,Runtime),ebqn_array:get(60,Runtime),5,6,15,1,0,-2,2,3,4],[[0,1,0,0]]]), %5‿6‿15≡∾´+´⚇1⟨⟨0,1⟩,⟨⟨⟩⟩⟩⥊⊸∾⚇¯2‿1⟨⟨2,3⟩,⟨4,5,6⟩⟩
    ok = try ebqn:run([[0,4,0,3,0,5,3,2,0,1,0,0,8,0,2,17,25],[ebqn_array:get(0,Runtime),ebqn_array:get(61,Runtime),2,1,4,char("c")],[[0,1,0,0]]]) % 2+⍟1‿'c'4
        catch _ -> ok
    end,
    ok = try ebqn:run([[0,3,0,2,0,1,0,0,8,16,25],[ebqn_array:get(4,Runtime),ebqn_array:get(61,Runtime),1.5,2],[[0,1,0,0]]]) % ⋆⍟1.5 2
        catch _ -> ok
    end,
    1 = ebqn:run([[0,6,0,5,0,2,0,0,8,0,4,17,0,1,0,3,17,25],[ebqn_array:get(0,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(61,Runtime),4,2,-1,6],[[0,1,0,0]]]), %4≡2+⍟¯1 6
    1 = ebqn:run([[0,8,0,6,0,3,16,0,0,0,7,17,0,4,0,0,8,0,5,17,0,2,0,6,0,3,16,0,1,0,5,17,17,25],[ebqn_array:get(0,Runtime),ebqn_array:get(2,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(61,Runtime),2,7,-3,6],[[0,1,0,0]]]), %(2×↕7)≡2+⍟(¯3+↕7)6
    1 = ebqn:run([[0,8,15,1,16,0,2,0,7,0,4,16,0,1,0,6,17,17,25,0,8,22,0,3,11,14,21,0,1,0,10,0,4,16,0,5,15,2,8,16,22,0,4,11,14,21,0,3,0,3,21,0,4,17,25,0,9,0,0,22,1,3,13,14,21,0,1,0,0,0,9,17,25],[ebqn_array:get(0,Runtime),ebqn_array:get(6,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(23,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(61,Runtime),3,5,0,1,4],[[0,1,0,0],[0,0,19,5],[0,0,55,3]]]), %(3⌊↕5)≡{i←0⋄r←{i+↩1⋄1+𝕩}⍟(↕4)𝕩⋄r∾i}0
    1 = ebqn:run([[0,9,0,4,16,0,3,0,3,0,7,0,0,8,0,8,19,0,1,9,0,2,0,5,0,6,0,0,7,7,19,16,25],[ebqn_array:get(0,Runtime),ebqn_array:get(13,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(21,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(44,Runtime),ebqn_array:get(47,Runtime),ebqn_array:get(61,Runtime),1,5],[[0,1,0,0]]]), %(+⌜˜≡·>1+⍟⊢⊢)↕5
    1 = ebqn:run([[0,9,0,2,16,0,3,0,0,7,16,0,1,0,4,0,5,0,6,0,7,0,8,3,5,17,25],[ebqn_array:get(0,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(51,Runtime),0,1,3,6,10,5],[[0,1,0,0]]]), %0‿1‿3‿6‿10≡+`↕5
    1 = ebqn:run([[0,9,0,2,16,0,3,0,0,7,16,0,1,0,4,0,5,0,6,0,7,0,8,3,5,0,0,16,17,25],[ebqn_array:get(1,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(51,Runtime),0,1,3,6,10,5],[[0,1,0,0]]]), %(-0‿1‿3‿6‿10)≡-`↕5
    1 = ebqn:run([[0,9,0,8,3,2,0,4,16,0,6,0,0,7,16,0,0,0,7,0,1,0,8,17,0,3,0,8,0,4,16,0,5,0,2,7,0,7,17,17,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(23,Runtime),ebqn_array:get(24,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(46,Runtime),ebqn_array:get(51,Runtime),0,3,2],[[0,1,0,0]]]), %((0∾¨↕3)≍3⥊0)≡≡`↕2‿3
    1 = ebqn:run([[3,0,0,2,0,0,7,16,0,1,3,0,17,25],[ebqn_array:get(2,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(51,Runtime)],[[0,1,0,0]]]), %⟨⟩≡×`⟨⟩
    1 = ebqn:run([[0,9,0,1,0,7,0,6,0,8,3,3,17,0,3,0,6,0,4,0,2,8,7,0,5,0,0,8,16,25],[ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(42,Runtime),ebqn_array:get(51,Runtime),ebqn_array:get(52,Runtime),ebqn_array:get(55,Runtime),0,3,2,str("")],[[0,1,0,0]]]), %≡⟜(!∘0`)3‿0‿2⥊""
    ok = try ebqn:run([[0,2,0,1,0,0,7,16,25],[ebqn_array:get(0,Runtime),ebqn_array:get(51,Runtime),4],[[0,1,0,0]]]) % +`4
        catch _ -> ok
    end,
    ok = try ebqn:run([[0,3,0,1,16,0,2,0,0,7,16,25],[ebqn_array:get(0,Runtime),ebqn_array:get(12,Runtime),ebqn_array:get(51,Runtime),char("c")],[[0,1,0,0]]]) % +`<'c'
        catch _ -> ok
    end,
    1 = ebqn:run([[0,6,0,2,16,0,3,0,0,7,0,4,17,0,1,0,4,0,5,0,6,0,7,0,8,3,5,17,25],[ebqn_array:get(0,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(51,Runtime),2,3,5,8,12],[[0,1,0,0]]]), %2‿3‿5‿8‿12≡2+`↕5
    ok = try ebqn:run([[0,5,0,1,0,4,0,2,0,0,7,8,0,6,17,0,3,0,0,7,0,5,0,6,3,2,17,25],[ebqn_array:get(0,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(47,Runtime),ebqn_array:get(51,Runtime),ebqn_array:get(53,Runtime),3,4],[[0,1,0,0]]]) % 3‿4+`4+⌜○↕3
        catch _ -> ok
    end,
    1 = ebqn:run([[0,8,0,4,0,7,0,5,0,0,7,8,0,12,17,0,6,0,2,7,0,12,0,13,3,2,17,0,3,0,11,0,8,3,2,0,5,0,1,7,0,9,0,8,0,10,3,3,17,0,2,0,8,17,17,25],[ebqn_array:get(0,Runtime),ebqn_array:get(2,Runtime),ebqn_array:get(4,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(47,Runtime),ebqn_array:get(51,Runtime),ebqn_array:get(53,Runtime),2,1,6,0,3,4],[[0,1,0,0]]]), %(2⋆1‿2‿6×⌜0‿2)≡3‿4⋆`3+⌜○↕2
    ok.

layer5(#a{r=Runtime}) ->
    1 = ebqn:run([[0,4,0,2,16,0,1,0,3,0,0,16,17,25],[ebqn_array:get(12,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(35,Runtime),char("a"),str("abc")],[[0,1,0,0]]]), %(<'a')≡⊏"abc"
    ok = try ebqn:run([[0,1,0,0,16,25],[ebqn_array:get(35,Runtime),str("")],[[0,1,0,0]]]) % ⊏""
        catch _ -> ok
    end,
    1 = ebqn:run([[0,5,0,3,0,1,7,16,0,2,16,0,0,0,4,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(35,Runtime),ebqn_array:get(45,Runtime),str("a"),str("abc")],[[0,1,0,0]]]), %"a"≡⊏⥊˘"abc"
    ok = try ebqn:run([[0,4,0,0,0,2,0,3,3,2,17,0,1,16,25],[ebqn_array:get(22,Runtime),ebqn_array:get(35,Runtime),0,3,str("")],[[0,1,0,0]]]) % ⊏0‿3⥊""
        catch _ -> ok
    end,
    1 = ebqn:run([[0,5,0,2,0,3,17,0,1,0,4,0,0,16,17,25],[ebqn_array:get(12,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(35,Runtime),2,char("c"),str("abc")],[[0,1,0,0]]]), %(<'c')≡2⊏"abc"
    ok = try ebqn:run([[0,2,0,0,0,1,17,25],[ebqn_array:get(35,Runtime),3,str("abc")],[[0,1,0,0]]]) % 3⊏"abc"
        catch _ -> ok
    end,
    ok = try ebqn:run([[0,2,0,0,0,1,17,25],[ebqn_array:get(35,Runtime),1.5,str("abc")],[[0,1,0,0]]]) % 1.5⊏"abc"
        catch _ -> ok
    end,
    ok = try ebqn:run([[0,2,0,0,0,1,17,25],[ebqn_array:get(35,Runtime),char("x"),str("abc")],[[0,1,0,0]]]) % 'x'⊏"abc"
        catch _ -> ok
    end,
    1 = ebqn:run([[0,5,0,2,0,3,17,0,1,0,4,0,0,16,17,25],[ebqn_array:get(12,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(35,Runtime),-1,char("c"),str("abc")],[[0,1,0,0]]]), %(<'c')≡¯1⊏"abc"
    1 = ebqn:run([[0,5,0,1,0,2,0,3,0,2,3,3,17,0,0,0,4,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(35,Runtime),2,-1,str("ccc"),str("abc")],[[0,1,0,0]]]), %"ccc"≡2‿¯1‿2⊏"abc"
    ok = try ebqn:run([[0,5,0,1,16,0,2,0,3,0,0,16,0,4,3,2,17,25],[ebqn_array:get(22,Runtime),ebqn_array:get(24,Runtime),ebqn_array:get(35,Runtime),0,1,str("abc")],[[0,1,0,0]]]) % ⟨⥊0,1⟩⊏≍"abc"
        catch _ -> ok
    end,
    1 = ebqn:run([[0,8,0,9,3,2,0,2,16,0,3,0,6,0,9,8,0,1,0,4,0,6,0,8,0,2,16,0,5,0,0,7,0,7,17,8,19,16,25],[ebqn_array:get(1,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(30,Runtime),ebqn_array:get(35,Runtime),ebqn_array:get(44,Runtime),ebqn_array:get(54,Runtime),3,5,2],[[0,1,0,0]]]), %((3-˜↕5)⊸⊏≡2⊸⌽)↕5‿2
    1 = ebqn:run([[0,7,0,2,16,0,1,0,6,0,5,3,2,17,0,3,3,0,17,0,0,0,4,0,1,0,4,0,5,3,2,17,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(35,Runtime),0,3,2,6],[[0,1,0,0]]]), %(0‿3⥊0)≡⟨⟩⊏2‿3⥊↕6
    1 = ebqn:run([[0,17,0,16,3,2,0,8,0,1,7,0,5,9,0,11,0,4,8,16,0,6,0,2,0,3,0,9,0,8,0,7,0,0,0,10,0,16,0,11,0,1,8,8,7,7,8,19,0,12,0,13,3,2,0,14,0,15,0,14,3,3,3,2,17,25],[ebqn_array:get(0,Runtime),ebqn_array:get(2,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(20,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(35,Runtime),ebqn_array:get(47,Runtime),ebqn_array:get(49,Runtime),ebqn_array:get(52,Runtime),ebqn_array:get(54,Runtime),ebqn_array:get(55,Runtime),3,0,2,1,5,6],[[0,1,0,0]]]), %⟨3‿0,2‿1‿2⟩(×⟜5⊸+⌜´∘⊣≡⊏)⥊⟜(↕×´)6‿5
    ok = try ebqn:run([[0,5,0,1,0,3,0,2,0,0,7,8,0,4,0,4,3,2,17,25],[ebqn_array:get(12,Runtime),ebqn_array:get(35,Runtime),ebqn_array:get(46,Runtime),ebqn_array:get(54,Runtime),0,str("abc")],[[0,1,0,0]]]) % 0‿0<¨⊸⊏"abc"
        catch _ -> ok
    end,
    1 = ebqn:run([[0,4,0,1,0,7,0,5,3,2,17,0,2,0,5,0,6,3,2,3,0,3,2,17,0,0,0,4,0,1,0,3,0,4,3,2,17,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(35,Runtime),2,0,3,-1,4],[[0,1,0,0]]]), %(2‿0⥊0)≡⟨3‿¯1,⟨⟩⟩⊏4‿3⥊0
    ok = try ebqn:run([[0,5,0,0,0,4,0,2,3,2,17,0,1,0,2,0,3,3,2,3,0,3,2,17,25],[ebqn_array:get(22,Runtime),ebqn_array:get(35,Runtime),3,ninf,4,0],[[0,1,0,0]]]) % ⟨3‿¯∞,⟨⟩⟩⊏4‿3⥊0
        catch _ -> ok
    end,
    1 = ebqn:run([[0,7,0,8,3,2,0,2,16,0,3,0,1,0,3,0,4,0,0,8,19,0,5,0,6,3,2,17,25],[ebqn_array:get(12,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(35,Runtime),ebqn_array:get(54,Runtime),5,1,6,2],[[0,1,0,0]]]), %5‿1(<⊸⊏≡⊏)↕6‿2
    ok = try ebqn:run([[0,6,0,7,3,2,0,2,16,0,3,0,4,0,5,3,2,0,0,16,0,1,16,0,1,16,17,25],[ebqn_array:get(12,Runtime),ebqn_array:get(24,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(35,Runtime),5,1,6,2],[[0,1,0,0]]]) % (≍≍<5‿1)⊏↕6‿2
        catch _ -> ok
    end,
    1 = ebqn:run([[0,15,0,3,16,0,5,0,6,0,0,7,7,16,0,5,0,6,0,1,7,7,0,9,0,4,8,0,2,0,6,0,1,7,0,8,0,7,0,6,0,0,7,7,8,19,0,10,0,11,3,2,0,12,0,13,0,14,0,13,0,12,0,11,3,6,3,2,17,25],[ebqn_array:get(0,Runtime),ebqn_array:get(2,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(35,Runtime),ebqn_array:get(44,Runtime),ebqn_array:get(47,Runtime),ebqn_array:get(49,Runtime),ebqn_array:get(54,Runtime),ebqn_array:get(55,Runtime),4,0,1,2,3,5],[[0,1,0,0]]]), %⟨4‿0,1‿2‿3‿2‿1‿0⟩(+⌜´⊸(×⌜)≡⊏⟜(×⌜˜))+⌜˜↕5
    1 = ebqn:run([[0,13,0,0,0,13,0,2,16,0,12,0,8,16,3,4,0,9,0,7,7,0,5,0,9,0,6,7,19,3,0,0,2,16,17,0,9,0,4,7,16,0,3,0,11,17,0,10,0,1,7,16,25],[ebqn_array:get(0,Runtime),ebqn_array:get(10,Runtime),ebqn_array:get(12,Runtime),ebqn_array:get(15,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(23,Runtime),ebqn_array:get(25,Runtime),ebqn_array:get(26,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(46,Runtime),ebqn_array:get(49,Runtime),1,3,char("\0")],[[0,1,0,0]]]), %∧´1=≡¨(<⟨⟩)(↑¨∾↓¨)⟨@,+,<@,↕3⟩
    1 = ebqn:run([[0,4,0,1,0,2,17,0,0,0,3,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(25,Runtime),3,str("abc"),str("abce")],[[0,1,0,0]]]), %"abc"≡3↑"abce"
    1 = ebqn:run([[0,4,0,1,0,2,17,0,0,0,3,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(25,Runtime),-1,str("e"),str("abce")],[[0,1,0,0]]]), %"e"≡¯1↑"abce"
    1 = ebqn:run([[0,4,0,1,0,2,17,0,0,0,3,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(25,Runtime),0,str(""),str("ab")],[[0,1,0,0]]]), %""≡0↑"ab"
    ok = try ebqn:run([[0,2,0,0,0,1,17,25],[ebqn_array:get(25,Runtime),2.5,str("abce")],[[0,1,0,0]]]) % 2.5↑"abce"
        catch _ -> ok
    end,
    1 = ebqn:run([[0,7,0,4,16,0,3,0,8,17,0,2,0,8,0,4,16,0,0,0,5,0,7,0,6,0,1,8,8,16,17,25],[ebqn_array:get(2,Runtime),ebqn_array:get(12,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(25,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(54,Runtime),ebqn_array:get(55,Runtime),3,5],[[0,1,0,0]]]), %(<⟜3⊸×↕5)≡5↑↕3
    1 = ebqn:run([[0,5,0,3,16,0,2,0,6,17,0,0,0,5,0,1,0,4,17,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(25,Runtime),ebqn_array:get(27,Runtime),6,0,-6],[[0,1,0,0]]]), %(6⥊0)≡¯6↑↕0
    1 = ebqn:run([[0,8,0,4,16,0,1,0,7,0,5,3,2,17,0,3,0,6,17,0,0,0,5,0,4,16,0,2,16,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(24,Runtime),ebqn_array:get(25,Runtime),ebqn_array:get(27,Runtime),3,1,2,6],[[0,1,0,0]]]), %(≍↕3)≡1↑2‿3⥊↕6
    1 = ebqn:run([[0,7,0,3,16,0,6,0,4,0,1,8,0,0,0,5,0,4,0,2,8,19,16,25],[ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(25,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(55,Runtime),4,0,3],[[0,1,0,0]]]), %(↑⟜4≡⥊⟜0)↕3
    1 = ebqn:run([[0,8,0,3,0,5,0,6,3,2,17,0,3,0,4,0,0,16,17,0,1,0,7,0,2,16,17,25],[ebqn_array:get(12,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(24,Runtime),ebqn_array:get(25,Runtime),1,2,3,str("abc"),str("abcd")],[[0,1,0,0]]]), %(≍"abc")≡(<1)↑2‿3↑"abcd"
    ok = try ebqn:run([[0,3,0,0,0,1,0,2,3,2,17,25],[ebqn_array:get(25,Runtime),2,char("c"),str("abcd")],[[0,1,0,0]]]) % 2‿'c'↑"abcd"
        catch _ -> ok
    end,
    ok = try ebqn:run([[0,4,0,1,0,2,0,3,3,2,0,0,16,17,25],[ebqn_array:get(24,Runtime),ebqn_array:get(25,Runtime),2,3,str("abcd")],[[0,1,0,0]]]) % (≍2‿3)↑"abcd"
        catch _ -> ok
    end,
    1 = ebqn:run([[0,6,0,3,16,0,1,0,8,0,9,3,2,17,0,4,0,5,0,1,8,0,0,0,2,19,0,7,0,1,0,6,17,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(25,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(36,Runtime),ebqn_array:get(55,Runtime),6,1,2,3],[[0,1,0,0]]]), %(6⥊1)(↑≡⥊⟜⊑)2‿3⥊↕6
    1 = ebqn:run([[0,8,0,3,0,5,0,2,8,0,1,0,0,0,6,0,7,8,0,5,0,3,0,5,0,4,0,3,7,8,8,19,16,25],[ebqn_array:get(0,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(25,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(46,Runtime),ebqn_array:get(52,Runtime),ebqn_array:get(54,Runtime),1,5],[[0,1,0,0]]]), %(↕¨∘↕∘(1⊸+)≡↑∘↕)5
    1 = ebqn:run([[0,10,0,2,0,9,0,8,3,2,17,0,0,0,6,0,2,7,0,8,0,6,0,3,7,0,7,0,5,16,17,19,0,1,0,4,19,16,25],[ebqn_array:get(12,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(24,Runtime),ebqn_array:get(25,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(46,Runtime),4,2,3,str("abcdef")],[[0,1,0,0]]]), %(↑≡((↕4)≍¨2)⥊¨<)3‿2⥊"abcdef"
    1 = ebqn:run([[0,4,0,1,0,2,17,0,0,0,3,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(26,Runtime),3,str("d"),str("abcd")],[[0,1,0,0]]]), %"d"≡3↓"abcd"
    ok = try ebqn:run([[0,2,0,0,0,1,17,25],[ebqn_array:get(26,Runtime),0.1,str("abcd")],[[0,1,0,0]]]) % 0.1↓"abcd"
        catch _ -> ok
    end,
    ok = try ebqn:run([[0,2,0,0,0,1,3,1,17,25],[ebqn_array:get(26,Runtime),ebqn_array:get(52,Runtime),str("abcd")],[[0,1,0,0]]]) % ⟨∘⟩↓"abcd"
        catch _ -> ok
    end,
    1 = ebqn:run([[0,9,0,7,3,2,0,2,0,3,0,1,0,4,0,8,8,0,5,0,0,8,8,0,6,0,7,3,2,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(26,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(53,Runtime),ebqn_array:get(54,Runtime),ebqn_array:get(55,Runtime),1,2,-3,4],[[0,1,0,0]]]), %1‿2≡⟜(¯3⊸↓)○↕4‿2
    1 = ebqn:run([[0,6,0,7,0,5,3,3,0,4,16,0,3,0,9,0,2,0,8,17,17,0,1,16,0,0,0,5,0,5,0,6,0,7,0,5,3,5,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(19,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(26,Runtime),ebqn_array:get(27,Runtime),1,3,2,5,0],[[0,1,0,0]]]), %1‿1‿3‿2‿1≡≢(5⥊0)↓↕3‿2‿1
    1 = ebqn:run([[0,10,0,4,0,6,0,2,8,0,5,0,8,0,0,8,0,0,0,7,0,9,8,0,6,0,4,8,19,0,1,0,4,0,6,0,3,8,19,16,25],[ebqn_array:get(0,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(25,Runtime),ebqn_array:get(26,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(30,Runtime),ebqn_array:get(52,Runtime),ebqn_array:get(54,Runtime),ebqn_array:get(55,Runtime),1,5],[[0,1,0,0]]]), %(↓∘↕≡↕∘(1⊸+)+⟜⌽↑∘↕)5
    1 = ebqn:run([[0,8,0,5,0,6,3,3,0,2,16,0,3,16,0,4,0,1,7,0,7,17,0,0,0,5,0,6,3,2,0,2,16,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(26,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(35,Runtime),ebqn_array:get(46,Runtime),3,4,1,2],[[0,1,0,0]]]), %(↕3‿4)≡1↓¨⊏↕2‿3‿4
    1 = ebqn:run([[0,7,0,2,16,0,2,0,6,17,0,1,0,6,0,2,0,4,0,3,0,0,7,8,0,5,17,17,25],[ebqn_array:get(0,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(47,Runtime),ebqn_array:get(53,Runtime),4,2,5],[[0,1,0,0]]]), %(4+⌜○↕2)≡2↕↕5
    ok = try ebqn:run([[0,1,0,0,16,0,0,0,2,17,25],[ebqn_array:get(27,Runtime),5,char("\0")],[[0,1,0,0]]]) % @↕↕5
        catch _ -> ok
    end,
    ok = try ebqn:run([[0,3,0,0,16,0,0,0,1,0,2,3,2,17,25],[ebqn_array:get(27,Runtime),2,1,5],[[0,1,0,0]]]) % 2‿1↕↕5
        catch _ -> ok
    end,
    ok = try ebqn:run([[0,2,0,0,16,0,0,0,1,17,25],[ebqn_array:get(27,Runtime),-1,5],[[0,1,0,0]]]) % ¯1↕↕5
        catch _ -> ok
    end,
    ok = try ebqn:run([[0,2,0,0,16,0,0,0,1,17,25],[ebqn_array:get(27,Runtime),7,5],[[0,1,0,0]]]) % 7↕↕5
        catch _ -> ok
    end,
    1 = ebqn:run([[0,6,0,2,0,4,0,5,3,2,17,0,1,0,0,0,3,19,3,0,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(21,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(27,Runtime),4,3,str("abcd")],[[0,1,0,0]]]), %⟨⟩(↕≡⊢)4‿3⥊"abcd"
    1 = ebqn:run([[0,10,0,5,16,0,3,0,7,0,1,0,0,0,9,19,0,6,0,4,7,0,8,19,8,0,2,0,5,0,7,0,8,8,19,16,25],[ebqn_array:get(0,Runtime),ebqn_array:get(14,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(24,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(44,Runtime),ebqn_array:get(54,Runtime),0,1,6],[[0,1,0,0]]]), %(0⊸↕≡(0≍˜1+≠)⊸⥊)↕6
    1 = ebqn:run([[0,6,0,1,0,5,0,3,0,5,3,3,17,0,0,0,6,0,1,0,4,0,5,3,2,17,0,2,0,3,17,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(27,Runtime),7,6,0,str("")],[[0,1,0,0]]]), %(7↕6‿0⥊"")≡0‿7‿0⥊""
    ok = try ebqn:run([[0,2,0,0,0,1,17,25],[ebqn_array:get(28,Runtime),char("a"),char("b")],[[0,1,0,0]]]) % 'a'«'b'
        catch _ -> ok
    end,
    ok = try ebqn:run([[0,1,0,0,0,2,17,25],[ebqn_array:get(29,Runtime),char("b"),str("a")],[[0,1,0,0]]]) % "a"»'b'
        catch _ -> ok
    end,
    ok = try ebqn:run([[0,3,0,1,0,2,0,0,8,16,25],[ebqn_array:get(24,Runtime),ebqn_array:get(29,Runtime),ebqn_array:get(54,Runtime),str("abc")],[[0,1,0,0]]]) % ≍⊸»"abc"
        catch _ -> ok
    end,
    1 = ebqn:run([[0,6,0,1,0,5,0,4,0,2,7,8,0,0,0,1,0,5,0,4,0,3,7,8,19,16,25],[ebqn_array:get(10,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(28,Runtime),ebqn_array:get(29,Runtime),ebqn_array:get(44,Runtime),ebqn_array:get(54,Runtime),str("")],[[0,1,0,0]]]), %(»˜⊸≡∧«˜⊸≡)""
    1 = ebqn:run([[0,2,0,1,3,0,17,0,0,0,2,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(29,Runtime),str("a")],[[0,1,0,0]]]), %"a"≡⟨⟩»"a"
    1 = ebqn:run([[3,0,0,1,0,2,17,0,0,3,0,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(29,Runtime),str("a")],[[0,1,0,0]]]), %⟨⟩≡"a"»⟨⟩
    1 = ebqn:run([[0,4,0,1,0,3,17,0,0,0,2,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(29,Runtime),str("aBC"),str("a"),str("BCD")],[[0,1,0,0]]]), %"aBC"≡"a"»"BCD"
    1 = ebqn:run([[0,4,0,1,0,3,17,0,0,0,2,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(28,Runtime),str("CDa"),str("a"),str("BCD")],[[0,1,0,0]]]), %"CDa"≡"a"«"BCD"
    1 = ebqn:run([[0,2,3,1,0,1,0,4,17,0,0,0,3,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(28,Runtime),4,str("d"),str("abcd")],[[0,1,0,0]]]), %"d"≡"abcd"«⟨4⟩
    1 = ebqn:run([[0,9,0,7,0,8,3,2,0,10,3,3,0,4,0,6,0,3,7,7,0,5,0,0,7,9,0,1,0,5,0,0,7,0,4,0,6,0,2,7,7,9,19,16,25],[ebqn_array:get(14,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(21,Runtime),ebqn_array:get(28,Runtime),ebqn_array:get(44,Runtime),ebqn_array:get(46,Runtime),ebqn_array:get(47,Runtime),2,3,str(""),str("abcde")],[[0,1,0,0]]]), %((⊢⌜˜≠¨)≡(≠¨«⌜˜))""‿⟨2,3⟩‿"abcde"
    1 = ebqn:run([[0,5,0,6,0,7,3,3,0,2,0,1,7,0,4,17,0,0,0,3,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(28,Runtime),ebqn_array:get(49,Runtime),str("Zcab"),str("WXYZ"),str("ab"),str("c"),str("")],[[0,1,0,0]]]), %"Zcab"≡"WXYZ"«´"ab"‿"c"‿""
    1 = ebqn:run([[0,4,0,1,0,2,17,0,0,0,3,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(29,Runtime),char("d"),str("dab"),str("abc")],[[0,1,0,0]]]), %"dab"≡'d'»"abc"
    1 = ebqn:run([[0,6,0,2,0,3,0,0,8,0,4,17,0,1,0,5,17,25],[ebqn_array:get(12,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(29,Runtime),ebqn_array:get(54,Runtime),char("d"),str("dab"),str("abc")],[[0,1,0,0]]]), %"dab"≡'d'<⊸»"abc"
    1 = ebqn:run([[0,12,0,13,3,2,0,8,0,1,7,0,4,9,0,10,0,3,8,16,0,0,0,14,17,0,5,0,9,0,7,8,0,2,0,6,0,9,0,11,8,19,16,25],[ebqn_array:get(0,Runtime),ebqn_array:get(2,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(28,Runtime),ebqn_array:get(30,Runtime),ebqn_array:get(35,Runtime),ebqn_array:get(49,Runtime),ebqn_array:get(54,Runtime),ebqn_array:get(55,Runtime),1,4,2,char("a")],[[0,1,0,0]]]), %(1⊸⌽≡⊏⊸«)'a'+⥊⟜(↕×´)4‿2
    1 = ebqn:run([[0,12,0,13,3,2,0,9,0,1,7,0,6,9,0,10,0,4,8,16,0,0,0,14,17,0,3,0,7,0,5,19,0,2,0,8,19,0,11,17,25],[ebqn_array:get(0,Runtime),ebqn_array:get(2,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(21,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(25,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(29,Runtime),ebqn_array:get(30,Runtime),ebqn_array:get(49,Runtime),ebqn_array:get(55,Runtime),-2,4,2,char("a")],[[0,1,0,0]]]), %¯2(⌽≡↑»⊢)'a'+⥊⟜(↕×´)4‿2
    1 = ebqn:run([[0,9,0,3,16,0,5,0,8,0,6,0,1,8,0,6,0,4,8,7,0,0,0,2,19,0,7,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(25,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(29,Runtime),ebqn_array:get(44,Runtime),ebqn_array:get(55,Runtime),6,0,4],[[0,1,0,0]]]), %6(↑≡»⟜(⥊⟜0)˜)↕4
    1 = ebqn:run([[0,7,0,1,0,5,0,6,3,2,17,0,0,0,4,0,3,0,2,7,8,16,25],[ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(28,Runtime),ebqn_array:get(44,Runtime),ebqn_array:get(54,Runtime),2,3,str("abcdef")],[[0,1,0,0]]]), %«˜⊸≡2‿3⥊"abcdef"
    1 = ebqn:run([[0,8,0,3,16,0,7,0,5,0,0,8,0,1,0,6,19,0,2,0,4,19,16,25],[ebqn_array:get(1,Runtime),ebqn_array:get(7,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(29,Runtime),ebqn_array:get(55,Runtime),0,1,6],[[0,1,0,0]]]), %(»≡0⌈-⟜1)↕6
    1 = ebqn:run([[0,6,0,1,16,0,3,0,4,0,5,8,0,0,0,2,19,16,25],[ebqn_array:get(18,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(28,Runtime),ebqn_array:get(30,Runtime),ebqn_array:get(54,Runtime),1,6],[[0,1,0,0]]]), %(«≡1⊸⌽)↕6
    1 = ebqn:run([[0,11,0,10,3,2,0,7,0,1,7,0,5,9,0,8,0,4,8,16,0,10,0,8,0,0,8,0,2,0,9,19,0,3,0,6,19,16,25],[ebqn_array:get(1,Runtime),ebqn_array:get(2,Runtime),ebqn_array:get(7,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(29,Runtime),ebqn_array:get(49,Runtime),ebqn_array:get(55,Runtime),0,2,5],[[0,1,0,0]]]), %(»≡0⌈-⟜2)⥊⟜(↕×´)5‿2
    1 = ebqn:run([[0,11,0,12,3,2,0,7,0,0,7,0,4,9,0,9,0,3,8,16,0,0,0,8,0,1,0,8,0,10,8,8,0,6,0,10,19,0,2,0,5,19,16,25],[ebqn_array:get(2,Runtime),ebqn_array:get(12,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(28,Runtime),ebqn_array:get(30,Runtime),ebqn_array:get(49,Runtime),ebqn_array:get(54,Runtime),ebqn_array:get(55,Runtime),1,5,2],[[0,1,0,0]]]), %(«≡1⌽1⊸<⊸×)⥊⟜(↕×´)5‿2
    ok = try ebqn:run([[0,1,0,0,16,25],[ebqn_array:get(30,Runtime),char("a")],[[0,1,0,0]]]) % ⌽'a'
        catch _ -> ok
    end,
    ok = try ebqn:run([[0,2,0,0,16,0,1,16,25],[ebqn_array:get(12,Runtime),ebqn_array:get(30,Runtime),inf],[[0,1,0,0]]]) % ⌽<∞
        catch _ -> ok
    end,
    1 = ebqn:run([[3,0,0,1,0,2,0,0,8,16,25],[ebqn_array:get(18,Runtime),ebqn_array:get(30,Runtime),ebqn_array:get(55,Runtime)],[[0,1,0,0]]]), %≡⟜⌽⟨⟩
    1 = ebqn:run([[0,3,0,1,0,2,0,0,8,16,25],[ebqn_array:get(18,Runtime),ebqn_array:get(30,Runtime),ebqn_array:get(55,Runtime),str("a")],[[0,1,0,0]]]), %≡⟜⌽"a"
    1 = ebqn:run([[0,4,0,1,0,2,0,0,8,0,3,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(30,Runtime),ebqn_array:get(55,Runtime),str("ba"),str("ab")],[[0,1,0,0]]]), %"ba"≡⟜⌽"ab"
    1 = ebqn:run([[0,13,0,14,0,15,3,3,0,6,16,0,3,0,12,0,11,0,3,0,5,0,12,19,0,4,0,8,0,10,0,0,8,19,8,0,1,0,9,0,0,7,0,12,19,19,0,2,0,7,19,16,25],[ebqn_array:get(1,Runtime),ebqn_array:get(14,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(21,Runtime),ebqn_array:get(23,Runtime),ebqn_array:get(26,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(30,Runtime),ebqn_array:get(36,Runtime),ebqn_array:get(44,Runtime),ebqn_array:get(53,Runtime),ebqn_array:get(60,Runtime),1,3,2,4],[[0,1,0,0]]]), %(⌽≡(1-˜≠)(-○⊑∾1↓⊢)⚇1⊢)↕3‿2‿4
    1 = ebqn:run([[0,4,0,1,16,0,1,16,0,2,0,3,0,0,8,16,25],[ebqn_array:get(18,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(30,Runtime),ebqn_array:get(55,Runtime),3],[[0,1,0,0]]]), %≡⟜⌽↕↕3
    ok = try ebqn:run([[0,2,0,0,0,1,17,25],[ebqn_array:get(30,Runtime),2,char("a")],[[0,1,0,0]]]) % 2⌽'a'
        catch _ -> ok
    end,
    ok = try ebqn:run([[0,4,0,0,16,0,1,0,2,0,3,3,2,17,25],[ebqn_array:get(27,Runtime),ebqn_array:get(30,Runtime),1,2,4],[[0,1,0,0]]]) % 1‿2⌽↕4
        catch _ -> ok
    end,
    ok = try ebqn:run([[0,7,0,1,0,4,0,3,0,0,7,8,0,6,17,0,2,0,2,0,5,3,2,17,25],[ebqn_array:get(0,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(30,Runtime),ebqn_array:get(47,Runtime),ebqn_array:get(53,Runtime),2,3,4],[[0,1,0,0]]]) % ⌽‿2⌽3+⌜○↕4
        catch _ -> ok
    end,
    ok = try ebqn:run([[0,4,0,1,16,0,2,0,3,0,0,16,0,0,16,17,25],[ebqn_array:get(12,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(30,Runtime),3,4],[[0,1,0,0]]]) % (<<3)⌽↕4
        catch _ -> ok
    end,
    1 = ebqn:run([[0,14,0,9,0,3,16,0,8,0,4,16,0,10,0,11,3,2,0,4,16,0,14,0,3,0,12,0,10,0,13,3,3,17,3,5,0,6,0,2,0,1,0,5,19,7,0,8,17,0,7,0,0,7,16,25],[ebqn_array:get(10,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(21,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(30,Runtime),ebqn_array:get(46,Runtime),ebqn_array:get(49,Runtime),5,inf,0,4,2,3,str("")],[[0,1,0,0]]]), %∧´5(⌽≡⊢)¨⟨"",⥊∞,↕5,↕0‿4,2‿0‿3⥊""⟩
    1 = ebqn:run([[0,10,0,11,0,12,0,13,0,8,0,14,0,15,3,7,0,1,0,9,17,0,0,0,8,17,0,5,0,17,0,7,0,4,8,0,3,0,16,19,7,16,0,6,0,2,7,16,25],[ebqn_array:get(0,Runtime),ebqn_array:get(2,Runtime),ebqn_array:get(10,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(30,Runtime),ebqn_array:get(46,Runtime),ebqn_array:get(49,Runtime),ebqn_array:get(55,Runtime),1,5,-10,-2,-1,0,6,61,str("bcdea"),str("abcde")],[[0,1,0,0]]]), %∧´("bcdea"≡⌽⟜"abcde")¨1+5×¯10‿¯2‿¯1‿0‿1‿6‿61
    1 = ebqn:run([[0,17,0,2,0,12,0,14,0,16,3,3,17,0,13,0,15,3,2,0,9,0,5,0,8,0,3,0,8,0,14,8,8,0,1,0,4,0,7,0,5,8,19,8,0,10,0,11,0,12,3,2,0,13,0,10,0,14,3,3,3,3,17,0,6,0,0,7,16,25],[ebqn_array:get(10,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(25,Runtime),ebqn_array:get(30,Runtime),ebqn_array:get(36,Runtime),ebqn_array:get(49,Runtime),ebqn_array:get(52,Runtime),ebqn_array:get(54,Runtime),ebqn_array:get(60,Runtime),1,0,2,-1,3,inf,5,str("abcdef")],[[0,1,0,0]]]), %∧´⟨1,0‿2,¯1‿1‿3⟩(⊑∘⌽≡(3⊸↑)⊸⊑)⚇¯1‿∞ 2‿3‿5⥊"abcdef"
    1 = ebqn:run([[0,4,0,0,0,1,0,2,0,3,3,0,8,19,16,25],[ebqn_array:get(12,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(30,Runtime),ebqn_array:get(54,Runtime),char("a")],[[0,1,0,0]]]), %(⟨⟩⊸⌽≡<)'a'
    ok = try ebqn:run([[0,1,0,0,16,25],[ebqn_array:get(32,Runtime),2],[[0,1,0,0]]]) % /2
        catch _ -> ok
    end,
    ok = try ebqn:run([[0,1,0,2,0,3,3,3,0,0,16,25],[ebqn_array:get(32,Runtime),1,-1,0],[[0,1,0,0]]]) % /1‿¯1‿0
        catch _ -> ok
    end,
    ok = try ebqn:run([[0,5,0,1,16,0,3,0,4,0,0,7,7,16,0,2,16,25],[ebqn_array:get(15,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(32,Runtime),ebqn_array:get(44,Runtime),ebqn_array:get(47,Runtime),2],[[0,1,0,0]]]) % /=⌜˜↕2
        catch _ -> ok
    end,
    1 = ebqn:run([[0,4,0,2,0,2,0,2,0,4,0,2,3,6,0,1,16,0,0,0,2,0,3,3,2,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(32,Runtime),0,4,1],[[0,1,0,0]]]), %0‿4≡/1‿0‿0‿0‿1‿0
    1 = ebqn:run([[0,4,0,3,0,2,3,3,0,1,16,0,0,0,2,0,2,0,3,3,3,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(32,Runtime),1,2,0],[[0,1,0,0]]]), %1‿1‿2≡/0‿2‿1
    1 = ebqn:run([[3,0,0,1,0,2,0,0,8,16,25],[ebqn_array:get(18,Runtime),ebqn_array:get(32,Runtime),ebqn_array:get(55,Runtime)],[[0,1,0,0]]]), %≡⟜/⟨⟩
    ok = try ebqn:run([[0,2,0,0,16,0,1,0,2,17,25],[ebqn_array:get(12,Runtime),ebqn_array:get(32,Runtime),2],[[0,1,0,0]]]) % 2/<2
        catch _ -> ok
    end,
    ok = try ebqn:run([[0,3,0,0,0,1,0,2,3,2,17,25],[ebqn_array:get(32,Runtime),0,1,str("abc")],[[0,1,0,0]]]) % 0‿1/"abc"
        catch _ -> ok
    end,
    ok = try ebqn:run([[0,3,0,1,0,2,0,0,16,0,2,0,0,16,3,2,17,25],[ebqn_array:get(27,Runtime),ebqn_array:get(32,Runtime),3,str("abc")],[[0,1,0,0]]]) % ⟨↕3,↕3⟩/"abc"
        catch _ -> ok
    end,
    ok = try ebqn:run([[0,5,0,0,0,2,0,1,8,0,3,0,4,3,2,17,25],[ebqn_array:get(24,Runtime),ebqn_array:get(32,Runtime),ebqn_array:get(53,Runtime),1,2,str("ab")],[[0,1,0,0]]]) % 1‿2/○≍"ab"
        catch _ -> ok
    end,
    ok = try ebqn:run([[0,3,0,0,0,1,0,2,3,2,17,25],[ebqn_array:get(32,Runtime),-1,2,str("ab")],[[0,1,0,0]]]) % ¯1‿2/"ab"
        catch _ -> ok
    end,
    1 = ebqn:run([[0,4,0,1,0,2,17,0,0,0,3,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(32,Runtime),2,str("aabbcc"),str("abc")],[[0,1,0,0]]]), %"aabbcc"≡2/"abc"
    1 = ebqn:run([[0,3,0,1,0,2,17,0,0,0,3,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(32,Runtime),4,str("")],[[0,1,0,0]]]), %""≡4/""
    1 = ebqn:run([[0,8,0,1,0,7,0,4,3,2,17,0,2,0,5,0,6,3,2,3,0,3,2,17,0,0,0,8,0,1,0,3,0,4,3,2,17,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(32,Runtime),6,0,5,1,2,str("")],[[0,1,0,0]]]), %(6‿0⥊"")≡⟨5,1⟩‿⟨⟩/2‿0⥊""
    1 = ebqn:run([[0,3,0,4,0,5,3,3,0,2,0,1,7,16,0,0,0,3,0,3,0,3,0,4,0,4,0,5,3,6,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(32,Runtime),ebqn_array:get(44,Runtime),3,2,1],[[0,1,0,0]]]), %3‿3‿3‿2‿2‿1≡/˜3‿2‿1
    1 = ebqn:run([[0,4,0,5,0,6,3,3,0,2,0,3,0,0,8,16,0,1,0,4,0,4,0,4,0,5,0,5,0,6,3,6,17,25],[ebqn_array:get(12,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(32,Runtime),ebqn_array:get(54,Runtime),3,2,1],[[0,1,0,0]]]), %3‿3‿3‿2‿2‿1≡<⊸/3‿2‿1
    1 = ebqn:run([[0,7,0,8,3,2,0,3,0,4,0,5,0,3,7,19,16,0,0,0,6,0,7,0,7,3,3,0,5,0,1,7,0,6,17,0,2,16,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(23,Runtime),ebqn_array:get(24,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(32,Runtime),ebqn_array:get(46,Runtime),1,2,3],[[0,1,0,0]]]), %(≍1∾¨1‿2‿2)≡(↕¨/↕)2‿3
    1 = ebqn:run([[0,4,0,0,0,1,0,2,0,3,3,0,8,19,16,25],[ebqn_array:get(12,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(32,Runtime),ebqn_array:get(54,Runtime),char("a")],[[0,1,0,0]]]), %(⟨⟩⊸/≡<)'a'
    1 = ebqn:run([[0,4,0,2,16,0,1,0,0,0,3,19,3,0,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(21,Runtime),ebqn_array:get(24,Runtime),ebqn_array:get(32,Runtime),str("ab")],[[0,1,0,0]]]), %⟨⟩(/≡⊢)≍"ab"
    1 = ebqn:run([[0,14,0,6,16,0,5,0,13,0,11,3,2,17,0,0,0,15,17,0,4,0,7,0,3,0,10,0,9,0,8,0,5,7,7,8,19,0,2,0,7,19,0,11,0,12,0,1,16,3,2,17,25],[ebqn_array:get(0,Runtime),ebqn_array:get(12,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(19,Runtime),ebqn_array:get(21,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(32,Runtime),ebqn_array:get(44,Runtime),ebqn_array:get(46,Runtime),ebqn_array:get(55,Runtime),2,3,4,8,char("a")],[[0,1,0,0]]]), %⟨2,<3⟩(/≡⥊˜¨⟜≢/⊢)'a'+4‿2⥊↕8
    ok.


layer6(#a{r=Runtime}) ->
    ok = try ebqn:run([[0,1,0,0,16,25],[ebqn_array:get(23,Runtime),char("c")],[[0,1,0,0]]]) % ∾'c'
        catch _ -> ok
    end,
    1 = ebqn:run([[0,5,0,3,0,1,7,0,2,9,0,4,0,0,8,16,25],[ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(23,Runtime),ebqn_array:get(46,Runtime),ebqn_array:get(55,Runtime),str("abc")],[[0,1,0,0]]]), %≡⟜(∾⥊¨)"abc"
    1 = ebqn:run([[0,3,0,4,0,5,3,3,0,1,0,0,0,2,0,1,7,19,16,25],[ebqn_array:get(18,Runtime),ebqn_array:get(23,Runtime),ebqn_array:get(49,Runtime),str("ab"),str("cde"),str("")],[[0,1,0,0]]]), %(∾´≡∾)"ab"‿"cde"‿""
    ok = try ebqn:run([[0,1,0,0,16,25],[ebqn_array:get(23,Runtime),str("abc")],[[0,1,0,0]]]) % ∾"abc"
        catch _ -> ok
    end,
    ok = try ebqn:run([[0,2,0,3,0,4,3,3,0,1,16,0,0,16,25],[ebqn_array:get(23,Runtime),ebqn_array:get(24,Runtime),str("ab"),str("cde"),str("")],[[0,1,0,0]]]) % ∾≍"ab"‿"cde"‿""
        catch _ -> ok
    end,
    ok = try ebqn:run([[0,2,0,1,0,3,3,3,0,0,16,25],[ebqn_array:get(23,Runtime),char("c"),str("ab"),str("")],[[0,1,0,0]]]) % ∾"ab"‿'c'‿""
        catch _ -> ok
    end,
    1 = ebqn:run([[0,11,0,8,16,0,0,0,9,17,0,7,0,6,0,2,19,0,1,0,4,19,16,0,5,16,0,3,0,9,0,10,0,11,0,12,0,13,0,14,3,6,17,25],[ebqn_array:get(0,Runtime),ebqn_array:get(2,Runtime),ebqn_array:get(14,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(21,Runtime),ebqn_array:get(23,Runtime),ebqn_array:get(25,Runtime),ebqn_array:get(26,Runtime),ebqn_array:get(27,Runtime),1,2,3,4,6,9],[[0,1,0,0]]]), %1‿2‿3‿4‿6‿9≡∾(⊢×≠↑↓)1+↕3
    1 = ebqn:run([[0,5,0,1,16,0,1,0,3,9,0,4,0,2,8,0,0,0,3,0,4,0,2,8,19,16,25],[ebqn_array:get(10,Runtime),ebqn_array:get(12,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(23,Runtime),ebqn_array:get(55,Runtime),4],[[0,1,0,0]]]), %(≡⟜∾∧≡⟜(∾<))<4
    1 = ebqn:run([[0,8,0,9,0,7,3,3,3,0,0,10,0,2,16,3,3,0,3,0,5,0,4,0,0,7,8,0,1,0,4,0,4,0,0,7,7,0,3,9,19,0,6,0,7,3,2,0,8,0,2,16,3,2,17,25],[ebqn_array:get(4,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(23,Runtime),ebqn_array:get(47,Runtime),ebqn_array:get(53,Runtime),1,4,2,3,5],[[0,1,0,0]]]), %⟨1‿4,⥊2⟩((∾⋆⌜⌜)≡⋆⌜○∾)⟨2‿3‿4,⟨⟩,⥊5⟩
    ok = try ebqn:run([[0,5,0,2,0,0,7,0,3,0,4,3,2,0,4,0,4,0,4,3,2,3,3,17,0,1,16,25],[ebqn_array:get(22,Runtime),ebqn_array:get(23,Runtime),ebqn_array:get(46,Runtime),2,3,0],[[0,1,0,0]]]) % ∾⟨2‿3,3,3‿3⟩⥊¨0
        catch _ -> ok
    end,
    ok = try ebqn:run([[0,6,0,2,0,0,7,0,3,0,4,3,2,0,5,0,4,3,2,0,3,0,3,3,2,3,3,17,0,1,16,25],[ebqn_array:get(22,Runtime),ebqn_array:get(23,Runtime),ebqn_array:get(46,Runtime),2,3,1,0],[[0,1,0,0]]]) % ∾⟨2‿3,1‿3,2‿2⟩⥊¨0
        catch _ -> ok
    end,
    1 = ebqn:run([[0,2,0,1,0,4,17,0,0,0,3,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(23,Runtime),char("d"),str("abcd"),str("abc")],[[0,1,0,0]]]), %"abcd"≡"abc"∾'d'
    1 = ebqn:run([[0,3,0,0,16,0,2,0,5,17,0,1,0,4,17,25],[ebqn_array:get(12,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(23,Runtime),char("d"),str("abcd"),str("abc")],[[0,1,0,0]]]), %"abcd"≡"abc"∾<'d'
    1 = ebqn:run([[0,5,0,2,16,0,3,0,1,7,0,5,17,0,1,0,5,0,5,3,2,0,2,16,17,0,0,0,4,0,5,3,2,0,2,16,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(23,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(46,Runtime),4,3],[[0,1,0,0]]]), %(↕4‿3)≡(↕3‿3)∾3∾¨↕3
    1 = ebqn:run([[0,15,0,3,0,13,0,14,3,2,17,0,8,0,5,7,0,3,0,11,0,2,0,10,0,6,0,4,0,7,0,10,0,9,0,0,7,8,19,0,11,0,12,8,8,8,9,0,1,0,8,0,4,7,19,16,25],[ebqn_array:get(2,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(19,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(23,Runtime),ebqn_array:get(24,Runtime),ebqn_array:get(25,Runtime),ebqn_array:get(26,Runtime),ebqn_array:get(44,Runtime),ebqn_array:get(49,Runtime),ebqn_array:get(52,Runtime),ebqn_array:get(54,Runtime),-1,2,3,str("abcdef")],[[0,1,0,0]]]), %(∾˜≡·¯1⊸(×´∘↓∾↑)∘≢⊸⥊≍˜)2‿3⥊"abcdef"
    1 = ebqn:run([[0,11,0,4,16,0,0,16,0,5,0,2,7,0,7,0,8,0,9,3,3,0,10,0,8,0,9,3,3,3,2,17,0,3,0,1,0,6,0,3,7,19,16,25],[ebqn_array:get(12,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(23,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(46,Runtime),ebqn_array:get(49,Runtime),3,2,1,0,6],[[0,1,0,0]]]), %(∾´≡∾)⟨3‿2‿1,0‿2‿1⟩⥊¨<↕6
    ok = try ebqn:run([[0,3,0,1,16,0,0,0,2,17,25],[ebqn_array:get(23,Runtime),ebqn_array:get(24,Runtime),char("a"),str("abc")],[[0,1,0,0]]]) % 'a'∾≍"abc"
        catch _ -> ok
    end,
    ok = try ebqn:run([[0,4,0,1,0,2,0,0,8,0,3,17,25],[ebqn_array:get(23,Runtime),ebqn_array:get(24,Runtime),ebqn_array:get(53,Runtime),str("ab"),str("cde")],[[0,1,0,0]]]) % "ab"∾○≍"cde"
        catch _ -> ok
    end,
    ok = try ebqn:run([[0,3,0,2,16,0,1,0,5,0,2,16,0,0,0,3,0,4,3,2,17,17,25],[ebqn_array:get(22,Runtime),ebqn_array:get(23,Runtime),ebqn_array:get(27,Runtime),2,3,6],[[0,1,0,0]]]) % (2‿3⥊↕6)∾↕2
        catch _ -> ok
    end,
    1 = ebqn:run([[0,3,0,5,0,5,0,4,3,4,0,2,16,0,0,0,3,0,4,3,2,0,5,0,1,16,0,6,0,1,16,3,3,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(41,Runtime),1,2,0,3],[[0,1,0,0]]]), %⟨1‿2,⥊0,⥊3⟩≡⊔1‿0‿0‿2
    1 = ebqn:run([[0,4,0,1,0,3,17,0,2,16,0,0,3,0,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(41,Runtime),5,-1],[[0,1,0,0]]]), %⟨⟩≡⊔5⥊¯1
    1 = ebqn:run([[3,0,0,1,0,2,0,0,8,16,25],[ebqn_array:get(18,Runtime),ebqn_array:get(41,Runtime),ebqn_array:get(55,Runtime)],[[0,1,0,0]]]), %≡⟜⊔⟨⟩
    ok = try ebqn:run([[0,1,0,0,16,25],[ebqn_array:get(41,Runtime),3],[[0,1,0,0]]]) % ⊔3
        catch _ -> ok
    end,
    ok = try ebqn:run([[0,2,0,0,16,0,1,16,25],[ebqn_array:get(12,Runtime),ebqn_array:get(41,Runtime),3],[[0,1,0,0]]]) % ⊔<3
        catch _ -> ok
    end,
    ok = try ebqn:run([[0,3,0,1,16,0,0,16,0,2,16,25],[ebqn_array:get(24,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(41,Runtime),3],[[0,1,0,0]]]) % ⊔≍↕3
        catch _ -> ok
    end,
    ok = try ebqn:run([[0,1,0,2,0,3,3,3,0,0,16,25],[ebqn_array:get(41,Runtime),1.5,0,2],[[0,1,0,0]]]) % ⊔1.5‿0‿2
        catch _ -> ok
    end,
    ok = try ebqn:run([[0,1,0,2,3,2,0,0,16,25],[ebqn_array:get(41,Runtime),1,-2],[[0,1,0,0]]]) % ⊔1‿¯2
        catch _ -> ok
    end,
    1 = ebqn:run([[0,6,0,7,0,7,0,8,3,4,3,1,0,2,0,5,0,3,0,5,0,4,0,4,0,1,7,7,8,8,0,0,0,3,19,16,25],[ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(36,Runtime),ebqn_array:get(41,Runtime),ebqn_array:get(46,Runtime),ebqn_array:get(52,Runtime),1,0,2],[[0,1,0,0]]]), %(⊔≡⥊¨¨∘⊔∘⊑)⟨1‿0‿0‿2⟩
    1 = ebqn:run([[0,9,0,11,0,12,3,3,0,12,0,11,3,2,3,2,0,5,16,0,1,0,10,0,9,3,2,0,3,16,0,4,16,0,6,0,0,0,7,0,9,0,8,0,2,8,8,7,16,17,25],[ebqn_array:get(12,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(24,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(30,Runtime),ebqn_array:get(41,Runtime),ebqn_array:get(46,Runtime),ebqn_array:get(52,Runtime),ebqn_array:get(61,Runtime),2,3,1,0],[[0,1,0,0]]]), %(≍⍟2∘<¨⌽↕3‿2)≡⊔⟨2‿1‿0,0‿1⟩
    1 = ebqn:run([[3,0,3,0,3,2,0,2,16,0,0,0,3,0,3,3,2,0,1,16,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(41,Runtime),0],[[0,1,0,0]]]), %(↕0‿0)≡⊔⟨⟩‿⟨⟩
    1 = ebqn:run([[0,14,0,15,0,14,0,14,3,4,0,15,0,14,0,14,3,3,3,2,0,7,0,1,0,11,0,14,8,0,10,0,5,8,7,0,9,0,8,0,3,7,7,9,0,0,0,10,0,13,0,12,0,4,8,8,9,0,2,0,6,19,16,25],[ebqn_array:get(12,Runtime),ebqn_array:get(15,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(23,Runtime),ebqn_array:get(24,Runtime),ebqn_array:get(32,Runtime),ebqn_array:get(41,Runtime),ebqn_array:get(46,Runtime),ebqn_array:get(47,Runtime),ebqn_array:get(49,Runtime),ebqn_array:get(52,Runtime),ebqn_array:get(54,Runtime),ebqn_array:get(61,Runtime),2,0,-1],[[0,1,0,0]]]), %(⊔≡·≍⍟2∘<·∾⌜´/∘(0⊸=)¨)⟨0‿¯1‿0‿0,¯1‿0‿0⟩
    1 = ebqn:run([[0,12,0,11,0,10,3,2,3,2,0,5,16,0,1,0,11,0,10,3,2,0,6,0,2,0,8,0,0,0,8,0,12,0,9,0,3,8,8,8,7,16,0,7,0,4,7,0,10,0,10,0,11,3,3,17,17,25],[ebqn_array:get(12,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(24,Runtime),ebqn_array:get(25,Runtime),ebqn_array:get(41,Runtime),ebqn_array:get(46,Runtime),ebqn_array:get(47,Runtime),ebqn_array:get(52,Runtime),ebqn_array:get(61,Runtime),0,1,2],[[0,1,0,0]]]), %(0‿0‿1↑⌜≍⍟2∘<∘⥊¨1‿0)≡⊔⟨2,1‿0⟩
    1 = ebqn:run([[0,14,0,13,0,12,3,2,3,2,0,7,0,5,0,10,0,12,0,12,3,2,8,7,16,0,6,16,0,1,0,13,0,12,3,2,0,7,0,2,0,10,0,12,0,12,0,12,3,3,8,0,0,9,0,9,0,14,0,11,0,3,8,8,7,16,0,8,0,4,7,0,12,0,12,0,13,3,3,17,17,25],[ebqn_array:get(12,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(23,Runtime),ebqn_array:get(24,Runtime),ebqn_array:get(25,Runtime),ebqn_array:get(26,Runtime),ebqn_array:get(41,Runtime),ebqn_array:get(46,Runtime),ebqn_array:get(47,Runtime),ebqn_array:get(52,Runtime),ebqn_array:get(54,Runtime),ebqn_array:get(61,Runtime),0,1,2],[[0,1,0,0]]]), %(0‿0‿1↑⌜≍⍟2∘(<0‿0‿0⊸∾)¨1‿0)≡⊔0‿0⊸↓¨⟨2,1‿0⟩
    1 = ebqn:run([[0,13,0,6,0,9,0,5,8,0,3,0,0,0,8,0,4,8,0,7,0,1,7,19,9,0,2,0,0,0,8,0,4,8,19,0,10,0,11,0,12,3,3,17,25],[ebqn_array:get(12,Runtime),ebqn_array:get(14,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(23,Runtime),ebqn_array:get(24,Runtime),ebqn_array:get(32,Runtime),ebqn_array:get(41,Runtime),ebqn_array:get(46,Runtime),ebqn_array:get(53,Runtime),ebqn_array:get(54,Runtime),4,3,2,str("abcdefghi")],[[0,1,0,0]]]), %4‿3‿2(≍○<≡·(≠¨≍○<∾)/⊸⊔)"abcdefghi"
    1 = ebqn:run([[0,5,0,2,0,4,0,1,0,3,17,17,0,0,3,0,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(41,Runtime),3,-1,str("abc")],[[0,1,0,0]]]), %⟨⟩≡(3⥊¯1)⊔"abc"
    ok = try ebqn:run([[0,4,0,2,0,3,3,3,0,1,0,0,7,16,25],[ebqn_array:get(41,Runtime),ebqn_array:get(44,Runtime),1,0,char("a")],[[0,1,0,0]]]) % ⊔˜'a'‿1‿0
        catch _ -> ok
    end,
    ok = try ebqn:run([[0,4,0,0,0,2,0,1,8,0,3,17,25],[ebqn_array:get(27,Runtime),ebqn_array:get(41,Runtime),ebqn_array:get(53,Runtime),4,2],[[0,1,0,0]]]) % 4⊔○↕2
        catch _ -> ok
    end,
    1 = ebqn:run([[0,19,0,6,16,0,3,0,15,0,16,0,13,3,3,17,0,7,0,16,0,15,3,2,0,17,0,18,0,17,3,3,3,2,17,0,5,0,15,17,0,2,0,13,0,6,16,0,9,0,0,7,0,14,0,13,3,2,17,0,12,0,11,0,3,0,10,0,1,8,8,0,12,0,12,0,13,3,3,17,0,8,0,4,7,16,17,25],[ebqn_array:get(0,Runtime),ebqn_array:get(12,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(24,Runtime),ebqn_array:get(26,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(41,Runtime),ebqn_array:get(45,Runtime),ebqn_array:get(47,Runtime),ebqn_array:get(52,Runtime),ebqn_array:get(59,Runtime),1,4,16,2,3,-1,0,24],[[0,1,0,0]]]), %(≍˘1‿1‿4<∘⥊⎉1 16‿4+⌜↕4)≡2↓⟨3‿2,¯1‿0‿¯1⟩⊔2‿3‿4⥊↕24
    1 = ebqn:run([[0,9,0,10,0,10,0,11,0,8,3,5,0,0,0,2,9,0,6,0,3,0,4,0,1,0,5,0,8,0,7,0,2,8,8,8,8,16,25],[ebqn_array:get(12,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(41,Runtime),ebqn_array:get(53,Runtime),ebqn_array:get(54,Runtime),ebqn_array:get(55,Runtime),ebqn_array:get(60,Runtime),0,1,2,-1],[[0,1,0,0]]]), %⥊⚇0⊸≡○⊔⟜(⥊<)1‿2‿2‿¯1‿0
    1 = ebqn:run([[0,12,0,4,16,0,2,0,9,0,10,0,11,3,3,17,0,0,0,8,0,5,0,8,0,1,0,7,0,6,0,4,7,8,8,0,3,9,8,16,25],[ebqn_array:get(18,Runtime),ebqn_array:get(19,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(23,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(41,Runtime),ebqn_array:get(46,Runtime),ebqn_array:get(52,Runtime),ebqn_array:get(54,Runtime),3,2,4,24],[[0,1,0,0]]]), %(∾↕¨∘≢⊸⊔)⊸≡ 3‿2‿4⥊↕24
    1 = ebqn:run([[0,10,0,3,0,9,17,0,2,0,5,0,4,8,0,1,0,4,19,0,6,0,8,0,7,0,0,8,8,16,25],[ebqn_array:get(1,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(24,Runtime),ebqn_array:get(41,Runtime),ebqn_array:get(53,Runtime),ebqn_array:get(54,Runtime),ebqn_array:get(55,Runtime),char("a"),str("acc"),str("bac")],[[0,1,0,0]]]), %-⟜'a'⊸(⊔≡⊔○⥊)"acc"≍"bac"
    1 = ebqn:run([[0,8,0,1,16,0,4,0,5,17,0,0,0,7,0,6,3,2,0,2,16,0,8,0,1,0,6,0,6,3,2,17,3,2,0,3,0,5,0,6,3,2,17,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(32,Runtime),ebqn_array:get(41,Runtime),2,1,0,3],[[0,1,0,0]]]), %(2‿1/⟨↕0‿1,1‿1⥊3⟩)≡2⊔⥊3
    1 = ebqn:run([[0,11,0,10,0,12,3,3,0,13,0,1,16,0,9,0,6,0,8,0,7,0,1,7,8,8,0,7,0,4,7,9,0,3,0,0,0,8,0,10,8,0,5,9,0,2,0,1,19,19,16,25],[ebqn_array:get(0,Runtime),ebqn_array:get(12,Runtime),ebqn_array:get(15,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(19,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(41,Runtime),ebqn_array:get(46,Runtime),ebqn_array:get(54,Runtime),ebqn_array:get(55,Runtime),1,2,3,char("\0")],[[0,1,0,0]]]), %((<=·↕1⊸+)≡·≢¨<¨⊸⊔⟜(<@))2‿1‿3
    ok = try ebqn:run([[0,5,0,0,0,3,0,4,3,2,17,0,1,0,2,0,3,3,2,0,4,0,2,3,2,3,2,17,25],[ebqn_array:get(22,Runtime),ebqn_array:get(41,Runtime),1,2,3,0],[[0,1,0,0]]]) % ⟨1‿2,3‿1⟩⊔2‿3⥊0
        catch _ -> ok
    end,
    ok = try ebqn:run([[0,9,0,0,0,3,0,4,3,2,17,0,1,0,2,0,3,3,2,0,4,0,5,0,6,3,3,0,7,0,8,3,2,3,3,17,25],[ebqn_array:get(22,Runtime),ebqn_array:get(41,Runtime),1,2,3,4,5,6,7,0],[[0,1,0,0]]]) % ⟨1‿2,3‿4‿5,6‿7⟩⊔2‿3⥊0
        catch _ -> ok
    end,
    ok = try ebqn:run([[0,5,0,1,16,0,3,0,0,7,16,0,2,0,4,0,0,8,16,25],[ebqn_array:get(24,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(41,Runtime),ebqn_array:get(45,Runtime),ebqn_array:get(54,Runtime),3],[[0,1,0,0]]]) % ≍⊸⊔≍˘↕3
        catch _ -> ok
    end,
    ok = try ebqn:run([[0,9,0,2,16,0,1,0,5,0,4,0,8,3,3,17,0,3,0,4,0,0,16,0,5,3,2,0,6,0,7,0,6,3,3,3,2,17,25],[ebqn_array:get(12,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(41,Runtime),3,2,-1,0,4,24],[[0,1,0,0]]]) % ⟨⟨<3,2⟩,¯1‿0‿¯1⟩⊔2‿3‿4⥊↕24
        catch _ -> ok
    end,
    1 = ebqn:run([[0,10,0,2,0,5,0,6,0,7,3,3,17,0,0,0,8,0,9,3,2,0,1,0,3,0,4,3,2,17,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(32,Runtime),ebqn_array:get(41,Runtime),1,3,0,-1,4,str("a"),str(""),str("ab")],[[0,1,0,0]]]), %(1‿3/⟨"a",""⟩)≡0‿¯1‿4⊔"ab"
    1 = ebqn:run([[0,11,0,3,0,8,0,7,0,8,0,9,3,3,3,2,17,0,0,0,10,0,4,0,1,0,6,0,2,0,5,0,1,8,8,7,0,7,0,7,0,8,3,3,17,0,1,16,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(24,Runtime),ebqn_array:get(32,Runtime),ebqn_array:get(41,Runtime),ebqn_array:get(46,Runtime),ebqn_array:get(52,Runtime),ebqn_array:get(55,Runtime),1,0,3,str("bac"),str("ab")],[[0,1,0,0]]]), %(≍1‿1‿0≍∘/⟜≍¨"bac")≡⟨0,1‿0‿3⟩⊔"ab"
    ok = try ebqn:run([[0,3,0,3,3,2,0,1,16,0,2,0,5,0,1,16,0,0,0,3,0,4,3,2,17,17,25],[ebqn_array:get(22,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(41,Runtime),2,3,4],[[0,1,0,0]]]) % (2‿3⥊↕4)⊔↕2‿2
        catch _ -> ok
    end,
    ok = try ebqn:run([[0,5,0,5,3,2,0,1,16,0,2,0,4,0,1,16,0,0,0,3,0,3,3,2,17,17,25],[ebqn_array:get(22,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(41,Runtime),3,4,2],[[0,1,0,0]]]) % (3‿3⥊↕4)⊔↕2‿2
        catch _ -> ok
    end,
    ok = try ebqn:run([[0,2,0,1,0,0,7,16,25],[ebqn_array:get(37,Runtime),ebqn_array:get(44,Runtime),char("a")],[[0,1,0,0]]]) % ⊐˜'a'
        catch _ -> ok
    end,
    ok = try ebqn:run([[0,3,0,1,0,2,0,0,8,16,25],[ebqn_array:get(35,Runtime),ebqn_array:get(37,Runtime),ebqn_array:get(54,Runtime),str("abc")],[[0,1,0,0]]]) % ⊏⊸⊐"abc"
        catch _ -> ok
    end,
    ok = try ebqn:run([[0,6,0,0,0,4,17,0,1,0,5,0,0,0,2,0,3,0,4,3,3,17,17,25],[ebqn_array:get(22,Runtime),ebqn_array:get(37,Runtime),3,2,4,0,1],[[0,1,0,0]]]) % (3‿2‿4⥊0)⊐4⥊1
        catch _ -> ok
    end,
    1 = ebqn:run([[0,6,0,1,0,5,17,0,0,0,2,0,3,0,4,3,3,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(37,Runtime),2,0,4,str("abcd"),str("cae")],[[0,1,0,0]]]), %2‿0‿4≡"abcd"⊐"cae"
    1 = ebqn:run([[0,4,0,1,0,3,17,0,0,0,2,3,1,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(37,Runtime),1,str("abcd"),str("b")],[[0,1,0,0]]]), %⟨1⟩≡"abcd"⊐"b"
    1 = ebqn:run([[0,7,0,2,0,4,0,6,8,0,5,0,3,8,16,0,1,0,6,0,0,16,17,25],[ebqn_array:get(12,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(35,Runtime),ebqn_array:get(37,Runtime),ebqn_array:get(54,Runtime),ebqn_array:get(55,Runtime),3,str("abcd")],[[0,1,0,0]]]), %(<3)≡⊐⟜(3⊸⊏)"abcd"
    1 = ebqn:run([[0,8,0,12,0,11,3,3,0,4,16,0,3,0,11,0,7,0,0,8,0,9,0,10,0,10,3,3,19,0,6,0,5,8,16,0,2,0,8,0,4,16,0,0,0,9,17,0,1,0,8,17,17,25],[ebqn_array:get(0,Runtime),ebqn_array:get(6,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(21,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(37,Runtime),ebqn_array:get(55,Runtime),ebqn_array:get(60,Runtime),5,3,0,1,2],[[0,1,0,0]]]), %(5⌊3+↕5)≡⊐⟜(3‿0‿0+⚇1⊢)↕5‿2‿1
    ok = try ebqn:run([[0,3,0,2,0,0,7,16,0,1,16,25],[ebqn_array:get(0,Runtime),ebqn_array:get(37,Runtime),ebqn_array:get(43,Runtime),char("\0")],[[0,1,0,0]]]) % ⊐+˙@
        catch _ -> ok
    end,
    1 = ebqn:run([[0,5,0,1,16,0,0,0,2,0,2,0,3,0,2,0,4,3,5,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(37,Runtime),0,1,2,str("ccacb")],[[0,1,0,0]]]), %0‿0‿1‿0‿2≡⊐"ccacb"
    1 = ebqn:run([[0,8,0,4,0,3,0,1,7,7,16,0,2,16,0,0,0,5,0,5,0,6,0,5,0,7,3,5,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(24,Runtime),ebqn_array:get(37,Runtime),ebqn_array:get(44,Runtime),ebqn_array:get(45,Runtime),0,1,2,str("ccacb")],[[0,1,0,0]]]), %0‿0‿1‿0‿2≡⊐≍˜˘"ccacb"
    1 = ebqn:run([[3,0,0,1,0,2,0,0,8,16,25],[ebqn_array:get(18,Runtime),ebqn_array:get(37,Runtime),ebqn_array:get(55,Runtime)],[[0,1,0,0]]]), %≡⟜⊐⟨⟩
    ok = try ebqn:run([[0,3,0,1,0,2,0,0,16,17,25],[ebqn_array:get(27,Runtime),ebqn_array:get(39,Runtime),5,1],[[0,1,0,0]]]) % (↕5)∊1
        catch _ -> ok
    end,
    ok = try ebqn:run([[0,5,0,1,16,0,3,0,0,7,16,0,2,0,4,17,25],[ebqn_array:get(24,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(39,Runtime),ebqn_array:get(45,Runtime),2,4],[[0,1,0,0]]]) % 2∊≍˘↕4
        catch _ -> ok
    end,
    1 = ebqn:run([[0,5,0,1,0,4,17,0,0,0,2,0,3,0,3,0,2,3,4,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(39,Runtime),1,0,str("acef"),str("adf")],[[0,1,0,0]]]), %1‿0‿0‿1≡"acef"∊"adf"
    1 = ebqn:run([[0,10,0,3,0,6,0,5,0,0,7,8,0,9,17,0,8,0,7,0,1,8,0,2,0,8,0,3,16,0,7,0,4,8,19,16,25],[ebqn_array:get(4,Runtime),ebqn_array:get(12,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(39,Runtime),ebqn_array:get(47,Runtime),ebqn_array:get(53,Runtime),ebqn_array:get(55,Runtime),2,3,5],[[0,1,0,0]]]), %(∊⟜(↕2)≡<⟜2)3⋆⌜○↕5
    1 = ebqn:run([[0,8,0,3,0,6,0,5,0,0,7,8,0,9,17,0,4,0,8,0,9,0,10,3,3,17,0,2,0,7,0,1,16,17,25],[ebqn_array:get(0,Runtime),ebqn_array:get(12,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(39,Runtime),ebqn_array:get(47,Runtime),ebqn_array:get(53,Runtime),1,3,4,5],[[0,1,0,0]]]), %(<1)≡3‿4‿5∊4+⌜○↕3
    ok = try ebqn:run([[0,2,0,0,16,0,1,16,25],[ebqn_array:get(12,Runtime),ebqn_array:get(39,Runtime),4],[[0,1,0,0]]]) % ∊<4
        catch _ -> ok
    end,
    1 = ebqn:run([[0,5,0,2,16,0,1,0,4,0,0,0,3,17,17,25],[ebqn_array:get(14,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(39,Runtime),char("0"),str("11010001"),str("abacbacd")],[[0,1,0,0]]]), %('0'≠"11010001")≡∊"abacbacd"
    1 = ebqn:run([[0,7,0,6,0,4,0,1,8,0,3,0,4,0,0,8,0,5,0,4,0,2,8,19,16,25],[ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(25,Runtime),ebqn_array:get(39,Runtime),ebqn_array:get(55,Runtime),1,inf,9],[[0,1,0,0]]]), %(↑⟜1≡⟜∊⥊⟜∞)9
    1 = ebqn:run([[0,7,0,2,0,4,0,3,8,0,0,0,6,0,5,0,1,8,19,16,25],[ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(39,Runtime),ebqn_array:get(52,Runtime),ebqn_array:get(55,Runtime),1,6],[[0,1,0,0]]]), %(⥊⟜1≡∊∘↕)6
    1 = ebqn:run([[3,0,0,1,0,2,0,0,8,16,25],[ebqn_array:get(18,Runtime),ebqn_array:get(39,Runtime),ebqn_array:get(55,Runtime)],[[0,1,0,0]]]), %≡⟜∊⟨⟩
    1 = ebqn:run([[0,7,0,4,0,3,0,1,7,7,0,6,0,2,0,5,0,0,8,8,16,25],[ebqn_array:get(18,Runtime),ebqn_array:get(24,Runtime),ebqn_array:get(39,Runtime),ebqn_array:get(44,Runtime),ebqn_array:get(45,Runtime),ebqn_array:get(53,Runtime),ebqn_array:get(55,Runtime),str("abcadbba")],[[0,1,0,0]]]), %≡○∊⟜(≍˜˘)"abcadbba"
    ok = try ebqn:run([[0,1,0,0,16,25],[ebqn_array:get(40,Runtime),char("a")],[[0,1,0,0]]]) % ⍷'a'
        catch _ -> ok
    end,
    1 = ebqn:run([[3,0,0,1,0,2,0,0,8,16,25],[ebqn_array:get(18,Runtime),ebqn_array:get(40,Runtime),ebqn_array:get(55,Runtime)],[[0,1,0,0]]]), %≡⟜⍷⟨⟩
    1 = ebqn:run([[0,3,0,1,16,0,0,0,2,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(40,Runtime),str("ba"),str("baa")],[[0,1,0,0]]]), %"ba"≡⍷"baa"
    ok = try ebqn:run([[0,3,0,1,0,2,0,0,8,16,25],[ebqn_array:get(24,Runtime),ebqn_array:get(40,Runtime),ebqn_array:get(54,Runtime),str("abc")],[[0,1,0,0]]]) % ≍⊸⍷"abc"
        catch _ -> ok
    end,
    1 = ebqn:run([[0,5,0,1,0,4,17,0,0,0,2,0,3,0,2,0,2,3,4,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(40,Runtime),0,1,str("abc"),str("aabcba")],[[0,1,0,0]]]), %0‿1‿0‿0≡"abc"⍷"aabcba"
    1 = ebqn:run([[0,11,0,3,16,0,1,0,10,0,10,3,2,17,0,4,0,8,0,9,3,2,0,2,0,6,0,7,3,2,17,17,0,0,0,5,0,5,3,2,0,2,0,5,0,6,3,2,17,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(24,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(40,Runtime),0,1,2,4,5,3,9],[[0,1,0,0]]]), %(0‿1≍0‿0)≡(1‿2≍4‿5)⍷3‿3⥊↕9
    1 = ebqn:run([[0,8,0,4,0,1,7,0,5,0,3,8,16,0,0,0,6,0,7,3,2,0,2,16,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(24,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(40,Runtime),ebqn_array:get(45,Runtime),ebqn_array:get(55,Runtime),3,0,str("abc")],[[0,1,0,0]]]), %(↕3‿0)≡⍷⟜(≍˘)"abc"
    1 = ebqn:run([[0,4,0,2,0,1,0,0,19,0,3,17,25],[ebqn_array:get(15,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(40,Runtime),char("a"),str("abc")],[[0,1,0,0]]]), %'a'(=≡⍷)"abc"
    1 = ebqn:run([[0,7,0,1,0,6,17,0,2,16,0,4,0,0,0,5,0,3,7,19,16,25],[ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(30,Runtime),ebqn_array:get(31,Runtime),ebqn_array:get(46,Runtime),2,3],[[0,1,0,0]]]), %(⌽¨≡⍉)↕2⥊3
    1 = ebqn:run([[0,3,0,0,0,1,0,2,19,16,25],[ebqn_array:get(12,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(31,Runtime),char("a")],[[0,1,0,0]]]), %(⍉≡<)'a'
    1 = ebqn:run([[0,7,0,1,16,0,8,0,9,0,10,3,4,0,4,0,2,0,6,0,3,8,7,16,0,5,0,0,7,16,25],[ebqn_array:get(10,Runtime),ebqn_array:get(12,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(31,Runtime),ebqn_array:get(46,Runtime),ebqn_array:get(49,Runtime),ebqn_array:get(54,Runtime),char("a"),str("a"),str("abc"),str("")],[[0,1,0,0]]]), %∧´⍉⊸≡¨⟨<'a',"a","abc",""⟩
    1 = ebqn:run([[0,7,0,8,3,2,0,2,16,0,5,0,0,7,0,3,9,0,1,0,4,0,5,0,4,0,0,7,7,7,19,0,6,0,2,16,17,25],[ebqn_array:get(1,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(31,Runtime),ebqn_array:get(44,Runtime),ebqn_array:get(47,Runtime),4,3,2],[[0,1,0,0]]]), %(↕4)(-˜⌜˜≡·⍉-⌜)↕3‿2
    ok = try ebqn:run([[0,4,0,0,0,4,0,0,0,5,17,17,0,1,0,2,0,3,0,4,3,3,17,25],[ebqn_array:get(22,Runtime),ebqn_array:get(31,Runtime),0,-1,1,3],[[0,1,0,0]]]) % 0‿¯1‿1⍉(3⥊1)⥊1
        catch _ -> ok
    end,
    ok = try ebqn:run([[0,7,0,0,0,6,17,0,1,0,3,0,2,0,0,7,8,0,4,0,5,3,2,17,25],[ebqn_array:get(24,Runtime),ebqn_array:get(31,Runtime),ebqn_array:get(45,Runtime),ebqn_array:get(54,Runtime),1,0,str("ab"),str("cd")],[[0,1,0,0]]]) % 1‿0≍˘⊸⍉"ab"≍"cd"
        catch _ -> ok
    end,
    ok = try ebqn:run([[0,7,0,1,16,0,3,0,4,0,0,7,7,16,0,2,0,5,0,6,3,2,17,25],[ebqn_array:get(0,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(31,Runtime),ebqn_array:get(44,Runtime),ebqn_array:get(47,Runtime),0,2,3],[[0,1,0,0]]]) % 0‿2⍉+⌜˜↕3
        catch _ -> ok
    end,
    ok = try ebqn:run([[0,4,0,0,16,0,0,16,0,1,0,2,0,3,0,3,3,3,17,25],[ebqn_array:get(27,Runtime),ebqn_array:get(31,Runtime),2,0,3],[[0,1,0,0]]]) % 2‿0‿0⍉↕↕3
        catch _ -> ok
    end,
    ok = try ebqn:run([[0,2,0,0,16,0,0,16,0,1,0,2,17,25],[ebqn_array:get(27,Runtime),ebqn_array:get(31,Runtime),3],[[0,1,0,0]]]) % 3⍉↕↕3
        catch _ -> ok
    end,
    1 = ebqn:run([[0,8,0,3,0,6,0,5,0,0,7,8,0,10,17,0,4,0,9,0,9,3,2,17,0,2,0,8,0,3,16,0,1,0,7,17,17,25],[ebqn_array:get(0,Runtime),ebqn_array:get(2,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(31,Runtime),ebqn_array:get(47,Runtime),ebqn_array:get(53,Runtime),2,3,0,6],[[0,1,0,0]]]), %(2×↕3)≡0‿0⍉6+⌜○↕3
    1 = ebqn:run([[0,4,0,0,0,1,0,2,0,3,3,0,8,19,16,25],[ebqn_array:get(12,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(31,Runtime),ebqn_array:get(54,Runtime),4],[[0,1,0,0]]]), %(⟨⟩⊸⍉≡<)4
    1 = ebqn:run([[0,4,0,0,16,0,2,0,1,0,3,19,3,0,17,25],[ebqn_array:get(12,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(21,Runtime),ebqn_array:get(31,Runtime),4],[[0,1,0,0]]]), %⟨⟩(⍉≡⊢)<4
    1 = ebqn:run([[0,7,0,2,16,0,2,16,0,3,0,6,0,4,0,5,0,6,3,4,17,0,0,3,0,0,1,0,4,0,5,0,6,3,3,17,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(31,Runtime),2,0,1,4],[[0,1,0,0]]]), %(2‿0‿1⥊⟨⟩)≡1‿2‿0‿1⍉↕↕4
    1 = ebqn:run([[0,9,0,2,16,0,2,16,0,3,0,4,0,0,8,0,6,17,0,1,0,5,0,6,0,7,0,8,3,4,0,2,16,17,25],[ebqn_array:get(12,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(31,Runtime),ebqn_array:get(54,Runtime),1,2,0,3,4],[[0,1,0,0]]]), %(↕1‿2‿0‿3)≡2<⊸⍉↕↕4
    1 = ebqn:run([[0,8,0,2,16,0,1,0,6,0,7,3,2,17,0,0,0,4,0,3,0,4,0,5,8,8,16,25],[ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(31,Runtime),ebqn_array:get(54,Runtime),0,2,3,6],[[0,1,0,0]]]), %0⊸⍉⊸≡2‿3⥊↕6
    ok = try ebqn:run([[0,1,0,0,16,25],[ebqn_array:get(33,Runtime),char("a")],[[0,1,0,0]]]) % ⍋'a'
        catch _ -> ok
    end,
    ok = try ebqn:run([[0,2,0,1,3,2,0,0,16,25],[ebqn_array:get(33,Runtime),ebqn_array:get(52,Runtime),char("a")],[[0,1,0,0]]]) % ⍋'a'‿∘
        catch _ -> ok
    end,
    ok = try ebqn:run([[0,1,0,0,16,25],[ebqn_array:get(34,Runtime),2],[[0,1,0,0]]]) % ⍒2
        catch _ -> ok
    end,
    1 = ebqn:run([[0,7,0,1,16,0,0,0,2,0,3,0,4,0,5,0,6,3,5,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(33,Runtime),2,0,3,1,4,str("bdace")],[[0,1,0,0]]]), %2‿0‿3‿1‿4≡⍋"bdace"
    1 = ebqn:run([[0,9,0,1,16,0,2,16,0,0,0,3,0,4,0,5,0,6,0,7,0,8,3,6,17,25],[ebqn_array:get(18,Runtime),ebqn_array:get(26,Runtime),ebqn_array:get(33,Runtime),5,2,4,3,0,1,str("deabb")],[[0,1,0,0]]]), %5‿2‿4‿3‿0‿1≡⍋↓"deabb"
    1 = ebqn:run([[0,7,0,6,0,3,16,0,8,0,0,16,0,2,0,6,17,3,3,0,5,0,1,0,4,19,16,25],[ebqn_array:get(12,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(25,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(33,Runtime),ebqn_array:get(34,Runtime),0,str(""),str("abc")],[[0,1,0,0]]]), %(⍋≡⍒)⟨"",↕0,0↑<"abc"⟩
    1 = ebqn:run([[0,6,0,7,0,8,0,9,0,10,0,11,0,12,3,7,0,0,0,5,0,2,0,5,0,3,8,8,0,1,0,4,19,16,25],[ebqn_array:get(14,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(30,Runtime),ebqn_array:get(34,Runtime),ebqn_array:get(52,Runtime),ninf,-1.5,3.141592653589793,inf,char("A"),char("a"),char("b")],[[0,1,0,0]]]), %(⍒≡⌽∘↕∘≠)⟨¯∞,¯1.5,π,∞,'A','a','b'⟩
    1 = ebqn:run([[0,8,0,4,16,0,9,0,10,0,10,0,11,3,2,0,10,0,8,3,2,0,10,0,8,0,8,3,3,0,10,0,12,3,2,0,8,0,8,0,3,0,13,17,0,14,0,15,0,16,0,0,0,15,17,3,12,0,1,0,7,0,4,0,7,0,5,8,8,0,2,0,6,19,16,25],[ebqn_array:get(0,Runtime),ebqn_array:get(14,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(30,Runtime),ebqn_array:get(34,Runtime),ebqn_array:get(52,Runtime),0,-1.1,-1,ninf,inf,6,1.0E-20,1,1.0E-15],[[0,1,0,0]]]), %(⍒≡⌽∘↕∘≠)⟨↕0,¯1.1,¯1,¯1‿¯∞,¯1‿0,¯1‿0‿0,¯1‿∞,0,6⥊0,1e¯20,1,1+1e¯15⟩
    1 = ebqn:run([[0,14,0,0,0,8,0,3,7,0,10,0,5,16,0,11,0,11,0,11,3,2,0,12,0,11,0,11,3,3,0,12,0,11,3,2,0,12,0,11,0,12,3,2,0,12,0,12,3,2,0,13,3,9,19,0,4,0,0,19,16,0,1,0,9,0,5,0,9,0,6,8,8,0,2,0,7,19,16,25],[ebqn_array:get(12,Runtime),ebqn_array:get(14,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(23,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(30,Runtime),ebqn_array:get(34,Runtime),ebqn_array:get(46,Runtime),ebqn_array:get(52,Runtime),0,1,2,3,char("a")],[[0,1,0,0]]]), %(⍒≡⌽∘↕∘≠)(<∾⟨↕0,1,1‿1,2‿1‿1,2‿1,2,1‿2,2‿2,3⟩⥊¨<)'a'
    1 = ebqn:run([[0,11,0,12,3,2,0,6,0,2,0,8,0,11,0,9,0,2,8,8,7,0,10,0,3,16,17,0,4,16,0,2,16,0,0,0,7,0,3,8,0,1,0,5,19,16,25],[ebqn_array:get(14,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(31,Runtime),ebqn_array:get(33,Runtime),ebqn_array:get(47,Runtime),ebqn_array:get(52,Runtime),ebqn_array:get(54,Runtime),ebqn_array:get(55,Runtime),5,1,char("b")],[[0,1,0,0]]]), %(⍋≡↕∘≠)⥊⍉(↕5)⥊⟜1⊸⥊⌜1‿'b'
    1 = ebqn:run([[0,9,0,10,0,8,0,11,3,4,0,3,0,4,0,1,0,0,0,7,0,8,3,2,19,19,0,5,0,6,0,2,8,0,3,19,16,25],[ebqn_array:get(0,Runtime),ebqn_array:get(14,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(21,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(33,Runtime),ebqn_array:get(53,Runtime),0,1,-2,char("a"),char("f")],[[0,1,0,0]]]), %(⊢≡○⍋(0‿1+≠)⥊⊢)⟨¯2,'a',1,'f'⟩
    1 = ebqn:run([[0,25,0,8,16,0,12,0,24,0,8,16,0,19,0,3,0,16,0,15,0,0,7,8,8,7,0,19,0,13,0,6,7,8,0,6,0,9,9,0,17,0,4,8,0,13,0,2,0,18,0,14,0,1,7,8,0,7,0,5,0,7,0,2,19,0,18,0,10,0,18,0,23,8,8,19,0,11,0,7,7,0,5,0,16,0,3,8,19,0,18,0,6,8,7,19,0,20,0,21,0,22,0,20,0,21,3,2,0,21,0,20,3,2,0,20,0,22,3,2,0,21,0,21,3,2,0,22,0,20,3,2,3,8,17,25],[ebqn_array:get(0,Runtime),ebqn_array:get(2,Runtime),ebqn_array:get(6,Runtime),ebqn_array:get(14,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(20,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(23,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(33,Runtime),ebqn_array:get(36,Runtime),ebqn_array:get(44,Runtime),ebqn_array:get(46,Runtime),ebqn_array:get(47,Runtime),ebqn_array:get(49,Runtime),ebqn_array:get(51,Runtime),ebqn_array:get(52,Runtime),ebqn_array:get(53,Runtime),ebqn_array:get(54,Runtime),ebqn_array:get(55,Runtime),1,2,3,-1,6,4],[[0,1,0,0]]]), %⟨1,2,3,1‿2,2‿1,1‿3,2‿2,3‿1⟩(⥊⊸(≠∘⊣∾˜¯1⊸⊑⊸(⌊∾⊣)∾×´⊸⌊)⌜≡○(⍋⥊)⥊⌜⟜(+`∘≠⟜(↕6)¨))↕4
    1 = ebqn:run([[0,14,0,5,16,0,6,0,12,17,0,8,0,0,0,7,19,0,3,0,2,0,10,0,12,0,13,3,2,0,11,0,4,8,0,1,0,9,0,4,7,19,8,19,16,25],[ebqn_array:get(0,Runtime),ebqn_array:get(1,Runtime),ebqn_array:get(14,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(32,Runtime),ebqn_array:get(33,Runtime),ebqn_array:get(34,Runtime),ebqn_array:get(44,Runtime),ebqn_array:get(52,Runtime),ebqn_array:get(55,Runtime),2,0,5],[[0,1,0,0]]]), %((⥊˜-⥊⟜2‿0)∘≠≡⍋+⍒)2/↕5
    ok = try ebqn:run([[0,0,3,1,0,2,16,0,1,16,25],[ebqn_array:get(0,Runtime),ebqn_array:get(10,Runtime),ebqn_array:get(35,Runtime)],[[0,1,0,0]]]) % ∧⊏⟨+⟩
        catch _ -> ok
    end,
    ok = try ebqn:run([[0,0,0,1,3,2,0,2,16,25],[ebqn_array:get(0,Runtime),ebqn_array:get(1,Runtime),ebqn_array:get(10,Runtime)],[[0,1,0,0]]]) % ∧+‿-
        catch _ -> ok
    end,
    ok = try ebqn:run([[0,1,0,0,16,25],[ebqn_array:get(11,Runtime),char("c")],[[0,1,0,0]]]) % ∨'c'
        catch _ -> ok
    end,
    1 = ebqn:run([[0,3,0,0,16,0,1,0,2,17,25],[ebqn_array:get(11,Runtime),ebqn_array:get(18,Runtime),str("edcba"),str("bdace")],[[0,1,0,0]]]), %"edcba"≡∨"bdace"
    1 = ebqn:run([[0,8,0,4,16,0,0,0,9,17,0,5,0,7,0,1,8,16,0,6,16,0,2,16,0,3,0,8,0,4,16,17,25],[ebqn_array:get(0,Runtime),ebqn_array:get(8,Runtime),ebqn_array:get(10,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(30,Runtime),ebqn_array:get(33,Runtime),ebqn_array:get(55,Runtime),7,1],[[0,1,0,0]]]), %(↕7)≡∧⍋|⟜⌽1+↕7
    ok = try ebqn:run([[0,2,0,1,0,0,7,16,25],[ebqn_array:get(33,Runtime),ebqn_array:get(44,Runtime),6],[[0,1,0,0]]]) % ⍋˜6
        catch _ -> ok
    end,
    ok = try ebqn:run([[0,3,0,0,0,2,0,1,8,16,25],[ebqn_array:get(27,Runtime),ebqn_array:get(34,Runtime),ebqn_array:get(55,Runtime),4],[[0,1,0,0]]]) % ⍒⟜↕4
        catch _ -> ok
    end,
    ok = try ebqn:run([[0,6,0,0,0,4,17,0,1,0,5,0,0,0,2,0,3,0,4,3,3,17,17,25],[ebqn_array:get(22,Runtime),ebqn_array:get(33,Runtime),3,2,4,0,1],[[0,1,0,0]]]) % (3‿2‿4⥊0)⍋4⥊1
        catch _ -> ok
    end,
    ok = try ebqn:run([[0,6,0,1,0,5,0,0,0,2,0,3,0,4,3,3,17,17,25],[ebqn_array:get(22,Runtime),ebqn_array:get(34,Runtime),3,2,4,0,1],[[0,1,0,0]]]) % (3‿2‿4⥊0)⍒1
        catch _ -> ok
    end,
    ok = try ebqn:run([[0,3,0,1,16,0,2,0,0,3,1,17,25],[ebqn_array:get(0,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(33,Runtime),6],[[0,1,0,0]]]) % ⟨+⟩⍋↕6
        catch _ -> ok
    end,
    ok = try ebqn:run([[0,1,0,2,15,1,3,3,3,1,0,0,0,1,0,2,0,1,3,3,0,1,0,2,0,3,3,3,3,2,17,25,21,0,1,25],[ebqn_array:get(34,Runtime),1,3,2],[[0,1,0,0],[0,0,32,3]]]) % ⟨1‿3‿1,1‿3‿2⟩⍒⟨1‿3‿{𝕩}⟩
        catch _ -> ok
    end,
    1 = ebqn:run([[0,23,0,7,0,20,0,9,16,0,12,0,1,7,0,19,17,17,0,7,0,14,0,10,8,0,2,0,14,0,13,0,0,7,8,0,11,0,15,0,10,8,0,6,19,0,8,0,5,19,0,5,0,14,0,3,8,19,0,4,0,10,19,0,16,0,17,0,18,0,21,0,22,3,5,17,25],[ebqn_array:get(0,Runtime),ebqn_array:get(3,Runtime),ebqn_array:get(13,Runtime),ebqn_array:get(14,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(20,Runtime),ebqn_array:get(21,Runtime),ebqn_array:get(23,Runtime),ebqn_array:get(26,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(33,Runtime),ebqn_array:get(35,Runtime),ebqn_array:get(44,Runtime),ebqn_array:get(51,Runtime),ebqn_array:get(52,Runtime),ebqn_array:get(54,Runtime),1,3,inf,2,8,char("e"),char("i"),str("aegz")],[[0,1,0,0]]]), %⟨1,3,∞,'e','i'⟩ (⍋≡≠∘⊣(⊣↓⊢⍋⊸⊏+`∘>)⍋∘∾) (2÷˜↕8)∾"aegz"
    1 = ebqn:run([[0,23,0,7,0,20,0,9,16,0,13,0,1,7,0,19,17,17,0,7,0,15,0,11,8,0,2,0,15,0,14,0,0,7,8,0,12,0,16,0,10,8,0,6,19,0,8,0,5,19,0,5,0,15,0,3,8,19,0,4,0,11,19,0,21,0,22,0,17,0,18,3,2,0,18,3,4,17,25],[ebqn_array:get(0,Runtime),ebqn_array:get(3,Runtime),ebqn_array:get(13,Runtime),ebqn_array:get(14,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(20,Runtime),ebqn_array:get(21,Runtime),ebqn_array:get(23,Runtime),ebqn_array:get(26,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(33,Runtime),ebqn_array:get(34,Runtime),ebqn_array:get(35,Runtime),ebqn_array:get(44,Runtime),ebqn_array:get(51,Runtime),ebqn_array:get(52,Runtime),ebqn_array:get(54,Runtime),1,0,2,8,char("z"),char("d"),str("aegz")],[[0,1,0,0]]]), %⟨'z','d',1‿0,0⟩ (⍒≡≠∘⊣(⊣↓⊢⍋⊸⊏+`∘>)⍒∘∾) (2÷˜↕8)∾"aegz"
    1 = ebqn:run([[0,8,0,4,0,6,0,7,0,3,16,8,0,2,0,0,0,5,0,1,8,19,16,25],[ebqn_array:get(7,Runtime),ebqn_array:get(12,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(33,Runtime),ebqn_array:get(52,Runtime),ebqn_array:get(54,Runtime),6,2.5],[[0,1,0,0]]]), %(<∘⌈≡(↕6)⊸⍋)2.5
    1 = ebqn:run([[0,7,0,3,16,0,0,0,5,17,0,4,0,6,0,7,3,2,0,3,16,17,0,2,0,5,0,1,16,17,25],[ebqn_array:get(0,Runtime),ebqn_array:get(12,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(27,Runtime),ebqn_array:get(33,Runtime),1,2,3],[[0,1,0,0]]]), %(<1)≡(↕2‿3)⍋1+↕3
    1 = ebqn:run([[0,9,0,3,16,0,0,0,5,0,4,0,6,0,2,8,8,0,8,17,0,1,0,7,0,0,16,17,25],[ebqn_array:get(12,Runtime),ebqn_array:get(18,Runtime),ebqn_array:get(22,Runtime),ebqn_array:get(24,Runtime),ebqn_array:get(34,Runtime),ebqn_array:get(53,Runtime),ebqn_array:get(54,Runtime),0,str("abc"),str("acc")],[[0,1,0,0]]]), %(<0)≡"abc"⥊⊸⍒○<≍"acc"
    ok.
