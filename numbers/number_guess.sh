#!/bin/bash


PSQL="psql --username=freecodecamp --dbname=number_guess -t -c"

#number to guess
GUESS_ME=$(($RANDOM%1000+1))

GUESS() {
  #print the message
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  #get input/number user is guessing
  read INPUT
  #add to guess count
  COUNT=$(($COUNT+1)) 
  
  #if not number
  if [[ ! $INPUT =~ ^[0-9]+$ ]]
  then
    #guess again
    GUESS "That is not an integer, guess again:"
  else
    #if right number is guessed
    if [[ $INPUT -eq $GUESS_ME ]]
    then
      WIN 
    #if guess < number
    elif [[ $INPUT -lt $GUESS_ME ]]
    then
      # guess again
      GUESS "It's higher than that, guess again:"
      # if guess > number
    else [[ $INPUT -gt $GUESS_ME ]]
      # guess again
      GUESS "It's lower than that, guess again:"
    fi
  fi
}

MAIN_GAME() {
  # user set up
  echo "Enter your username:"
  read USERNAME
  USER_INFO=$($PSQL "SELECT games_played, best_game FROM users WHERE username='$USERNAME'")
  
  if [[ -z $USER_INFO ]]
  then
    #if new user
    INSERT_USER
  else
    #if existing user
    GET_USER
  fi

  # get guesses to 0
  # begin the game
  COUNT=0
  GUESS "Guess the secret number between 1 and 1000: "
}

GET_USER() {
  GET_USER_INFO=$($PSQL "SELECT username,games_played,best_game FROM users WHERE username='$USERNAME'")
  echo "$GET_USER_INFO" | while read USER BAR GAMES_PLAYED BAR BEST_GAME
  do
    echo "Welcome back, $USER! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  done
}

INSERT_USER() {
  INSERT_USER_RESULT=$($PSQL "INSERT INTO users(username, games_played) VALUES('$USERNAME',0)")
  echo "Welcome, $USERNAME! It looks like this is your first time here."
}

WIN() {
  echo -e "\nYou guessed it in $COUNT tries. The secret number was $GUESS_ME. Nice job!"
  # add 1 to games played, if count < best game, bestgame=count
  UPDATE_USER=$($PSQL "UPDATE users SET best_game=LEAST(best_game,$COUNT), games_played=games_played+1 where username='$USERNAME'")
}

MAIN_GAME