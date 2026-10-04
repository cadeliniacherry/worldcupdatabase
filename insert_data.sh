#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

declare -A team_ids
team_values=()
game_values=()

while IFS=, read -r year round winner opponent winner_goals opponent_goals
do
  winner=${winner//\'/\'\'}
  opponent=${opponent//\'/\'\'}
  round=${round//\'/\'\'}

  if [[ -z ${team_ids[$winner]} ]]
  then
    team_ids[$winner]=1
    team_values+=("('$winner')")
  fi

  if [[ -z ${team_ids[$opponent]} ]]
  then
    team_ids[$opponent]=1
    team_values+=("('$opponent')")
  fi

  game_values+=("($year, '$round', (SELECT team_id FROM teams WHERE name = '$winner'), (SELECT team_id FROM teams WHERE name = '$opponent'), $winner_goals, $opponent_goals)")
done < <(tail -n +2 games.csv)

team_rows=$(IFS=,; echo "${team_values[*]}")
game_rows=$(IFS=,; echo "${game_values[*]}")

$PSQL "INSERT INTO teams(name) VALUES $team_rows ON CONFLICT (name) DO NOTHING; INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES $game_rows;"
