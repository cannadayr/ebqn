-module(ebqn_test).

-include("schema.hrl").

-import(ebqn,[str/1]).
-export([test/1,test1/0,test2/1,test3/1]).

test([B,O,S]) ->
    ebqn:run(list_to_tuple(B),list_to_tuple(O),list_to_tuple(lists:map(fun list_to_tuple/1,S))).

test1() ->
    % bytecode tests
    5 = test([[0,0,25],[5],[[0,1,0,0]]]), % 5
    3 = test([[0,0,14,0,1,25],[4,3],[[0,1,0,0]]]), % 4⋄3
    5 = test([[0,0,22,0,0,11,25],[5],[[0,1,0,1]]]), % a←5
    4 = test([[0,0,22,0,0,11,14,0,1,22,0,0,12,25],[5,4],[[0,1,0,1]]]), % a←5⋄a↩4
    2 = test([[0,0,22,0,0,11,14,0,1,22,0,1,11,14,21,0,0,25],[2,3],[[0,1,0,2]]]), % a←2⋄b←3⋄a
    1 = test([[0,0,22,0,0,11,14,0,1,21,0,0,16,25],[1,4],[[0,1,0,1]]]), % a←1⋄A 4
    2 = test([[0,0,22,0,0,11,14,0,2,21,0,0,0,1,17,25],[2,3,4],[[0,1,0,1]]]), % a←2⋄3 A 4
    6 = test([[0,0,15,1,16,25,21,0,1,25],[6],[[0,1,0,0],[0,0,6,3]]]), % {𝕩}6
    3 = test([[15,1,22,0,0,11,14,0,1,21,0,0,0,0,17,25,21,0,2,25],[3,4],[[0,1,0,1],[0,0,16,3]]]), % A←{𝕨}⋄3 A 4
    7 = test([[0,0,0,1,3,2,22,0,0,22,0,1,4,2,11,14,21,0,0,25],[7,2],[[0,1,0,2]]]), % a‿b←7‿2⋄a
    4 = test([[0,1,15,1,0,0,7,16,25,21,0,1,25],[4,6],[[0,1,0,0],[1,1,9,2]]]), % "4{𝔽}6"
    6 = test([[0,1,15,1,0,0,7,16,25,21,0,4,14,21,0,1,25],[4,6],[[0,1,0,0],[1,0,9,5]]]), % "4{𝔽⋄𝕩}6"
    1 = test([[0,1,15,1,15,2,0,0,8,16,25,21,0,1,25,21,0,2,25],[3,1],[[0,1,0,0],[0,0,11,3],[2,1,15,3]]]), % "3{𝔾}{𝕩} 1 "
    2 = test([[0,1,15,1,15,2,0,0,7,9,16,25,21,0,1,25,21,0,1,25],[2,3],[[0,1,0,0],[0,0,12,3],[1,1,16,2]]]), % "(2{𝔽}{𝕩})3 "
    3 = test([[0,1,15,1,15,2,9,0,0,17,25,21,0,2,21,0,1,3,2,25,21,0,1,22,0,3,22,0,4,4,2,11,14,21,0,3,25],[3,4],[[0,1,0,0],[0,0,11,3],[0,0,20,5]]]), % "3({a‿b←𝕩⋄a}{𝕨‿𝕩})4 "
    4 = test([[0,1,15,1,15,2,15,3,19,0,0,17,25,21,0,2,25,21,0,1,25,21,0,2,21,0,1,3,2,25],[4,5],[[0,1,0,0],[0,0,13,3],[0,0,17,3],[0,0,21,3]]]), % "4({𝕨‿𝕩}{𝕩}{𝕨})5"
    2 = test([[0,1,15,1,15,2,0,0,19,16,22,0,0,22,0,1,4,2,11,14,21,0,0,25,21,0,1,25,21,0,2,21,0,1,3,2,25],[2,5],[[0,1,0,2],[0,0,24,3],[0,0,28,3]]]), % "a‿b←(2{𝕨‿𝕩}{𝕩})5⋄a "
    2 = test([[0,2,22,0,0,11,15,1,15,2,15,3,19,16,25,0,1,22,1,0,12,14,21,0,1,25,21,0,1,14,21,1,0,25,0,0,22,1,0,12,14,21,0,1,25],[2,3,4],[[0,1,0,1],[0,0,15,3],[0,0,26,3],[0,0,34,3]]]), % "({a↩2⋄𝕩}{𝕩⋄a}{a↩3⋄𝕩})a←4 "
    8 = test([[0,0,22,0,0,11,14,0,1,15,1,22,0,0,13,14,21,0,0,25,21,0,1,25],[3,8],[[0,1,0,1],[0,0,20,3]]]), % "a←3⋄a{𝕩}↩8⋄a  "
    4 = test([[0,0,0,1,3,2,22,0,0,22,0,1,4,2,11,14,0,2,15,1,22,0,0,22,0,1,4,2,13,14,21,0,0,25,21,0,1,21,0,2,3,2,25],[2,1,4],[[0,1,0,2],[0,0,34,3]]]), % "a‿b←2‿1⋄a‿b{𝕩‿𝕨}↩4⋄a "
    1 = test([[0,0,22,0,0,11,14,15,1,14,21,0,0,25,0,1,22,0,0,11,25],[1,2],[[0,1,0,1],[0,1,14,1]]]), % "a←1⋄{a←2}⋄a"
    2 = test([[0,0,22,0,0,11,14,15,1,14,21,0,0,25,0,1,22,1,0,12,25],[1,2],[[0,1,0,1],[0,1,14,0]]]), % "a←1⋄{a↩2}⋄a"
    6 = test([[15,1,22,0,0,22,0,1,4,2,11,14,0,1,21,0,0,16,14,0,2,21,0,1,16,25,0,0,22,0,0,11,14,15,2,15,3,3,2,25,21,0,1,22,1,0,12,25,21,0,1,14,21,1,0,25],[2,6,0],[[0,1,0,2],[0,1,26,1],[0,0,40,3],[0,0,48,3]]]), % "f‿g←{a←2⋄{a↩𝕩}‿{𝕩⋄a}}⋄F 6⋄G 0"
    5 = test([[15,1,22,0,0,11,14,0,0,21,0,0,16,21,0,0,16,21,0,0,16,15,2,16,25,15,3,21,0,1,7,25,21,0,0,21,0,1,16,25,21,0,4,21,0,1,16,25],[5],[[0,1,0,1],[0,0,25,3],[0,0,32,3],[1,0,40,5]]]), % "L←{𝕩{𝕏𝕗}}⋄{𝕏𝕤}L L L 5"
    3 = test([[15,1,22,0,0,11,14,0,1,21,0,0,0,0,7,16,21,0,0,15,2,7,16,15,3,16,25,21,0,4,15,4,21,0,1,7,9,25,21,0,1,25,21,0,0,21,0,1,16,25,21,0,4,21,0,1,16,25],[3,5],[[0,1,0,1],[1,0,27,5],[0,0,38,3],[0,0,42,3],[1,0,50,5]]]), % "_l←{𝕩{𝕏𝕗} 𝔽}⋄{𝕏𝕤} {𝕩}_l 3 _l 5"
    1 = test([[0,1,15,1,15,2,15,3,8,0,0,17,25,21,0,1,25,21,0,1,21,0,2,15,4,21,0,1,7,19,25,21,0,2,25,21,0,2,21,0,4,21,0,1,17,25],[1,0],[[0,1,0,0],[0,0,13,3],[2,1,17,3],[0,0,31,3],[1,0,35,5]]]), % "1{𝕨}{𝔽{𝕩𝔽𝕨}𝔾𝔽}{𝕩}0 "
    2 = test([[0,0,0,1,0,2,0,3,0,4,15,1,3,2,3,2,3,2,3,2,3,2,15,2,0,0,0,0,15,3,3,2,3,2,7,16,25,21,0,1,25,21,0,1,15,4,16,25,21,0,1,25,21,0,1,22,0,3,22,0,4,4,2,11,14,21,0,0,22,0,5,11,14,0,0,15,5,15,6,7,16,14,15,7,21,0,4,21,0,5,16,7,25,21,0,1,21,1,4,16,25,21,0,0,14,15,8,22,1,5,12,25,21,0,1,22,0,5,22,0,6,4,2,11,14,21,0,6,21,0,4,16,25,21,0,0,14,15,9,25,21,0,1,22,0,3,22,0,4,4,2,11,14,21,0,3,25],[0,1,2,3,4],[[0,1,0,0],[0,0,37,3],[1,1,41,2],[0,0,48,3],[0,0,52,6],[1,1,93,2],[0,0,101,3],[1,0,112,7],[0,0,133,3],[0,0,140,5]]]), % "0‿(0‿{𝕩}){{a‿b←𝕩⋄t←𝕤⋄{𝕤⋄T↩{𝕤⋄{a‿b←𝕩⋄a}}}{B𝕗}0⋄(T b){a‿b←𝕩⋄𝔽b}}𝕗} 0‿(1‿(2‿(3‿(4‿{𝕩}))))"
    true.

