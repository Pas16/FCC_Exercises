#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo Enter your username:
read NAME

# check if player played the game before
USER_ID=$($PSQL "SELECT user_id FROM users WHERE name='$NAME'")
if [[ -z $USER_ID ]]
then
  # when not found, register the player
  echo "Welcome, $NAME! It looks like this is your first time here."
  REGISTER=$($PSQL "INSERT INTO users(name) VALUES('$NAME')")
  # get user_id
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE name='$NAME'")
else
  # display the player's static
  READ_RECORDS=$($PSQL "SELECT COUNT(*), MIN(number_of_guesses) FROM records WHERE user_id='$USER_ID'")
  echo $READ_RECORDS | while IFS="|" read GAMES_PLAYED BEST_GAME
  do
    echo "Welcome back, $NAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  done
fi

# time to guess
NUMBER=$(($RANDOM%1000+1))
echo Guess the secret number between 1 and 1000:
GUESS=0
TRY=0
while (( $GUESS != $NUMBER ))
do
  read GUESS
  ((TRY++))
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo That is not an integer, guess again:
  else
    if (( $GUESS == $NUMBER )) # correct guess
    then
      echo "You guessed it in $TRY tries. The secret number was $NUMBER. Nice job!"
    else # incorrect guess
      if (( $GUESS > $NUMBER )) # guess too high
      then
        echo "It's lower than that, guess again:"
      else # guess too low
        echo "It's higher than that, guess again:"
      fi
    fi
  fi
done

# save to record
SAVE_RECORD=$($PSQL "INSERT INTO records(user_id, number_of_guesses) VALUES($USER_ID,$TRY)")
