{smcl}
{* *! version 1.0.4 19AUG2014}{...}
{cmd:help libjson}
{hline}

{title:Title}

     {hi:libjson: a mata class library for obtaining and parsing JSON strings into object trees}


{title:Description}
{pstd}The libjson class (library) is designed to be called from the Mata environement to perform tasks related to obtaining a JavaScript Object Notation (JSON) formatted response from the file or website URL (via a REST API).
Most users will want to write an ado file that employs the libjson object to do all the heavy lifting, with the final tailoring of the output to be handled by the ado file.
The first eight methods are the workhorse methods that most programmers will use (plus perhaps the four ulitily methods). The rest are included for exceptional cases.
See the code examples below for more information.

{title:Public Methods}

{col 5}   {c TLC}{hline 47}{c TRC}
{col 5}{hline 3}{c RT}{it: Methods used for calling JSON-based REST APIs }{c LT}{hline}
{col 5}   {c BLC}{hline 47}{c BRC}

	{synopt:{opt static pointer (class libjson scalar) scalar webcall(string scalar url_base, string matrix args)}}Calls the REST API using the given URL and Args, parses the JSON response, and returns the root node of the libjson object tree. 
	Arguments in the form of the given N x 2 string matrix are used to construct the full url with all values properly formatted("escaped") for use in a URL.

	{synopt:{opt static string matrix webcall_flatten(string scalar url_base, string matrix args)}}Call the web REST API, and pass the results though flatten().

{col 5}   {c TLC}{hline 20}{c TRC}
{col 5}{hline 3}{c RT}{it: Sub-Tree selection }{c LT}{hline}
{col 5}   {c BLC}{hline 20}{c BRC}

	{synopt:{opt pointer (class libjson scalar) scalar getNode(string rowvector selector)}}Returns the node branch address by given selector.

	{synopt:{opt string scalar getString(string rowvector selector, string scalar missing_val)}}Returns the Scalar addressed by given selector.

	{synopt:{opt real scalar getReal(string rowvector selector, real scalar missing_val)}}Returns the real number (converted from the Scalar addressed by given selector). 

	{synopt:{opt static string rowvector parseSelector(string scalar selstr)}}Converts a selector string into the vector format by breaking up the string at the colons. 

{col 5}   {c TLC}{hline 35}{c TRC}
{col 5}{hline 3}{c RT}{it: Working with flat key-value pairs }{c LT}{hline}
{col 5}   {c BLC}{hline 35}{c BRC}

	{synopt:{opt string matrix flattenToKV()}} Return the entire libjson object as a list of flattened object names and values. Useful for processing small json responses from web servers.

	{synopt:{opt static string scalar getFlattenedValue(string matrix flattened_results, string scalar key, string scalar value_if_missing)}}Scans the given flatten() resutls for the given key, and returns the scalar (string) value. A helper function for scanning the result of flatten() for particular key-value pairs {p_end}

{col 5}   {c TLC}{hline 16}{c TRC}
{col 5}{hline 3}{c RT}{it: Utility methods}{c LT}{hline}
{col 5}   {c BLC}{hline 16}{c BRC}

	{synopt:{opt static string scalar urlencode(string scalar s)}}Returns the given string with certain unsafe characters escaped as necessary for use in a URL.
	
	{synopt:{opt static string scalar getrawcontents(string scalar url_base, string matrix args)}}Makes an http request using the given URL and extra arguments, and returns the results as a single string.

	{synopt:{opt static real rowvector getVersion()}}Returns a vector with the library version number, in form of (major, minor, build).

	{synopt:{opt static real rowvector checkVersion(real rowvector version_to_check)}}True if the library version number exceeds that of version_to_check.

{col 5}   {c TLC}{hline 34}{c TRC}
{col 5}{hline 3}{c RT}{it: Working with libjson trees/nodes }{c LT}{hline}
{col 5}   {c BLC}{hline 34}{c BRC}

	{synopt:{opt real scalar isArray()}}true if this libjson object is holding an Array.
	
	{synopt:{opt real scalar isObject()}}true if this libjson object is holding an Object.
	
	{synopt:{opt real scalar isAttribute()}}true if this libjson object is holding an Attribute (name/value pair).
	
	{synopt:{opt real scalar isString()}}true if this libjson object is holding a string literal, or an attribute that holds a literal.
	
	{synopt:{opt real scalar isScalar()}}true if this libjson object is holding a scalar value (=string).

	{synopt:{opt real scalar arrayLength()}} returns the number of objects in an Array.
	
	{synopt:{opt pointer (class libjson scalar) scalar getArrayValue()}}returns the Nth element of the array.

	{synopt:{opt string scalar getAttributeScalar(string scalar key, string scalar missing_value)}} returns the named attribute as a scalar (string) value {p_end}

	{synopt:{opt pointer (class libjson scalar) scalar getAttribute(string scalar key)}}returns a pointer to the named attribute contained in this Object.

	{synopt:{opt string scalar getAttributeName()}} returns the name of an Attribute.

	{synopt:{opt string rowvector listAttributeNames(real scalar one_string_flag)}} Returns a list of the attributes of the Object.

	{synopt:{opt string scalar bracketArrayScalarValues()}} Returns all scalar values in the array in the familiar bracket notation.

	{synopt:{opt void prettyPrint()}}Print to the console the libjson object tree in a human-readible form that is JSON compliant.

	{synopt:{opt string scalar toString()}}Reconstitutes the given libjson tree into a JSON string. Note that this will not be a perfect reproduction of the original input becuase all numbers and unquoted words get converted to strings (ie. 'null','true','false', etc.).

