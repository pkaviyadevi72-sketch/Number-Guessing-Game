#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo "Enter your username:"
read USERNAME

USER_INFO=$($PSQL "SELECT games_played, best_game FROM users WHERE username='$USERNAME'")

if [[ -z $USER_INFO ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  $PSQL "INSERT INTO users(username) VALUES('$USERNAME')" > /dev/null
else
  GAMES_PLAYED=$(echo "$USER_INFO" | cut -d'|' -f1)
  BEST_GAME=$(echo "$USER_INFO" | cut -d'|' -f2)

  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

SECRET_NUMBER=$((RANDOM % 1000 + 1))
GUESSES=0

echo "Guess the secret number between 1 and 1000:"
read GUESS

while true
do
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
  elif [[ $GUESS -gt $SECRET_NUMBER ]]
  then
    echo "It's lower than that, guess again:"
  elif [[ $GUESS -lt $SECRET_NUMBER ]]
  then
    echo "It's higher than that, guess again:"
  else
    break
  fi

  GUESSES=$((GUESSES + 1))
  read GUESS
done

GUESSES=$((GUESSES + 1))

echo "You guessed it in $GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"

CURRENT_GAMES=$($PSQL "SELECT games_played FROM users WHERE username='$USERNAME'")
NEW_GAMES=$((CURRENT_GAMES + 1))

BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username='$USERNAME'")

if [[ -z $BEST_GAME ]]
then
  $PSQL "UPDATE users SET games_played=$NEW_GAMES, best_game=$GUESSES WHERE username='$USERNAME'" > /dev/null
elif [[ $GUESSES -lt $BEST_GAME ]]
then
  $PSQL "UPDATE users SET games_played=$NEW_GAMES, best_game=$GUESSES WHERE username='$USERNAME'" > /dev/null
else
  $PSQL "UPDATE users SET games_played=$NEW_GAMES WHERE username='$USERNAME'" > /dev/null
fi
