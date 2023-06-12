#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t -c"

if [[ -z $1 ]] 
then
  echo "Please provide an element as an argument."
else
  # number or string
  if [[ $1 =~ ^[0-9]+$ ]]
  then
    ELEMENT_FOUND_RESULT=$($PSQL "SELECT atomic_number, name, symbol, type, atomic_mass, melting_point_celsius, boiling_point_celsius FROM properties INNER JOIN elements USING(atomic_number) LEFT JOIN types USING(type_id) WHERE atomic_number=$1")
  else
    ELEMENT_FOUND_RESULT=$($PSQL "SELECT atomic_number, name, symbol, type, atomic_mass, melting_point_celsius, boiling_point_celsius FROM properties INNER JOIN elements USING(atomic_number) LEFT JOIN types USING(type_id) WHERE symbol='$1' OR name='$1'")
  fi

  # if nothing found
  if [[ -z $ELEMENT_FOUND_RESULT ]]
  then
    echo "I could not find that element in the database."
  else 
    echo $ELEMENT_FOUND_RESULT | while read ATOMIC_NUM BAR NAME BAR SYMBOL BAR TYPE BAR ATOMIC_MASS BAR MELTING_POINT BAR BOILING_POINT 
    do
      echo "The element with atomic number $ATOMIC_NUM is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
    done
  fi
fi