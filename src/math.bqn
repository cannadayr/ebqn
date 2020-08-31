# Loading
# )cs •Ex "../bqn-ws/src/math.bqn"

# Univariate Sample Statistics

⟨Mean,Stdev,Skew,Kurt⟩ ← {
    Mean  ← { (+´÷≠) 𝕩}
    _foo  ← { (𝕗 +≠ 𝕩) ÷˜ +´(𝕩 - Mean 𝕩) ⋆ 𝕨    }
    _bar  ← { (𝕨 𝔽  𝕩) ÷    (2   𝔽    𝕩) ⋆ 𝕨 ÷ 2}
    Stdev ← { √ 2(¯1 _foo)      𝕩}
    Skew  ← {   3( 0 _foo) _bar 𝕩}
    Kurt  ← {   4( 0 _foo) _bar 𝕩}
    ⟨Mean,Stdev,Skew,Kurt⟩
}

# tests
#    Stdev ⟨2,3,4,6,13,2⟩
# 4.19523539268061
#    Skew ⟨2,3,4,6,13,2⟩
# 1.33525474738746
#    Kurt ⟨2,3,4,6,13,2⟩
# 3.31301652892562

# Univariate Population Statistics #TODO

⍎
