#!/bin/bash

function isValidDBName(){
    if [[ ! "$1" =~ ^[A-Za-z][A-Za-z0-9_]{0,63}$ ]]; then
        echo -e "${RED}"
        echo "=====Invalid database name====="
        echo -e "${CYAN}"
        return 1 
    fi
    return 0  
}

function isEmpty(){
    if [[ -z "$1" ]]; then
        return 0
    fi
    return 1
}

function createDB(){
    read -p "Enter the name for new database: " dbname
    if ! isValidDBName "$dbname"; then
        read -n 1 -s -r -p "✨ Press any key to continue..."
        return  
    fi
    
    local db="$BASE_DIR/$dbname"
    if [[ -d "$db" ]]; then
        echo -e "${YELLOW}"
        echo "=====Database name already exists====="
        echo -e "${CYAN}"    
    else
        mkdir -p "$db" "$db/tables" "$db/metadata"
        echo -e "${GREEN}"
        echo "=====Database ${dbname} created successfully====="
        echo
        echo -e "${CYAN}"
    fi
}

function listDB() {
    echo -e "\nDatabases:\n"
    printf "%-5s | %-30s\n" "No." "Database Name"
    printf "%-5s-+-%-30s\n" "-----" "------------------------------"
    local count=0
    
    for db in $(ls -1 "$BASE_DIR" 2>/dev/null); do
        ((count++))
        printf "%-5s | %-30s\n" "$count" "$db"
    done
    
    if [[ $count -eq 0 ]]; then
        echo "(none)"
    fi
    echo 
}

function connectDB(){
    echo "Databases: " 
    listDB
    
    read -r -p "Database name to connect: " dbname
    if ! isValidDBName "$dbname"; then
        read -n 1 -s -r -p "✨ Press any key to continue..."
        mainMenu
        return
    fi
    
    local db="$BASE_DIR/$dbname"
    if [[ ! -d "$db" ]]; then
        echo -e "${RED}"
        echo "=====No such database====="
        echo
        echo -e "${CYAN}"
        read -n 1 -s -r -p "✨ Press any key to continue..."
        mainMenu
        return
    fi
    
    dbMenu "$dbname"
}

function dropDB(){
    echo "Databases: " 
    listDB
    
    while true; do  
        read -r -p "Database name to drop or Enter to exit: " dbname
        
        if isEmpty "$dbname"; then
            echo
            return
        fi
        
        local db="$BASE_DIR/$dbname"
        if [[ -d "$db" ]]; then
            break  
        fi
        
        echo -e "${RED}"  
        echo "=====No such database====="
        echo -e "${CYAN}"
    done   
    
    read -r -p "Are you sure you want to delete database ${dbname} and all its tables? (Y/N) " opt
    if [[ "$opt" =~ ^[Yy]$ ]]; then
        echo -e "${GREEN}"
        if rm -rf "$db"; then
            echo "=====Deleted successfully===="
            echo
        fi
        echo -e "${CYAN}"
    else
        echo "Aborted"
    fi
}
