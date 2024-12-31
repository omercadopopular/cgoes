.-
help for ^matcorr^                                                 (STB-56: dm79)
.-

Correlation (covariance) matrix
-------------------------------

    ^matcorr^ varlist [^if^ exp] [^in^ range] [weight] ^, m^atrix^(^matname^)^
               [ ^c^ovariance ] 


Description
-----------

^matcorr^ puts the correlations (optionally the variances and 
covariances) of varlist into matrix matname. 


Remarks
-------

As with ^correlate^, ^matcorr^ performs casewise deletion so 
that all correlations are calculated from those observations for 
which non-missing values exist for all variables in varlist. 


Options
-------

^matrix(^matname^)^ specifies the name of a matrix to hold the 
results. It is a required option. 

^covariance^ specifies the calculation of covariances. 


Examples
--------

    . ^matcorr A B C D, m(R)^
    . ^matcorr A B C D, m(R) c^ 


Author
------

         Nicholas J. Cox, University of Durham, U.K.
         n.j.cox@@durham.ac.uk


Also see
--------

On-line: help for @correlate@ 
 Manual: [R] correlate, [R] matrix accum 
 

