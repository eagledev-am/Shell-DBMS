#!/bin/bash

# Function to prompt for column name and type
function colNameAndTypeSelect() {
    read -p "  Name: " colName
    PS3=$'\nSelect column type: '
    select colType in "string" "int" "Exit"; do
        case $colType in
            string|int) 
                echo "Column type will be ${colType}"
                break
                ;;
            Exit)
                echo "Exiting column definition."
                return 1
                ;;
            *) echo "Invalid column type." ;;
        esac
    done
    # Export the selected values
    export colName
    export colType
    return 0
}

# Function to create a table and its metadata
function createTable() {
    db="$1"

    # Check database connection
    if [ -z "$db" ] || [ ! -d "$db" ]; then
        echo "Error: No database connected."
        return 1
    fi

    # Get and validate table name
    read -p "Enter table name: " tableName
    if [[ ! "$tableName" =~ ^[A-Za-z0-9_-]+$ ]]; then
        echo "Error: Invalid table name."
        return 1
    fi

    # Check if table already exists
    if [ -f "$db/${tableName}.table" ]; then
        echo "Error: Table '$tableName' already exists."
        return 1
    fi

    # Get number of columns
    read -p "Enter number of columns: " numCols
    if [[ ! "$numCols" =~ ^[1-9][0-9]*$ ]]; then
        echo "Error: Invalid number of columns."
        return 1
    fi

    columns=""
    metadata=""
    primary_key=""

    # Loop to define each column
    for ((i = 1; i <= numCols; i++)); do
        echo "Column $i:"
        if ! colNameAndTypeSelect; then
            echo "Column definition cancelled."
            return 1
        fi

        # Build columns header
        if [ $i -eq 1 ]; then
            columns="$colName"
        else
            columns="${columns}:${colName}"
        fi

        # Append to metadata
        if [ -z "$primary_key" ]; then
            read -p "  Set as primary key? (y/n): " isPk
            if [[ "$isPk" =~ ^[Yy]$ ]]; then
                primary_key="$colName"
                metadata="${metadata}${colName}:${colType}:PK\n"
            else
                metadata="${metadata}${colName}:${colType}:\n"
            fi
        else
            metadata="${metadata}${colName}:${colType}:\n"
        fi
    done

    # Ensure a primary key was chosen
    if [ -z "$primary_key" ]; then
        echo "Error: No primary key defined."
        return 1
    fi

    # Create the table file with header
    echo "$columns" > "$db/content/${tableName}.table"

    # Create the metadata file
    echo -e "PK:$primary_key\n$metadata" > "$db/data/metadata_${tableName}"

    echo "Table '$tableName' created successfully!"
    echo "Primary key: $primary_key"
}


