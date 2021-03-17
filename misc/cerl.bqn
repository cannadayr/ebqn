#! /usr/bin/env dbqn

# Javascript/JSON formatting
L ← "["∾"]"∾˜1↓·∾","⊸∾¨       # Native list/array
Ind ← {∾"ebqn_array:get("‿𝕩‿","‿𝕨‿")"}          # Native list/array indexing
Cat ← {∾𝕨‿"lists:append(ebqn_core:fns(),"‿𝕩‿")"}   # Native list/array concatenation (like ∾)
# Escape the special characters that appear in BQN sources.
Esc←{
  in ← (@+0‿9‿10‿13)∾"'"""    # Null, Tab, LF, CR, and quotes
  out ← "0tnr"                # Whitespace characters changed to letters
  i ← in⊐𝕩
  𝕩 ↩ i ⊏⟜out⌾((i<≠out)⊸/) 𝕩  # Replace
  ∾(i<≠in) /⟜"\"⊸∾¨ 𝕩         # Insert \
}
Str ← "str("""∾Esc∾""")"˜     # A BQN string
Char ← '"'(∾∾⊣)Esc∘⥊          # A BQN character
FP ← ∞⊸=◶⟨⍕,"inf"⟩            # Format positive number
Num0 ← 0⊸≤◶⟨"-"∾FP∘|,FP⟩      # Format number
Num ← ¯∞⊸≢◶⟨"n"∾Num0∘|,Num0⟩

F ← ⍕  # Format number

compile ← •Import "c.bqn"
useInd ← "-i"≡⊑args←•args ⋄ args↓˜↩useInd
Comp ← (3+useInd) ↑ ((<"Runtime" Ind ⍕)¨↕62)⊸Compile
J ← ∾∾⟜(@+10)¨
Fconst ← ≡◶⟨@⊸≤◶Num‿Char, Str, ⊑⟩
Fout ← (≠↑⟨F,Fconst,L F¨,F⟩˙) {L𝕎¨𝕩}¨ ⊢
Frun ← ""⊸Cat⌾(1⊸⊑) Fout
Long ← ∾ (≠↑1‿3/⟨"  "⊸∾⋄((@+10)∾" ,")⊸∾⟩˙) {𝕎𝕩}¨ ⊢
•Out (⊑"r"‿"c"‿"f"‿"e"⊐⊏)◶⟨
  {𝕩⋄ref‿len←•Import"pr.bqn"⋄Long Frun len⊸↓⌾(1⊸⊑)Comp ref}
  {𝕩⋄Long Fout Comp •FChars "c.bqn"}
  {𝕩⋄Long Fout Comp •FChars "f.bqn"}
  {𝕩⋄Long Fout Comp ⟨"Modify←GetHighlights←⊢⋄"⟩∾∾ •FChars∘∾⟜".bqn"¨ "../svg"‿"e"}
  ¯1 ↓ · J L∘Fout∘Comp¨
⟩ args