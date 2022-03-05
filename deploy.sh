#!/bin/bash
hugo
commit="no msg for this commit"
[["${1}"]] && commit=${1}

cd public
git add .
git commit -m "${commit}"
git push origin main

cd .. 
git add .
git commit -m "${commit}"
git push origin main