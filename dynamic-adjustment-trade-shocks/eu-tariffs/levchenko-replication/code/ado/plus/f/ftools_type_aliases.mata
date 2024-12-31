// Type aliases -------------------------------------------------------------

        // Numeric (scalars)
        loc Boolean           real scalar
        loc Integer           real scalar
        loc Real              real scalar

        // Numeric (matrices)
        loc Vector            real colvector
        loc RowVector         real rowvector
        loc Matrix            real matrix

        // String (scalars)
        loc String            string scalar
        
        // String (matrices)
        loc StringVector      string colvector
        loc StringRowVector   string rowvector
        loc StringMatrix      string matrix

        // Stata-specific
        loc Varname           string scalar
        loc Varlist           string rowvector // after tokens()

        loc Variable          real colvector // N * 1
        loc Variables         real matrix // N * K

        loc DataFrame         transmorphic matrix // N * K
        loc DataCol           transmorphic colvector // N * 1
        loc DataRow           transmorphic rowvector // 1 * K
        loc DataCell          transmorphic scalar // 1 * 1

        // Classes
        loc Handle            transmorphic scalar // General scalar
        loc Anything          transmorphic matrix // General matrix
        loc Dict              transmorphic scalar // Use for asarray()
        loc Factor            class Factor scalar

        // Pointers
        local FunctionP       pointer(`Variables' function) scalar

        // Misc
        loc Void              void


// Backwards compatibility for Mata functions -------------------------------

        loc selectindex selectindex
        loc panelsum panelsum

        if (c(stata_version) < 13) {
                cap mata: boottestVersion()
                if (c(rc)) {
                        di as err "Error: Stata versions 12 or earlier require the boottest package"
                        di as err "To install, from within Stata type " _c
                        di as smcl "{stata ssc install boottest :ssc install boottest}"
                        exit 601
                }
                loc selectindex boottest_selectindex
                loc panelsum _panelsum
        }
