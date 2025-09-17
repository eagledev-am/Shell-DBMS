#!/bin/bash

function skipToNext(){
read -n 1 -s -r -p "✨ Press any key to continue..."
}

tableMenu(){
  echo "table "
  list_tables "$1"
  local db="$1"

  read -r -p "Table name to connect: " tableName
  
    if [ -z "$tableName" ] || [[ "$tableName" =~ [^a-zA-Z0-9_] ]]; then
        echo -e ${RED}
        echo "====Invalid table name====="
        echo -e ${CYAN}
        return
    fi
  
  
   DATA="$db/tables/$tableName"
   META="$db/metadata/$tableName.meta"
   
   
  if [ ! -f $tablePath || ! -f $metaDataPath]; then
    echo "Table not exist"
  fi
  
  while true; do
    screenHeader

    echo "===  DB : $dbname ==="
    echo "========================="
    echo " Table  :  $tableName  " 
    echo "========================="
    echo
    PS3=$'\nChoose an option: '  
    select opt in "Insert into Table" "Select From Table" "Delete From Table" "Update Table" "Disconnect" "Exit"
    do
    case $REPLY in
      1) instert_table; skipToNext; break ;;
      2) select_fn; skipToNext; break ;;
      3) delete_fn; skipToNext; break ;;
      4) update_fn; skipToNext; break ;;
      5) dbMenu $dbname;; 
      6) exit ;;
      *) echo "Invalid";;
    esac
    done
  done
}

function dbMenu(){
  local dbname="$1"
  local db="$BASE_DIR/$dbname"
  
  while true; do
    screenHeader
    echo "=== Connected to DB: $dbname ==="
    echo
    PS3=$'\nChoose an option: '  
    select opt in "Create Table" "List Tables" "Drop Table" "Select Table" "back" "exit"
    do
    case $REPLY in
      1) add_table "$db"; skipToNext; break ;;
      2) list_tables "$db"; skipToNext; break ;;
      3) drop_table "$db"; skipToNext; break ;;
      4) tableMenu "$db"; skipToNext; break ;;
      5) mainMenu; skipToNext; break ;;
      6) exit  ;;
      *) echo "Invalid";;
    esac
    done
  done
}



function mainMenu(){
  while true; do
    screenHeader
    PS3=$'\nChoose an option: '  
    select opt in "Create Database" "List Databases" "Connect To Database" "Drop Database" "Exit"
    do
      case $REPLY in   # $REPLY = user’s numeric choice
        1) createDB; skipToNext; break ;;
        2) listDB; skipToNext; break ;;
        3) connectDB; skipToNext; break ;;
        4) dropDB; skipToNext; break ;;
        5) echo "DB Exiting."; exit 0 ;;
        *) echo "Invalid";;
      esac
    done
  done
}


