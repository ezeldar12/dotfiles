#!/usr/bin/env bash

git add --all
read -r -p "commit message" MESSAGE
git commit -m "$MESSAGE"
echo "This is your commit message -> $MESSAGE"
git push -u origin master 