% ebqn_test:test2(ebqn:call(ebqn_test:test(ebqn_bc:runtime()),ebqn_core:fns(),undefined)).
% notes of changes made to cjs output:
%   runtime[N] becomes array:get(N,R)
%   single quoted strings become double quoted strings
%   'Infinity' and '-Infinity' become 'inf' and 'ninf'
test2(#v{r=R}) ->
    1 = test([[0,4,0,0,0,3,17,0,1,0,2,17,25],[ebqn_array:get(0,R),ebqn_array:get(18,R),0,-2,2],[[0,1,0,0]]]), % 0≡¯2+2
    1 = test([[0,3,0,0,0,3,17,0,1,0,2,17,25],[ebqn_array:get(0,R),ebqn_array:get(18,R),10000,5000],[[0,1,0,0]]]), % 1e4≡5e3+5e3
    1 = test([[0,2,0,0,0,4,17,0,1,0,3,17,25],[ebqn_array:get(0,R),ebqn_array:get(18,R),2,"c","a"],[[0,1,0,0]]]), % 'c'≡'a'+2
    1 = test([[0,4,0,0,0,2,17,0,1,0,3,17,25],[ebqn_array:get(0,R),ebqn_array:get(18,R),-2,"a","c"],[[0,1,0,0]]]), % 'a'≡¯2+'c'
    ok = try test([[0,2,0,0,0,1,17,25],[ebqn_array:get(0,R),"a","c"],[[0,1,0,0]]]) % ! % 'a'+'c'
        catch _ -> ok
    end,
    ok = try test([[0,1,22,0,0,11,14,0,2,0,0,21,0,0,17,25],[ebqn_array:get(0,R),ebqn_array:get(1,R),2],[[0,1,0,1]]]) % F←-⋄f+2
        catch _ -> ok
    end,
    1 = test([[0,4,0,0,0,3,17,0,1,0,2,17,25],[ebqn_array:get(1,R),ebqn_array:get(18,R),ninf,1000000,inf],[[0,1,0,0]]]), % ¯∞≡1e6-∞
    1 = test([[0,3,0,0,16,0,1,0,2,17,25],[ebqn_array:get(1,R),ebqn_array:get(18,R),4,-4],[[0,1,0,0]]]), % 4≡-¯4
    1 = test([[0,3,0,0,16,0,1,0,2,17,25],[ebqn_array:get(1,R),ebqn_array:get(18,R),ninf,inf],[[0,1,0,0]]]), % ¯∞≡-∞
    1 = test([[0,3,0,0,16,0,1,0,2,17,25],[ebqn_array:get(1,R),ebqn_array:get(18,R),inf,ninf],[[0,1,0,0]]]), % ∞≡-¯∞
    1 = test([[0,4,0,0,0,3,17,0,1,0,2,17,25],[ebqn_array:get(1,R),ebqn_array:get(18,R),4,9,5],[[0,1,0,0]]]), % 4≡9-5
    1 = test([[0,2,0,0,0,4,17,0,1,0,3,17,25],[ebqn_array:get(1,R),ebqn_array:get(18,R),97,"\0","a"],[[0,1,0,0]]]), % @≡'a'-97
    1 = test([[0,4,0,0,0,3,17,0,1,0,2,17,25],[ebqn_array:get(1,R),ebqn_array:get(18,R),3,"d","a"],[[0,1,0,0]]]), % 3≡'d'-'a'
    ok = try test([[0,2,0,0,0,1,17,25],[ebqn_array:get(1,R),97,"a"],[[0,1,0,0]]]) % 97-'a'
        catch _ -> ok
    end,
    %ok = try test([[0,1,0,0,0,2,17,25],[ebqn_array:get(1,R),1,"\0"],[[0,1,0,0]]]) % @-1
    %    catch _ -> ok
    %end,
    ok = try test([[0,1,0,0,16,25],[ebqn_array:get(1,R),"a"],[[0,1,0,0]]]) % -'a'
        catch _ -> ok
    end,
    ok = try test([[0,1,22,0,0,11,14,21,0,0,0,0,16,25],[ebqn_array:get(1,R),ebqn_array:get(3,R)],[[0,1,0,1]]]) % F←÷⋄-f
        catch _ -> ok
    end,
    1 = test([[0,4,0,0,0,3,17,0,1,0,2,17,25],[ebqn_array:get(2,R),ebqn_array:get(18,R),1.5,3,0.5],[[0,1,0,0]]]), % 1.5≡3×0.5
    ok = try test([[0,2,0,0,0,1,17,25],[ebqn_array:get(2,R),2,"a"],[[0,1,0,0]]]) % 2×'a'
        catch _ -> ok
    end,
    1 = test([[0,3,0,0,16,0,1,0,2,17,25],[ebqn_array:get(3,R),ebqn_array:get(18,R),4,0.25],[[0,1,0,0]]]), % 4≡÷0.25
    1 = test([[0,3,0,0,16,0,1,0,2,17,25],[ebqn_array:get(3,R),ebqn_array:get(18,R),inf,0],[[0,1,0,0]]]), % ∞≡÷0
    1 = test([[0,3,0,0,16,0,1,0,2,17,25],[ebqn_array:get(3,R),ebqn_array:get(18,R),0,inf],[[0,1,0,0]]]), % 0≡÷∞
    ok = try test([[0,1,0,0,16,25],[ebqn_array:get(3,R),"b"],[[0,1,0,0]]]) % ÷'b'
        catch _ -> ok
    end,
    ok = try test([[0,1,0,0,16,25],[ebqn_array:get(3,R),"b"],[[0,1,0,0]]]) % F←√-⋄÷f
        catch _ -> ok
    end,
    1 = test([[0,3,0,0,16,0,1,0,2,17,25],[ebqn_array:get(4,R),ebqn_array:get(18,R),1,0],[[0,1,0,0]]]), % 1≡⋆0
    1 = test([[0,3,0,0,0,2,17,0,1,0,2,17,25],[ebqn_array:get(4,R),ebqn_array:get(18,R),-1,5],[[0,1,0,0]]]), % ¯1≡¯1⋆5
    1 = test([[0,4,0,0,0,3,17,0,1,0,2,17,25],[ebqn_array:get(4,R),ebqn_array:get(18,R),1,-1,-6],[[0,1,0,0]]]), % 1≡¯1⋆¯6
    ok = try test([[0,1,0,0,16,25],[ebqn_array:get(4,R),"π"],[[0,1,0,0]]]) % ⋆'π'
        catch _ -> ok
    end,
    ok = try test([[0,2,0,0,0,1,17,25],[ebqn_array:get(4,R),"e","π"],[[0,1,0,0]]]) % 'e'⋆'π'
        catch _ -> ok
    end,
    1 = test([[0,3,0,0,16,0,1,0,2,17,25],[ebqn_array:get(6,R),ebqn_array:get(18,R),3,3.9],[[0,1,0,0]]]), % 3≡⌊3.9
    1 = test([[0,3,0,0,16,0,1,0,2,17,25],[ebqn_array:get(6,R),ebqn_array:get(18,R),-4,-3.9],[[0,1,0,0]]]), % ¯4≡⌊¯3.9
    1 = test([[0,2,0,0,16,0,1,0,2,17,25],[ebqn_array:get(6,R),ebqn_array:get(18,R),inf],[[0,1,0,0]]]), % ∞≡⌊∞
    1 = test([[0,2,0,0,16,0,1,0,2,17,25],[ebqn_array:get(6,R),ebqn_array:get(18,R),ninf],[[0,1,0,0]]]), % ¯∞≡⌊¯∞
    1 = test([[0,2,0,0,16,0,1,0,2,17,25],[ebqn_array:get(6,R),ebqn_array:get(18,R),-1.0E30],[[0,1,0,0]]]), % ¯1e30≡⌊¯1e30
    ok = try test([[0,1,22,0,0,11,14,21,0,0,0,0,16,25],[ebqn_array:get(6,R),ebqn_array:get(7,R)],[[0,1,0,1]]]) % F←⌈⋄⌊f
        catch _ -> ok
    end,
    1 = test([[0,2,0,0,0,2,17,0,1,0,2,17,25],[ebqn_array:get(15,R),ebqn_array:get(18,R),1],[[0,1,0,0]]]), % 1≡1=1
    1 = test([[0,4,0,0,0,3,17,0,1,0,2,17,25],[ebqn_array:get(15,R),ebqn_array:get(18,R),0,-1,inf],[[0,1,0,0]]]), % 0≡¯1=∞
    1 = test([[0,3,0,0,0,3,17,0,1,0,2,17,25],[ebqn_array:get(15,R),ebqn_array:get(18,R),1,"a"],[[0,1,0,0]]]), % 1≡'a'='a'
    1 = test([[0,4,0,0,0,3,17,0,1,0,2,17,25],[ebqn_array:get(15,R),ebqn_array:get(18,R),0,"a","A"],[[0,1,0,0]]]), % 0≡'a'='A'
    1 = test([[15,1,0,2,0,3,17,25,0,0,22,0,0,11,14,21,0,0,0,1,21,0,0,17,25],[ebqn_array:get(0,R),ebqn_array:get(15,R),ebqn_array:get(18,R),1],[[0,1,0,0],[0,1,8,1]]]), % 1≡{F←+⋄f=f}
    1 = test([[15,1,0,2,0,4,17,25,0,3,0,0,7,0,3,0,0,7,3,2,22,0,0,22,0,1,4,2,11,14,21,0,1,0,1,21,0,0,17,25],[ebqn_array:get(0,R),ebqn_array:get(15,R),ebqn_array:get(18,R),ebqn_array:get(49,R),1],[[0,1,0,0],[0,1,8,2]]]), % 1≡{a‿b←⟨+´,+´⟩⋄a=b}
    1 = test([[15,1,0,1,0,2,17,25,15,2,22,0,0,11,14,0,3,0,0,21,0,0,17,25,21,0,1,25],[ebqn_array:get(15,R),ebqn_array:get(18,R),0,"o"],[[0,1,0,0],[0,1,8,1],[1,1,24,2]]]), % 0≡{_op←{𝕗}⋄op='o'}
    1 = test([[15,1,0,1,0,2,17,25,15,2,22,0,0,11,14,15,3,22,0,1,11,14,21,0,1,0,0,21,0,0,17,25,21,0,1,25,21,0,1,25],[ebqn_array:get(15,R),ebqn_array:get(18,R),0],[[0,1,0,0],[0,1,8,2],[0,0,32,3],[0,0,36,3]]]), % 0≡{F←{𝕩}⋄G←{𝕩}⋄f=g}
    1 = test([[15,1,0,1,0,2,17,25,15,2,22,0,0,11,14,21,0,0,0,0,21,0,0,17,25,21,0,1,25],[ebqn_array:get(15,R),ebqn_array:get(18,R),1],[[0,1,0,0],[0,1,8,1],[0,0,25,3]]]), % 1≡{F←{𝕩}⋄f=f}
    1 = test([[0,2,0,0,0,2,17,0,1,0,2,17,25],[ebqn_array:get(16,R),ebqn_array:get(18,R),1],[[0,1,0,0]]]), % 1≡1≤1
    1 = test([[0,4,0,0,0,3,17,0,1,0,2,17,25],[ebqn_array:get(16,R),ebqn_array:get(18,R),1,ninf,-1000],[[0,1,0,0]]]), % 1≡¯∞≤¯1e3
    1 = test([[0,4,0,0,0,3,17,0,1,0,2,17,25],[ebqn_array:get(16,R),ebqn_array:get(18,R),0,inf,ninf],[[0,1,0,0]]]), % 0≡∞≤¯∞
    1 = test([[0,4,0,0,0,3,17,0,1,0,2,17,25],[ebqn_array:get(16,R),ebqn_array:get(18,R),1,inf,"\0"],[[0,1,0,0]]]), % 1≡∞≤@
    1 = test([[0,3,0,0,0,4,17,0,1,0,2,17,25],[ebqn_array:get(16,R),ebqn_array:get(18,R),0,-0.5,"z"],[[0,1,0,0]]]), % 0≡'z'≤¯0.5
    1 = test([[0,4,0,0,0,3,17,0,1,0,2,17,25],[ebqn_array:get(16,R),ebqn_array:get(18,R),0,"c","a"],[[0,1,0,0]]]), % 0≡'c'≤'a'
    ok = try test([[0,0,22,0,0,11,14,0,1,22,0,1,11,14,21,0,1,0,2,21,0,0,17,25],[ebqn_array:get(0,R),ebqn_array:get(1,R),ebqn_array:get(16,R)],[[0,1,0,2]]]) % F←+⋄G←-⋄f≤g
        catch _ -> ok
    end,
    1 = test([[0,3,0,0,16,0,2,16,0,1,3,0,17,25],[ebqn_array:get(12,R),ebqn_array:get(18,R),ebqn_array:get(19,R),2],[[0,1,0,0]]]), % ⟨⟩≡≢<2
    1 = test([[0,3,0,1,16,0,0,0,2,3,1,17,25],[ebqn_array:get(18,R),ebqn_array:get(19,R),3,str("abc")],[[0,1,0,0]]]), % ⟨3⟩≡≢"abc"
    1 = test([[0,5,0,6,3,2,0,0,16,0,2,16,0,1,0,3,0,4,3,2,17,25],[ebqn_array:get(13,R),ebqn_array:get(18,R),ebqn_array:get(19,R),2,3,str("abc"),str("fed")],[[0,1,0,0]]]), % ⟨2,3⟩≡≢>"abc"‿"fed"
    1 = test([[0,8,0,3,16,0,2,0,4,0,5,0,6,0,7,3,4,17,0,1,16,0,0,0,4,0,5,0,6,0,7,3,4,17,25],[ebqn_array:get(18,R),ebqn_array:get(19,R),ebqn_array:get(22,R),ebqn_array:get(27,R),2,3,4,5,120],[[0,1,0,0]]]), % ⟨2,3,4,5⟩≡≢2‿3‿4‿5⥊↕120
    1 = test([[0,5,0,6,3,2,0,0,16,0,3,16,0,2,16,0,1,0,4,3,1,17,25],[ebqn_array:get(13,R),ebqn_array:get(18,R),ebqn_array:get(19,R),ebqn_array:get(22,R),6,str("abc"),str("fed")],[[0,1,0,0]]]), % ⟨6⟩≡≢⥊>"abc"‿"fed"
    1 = test([[0,3,0,4,3,2,0,1,0,2,17,0,0,0,3,17,25],[ebqn_array:get(18,R),ebqn_array:get(36,R),0,str("abc"),str("de")],[[0,1,0,0]]]), % "abc"≡0⊑"abc"‿"de"
    1 = test([[0,4,0,3,3,2,0,1,0,2,17,0,0,0,3,17,25],[ebqn_array:get(18,R),ebqn_array:get(36,R),1,str("de"),str("abc")],[[0,1,0,0]]]), % "de"≡1⊑"abc"‿"de"
    1 = test([[0,2,0,1,16,0,0,3,0,17,25],[ebqn_array:get(18,R),ebqn_array:get(27,R),0],[[0,1,0,0]]]), % ⟨⟩≡↕0
    1 = test([[0,3,0,1,16,0,0,0,2,3,1,17,25],[ebqn_array:get(18,R),ebqn_array:get(27,R),0,1],[[0,1,0,0]]]), % ⟨0⟩≡↕1
    1 = test([[0,9,0,1,16,0,0,0,2,0,3,0,4,0,5,0,6,0,7,0,8,3,7,17,25],[ebqn_array:get(18,R),ebqn_array:get(27,R),0,1,2,3,4,5,6,7],[[0,1,0,0]]]), % ⟨0,1,2,3,4,5,6⟩≡↕7
    1 = test([[0,2,0,1,16,0,0,0,2,17,25],[ebqn_array:get(18,R),ebqn_array:get(42,R),1],[[0,1,0,0]]]), % 1≡!1
    1 = test([[0,2,0,1,0,3,17,0,0,0,2,17,25],[ebqn_array:get(18,R),ebqn_array:get(42,R),1,"e"],[[0,1,0,0]]]), % 1≡'e'!1
    ok = try test([[0,1,0,0,16,25],[ebqn_array:get(42,R),0],[[0,1,0,0]]]) % !0
        catch _ -> ok
    end,
    ok = try test([[0,2,0,0,0,1,17,25],[ebqn_array:get(42,R),str("error"),str("abc")],[[0,1,0,0]]]) % "error"!"abc"
        catch _ -> ok
    end,
    ok.

test3(#v{r=R}) ->
    1 = test([[0,7,0,0,0,1,3,2,0,4,0,2,8,0,6,17,0,3,0,5,17,25],[ebqn_array:get(0,R),ebqn_array:get(1,R),ebqn_array:get(13,R),ebqn_array:get(18,R),ebqn_array:get(58,R),3,4,1],[[0,1,0,0]]]), % 3≡4>◶+‿-1
    1 = test([[0,7,0,0,0,1,3,2,0,4,0,3,8,0,6,17,0,2,0,5,17,25],[ebqn_array:get(0,R),ebqn_array:get(1,R),ebqn_array:get(18,R),ebqn_array:get(21,R),ebqn_array:get(58,R),3,4,1],[[0,1,0,0]]]), % 3≡4⊢◶+‿-1
    1 = test([[0,6,0,0,0,1,3,2,0,3,0,6,8,0,5,17,0,2,0,4,17,25],[ebqn_array:get(0,R),ebqn_array:get(1,R),ebqn_array:get(18,R),ebqn_array:get(58,R),3,4,1],[[0,1,0,0]]]), % 3≡4 1◶+‿-1
    1 = test([[0,7,0,0,0,1,3,2,0,4,0,2,8,0,6,17,0,3,0,5,17,25],[ebqn_array:get(0,R),ebqn_array:get(1,R),ebqn_array:get(12,R),ebqn_array:get(18,R),ebqn_array:get(58,R),5,4,1],[[0,1,0,0]]]), % 5≡4<◶+‿-1
    1 = test([[0,7,0,0,0,1,3,2,0,3,0,6,8,0,5,17,0,2,0,4,17,25],[ebqn_array:get(0,R),ebqn_array:get(1,R),ebqn_array:get(18,R),ebqn_array:get(58,R),5,4,0,1],[[0,1,0,0]]]), % 5≡4 0◶+‿-1
    1 = test([[0,5,0,4,0,2,0,0,8,16,0,1,0,3,17,25],[ebqn_array:get(1,R),ebqn_array:get(18,R),ebqn_array:get(57,R),1,0,-1],[[0,1,0,0]]]), % 1≡-⊘0 ¯1
    1 = test([[0,6,0,0,0,3,0,1,8,0,5,17,0,2,0,4,17,25],[ebqn_array:get(0,R),ebqn_array:get(1,R),ebqn_array:get(18,R),ebqn_array:get(57,R),1,-1,2],[[0,1,0,0]]]), % 1≡¯1-⊘+2
    1 = test([[0,2,0,1,16,0,0,0,2,17,25],[ebqn_array:get(18,R),ebqn_array:get(21,R),str("abc")],[[0,1,0,0]]]), % "abc"≡⊢"abc"
    1 = test([[0,3,0,1,0,2,17,0,0,0,3,17,25],[ebqn_array:get(18,R),ebqn_array:get(21,R),3,str("")],[[0,1,0,0]]]), % ""≡3⊢""
    1 = test([[3,0,0,1,16,0,0,3,0,17,25],[ebqn_array:get(18,R),ebqn_array:get(20,R)],[[0,1,0,0]]]), % ⟨⟩≡⊣⟨⟩
    1 = test([[3,0,0,1,0,2,17,0,0,0,2,17,25],[ebqn_array:get(18,R),ebqn_array:get(20,R),str("ab")],[[0,1,0,0]]]), % "ab"≡"ab"⊣⟨⟩
    1 = test([[0,4,0,2,0,0,7,16,0,1,0,3,17,25],[ebqn_array:get(0,R),ebqn_array:get(18,R),ebqn_array:get(44,R),4,2],[[0,1,0,0]]]), % 4≡+˜2
    1 = test([[0,5,0,2,0,0,7,0,4,17,0,1,0,3,17,25],[ebqn_array:get(1,R),ebqn_array:get(18,R),ebqn_array:get(44,R),3,1,4],[[0,1,0,0]]]), % 3≡1-˜4
    1 = test([[0,5,0,1,0,3,0,0,8,16,0,2,0,4,17,25],[ebqn_array:get(1,R),ebqn_array:get(2,R),ebqn_array:get(18,R),ebqn_array:get(52,R),1,-6],[[0,1,0,0]]]), % 1≡-∘×¯6
    1 = test([[0,6,0,1,0,3,0,0,8,0,5,17,0,2,0,4,17,25],[ebqn_array:get(1,R),ebqn_array:get(2,R),ebqn_array:get(18,R),ebqn_array:get(52,R),-6,2,3],[[0,1,0,0]]]), % ¯6≡2-∘×3
    1 = test([[0,5,0,1,0,3,0,0,8,16,0,2,0,4,17,25],[ebqn_array:get(1,R),ebqn_array:get(2,R),ebqn_array:get(18,R),ebqn_array:get(53,R),1,-7],[[0,1,0,0]]]), % 1≡-○×¯7
    1 = test([[0,6,0,1,0,3,0,0,8,0,5,17,0,2,0,4,17,25],[ebqn_array:get(1,R),ebqn_array:get(2,R),ebqn_array:get(18,R),ebqn_array:get(53,R),2,5,-7],[[0,1,0,0]]]), % 2≡5-○×¯7
    1 = test([[0,6,0,1,0,3,0,0,0,3,0,5,8,8,16,0,2,0,4,17,25],[ebqn_array:get(1,R),ebqn_array:get(2,R),ebqn_array:get(18,R),ebqn_array:get(54,R),-20,1,5],[[0,1,0,0]]]), % ¯20≡1⊸-⊸×5
    1 = test([[0,11,0,5,16,0,4,0,7,0,3,8,0,12,0,13,3,2,0,1,16,17,0,2,0,8,0,10,3,2,0,6,0,0,7,0,8,0,9,3,2,17,17,25],[ebqn_array:get(0,R),ebqn_array:get(13,R),ebqn_array:get(18,R),ebqn_array:get(19,R),ebqn_array:get(22,R),ebqn_array:get(27,R),ebqn_array:get(47,R),ebqn_array:get(54,R),0,2,1,4,str("ab"),str("cd")],[[0,1,0,0]]]), % (0‿2+⌜0‿1)≡(>⟨"ab","cd"⟩)≢⊸⥊↕4
    1 = test([[0,6,0,5,0,3,0,0,8,0,3,0,1,8,16,0,2,0,4,17,25],[ebqn_array:get(1,R),ebqn_array:get(2,R),ebqn_array:get(18,R),ebqn_array:get(55,R),20,1,5],[[0,1,0,0]]]), % 20≡×⟜(-⟜1)5
    1 = test([[0,6,0,1,0,3,0,0,8,0,5,17,0,2,0,4,17,25],[ebqn_array:get(0,R),ebqn_array:get(2,R),ebqn_array:get(18,R),ebqn_array:get(55,R),4,5,-3],[[0,1,0,0]]]), % 4≡5+⟜×¯3
    1 = test([[0,6,0,5,0,2,0,0,8,0,4,17,0,1,0,3,17,25],[ebqn_array:get(0,R),ebqn_array:get(18,R),ebqn_array:get(55,R),7,5,2,-3],[[0,1,0,0]]]), % 7≡5+⟜2 ¯3
    1 = test([[0,3,0,0,16,0,1,0,2,17,25],[ebqn_array:get(5,R),ebqn_array:get(18,R),2,4],[[0,1,0,0]]]), % 2≡√4
    1 = test([[0,3,0,0,0,2,17,0,1,0,2,17,25],[ebqn_array:get(5,R),ebqn_array:get(18,R),3,27],[[0,1,0,0]]]), % 3≡3√27
    ok = try test([[0,1,0,0,16,25],[ebqn_array:get(5,R),"x"],[[0,1,0,0]]]) %  √'x'
        catch _ -> ok
    end,
    1 = test([[0,4,0,0,0,3,17,0,1,0,2,17,25],[ebqn_array:get(10,R),ebqn_array:get(18,R),6,2,3],[[0,1,0,0]]]), % 6≡2∧3
    1 = test([[0,2,0,0,0,3,17,0,1,0,2,17,25],[ebqn_array:get(10,R),ebqn_array:get(18,R),0,-2],[[0,1,0,0]]]), % 0≡¯2∧0
    ok = try test([[0,1,0,0,0,2,17,25],[ebqn_array:get(10,R),-1,"a"],[[0,1,0,0]]]) %  'a'∧¯1
        catch _ -> ok
    end,
    1 = test([[0,4,0,2,0,0,7,16,0,1,0,3,17,25],[ebqn_array:get(11,R),ebqn_array:get(18,R),ebqn_array:get(44,R),0.75,0.5],[[0,1,0,0]]]), % 0.75≡∨˜0.5
    1 = test([[0,4,0,0,0,3,17,0,1,0,2,17,25],[ebqn_array:get(11,R),ebqn_array:get(18,R),1.75,2,0.25],[[0,1,0,0]]]), % 1.75≡2∨0.25
    ok = try test([[0,0,22,0,0,11,14,21,0,0,0,1,0,2,17,25],[ebqn_array:get(1,R),ebqn_array:get(11,R),2],[[0,1,0,1]]]) %  F←-⋄2∨f
        catch _ -> ok
    end,
    1 = test([[0,3,0,0,16,0,1,0,2,17,25],[ebqn_array:get(9,R),ebqn_array:get(18,R),0,1],[[0,1,0,0]]]), % 0≡¬1
    1 = test([[0,3,0,0,16,0,1,0,2,17,25],[ebqn_array:get(9,R),ebqn_array:get(18,R),1,0],[[0,1,0,0]]]), % 1≡¬0
    1 = test([[0,3,0,0,16,0,1,0,2,17,25],[ebqn_array:get(9,R),ebqn_array:get(18,R),2,-1],[[0,1,0,0]]]), % 2≡¬¯1
    ok = try test([[0,1,0,0,16,25],[ebqn_array:get(9,R),"a"],[[0,1,0,0]]]) %  ¬'a'
        catch _ -> ok
    end,
    1 = test([[0,4,0,0,0,3,17,0,1,0,2,17,25],[ebqn_array:get(9,R),ebqn_array:get(18,R),0,3,4],[[0,1,0,0]]]), % 0≡3¬4
    1 = test([[0,4,0,0,0,3,17,0,1,0,2,17,25],[ebqn_array:get(9,R),ebqn_array:get(18,R),2,4,3],[[0,1,0,0]]]), % 2≡4¬3
    1 = test([[0,4,0,0,0,3,17,0,1,0,2,17,25],[ebqn_array:get(9,R),ebqn_array:get(18,R),4,5,2],[[0,1,0,0]]]), % 4≡5¬2
    ok.
