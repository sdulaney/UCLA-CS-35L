#!/usr/bin/env python3

import os, sys, zlib

def main():
    # Discover the .git directory
    top_level_git_dir = os.getcwd()
    while os.path.isdir(os.path.join(top_level_git_dir, ".git")) == False:
        if top_level_git_dir == "/":
            sys.stderr.write("Not inside a Git repository")
            sys.exit(1)
        top_level_git_dir = os.path.dirname(top_level_git_dir)
    
    

if __name__ == "__main__":
        main()
