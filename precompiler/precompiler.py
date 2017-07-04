# Author:
# Curtis Babnik
# cbabnik@sfu.ca

# This file removes comments, condenses whitespace, and replaces aliassed short-forms
# Most importantly though, it adds semicolon delimiters to function calls.
# This is because I need the delimiters to make the grammar i want unambiguous

# The file is just a stand-in. It's inefficient and has some flaws.

# The simple stuff...

import sys
import re

if len(sys.argv) < 3:
    print("Please give the name of the source file and destination file.")
    print("Example: python3 precompiler src/dec production/precompiled/dec")
    exit(1)
fileIn  = sys.argv[1]
fileOut = sys.argv[2]

expr  = re.compile(r"[0-9]+|_|_\^")
func  = re.compile(r"\+\+|\~\&\&|\$|[a-zA-Z]+")
define= re.compile(r"\!")

def main():
    code = read(fileIn)

    code = simplesubs(code)

    populate_func_table(code)
    code = add_semis(code)

    write(fileOut, code)


def read(fileName):
    string = ""
    try:
        f = open(fileName, "r")
        string = f.read()
        f.close()
    except IOError:
        print("error reading from %s" % fileName)
        exit(1)
    return string


def write(fileName, string):
    try:
        f = open(fileName, "w+")
        f.write(string)
        f.write("\n")
    except IOError:
        print("error writing to %s" % fileName)
        exit(1)


def simplesubs(string):
    # remove comments
    string = re.sub(r"#.*?#", "", string, flags=re.DOTALL)
    # remove trailing whitespace
    string = re.sub(r"[ \t]+$", "", string, flags=re.M)

    # replace aliasses
    string = re.sub(r"\b\~\~\b"  , "extset0not", string)
    string = re.sub(r"\b\&\&\b"  , "extset0and", string)
    string = re.sub(r"\b\~\|\|\b", "extset0nor", string)
    string = re.sub(r"\b\|\|\b"  , "extset0or" , string)
    string = re.sub(r"\b\~\|\b"  , "extset0norBitwise" , string)
    string = re.sub(r"\b\|\b"    , "extset0orBitwise"  , string)
    string = re.sub(r"\b\~\&\b"  , "extset0nandBitwise", string)
    string = re.sub(r"\b\&\b"    , "extset0andBitwise" , string)
    string = re.sub(r"\b\~\b"    , "extset0notBitwise" , string)
    string = re.sub(r"\b\-\-\b"  , "extset0dec"   , string)
    string = re.sub(r"\b\+\b"    , "extset0add"   , string)
    string = re.sub(r"\b\-\b"    , "extset0sub"   , string)
    string = re.sub(r"\b\*\b"    , "extset0mult"  , string)
    string = re.sub(r"\b\/\b"    , "extset0div"   , string)
    string = re.sub(r"\b\%\b"    , "extset0mod"   , string)
    string = re.sub(r"\b\?0\b"   , "extset0testZero"   , string)
    string = re.sub(r"\b\?t\b"   , "extset0testTrue"   , string)
    string = re.sub(r"\b\?f\b"   , "extset0testFalse"   , string)
    string = re.sub(r"\b\?=\b"   , "extset0testEqual"   , string)
    string = re.sub(r"\b\?<\b"   , "extset0testLT"   , string)
    string = re.sub(r"\b\?>\b"   , "extset0testMT"   , string)
    string = re.sub(r"\b\?<=\b"  , "extset0testLTE"  , string)
    string = re.sub(r"\b\?>=\b"  , "extset0testMTE"  , string)

    return string

# ============================================
# !! The more complicated stuff starts here !!
# This is the process of inserting semicolons.
# ============================================

# The first step is to fill out a table which keeps track of how many parameters
# each function requires. This is the hardest part of this file to implement.
#
# Later the function table should get populated in part by other files which are
# appropriately named. I'm not sure how I want to do that though, so it's on hold.
func_table = {"++":1, "~&&":2, "$":1}

def populate_func_table(code):
    tokens = re.split(r"[ \t\r\n]+", code)
    tokens = [t for t in tokens if t != '']

    idx = 0
    # look for functions that are being defined
    while idx < len(tokens):
        token = tokens[idx];
        if token=="!":
            idx += 1
            parent_params, idx = get_param_count(tokens, idx)
        idx+=1

def get_param_count(tokens, idx):
    stack = [1]
    current_define = tokens[idx];
    params = 0
    parent_params = 0

    idx += 1
    while idx < len(tokens):
        token = tokens[idx]
        if func.fullmatch(token):
            if token in func_table:
                if func_table[token] == 0:
                    stack, semis = remove_one(stack)
                    if stack == []:
                        func_table[current_define] = params
                        return parent_params, idx
                else:
                    stack.append(func_table[token])
            else:
                print("function undefined: %s" % token)
                exit(1)
        elif expr.fullmatch(token):
            if token == "_":
                params+=1
            elif token == "_^":
                parent_params += 1
            stack, semis = remove_one(stack)
            if stack == []:
                func_table[current_define] = params
                return parent_params, idx
        elif define.fullmatch(token):
            idx += 1
            parent_count, idx = get_param_count(tokens, idx)
            params += parent_count
        else:
            print("unrecognized token during populate_func_table: %s" % token)
            exit(1)
        idx += 1
    func_table[current_define] = params
    return parent_params, idx

# the stack represents how many expressions are needed for a function call to finish.
# each time a function call finishes, the parent removes one expression needed aswell
# because each function returns an expression of it's own. hence the recursion.
def remove_one(stack):
    # if function is empty, do nothing, this happens when a function definition ends
    # or when the file reaches the end
    if len(stack) == 0:
        return (stack, [])
    if stack == [1]:
        return ([], [";"])
    val = stack.pop()
    # remove one from top level, if that would make the count 0, add ';' and recurse
    if (val == 1):
        stack, semis = remove_one(stack)
        semis.append(";")
        return stack, semis
    else:
        stack.append(val-1)
        return (stack, [])

# scans through with the following logic:
# if you run into a...
#   expression, remove one from the top level function call
#   function, look it up in the function table and add the #params needed to stack
#   !, skip fnct name, then add one to #params needed, since ! has an extra expr
#   something else? break! it's not my job to explain errors to the users >:3
def add_semis(code):
    tokens = re.split(r"[ \t\r\n]+", code)
    tokens = [t for t in tokens if t != '']

    stack = []
    idx = 0
    while idx < len(tokens):
        token = tokens[idx]
        if func.fullmatch(token):
            # function label
            if token in func_table:
                # function in table
                if func_table[token] == 0:
                    stack.append(1)
                    # expression
                    stack, semis = remove_one(stack)
                    if len(semis) > 0:
                        tokens = tokens[:idx+1] + semis + tokens[idx+1:]
                        idx += len(semis)
                else:
                    stack.append(func_table[token])
            else:
                # function not in table, fatal crash
                print("function undefined: %s" % token)
                exit(1)
        elif expr.fullmatch(token):
            # expression
            stack, semis = remove_one(stack)
            if len(semis) > 0:
                tokens = tokens[:idx+1] + semis + tokens[idx+1:]
                idx += len(semis)
        elif define.fullmatch(token):
            if len(stack) > 0:
                stack.append(stack.pop()+1)
            idx += 1
        else:
            pass
        idx += 1

    return ' '.join(tokens)

if __name__ == '__main__':
    main()
