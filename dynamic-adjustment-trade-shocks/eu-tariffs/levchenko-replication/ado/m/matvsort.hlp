.-
help for ^matvsort^                                                (STB-56: dm79)
.-

Sort vector
-----------

    ^matvsort^ vector1 vector2 [ ^, d^ecrease ]  

    
Description
-----------

Given vector1 (a 1 X c matrix or an r X 1 matrix), ^matvsort^ 
sorts the elements into numeric order and places the sorted elements 
into vector2. vector2 may have the same name as vector1, in which case the 
original vector is overwritten. 

By default, elements are sorted into increasing order, smallest first.  


Options
------- 

^decrease^ specifies sorting into decreasing order, smallest last. 


Remarks
-------

^matvsort^ may make it easier to identify the smallest or largest element(s) 
of a vector. If a vector ^b^ has been sorted into increasing order, its 
smallest element is accessible as ^b[1,1]^ and its largest as ^b[1,colsof(b)]^ 
if ^b^ is a row vector and ^b[rowsof(b),1]^ if ^b^ is a column vector. 

The corresponding names are accessible as in this example: 

    ^local colnames : colnames b^
    ^local c1name : word 1 of `colnames'^ 

^matvsort^ typically changes the sort order of the data. You may need to 
resort the data. 


Examples
--------

    . ^matvsort b b^
    . ^matvsort b bsort^
    . ^matvsort b bsort, d^ 


Author
------

         Nicholas J. Cox, University of Durham, U.K.
         n.j.cox@@durham.ac.uk


Also see
--------

 Manual: ^[U] 17 Matrix expressions^
         ^[R] matrix^
On-line: help for @matrix@

