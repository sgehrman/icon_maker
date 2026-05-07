#!/bin/bash

 
echo
echo '### optimize pngs'

# optipng -o7 icons/*.png

# parallelize the optimization using all available CPU cores
ls icons/*.png | xargs -P$(nproc) -I{} optipng -o7 {}                                                                               
