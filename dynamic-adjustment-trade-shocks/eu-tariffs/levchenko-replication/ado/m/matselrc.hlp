.-
help for ^matselrc^                                                (STB-56: dm79)
.-

Selection of rows and/or columns from matrix
--------------------------------------------

    ^matselrc^ matrix1 matrix2 [^, r^ow^(^rows^) c^ol^(^cols^) n^ames ]


Description
-----------

Given matrix1, ^matselrc^ produces matrix2 containing only specified rows 
and/or columns. 

^matselrc^ takes the order of row and column specification literally, 
and thus could be used to reorder the rows and/or columns of a matrix. 


Options
-------

^row(^rows^)^ specifies rows. The specification should be either a 
    numlist containing integers between 1 and the number of rows, or 
    a list of row names, in which case each individual name should be 
    explicit. Quotation marks ^" "^ should not be used in the second case. 
    
^col(^cols^)^ specifies columns. The specification should be either a 
    numlist containing integers between 1 and the number of columns, 
    or a list of column names, in which case each individual name should be 
    explicit. Quotation marks ^" "^ should not be used in the second case. 

^names^ is for a special case, when the row or column names would look 
    like a numlist to Stata, but they are really names. Thus 
    ^matrix rowname A = 3 2 1^ is legal in Stata for a matrix with 3 rows. 
    The ^names^ option is used to force Stata to treat ^row(3 2 1)^ as 
    a specification of row names. 


Examples
--------

    . ^matselrc A B, c(1 2 3)^

    . ^matselrc A A, c(1/3)^ 

    . ^matselrc A B, r(mpg foreign weight) c(mpg foreign weight)^ 

    (to reverse the columns of a 4 X 5 matrix) 
    . ^matselrc B B, c(5/1)^ 

    (to reverse the rows of a 4 X 5 matrix) 
    . ^matselrc B B, r(4/1)^ 


Author
------

        Nicholas J. Cox, University of Durham, U.K.
        n.j.cox@@durham.ac.uk


Also see
--------

 Manual:  ^[U] 17 Matrix expressions^, ^[R] matrix^
On-line:  help for @matrix@, @numlist@ 

