#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

SERVICES_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  # get services
  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  echo "$SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done
  read SERVICE_ID_SELECTED
  
  case $SERVICE_ID_SELECTED in 
    1 | 2 | 3 | 4 | 5) 
      MAKE_APPOINTMENT
    ;;
    *) SERVICES_MENU "I could not find that service. What would you like today?";;
  esac
}

MAIN_MENU() {
  echo -e "Welcome to My Salon, how can I help you?\n"

  SERVICES_MENU
}

MAKE_APPOINTMENT() {
  #get cust info
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE

    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
    #if not in customers
    if [[ -z $CUSTOMER_NAME ]]
    then
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME

      INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone,name) VALUES('$CUSTOMER_PHONE','$CUSTOMER_NAME')")
    fi
    # get customer_id
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    
    #remove spaces from cust name
    CUSTOMER_NAME_NO_SPACE=$(echo $CUSTOMER_NAME | sed -E 's/^ *| *$//')

    # get service_id, remove spaces
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
    SERVICE_NAME_NO_SPACE=$(echo $SERVICE_NAME | sed 's/^ *//')

    # get time for cut
    echo -e "\nWhat time would you like your $SERVICE_NAME_NO_SPACE, $CUSTOMER_NAME_NO_SPACE?"
    read SERVICE_TIME

    INSERT_APPT_RESULT=$($PSQL "INSERT INTO appointments(time, customer_id, service_id) VALUES('$SERVICE_TIME',$CUSTOMER_ID,$SERVICE_ID_SELECTED)")

    echo -e "\nI have put you down for a $SERVICE_NAME_NO_SPACE at $SERVICE_TIME, $CUSTOMER_NAME_NO_SPACE.\n"

}

MAIN_MENU