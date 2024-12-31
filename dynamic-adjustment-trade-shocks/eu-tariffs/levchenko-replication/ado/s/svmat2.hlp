.-
help for ^svmat2^                                                  (STB-56: dm79)
.-

Convert matrix to variables
---------------------------

        ^svmat2^ [type] A
        [^, n^ames^(^{^col^|^eqcol^|^matcol^|stub^*^|namelist}^)^
        ^r^names^(^newvar^) f^ull ]

where A is the name of an existing matrix and type is a storage type for
new variables.


Description
-----------

^svmat2^ takes a matrix and stores its columns as new variables.  It is
the reverse of ^mkmat^.

^svmat2^ adds to ^svmat^ (in official Stata) options to save matrix row
names in a new string variable and to use any desired new variable
names.


Remarks
-------

Matrix column names including colons ^:^ (always) or periods ^.^
(usually) cannot be used as variable names.


Options
-------

^n^ames^(col^|^eqcol^|^matcol^|stub^*^|namelist^)^ specifies how the new
     variables are to be named.

    ^names(col)^ uses the column names as the names of the variables.

    ^names(eqcol)^ uses the equation names prefixed to the column names.

    ^names(matcol)^ uses the matrix name prefixed to the column names.

    ^names(^stub^*)^ names the variables stub^1^, stub^2^, ... . The ^*^
    must be given. Note: this convention differs from that in ^svmat^.

    ^names(^namelist^)^ names the variables according to the names in
    namelist, one new name for each column in varlist.

    If ^names()^ is not specified, the variables are named A^1^, A^2^,
    ..., where A is the name of the matrix.  If necessary, names will be
    truncated to 8 characters; if these names are not unique, an error
    will be returned.

^rnames(^newvar^)^ names a new string variable for storing matrix
    row names.

^full^ specifies that full row names are to be used. This is relevant
    only under Stata 6.0 or greater.


Examples
--------

        . ^regress mpg weight gratio foreign^

        Stata 5.0:
        . ^matrix c = get(_b)^
        . ^matrix c = c'^

        Stata 6.0:
        . ^matrix c = e(b)'^

        . ^svmat2 double c, name(bvector) r(Bnames)^
        . ^list bvector1 Bnames in 1/5^


Author
------

        Nicholas J. Cox, University of Durham, U.K.
        n.j.cox@@durham.ac.uk


Acknowledgement
---------------

        Vincent Wiggins gave very helpful advice.


Also see
--------

 Manual:  ^[R] matrix mkmat^
On-line:  help for @matrix@
