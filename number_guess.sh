#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=postgres -t --no-align -c"

echo "Enter your username:"
read NAME

IS_NEW_USER=$($PSQL "SELECT username,games_played,best_game FROM number_guess WHERE username='$NAME'")

if [[ -z $IS_NEW_USER ]]
then
  echo "Welcome, $NAME! It looks like this is your first time here."
  BEST_GAME=999999999
  INSERT_RESULT=$($PSQL "INSERT INTO number_guess(username,games_played,best_game) VALUES('$NAME',0,99999999)")
else
  IFS='|' read -r NAME GAMES_PLAYED BEST_GAME <<< "$IS_NEW_USER"
  echo "Welcome back, $NAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

echo "Guess the secret number between 1 and 1000:"
read GUESS 

RANDOM_NUM=$((1 + $RANDOM % 1000));

NUM_OF_GUESSES=1

SAVE_GAME () {
  GUESSES=$1
  ((GAMES_PLAYED+=1))

  if [[ $GUESSES -lt $BEST_GAME ]]
  then
    UPDATE_RESULT=$($PSQL "UPDATE number_guess SET games_played=$GAMES_PLAYED, best_game=$GUESSES WHERE username='$NAME';")
  else
    UPDATE_RESULT=$($PSQL "UPDATE number_guess SET games_played=$GAMES_PLAYED WHERE username='$NAME';")
  fi

}


while [[ 1 ]]
do
  if [[ $GUESS =~ ^[0-9]+$ ]]
  then
    if [[ $GUESS -gt $RANDOM_NUM ]]
    then
      echo "It's lower than that, guess again:"
      read GUESS
      ((NUM_OF_GUESSES+=1))
    elif [[ $GUESS -lt $RANDOM_NUM ]]
    then
      echo "It's higher than that, guess again:"
      read GUESS
      ((NUM_OF_GUESSES+=1))
    else
      echo "You guessed it in $NUM_OF_GUESSES tries. The secret number was $RANDOM_NUM. Nice job!"
      SAVE_GAME $NUM_OF_GUESSES
      exit
    fi
  else
   ((NUM_OF_GUESSES+=1))
   echo "That is not an integer, guess again:"
   read GUESS
  fi
done


