#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
echo -e "\n~~~~~ MY SALON ~~~~~\n"

MAIN_MENU() {

  echo "Welcome to My Salon, how can I help you?" 
  echo -e "\n1) cut\n2) color\n3) perm\n4) style\n5) trim"
  read SERVICE_ID_SELECTED
  
  case $SERVICE_ID_SELECTED in
    1 | 2 | 3 | 4 | 5) SERVICE_MENU ;;
    *) MAIN_MENU "I could not find that service. What would you like today?";;
  esac
}

SERVICE_MENU() {

  # read service name
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = '$SERVICE_ID_SELECTED'")

  # read customer phone number
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE

  # read customer_id from db using phone number
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

  # check if customer is not in db
  if [[ -z $CUSTOMER_ID  ]]
  then
    echo "I don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME
    INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
  else
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  fi

  # get customer_id
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

  # enter appointment into db
  echo "What time would you like your"$SERVICE_NAME"," $CUSTOMER_NAME"?" 
  read SERVICE_TIME
  INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES('$CUSTOMER_ID', '$SERVICE_ID_SELECTED', '$SERVICE_TIME')")

  # appointment confirmation
  echo "I have put you down for a" $SERVICE_NAME "at" $SERVICE_TIME"," $CUSTOMER_NAME"."
}

MAIN_MENU