#!/bin/bash

BASE_DIR="$(pwd)"
DELIM='|'


function mainMenu(){
  while true; do
    clear
    echo "==========================================="
    echo "          🗄️  Welcome to Bash DBMS          "
    echo "==========================================="
    echo "Base folder: $BASE_DIR"
    echo

    PS3=$'\nChoose an option: '   # prompt shown by select
    select opt in "Create Database" "List Databases" "Connect To Database" "Drop Database" "Exit"
    do
      case $REPLY in   # $REPLY = user’s numeric choice
        1) createDB;continue; break ;;
        2) listDB;continue; break ;;
        3) connectDB;continue; break ;;
        4) dropDB;continue; break ;;
        5) echo "DB Exiting."; exit 0 ;;
        *) echo "Invalid";;
      esac
    done
  done
}


function createDB(){
  read -p "Enter the name for new database: " dbname
  if [[ ! "$dbname" =~ ^[A-Za-z0-9_-]+$ ]]; then
    echo "Invalid database name"
    return
  fi
  local db="$BASE_DIR/$dbname"
  if [ -d "$db" ]; then
    echo "Database name already exists"
  else
    mkdir "$db"
    echo "Database ${dbname} created successfully"
  fi
}

function connectDB(){
  read -r -p "Database name to connect: " dbname
  local db="$BASE_DIR/$dbname"
  if [[ ! -d "$db" ]]; then
    echo "No such database!"
  fi
  dbMenu "$dbname"
}

function listDB(){
  echo "Databases: "
  ls "$BASE_DIR" 2> /dev/null | grep -vE '\.sh$' || echo "(none)"
}

function dropDB(){
  read -r -p "Database name to drop: " dbname
  local db="$BASE_DIR/$dbname"
  if [[ ! -d "$db" ]]; then
    echo "No such database!"
    return
  fi
  read -r -p "Are you sure you want to delete database ${dbname} and all its tables? (Y/N) " opt
  if [[ "$opt" =~ ^[Yy]$ ]]; then
    rm -rf "$db" && echo "Deleted successfully"
  else
    echo "Aborted"
  fi
  
}

function dbMenu(){
  local dbname="$1"
  local db="$BASE_DIR/$dbname"
  while true; do
    clear
    echo "=== Connected to DB: $dbname ==="
    echo
    echo "1) Create Table"
    echo "2) List Tables"
    echo "3) Drop Table"
    echo "4) Insert into Table"
    echo "5) Select From Table"
    echo "6) Delete From Table"
    echo "7) Update Table"
    echo "8) Disconnect"
    read -r -p $'\nChoose an option: ' opt
    case $opt in
      1) create_table "$db" ;;
      2) list_tables "$db" ;;
      3) drop_table "$db" ;;
      4) insert_into_table "$db" ;;
      5) select_from_table "$db" ;;
      6) delete_from_table "$db" ;;
      7) update_table "$db" ;;
      8) break ;;
      *) echo "Invalid";;
    esac
  done
}


