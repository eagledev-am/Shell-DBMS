#!/bin/bash

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
    rm -rf "$db" && echo "\n =====Deleted successfully===="
  else
    echo "Aborted"
  fi
  
}



