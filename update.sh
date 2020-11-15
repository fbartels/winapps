#!/bin/sh

#git checkout main
git pull --rebase upstream main
./installer.sh --user
