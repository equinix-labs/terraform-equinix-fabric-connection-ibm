#!/bin/bash

# Exit if any of the intermediate steps fail
set -e

unameOut="$(uname -s)"
case "${unameOut}" in
    Darwin*)    machine=darwin;;
    *)          machine="linux"
esac
echo "{\"os\": \"${machine}\"}" 
