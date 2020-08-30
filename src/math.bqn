# Univariate Sample Statistics
Mean  ← { (+´÷≠) 𝕩}                     # arithmetic mean #pub
Diff  ← {+´𝕨⋆˜𝕩-Mean 𝕩}                 # mean power diff
Ndiff ← {(≠𝕩)÷˜𝕨 Diff 𝕩}                # normal mean power diff
Stdev ← {√(1-˜≠𝕩)÷˜2 Diff 𝕩}            # standard deviation #pub
Mmnt  ← Ndiff {((𝕨÷2)⋆˜2 𝔽 𝕩)÷˜𝕨 𝔽 𝕩}   # moment
Skew  ← {3 Mmnt 𝕩}                      # skewness #pub
Kurt  ← {4 Mmnt 𝕩}                      # kurtosis #pub

# tests
#    Stdev ⟨2,3,4,6,13,2⟩
# 4.19523539268061
#    Skew ⟨2,3,4,6,13,2⟩
# 1.33525474738746
#    Kurt ⟨2,3,4,6,13,2⟩
# 3.31301652892562

# Univariate Population Statistics #TODO


