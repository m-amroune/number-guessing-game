#!/bin/bash

# Generate a random number between 1 and 1000
SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))

# Prompt the user for a username
echo "Enter your username:"
read USERNAME

# DB helper
PSQL="psql -X --username=freecodecamp --dbname=number_guess -t --no-align -c"

# Check if user exists
EXISTS=$($PSQL "SELECT 1 FROM users WHERE username='$USERNAME' LIMIT 1;")

if [[ -z $EXISTS ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  $PSQL "INSERT INTO users(username) VALUES('$USERNAME');" > /dev/null
else
  USER_DATA=$($PSQL "SELECT games_played, best_game FROM users WHERE username='$USERNAME';")
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

# Update games played and best game in DB
USER_DATA=$($PSQL "SELECT games_played, best_game FROM users WHERE username='$USERNAME';")
IFS="|" read GAMES_PLAYED BEST_GAME <<< "$USER_DATA"

NEW_GAMES_PLAYED=$(( GAMES_PLAYED + 1 ))

if [[ -z $BEST_GAME || $NUMBER_OF_GUESSES -lt $BEST_GAME ]]
then
  $PSQL "UPDATE users SET games_played=$NEW_GAMES_PLAYED, best_game=$NUMBER_OF_GUESSES WHERE username='$USERNAME';" > /dev/null
else
  $PSQL "UPDATE users SET games_played=$NEW_GAMES_PLAYED WHERE username='$USERNAME';" > /dev/null
fi




