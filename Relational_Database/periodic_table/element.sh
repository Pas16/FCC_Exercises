#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=periodic_table --tuples-only -c"

# check if there is an argument
if [[ ! $1 ]]
then
  echo Please provide an element as an argument.
else
  # check if arg is a number
  if [[ $1 =~ ^[0-9]+$ ]]
  then
    # check if arg is a valid atomic_number
    ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE atomic_number=$1")
    if [[ -z $ATOMIC_NUMBER ]]
    then 
      echo I could not find that element in the database.
      exit 0
    fi
  else # if arg is not a number
    # check if arg is a valid symbol
    ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE symbol='$1'")
    if [[ -z $ATOMIC_NUMBER ]]
    then
      # check if arg is a valid name
      ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE name='$1'")
      if [[ -z $ATOMIC_NUMBER ]]
      then
        echo I could not find that element in the database.
        exit 0
      fi      
    fi
  fi
  # print data as formatted
  READ_DATABASE=$($PSQL "SELECT * FROM elements LEFT JOIN properties USING(atomic_number) LEFT JOIN types USING(type_id) WHERE atomic_number=$ATOMIC_NUMBER")
  echo $READ_DATABASE | while IFS=" | " read TYPE_ID ATOMIC_NUMBER SYMBOL NAME MASS MP BP TYPE
  do
    echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MP celsius and a boiling point of $BP celsius."
  done
fi
