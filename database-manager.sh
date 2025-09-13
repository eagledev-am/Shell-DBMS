#!/bin/bash

BASE_DIR="$(pwd)"
DELIM='|'

function pause(){ read -r -p "Press Enter to continue..."; }

function mainMenu(){
  while true; do
    clear
    echo "==========================================="
    echo "          🗄️  Welcome to Bash DBMS          "
    echo "==========================================="
    echo "Base folder: $BASE_DIR"
    echo
    echo "1) Create Database"
    echo "2) List Databases"
    echo "3) Connect To Database"
    echo "4) Drop Database"
    echo "5) Exit"
    read -r -p $'\nChoose an option: ' opt
    case $opt in
      1) createDB ;;
      2) listDB ;;
      3) connectDB ;;
      4) dropDB ;;
      5) echo "Goodbye."; exit 0 ;;
      *) echo "Invalid"; pause ;;
    esac
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
    pause
    return
  fi
  dbMenu "$dbname"
}

function listDB(){
  echo "Databases: "
  ls "$BASE_DIR" 2> /dev/null || echo "(none)"
  pause
}

function dropDB(){
  read -r -p "Database name to drop: " dbname
  local db="$BASE_DIR/$dbname"
  if [[ ! -d "$db" ]]; then
    echo "No such database!"
    pause
    return
  fi
  read -r -p "Are you sure you want to delete database ${dbname} and all its tables? (Y/N) " opt
  if [[ "$opt" =~ ^[Yy]$ ]]; then
    rm -rf "$db" && echo "Deleted successfully"
  else
    echo "Aborted"
  fi
  pause
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
      *) echo "Invalid"; pause ;;
    esac
  done
}

mainMenu
