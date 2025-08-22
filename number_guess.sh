#!/bin/bash

# Generate a random number between 1 and 1000
SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))

# Prompt the user for a username
echo "Enter your username:"
read USERNAME