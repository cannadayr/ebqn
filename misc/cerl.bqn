#! /usr/bin/env dbqn
args←•args
"Usage: ./cc.bqn path/to/mlochbaum/BQN <one of [rcfe] or an expression>"!2≤≠args
return ← 1≡⊑args
args↓˜↩ return
path←(⊑args)∾"/src/"
args↓˜↩1

# Erlang formatting
L ← "["∾"]"∾˜1↓·∾","⊸∾¨       # Native list/array
Ind ← {∾"ebqn_array:get("‿𝕩‿","‿𝕨‿")"}          # Native list/array indexing
Cat ← {∾𝕨‿"lists:append(ebqn_core:fns(),"‿𝕩‿")"}   # Native list/array concatenation (like ∾)
# Escape the special characters that appear in BQN sources.
Esc←{
  in ← (@+0‿9‿10‿13)∾"'"""   # Null, Tab, LF, CR, and quotes
  out ← "0tnr"               # Whitespace characters changed to letters
  i ← in⊐𝕩
  𝕩 ↩ i ⊏⟜out⌾((i<≠out)⊸/) 𝕩 # Replace
  ∾(i<≠in) /⟜"\"⊸∾¨ 𝕩        # Insert \
}
Str ← "ebqn:str("""∾Esc∾""")"˜       # A BQN string
Char ← {"ebqn:char("""∾𝕩∾""")"}Esc∘⥊ # A BQN character
FP ← ∞⊸=◶⟨⍕,"inf"⟩              # Format positive number
Num0 ← 0⊸≤◶⟨"-"∾FP∘|,FP⟩        # Format number
Num ← ¯∞⊸≢◶⟨"n"∾Num0∘|,Num0⟩

F ← ⍕  # Format number

Import ← {𝕨•Import path∾𝕩}
FChars ← {𝕨•FChars path∾𝕩}
FLines ← {𝕨•FLines path∾𝕩}

glyphs ← Import "glyphs.bqn"
_getComp ← { (3+useInd) ↑ (𝕗 Import "c.bqn"){𝔽} }
useInd ← "-i"≡⊑args ⋄ args↓˜↩useInd
Comp ← ((<"Rt#a.r" Ind ⍕)¨↕62) glyphs _getComp ⊢
J ← ∾∾⟜\n¨
Fconst ← ≡◶⟨@⊸≤◶Num‿Char, Str, ⊑⟩
Fout ← (≠↑⟨F,Fconst,L ·F¨4⊸↑,F⟩˙) {L𝕎¨𝕩}¨ ⊢
Frun ← ""⊸Cat⌾(1⊸⊑) Fout
Long ← ∾ (≠↑1‿3/⟨"  "⊸∾⋄((@+10)∾" ,")⊸∾⟩˙) {𝕎𝕩}¨ ⊢

RT ← {
  src‿need‿inputs←𝕩Import"pr.bqn"
  pr←"runtime_0"‿"Pr"{(∾𝕨<⊸(<∘{∾"ebqn_array:get("‿𝕩‿","‿𝕨‿"#a.r"‿")"}⟜F¨)⟜(↕≠)¨𝕩)⊏˜(∾𝕩)⊐∾need}○((-1+1=𝕩)⊸↑)inputs
  Long Fout pr need _getComp src
}
CArg ← {J (¯5⊸↓∾𝕩˙)⌾⊑ FLines "c.bqn"}
LFC ← Long∘Fout∘Comp

•Out⍟(¬return) (⊑"r"‿"r0"‿"r1"‿"c"‿"f"⊐⊏)◶⟨
  RT∘2, RT∘0, RT∘1
  {𝕩⋄LFC CArg "⟨"∾"⟩"«∾","⊸∾¨'"'(⊣∾∾˜)¨glyphs}
  {𝕩⋄LFC FChars "f.bqn"}
  ¯1 ↓ · J L∘Fout∘Comp¨
⟩ args
