#!/bin/zsh

grep categories *.md | awk '{print $2}' | sort | uniq >categories
