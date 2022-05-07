import re
import os

# Importing auxiliar libraries for the test
import argparse                     # This library allows us to easily parse the command line arguments
from pathlib import Path
from pyexcel_ods import get_data    # This function allows us to easily read an ODS file (for api)

# Importing test configuration file
import config

######### WE WILL PARSE THE COMMAND LINE ARGUMENTS FOR THE WRAPPER GEN #############
parser = argparse.ArgumentParser(description='Launches a PORIS xml generation from an ODS file describing the PORIS instrument')

## The second argument is the api ODS file
parser.add_argument('sys_file', help="The name of the device")

# Obtaining the arguments from the command line
args=parser.parse_args()

# Printing the obtained arguments:
print("The PORIS instrument description ODS filename is:",args.sys_file+".ods")
projectName = args.sys_file

# Read excel file with functions

# Now we read the methods list from the file
functionsfile = "./"+projectName+".user/methods.ods"
functionsdata = get_data(functionsfile,start_row=config.methods_file_start_row, row_limit=config.methods_file_row_limit, 
    start_column=config.methods_file_start_column,column_limit=config.methods_file_column_limit)[config.methods_file_sheet]

methods_dict = {}

for row in functionsdata:
    if (len(row)>1):
        thiskey = row[config.methods_function_column]
        if (len(thiskey)>0):
            print(thiskey)
            thisnode = {}
            thisnode['function'] = thiskey
            thisnode['node'] = row[config.methods_node_column]
            thisnode['call'] = row[config.methods_call_column]
            thisnode['device'] = row[config.methods_device_column]
            methods_dict[thiskey] = thisnode

file = open("./"+projectName+"/"+projectName+".l/"+projectName+".h")
text = file.read()
text = text.replace('#include "'+projectName+'Base.h"','#include "'+projectName+'Base.h"\n#include "PORIS.h"\n')
text = text.replace('-\n protected:','-\n\n protected:\n\t/* PORIS support functions */\n\t#include "_'+projectName+'PORIS.h"\n')

with open("./"+projectName+"/"+projectName+".l/"+projectName+".h", "w") as text_file:
    text_file.write(text)

with open("./"+projectName+"/"+projectName+".l/"+projectName+"_user.cpp", "w+") as text_file:
    text_file.write('#include "../../'+projectName+'.user/_'+projectName+'_user.cpp"\n')

# logInfo_("setX() completed successfully");

fileparam = open("./PORIS/patterns/fragments/_pattern_Values.c")
patternparam = fileparam.read()
#print(patternparam)
filedouble = open("./PORIS/patterns/fragments/_pattern_Doubles.c")
patterndouble = filedouble.read()
#print(patterndouble)
filemode = open("./PORIS/patterns/fragments/_pattern_Modes.c")
patternmode = filemode.read()
#print(patternmode)

inputcppfilestr = "./"+projectName+"/"+projectName+".l/"+projectName+".cpp"

if not os.path.isfile(inputcppfilestr+".bak"):
    os.rename(inputcppfilestr, inputcppfilestr+".bak")

file = open(inputcppfilestr+".bak")
text = file.read()
text = text.replace('#include "'+projectName+'.h"','#include "'+projectName+'.h"\n#include "../../'+projectName+'.user/'+projectName+'_user.h"')

matchlist = re.findall(r'(logInfo_\("set([a-zA-Z_]*)\(\) completed successfully"\);)',text)

nodesdict = {}
# Creating a dictionary to know what to do
for r1 in matchlist:
    nodename = r1[1]
    nodesdict[nodename] = r1

for r1 in matchlist:
    nodename = r1[1]
    stringtoreplace = r1[0]
    isMode = nodename[-4:] == "Mode"
    isDouble = nodename[-6:] == "Double"
    if isMode:
        paramname = nodename[:-4]
        print(paramname+"XXXX")
        stringtoinject = patternmode.replace('$$$$',paramname)
        text = text.replace(stringtoreplace,stringtoinject)
    else:
        if isDouble:
            parentname = nodename[:-6]
            stringtoinject = patterndouble.replace('$$$$',parentname)
            text = text.replace(stringtoreplace,stringtoinject)
        else:
            stringtoinject = patternparam.replace('$$$$',nodename)
            text = text.replace(stringtoreplace,stringtoinject)
        
for key in methods_dict.keys():
    m = methods_dict[key]

    stringtoreplace = 'logInfo_("'+key+'() completed successfully");'

    stringtoinject = 'if ('+m['call']+' == EXIT_SUCCESS) {\n'
    stringtoinject += '\t\t\t\t'+stringtoreplace+'\n'
    stringtoinject += '\t\t\t} else {\n'
    stringtoinject += '\t\t\t\tlogInfo_("'+key+'() NOT completed");\n'
    stringtoinject += '\t\t\t}\n'

    text = text.replace(stringtoreplace,stringtoinject)


text = text.replace('trace_.out("'+projectName+' constructor\\n");','trace_.out("'+projectName+'  constructor\\n");\n\trootsys = PORIS_init();')
with open(inputcppfilestr, "w") as text_file:
    text_file.write(text)

import fileinput,re,sys

def  modify_file(file_name,pattern,value=""):  
    fh=fileinput.input(file_name,inplace=True)
    print(file_name)  
    print(pattern,value)
    for line in fh:  
        replacement= line + value
        line=re.sub(pattern,replacement,line)
        sys.stdout.write(line)

    fh.close()  

filestr = "./"+projectName+"/tests/test"+projectName+".p/test"+projectName+".cpp"

with open(filestr) as f:
    if 'Init_ACE.h' not in f.read():
        print("*****************************************************************")
        modify_file(filestr,
            "#include \"test"+projectName+".h\"",
            "#include \"ace/Init_ACE.h\"")

filestr = "./"+projectName+"/examples/run"+projectName+".p/Test"+projectName+"LCU.cpp"

with open(filestr) as f:
    if 'Init_ACE.h' not in f.read():
        modify_file(filestr,
            "#include \"ace/ACE.h\"",
            "#include \"ace/Init_ACE.h\"")

filestr = "./"+projectName+"/examples/use"+projectName+".p/use"+projectName+".cpp"

with open(filestr) as f:
    if 'Init_ACE.h' not in f.read():
        modify_file(filestr,
            "#include \"use"+projectName+".h\"",
            "#include \"ace/Init_ACE.h\"")

file = open("./"+projectName+".user/_lmk.linux")
lmktext = file.read()
file.close()

doIt = False
filestr = "./"+projectName+"/tests/test"+projectName+".p/lmk.linux"
with open(filestr) as f:
    if '$(GSL_LIBS)' not in f.read():
        doIt = True

with open(filestr, "a") as file_object:
    if doIt:
        file_object.write("LDLIBS +=  $(GSL_LIBS)\n")
    
    file_object.write(lmktext)


doIt = False
filestr = "./"+projectName+"/examples/run"+projectName+".p/lmk.linux"
with open(filestr) as f:
    if '$(GSL_LIBS)' not in f.read():
        doIt = True
    
with open(filestr, "a") as file_object: 
    if doIt:
        file_object.write("LDLIBS +=  $(GSL_LIBS)\n")
    
    file_object.write(lmktext)

doIt = False
filestr = "./"+projectName+"/examples/use"+projectName+".p/lmk.linux"
with open(filestr) as f:
    if '$(GSL_LIBS)' not in f.read():
        doIt = True
    
with open(filestr, "a") as file_object: 
    if doIt:
        file_object.write("LDLIBS +=  $(GSL_LIBS)\n")
    
    file_object.write(lmktext)