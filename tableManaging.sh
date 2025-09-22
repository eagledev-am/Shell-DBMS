#!/bin/bash


validate_name() {
    local name="$1"
    if [ -z "$name" ] || [[ "$name" =~ [^a-zA-Z0-9_] ]] || [[ "$name" =~ ^[0-9] ]]; then
        echo "Invalid name: $name (must start with a letter/underscore and contain only letters, digits, and underscores)"
        return 1
    fi
    return 0
}

function add_table() {
    local WDB="$1"
    while true; do
        read -p "Enter table name: " tableName
        
        if ! validate_name "$tableName"; then
            continue
        fi

        
        if [ -f "$WDB/tables/$tableName" ] || [ -f "$WDB/metadata/$tableName.meta" ]; then
            echo "=====Table already exists.====="
            exit 1
        fi
        
        read -p "How many columns? " col
        touch "$WDB/metadata/$tableName.meta"
        
        counter=1
        while (( counter <= col )); do
            read -p "Enter name for column $counter: " colName
            
            if ! validate_name "$colName"; then
                continue
            fi
            
            if grep -q "^$colName:" "$WDB/metadata/$tableName.meta"; then
                echo "=====$colName column already exists.====="
                continue
            fi
            
            read -p "Enter data type (str/int): " colType
            if [ "$colType" != "str" ] && [ "$colType" != "int" ]; then
                echo "=====Invalid column type. Must be 'str' or 'int'.====="
                continue
            fi
            
            echo "$colName:$colType" >> "$WDB/metadata/$tableName.meta"
            echo "=====$colName column has been added.====="
            ((counter++))
        done
        
        touch "$WDB/tables/$tableName"
        echo "=====Table '$tableName' created successfully with $col columns====="
        break
    done
}

function drop_table() {
    local WDB="$1"
    list_tables "$WDB"
    while true; do
        read -p "Enter the name of the table: " tableName
        
        if [ -z "$tableName" ]; then
            continue
        fi
        
        if [ -e "$WDB/tables/$tableName" ] && [ ! -d "$WDB/tables/$tableName" ]; then
            read -p "Are you sure you want to delete the table '$tableName'? (y/n): " confirm
            
            if [[ $confirm == [Yy] ]]; then
                rm -r "$WDB/tables/$tableName"
                rm -r "$WDB/metadata/$tableName.meta"
                echo "=====$tableName table has been removed====="
                
            else
                echo "=====Cancelled.====="
            fi
            break
        else
            echo "=====The $tableName table doesn't exist.====="
            continue
        fi
    done
}

function list_tables() {
    local WDB="$1"
    tables=$(find "$WDB/tables" -maxdepth 1 -type f ! -name "*.meta" -exec basename {} \;)
    
    if [ -z "$tables" ]; then
        echo "=====No tables found in database.====="
    else
        echo
        echo "Table : "
        printf "%-5s | %-30s\n" "No." "Tables Name"
        printf "%-5s-+-%-30s\n" "-----" "------------------------------"
        local count=0
        
        for table in $tables; do
            ((count++))
            printf "%-5s | %-30s\n" "$count" "$table"
        done
    fi
    echo
}

