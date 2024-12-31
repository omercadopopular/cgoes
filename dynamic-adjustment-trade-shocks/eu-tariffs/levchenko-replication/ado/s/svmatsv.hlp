.-
help for ^svmatsv^                                                 (STB-56: dm79)
.-

Convert matrix to single variable
---------------------------------

        ^svmatsv^ [type] A ^, g^enerate^(^newvar^)^ [ ^lh pd uh^ ]

where A is the name of an existing matrix and type is a storage type for
new variables.


Description
-----------

^svmatsv^ takes a matrix and stores its values as a single new variable.
Values are in row major order, i.e. ^A[1,2]^ precedes ^A[2,1]^ whenever both 
are included. If column major order is desired, transpose the matrix first.  

^svmatsv^ requires that the number of values saved should not exceed
the current number of observations. If desired, increase that by using 
^set obs^. See help on @obs@.  


Options
-------

^generate(^newvar^)^ specifies the name of the new variable and is a required 
     option.    

For a square matrix, 

    ^lh^ specifies that the lower half matrix is to be stored. This consists 
    of elements below the principal diagonal. 

    ^pd^ specifies that the principal diagonal (a.k.a. major or main 
    diagonal, or just diagonal) is to be stored. For a matrix ^A^, this is 
    ^A[1,1]^, ^A[2,2]^, etc. 

    ^uh^ specifies that the upper half matrix is to be stored. This consists 
    of elements above the principal diagonal. 

    ^lh^, ^pd^ and ^uh^ may be used in any combination. 


Examples
--------

        (correlation matrix) 
        . ^matrix accum R = x*, noc d^
	. ^matrix R = corr(R)^   

	. ^svmatsv R, gen(corr) lh^ 
	. ^gra corr, xsc(-1,1) bin(50)^ 


	(table of counts) 
	. ^tab x y, matcell(T)^
	
	. ^svmatsv T, gen(freq)^ 
	

Author
------

        Nicholas J. Cox, University of Durham, U.K.
        n.j.cox@@durham.ac.uk



Acknowledgements
----------------

        Kit Baum made helpful comments. 
	
Also see
--------

 Manual:  ^[R] matrix mkmat^
On-line:  help for @matrix@, @obs@ 

