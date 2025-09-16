#!/bin/bash


function skipToNext(){
read -n 1 -s -r -p "✨ Press any key to continue..."
}

tableMenu(){
  
  local dbname="$1"
  local db="$BASE_DIR/$dbname"
  
  read -p "Enter Table name: " tableName
  
  local tablePath = "$BASE_DIR/$dbname/data/$tableName"
  local metaDataPath= "$BASE_DIR/$dbname/metadata/$tableName"
  
  if [ ! -f $tablePath ]; then
    echo "Table not exist"
  fi
  
  while true; do
    screenHeader
    echo "===  DB : $dbname ==="
    echo "========================="
    echo " Table  :  		$tableName  " 
    echo "========================="
    echo
    PS3=$'\nChoose an option: '  
    select opt in "Insert into Table" "Select From Table" "Delete From Table" "Update Table" "Disconnect" "Exit"
    do
    case $REPLY in
      1) createTable "$tablePath" "$metaDataPath"; skipToNext; break ;;
      2) listTables "$tablePath" "$metaDataPath"; skipToNext; break ;;
      3) dropTables "$tablePath" "$metaDataPath"; skipToNext; break ;;
      4) updateTables "$tablePath" "$metaDataPath"; skipToNext; break ;;
      5) dbMenu;; 
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
      1) createTable "$db"; skipToNext; break ;;
      2) listTables "$db"; skipToNext; break ;;
      3) dropTables "$db"; skipToNext; break ;;
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
    PS3=$'\nChoose an option: '   # prompt shown by select
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


