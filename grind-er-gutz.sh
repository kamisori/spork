#!/bin/sh

valgrind -s --read-var-info=yes --trace-children=yes --keep-debuginfo=yes --leak-check=full --show-leak-kinds=all --track-origins=yes ../janet/build/janet test/suite0015.janet 