{col 5}   {c TLC}{hline 24}{c TRC}
{col 5}{hline 3}{c RT}{it: Building libjson trees }{c LT}{hline}
{col 5}   {c BLC}{hline 24}{c BRC}

	{synopt:{opt pointer (class libjson scalar) scalar parse(string scalar libjson_string)}}Parses the given JSON-formatted string into a libjson object tree, and returns the root node.

	{synopt:{opt void addArrayValue(pointer (class libjson scalar) scalar p)}}Adds the libjson object to the end of the array.
	
	{synopt:{opt void addArrayScalar(string scalar s)}} Adds the string to the end of the array as a Scalar object.
	
	{synopt:{opt void addAttributeScalar(string scalar key, string scalar val)}}Adds the key/value(string) to the end of the array as a Scalar Attribute object.
	
	{synopt:{opt void addAttribute(string scalar key, pointer (class libjson scalar) val)}}Adds the libjson object  to the end of the array as a Scalar Attribute object.
	
	{synopt:{opt void makeScalar()}} Force the libjson object to hold the given string.

{hline}
{p2colreset}

{title:Selectors}
{pstd}Selectors are a series of named (or implicitly named in the case of arrays, which start at index "1") branches to take, starting from the given node (usually the root node).
 
Given the following example JSON object: 
	{
	"foo" : "1", 
 	"bar": {
              "bar2":"2"
              },
  	"foobar": [ "bar1","bar2"]
     }
      
the results of the following selectors would be...
{lalign 30:{space 10}{opt ("foo")}} --> "1"
       
{lalign 30:{space 10}{opt ("bar","bar2")}} --> "2"

{lalign 30:{space 10}{opt ("foobar","2")}} --> "bar2"

{lalign 30:{space 10}{opt ("bar")}} --> Depends. If a node is expected, then the node is selected. If a Scalar (string, real) is expected, then is NOT FOUND and considered missing.

{title:Flattened Selectors}
{pstd}  A "flattened" selector is a single string with a colon inserted between each selector. For example,  ("foo":"bar") --> "foo:bar".	

{title:Code Examples}
{p 4 17 2}In the following examples, it is assumed that the source is returns a JSON object with a status result in meta:result that we need to test.
	
 {hi:Example with libjson object tree result}: 
    pointer (class libjson scalar) scalar root
    root = libjson::webcall("http://server.address/service_name/",("arg1","val1" \ "arg2", "val2"))
    if (root && root->getString(("meta", "result"),"") == "OK") { ... }


 {hi:Example with "flattened" response (for those not comfortable with object trees, or for trivial JSON responses)}: 
    key_val_matrix = libjson::webcall_flatten("http://server.address/service_name/",("arg1","val1" \ "arg2", "val2"))
    if (libjson::getFlattenedValue(key_val_matrix, "meta:result")) == "OK") { ... }


 {hi:Example for loading a JSON object from a local file}: 
    pointer (class libjson scalar) sclar root
    root = libjson::webcall("/path/to/local/JSON/file",.)
    if (root && root->getString(("meta", "result"),"") == "OK") { ... }


 {hi:Note that to use these examples interactively from the command line (or when embedded in an ado file), one must wrap them in a mata function body. For example,}

			string rowvector getExampleDataRow(url, string rowvector selectors) {
				pointer (class libjson scalar) scalar root
			    root = libjson::webcall(url,"")
			    if (root) {
				    string rowvector res
				    res = J(1,cols(selectors),"")
				    for (c=1; c<= cols(selectors); c++) {	
				    		res[c] = root->getString( libjson::parseSelector(selectors[c]) ,"")
				    }
					return(res)
				} else return(J(1,0,""));
			}
			data=getExampleDataRow("http://server.address/service_name/",("meta:result","flattened_selector1","flattened_selector2"))
 
 {hi:will extract the selected scalars values from a valid JSON response and place them in a string rowvector.}

	
{title:Latest Version}
{pstd}
The latest version is always kept on the SSC website. To install the latest version click
on the following link 

{pstd}
{stata ssc install libjson, replace}.

{title:Recompiling}
{pstd}
If you get an error about the version of the .mlib file not being compatible (and you are running Stata 11 or newer), the library can be recompiled locally with:

{pstd}
{cmd: do "libjson_source.mata"}

{pstd}However, you will likely then need to manually copy the new library over the old one.
 
{title:Author}

{pstd}
Erik Lindsley, Ph.D. ( {browse "mailto:ssc@holocron.org":ssc@holocron.org} ){p_end}

{title:Special Thanks}

{pstd}To my testers & bug reporters:{p_end}
	Alejandro Molnar
