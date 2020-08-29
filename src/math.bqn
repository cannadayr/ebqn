# Univariate Sample Statistics
Mean  ← { (+´÷≠) 𝕩}                    # arithmetic
Mmnt  ← {+´𝕨⋆˜𝕩-Mean 𝕩}                # moment
Ctrl  ← {(≠𝕩)÷˜𝕨 Mmnt 𝕩}               # central moment
Stdev ← {√(1-˜≠𝕩)÷˜2 Mmnt 𝕩}           # stdev
Skew  ← Ctrl {(3 𝔽 𝕩)÷(3÷2)⋆˜2 𝔽 𝕩}    # skewness
Kurt  ← Ctrl {(2⋆˜2 𝔽 𝕩)÷˜4 𝔽 𝕩}       # kurtosis

# Univariate Population Statistics #TODO

