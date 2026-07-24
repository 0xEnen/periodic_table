#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

if [[ -z $1 ]]
then
  echo "Please provide an element as an argument."
else
  if [[ $1 =~ ^[0-9]+$ ]]
  then
    QUERY="SELECT atomic_number, name, symbol FROM elements WHERE atomic_number=$1"
  else
    QUERY="SELECT atomic_number, name, symbol FROM elements WHERE name='$1' OR symbol='$1'"
  fi

  ELEMENT=$($PSQL "$QUERY")

  if [[ -z $ELEMENT ]]
  then
    echo "I could not find that element in the database."
  else
    ATOMIC_NUMBER=$(echo $ELEMENT | cut -d'|' -f1 | sed 's/ //g')
    NAME=$(echo $ELEMENT | cut -d'|' -f2 | sed 's/ //g')
    SYMBOL=$(echo $ELEMENT | cut -d'|' -f3 | sed 's/ //g')

    PROPS=$($PSQL "SELECT type, atomic_mass, melting_point_celsius, boiling_point_celsius FROM properties INNER JOIN types USING(type_id) WHERE atomic_number=$ATOMIC_NUMBER")

    TYPE=$(echo $PROPS | cut -d'|' -f1 | sed 's/ //g')
    MASS=$(echo $PROPS | cut -d'|' -f2 | sed 's/ //g')
    MELTING=$(echo $PROPS | cut -d'|' -f3 | sed 's/ //g')
    BOILING=$(echo $PROPS | cut -d'|' -f4 | sed 's/ //g')

    ARTICLE="a"
    if [[ $TYPE == "metalloid" ]]
    then
      ARTICLE="an"
    fi

    echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's $ARTICLE $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELTING celsius and a boiling point of $BOILING celsius."
  fi
fi