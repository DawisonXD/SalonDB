#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~My Salon~~~\n"

MAIN_MENU(){
  #display message if error
  if [[ $1 ]]
  then
  echo -e "\n$1"
  fi

  #display services
  echo -e "\nThe services we offer are:\n"
  SERVICES=$($PSQL "SELECT service_id, name FROM services")
  echo "$SERVICES" | while read SERVICE_ID SERVICE_NAME
  do
  if [[ $SERVICE_ID != 'service_id' && $SERVICE_ID =~ ^[0-9]+$ ]] 
  then
  echo "$SERVICE_ID) $SERVICE_NAME" | sed 's/ //g;s/|/ /'
  fi
  done
  echo "4) exit"

  #read input and redirect
  read SERVICE_ID_SELECTED
  case $SERVICE_ID_SELECTED in
  1) SERVICE_MENU "haircut" ;;
  2) SERVICE_MENU "barbering" ;;
  3) SERVICE_MENU "nails" ;;
  4) EXIT;;
  *) MAIN_MENU "That service does not exist" ;;
  esac
}

SERVICE_MENU(){

  if [[ $1 ]]
  then
  SERVICE_ID=$($PSQL "SELECT service_id FROM services WHERE name = '$1'")
  echo -e "\nSo you want $1, uh?"
  fi

  echo "What's your phone number?"
  read CUSTOMER_PHONE
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

  if [[ -z $CUSTOMER_ID ]]
  then
  echo "It looks like it's your first time here. What's your name?"
  read CUSTOMER_NAME
  INSERT_CUSTOMER=$($PSQL "INSERT INTO customers(phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  echo "What time would that be $CUSTOMER_NAME?"
  read SERVICE_TIME
  INSERT_APP=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID, '$SERVICE_TIME')")
  echo "I have put you down for a $1 at $SERVICE_TIME, $CUSTOMER_NAME."

  else
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  echo "Hi$CUSTOMER_NAME, is good to see you again! What time?"
  read SERVICE_TIME
  INSERT_APP=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID, '$SERVICE_TIME')")
  echo "All set G$CUSTOMER_NAME! You have your $1 at $SERVICE_TIME."
  fi

}

EXIT(){
  echo "Thank you for coming by ^.^"
}


MAIN_MENU

