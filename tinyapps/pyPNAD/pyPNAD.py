# -*- coding: utf-8 -*-

"""
pyPNAD
October 2017 release

The purpose of this code is to import PNAD and PNADC microdata,
released by the Brazilian Office of Statistics (IBGE), into a
pandas DataFrame in a simple and straightforward fashion.

This code was originally written by Lincoln de Sousa.
The original code can be found on https://github.com/clarete/pnad
I was then simplified and updated by Carlos Góes on October 2017.

The procedure is quite simple. The main() function requires two
parameters:
    
main(data_file, input_file)
    
* data_file is a the raw text file that holds the microdata for
    every PNAD and PNAD.
* input_file is a SAS variable dictionary, which is a companion file to
    the microdata and contains variable names, text positions, and lenghts.

"""

import io
import pandas as pd

# Parse through dictionary line,
    # return name, position, size, and label

def get_var(line):
    # Read
    position, rest = line.split(' ', 1)
    variable, rest = rest.strip().split(' ', 1)
    size, rest = rest.strip().split(' ', 1)
    comment = rest.replace('/*', '').replace('*/', '').strip()

    # Convert
    position = int(position.replace('@', ''))
    variable = variable.strip()
    size = int(float(size.replace('$', '')))

    return {
        'name': variable,
        'position': position,
        'size': size,
        'comment': comment,
    }
    
# Parse through dictionary line,
    # return a colection of names, positions, sizes, and labels

def get_vars(varsfile):
    variables = []
    for line in varsfile:
        if line[0] is '@':
            variable = get_var(line)
            variables.append(variable)
        else:
            pass
    return variables

# Parse through all variables in PNAD,
    # return column names and widths

def col_widths(vars_file):
    vars_fp = io.open(vars_file)
    variables = get_vars(vars_fp)
    
    columns = [var['name'] for var in variables]
    widths = [var['size'] for var in variables]
   
    return columns, widths

# Loads all input and source files,
    # returns a pandas DataFrame

def main(data_file, input_file):
    columns, widths = col_widths(input_file)
    df = pd.read_fwf(data_file, widths=widths, header=None, names=columns)
    return df
