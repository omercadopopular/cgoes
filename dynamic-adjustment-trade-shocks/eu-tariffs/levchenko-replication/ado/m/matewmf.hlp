.-
help for ^matewmf^                                                 (STB-56: dm79)
.-

Elementwise monadic function applied to matrices
------------------------------------------------

    ^matewmf^ matrix1 matrix2 ^, f^unction^(^f^)^


Description
-----------

Given matrix ^A^ and a user-supplied monadic function f with Stata syntax 
f^( )^, ^matewmf^ calculates and displays matrix ^B^ with typical element

    ^B[i,j] =  f(A[i,j])^ 
    
provided that no ^B[i,j]^ would be missing. 

B may overwrite A. 


Option
------

^function(^f^)^ specifies a monadic function and is a required option. 
    The function must have Stata syntax f^( )^, take a single finite 
    numeric argument and produce a single finite numeric result.
    See help on @functions@.  


Example
-------

    . ^matewmf A B , f(exp)^


Author
------

         Nicholas J. Cox, University of Durham, U.K.
         n.j.cox@@durham.ac.uk


