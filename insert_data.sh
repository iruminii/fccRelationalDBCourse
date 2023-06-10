#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
#empty db tables
echo $($PSQL "TRUNCATE TABLE games, teams RESTART IDENTITY;")

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $YEAR != "year" ]]
  then
    ### teams table inserts ###
    #get team_id of winner
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    echo WINNING TEAM is $WINNER
    #if no team_id
    if [[ -z $WINNER_ID ]]
    then
      echo HI NO TEAM_ID FOUND FOR winning $WINNER
      #insert to team table
      INSERT_WINNER_ID_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
      if [[ $INSERT_WINNER_ID_RESULT == "INSERT 0 1" ]]
      then 
        WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
        echo "inserted WINNING $WINNER into teams at $WINNER_ID"
      fi
    fi
    #get team_id of opponent
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    echo OPPONENT TEAM is $OPPONENT 
    #if no opponent_id
    if [[ -z $OPPONENT_ID ]]
    then
      echo HI NO TEAM_ID FOUND FOR opposing $OPPONENT
      #insert opponents into teams
      INSERT_OPPONENT_ID_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
      if [[ $INSERT_OPPONENT_ID_RESULT == "INSERT 0 1" ]]
      then
        OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
        echo "inserted OPPOSING $OPPONENT into teams at $OPPONENT_ID"
      fi
    fi
    ### games table insert ###
    echo WIN_ID $WINNER_ID OPP_ID $OPPONENT_ID
    #insert game
    INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR,'$ROUND',$WINNER_ID,$OPPONENT_ID,$WINNER_GOALS,$OPPONENT_GOALS)")
    if [[ $INSERT_GAME_RESULT == "INSERT 0 1" ]]
    then
      echo Inserted into games $YEAR $ROUND $WINNER $OPPONENT
    fi
  fi
done
