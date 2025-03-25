#import Pkg; Pkg.add("Optim")
using Optim

P(x,y) = x^2 - 3x*y + 5y^2 - 7y + 3   # user defined function

z₀ = [ 0.0
       0.0 ]     # starting point 

optimize(z -> P(z...), z₀, ConjugateGradient())
optimize(z -> P(z...), z₀, Newton())
optimize(z -> P(z...), z₀, Newton();autodiff = :forward)

