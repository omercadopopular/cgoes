.-
help for ^matvtom^                                                 (STB-56: dm79)
.-

Convert vector to matrix
------------------------

        ^matvtom^ a B ^, r^ow^(^#^) c^ol^(^#^) o^rder^(^{ ^r^ow|^c^ol}^)^

where a is the name of an existing vector and B is the name of an existing 
or new matrix.


Description
-----------

^matvtom^ converts a vector (r X 1 or 1 X c) to a ^row^ X ^col^ matrix 
so long as the numbers of elements in the vector and the matrix are equal. 


Options
-------

^row(^#^)^ specifies the number of rows in the new matrix. 
        
^col(^#^)^ specifies the number of columns in the new matrix. 

^order(^ ^)^ specifies whether elements are to be assigned row by row or 
column by column. 

    ^order(row)^ (or ^order(r)^) specifies that the first ^row^ elements 
    of a will be the first row of B, and so forth.

    ^order(col)^ (or ^order(c)^) specifies that the first ^col^ elements 
    of a will be the first column of B, and so forth. 

All options are required. 


Examples
--------

	(a is either a 10 X 1 vector, or a 1 X 10 vector) 

	. ^matvtom a B, r(5) c(2) o(r)^
	
Author
------

        Nicholas J. Cox, University of Durham, U.K.
        n.j.cox@@durham.ac.uk


Also see
--------

On-line:  help for @matvec@ (if installed), @matvech@ (if installed) 

