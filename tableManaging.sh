#!/bin/bash


function validate_name() {
    local name="$1"
    # optional label: "Table" or "Column"
    if [ -z "$name" ] || [[ "$name" =~ [^a-zA-Z0-9_] ]]; then
        echo "Invalid name: $name (only letters, digits, and underscores allowed)"
        return 1
    fi
    return 0
}

function add_table() {
    local WDB="$1"
    while true; do
        read -p "Enter table name: " tableName

        # Validate table name
        if ! validate_name "$tableName" "Table"; then
            continue
        fi

        if [ -f "$WDB/tables/$tableName" ] || [ -f "$WDB/metadata/$tableName.meta" ]; then
            echo -e "${RED}"
            echo "=====Table already exists.====="
            echo -e "${CYAN}"
            exit 1
        fi

        read -p "How many columns? " col
        echo "RN:number" >> "$WDB/metadata/$tableName.meta"

        counter=1
        while (( counter <= col )); do
            read -p "Enter name for column $counter: " colName

            # Validate column name
            if ! validate_name "$colName" "Column"; then
                continue
            fi

            if grep -q "^$colName:" "$WDB/metadata/$tableName.meta"; then
                echo -e "${RED}"
                echo "=====$colName column already exists.====="
                echo -e "${CYAN}"
                continue
            fi

            read -p "Enter data type (string/number): " colType
            if [ "$colType" != "number" ] && [ "$colType" != "string" ]; then
                echo -e "${RED}"
                echo "=====Invalid column type. Must be 'string' or 'number'.====="
                echo -e "${CYAN}"
                continue
            fi

            echo "$colName:$colType" >> "$WDB/metadata/$tableName.meta"
            echo -e "${GREEN}"
            echo "=====$colName column has been added.====="
            echo -e "${CYAN}"
            ((counter++))
        done

        touch "$WDB/tables/$tableName"

        # Add header row based on meta
        # awk -F: '{print $1}' "$WDB/metadata/$tableName.meta" | paste -sd':' - >> "$WDB/tables/$tableName"
        echo -e "${GREEN}"
        echo "=====Table '$tableName' created successfully with $col columns====="
        echo -e "${CYAN}"
        break
    done
}

# Function to drop a table
function drop_table() {
    local WDB="$1" 
    list_tables "$WDB"
    while true; do
        read -p "Enter the name of the table: " tableName

        if [ -z "$tableName" ]; then
            echo -e "${YELLOW}"
            echo "=====The name of the table can't be empty!====="
            echo -e "${CYAN}"
            continue
        fi
        
        if [ -e "$WDB/tables/$tableName" ] && [ ! -d "$WDB/tables/$tableName" ]; then
            read -p "Are you sure you want to delete the table '$tableName'? (y/n): " confirm

            if [[ $confirm == [Yy] ]]; then
                rm -r "$WDB/tables/$tableName"
                rm -r "$WDB/metadata/$tableName.meta"
                
                echo -e "${GREEN}"
                echo "=====$tableName table has been removed====="
                echo -e "${CYAN}"
                
            else
                echo -e "${YELLOW}"
                echo "=====Cancelled.====="
                echo -e "${CYAN}"
            fi
            break
        else
            echo -e "${RED}"
            echo "=====The $tableName table doesn't exist.====="
            echo -e "${CYAN}"
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

