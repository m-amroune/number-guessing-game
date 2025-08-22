#!/bin/bash

# Generate a random number between 1 and 1000
SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))

# Prompt the user for a username
echo "Enter your username:"
read USERNAME

# DB helper
PSQL="psql -X --username=freecodecamp --dbname=number_guess -t --no-align -c"

# Check if user exists
USER_DATA=$($PSQL "SELECT games_played, best_game FROM users WHERE username='$USERNAME';")

if [[ -z $USER_DATA ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  $PSQL "INSERT INTO users(username) VALUES('$USERNAME');" > /dev/null
else
  IFS="|" read GAMES_PLAYED BEST_GAME <<< "$USER_DATA"
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

# Guess prompt
echo "Guess the secret number between 1 and 1000:"
read GUESS

# Guess counter
NUMBER_OF_GUESSES=1

# Validate first input
while [[ ! $GUESS =~ ^[0-9]+$ ]]
do
  echo "That is not an integer, guess again:"
  read GUESS
  ((NUMBER_OF_GUESSES++))
done

# Loop until correct guess
while [[ $GUESS -ne $SECRET_NUMBER ]]
do
  if [[ $GUESS -gt $SECRET_NUMBER ]]
  then
    echo "It's lower than that, guess again:"
  else
    echo "It's higher than that, guess again:"
  fi
  read GUESS
  ((NUMBER_OF_GUESSES++))
  while [[ ! $GUESS =~ ^[0-9]+$ ]]
  do
    echo "That is not an integer, guess again:"
    read GUESS
    ((NUMBER_OF_GUESSES++))
  done
done

# Winning message
echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"




