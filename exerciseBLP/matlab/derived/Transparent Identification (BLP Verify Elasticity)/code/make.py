#! /usr/bin/env python
#****************************************************
# GET LIBRARY
#****************************************************
import subprocess, shutil, os
gslab_make_path = os.getenv('gslab_make_path')
subprocess.call('svn export --force -r 27564 ' + gslab_make_path + ' gslab_make', shell = True)
from gslab_make.py.get_externals import *
from gslab_make.py.make_log import *
from gslab_make.py.make_links import *
from gslab_make.py.make_link_logs import *
from gslab_make.py.run_program import *
from gslab_make.py.dir_mod import *

#****************************************************
# MAKE.PY STARTS
#****************************************************
clear_output_dirs()
start_make_logging()

# GET_EXTERNALS
get_externals('externals.txt')

# RUN CODE
run_command(command = 'tgauss -b build.gau')

end_make_logging()

shutil.rmtree('gslab_make')
raw_input('\n Press <Enter> to exit.')
