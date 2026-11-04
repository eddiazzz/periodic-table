#!/bin/bash

if [[ $# -eq 0 ]]; then
  echo "Please provide an element as an argument."
  exit 0
fi

ELEMENT=$(psql -X -qAt --username=freecodecamp --dbname=periodic_table \
  --set=ON_ERROR_STOP=1 --set=lookup="$1" --field-separator='|' <<'SQL'
SELECT atomic_number, name, symbol, type, atomic_mass,
       melting_point_celsius, boiling_point_celsius
FROM elements
JOIN properties USING (atomic_number)
JOIN types USING (type_id)
WHERE atomic_number::text = :'lookup'
   OR symbol = :'lookup'
   OR name = :'lookup';
SQL
) || exit 1

if [[ -z $ELEMENT ]]; then
  echo "I could not find that element in the database."
  exit 0
fi

IFS='|' read -r NUMBER NAME SYMBOL TYPE MASS MELTING BOILING <<< "$ELEMENT"
printf "The element with atomic number %s is %s (%s). It's a %s, with a mass of %s amu. %s has a melting point of %s celsius and a boiling point of %s celsius.\n" \
  "$NUMBER" "$NAME" "$SYMBOL" "$TYPE" "$MASS" "$NAME" "$MELTING" "$BOILING"
