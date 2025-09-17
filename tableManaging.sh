#!/bin/bash



# Function to validate names (only letters, digits, underscore allowed)
validate_name() {
    local name="$1"
    # optional label: "Table" or "Column"
    if [ -z "$name" ] || [[ "$name" =~ [^a-zA-Z0-9_] ]]; then
        echo "Invalid name: $name (only letters, digits, and underscores allowed)"
        return 1
    fi
    return 0
}

# Function to add a table
add_table(WDB="$1") {
    while true; do
        read -p "Enter table name: " tableName

        # Validate table name
        if ! validate_name "$tableName" "Table"; then
            continue
        fi

        if [ -f "./$WDB/$tableName" ] || [ -f "./$WDB/$tableName.meta" ]; then
            echo "Table already exists."
            exit 1
        fi

        read -p "How many columns? " col
        echo "RN:number" >> "./$WDB/$tableName.meta"

        counter=1
        while (( counter <= col )); do
            read -p "Enter name for column $counter: " colName

            # Validate column name
            if ! validate_name "$colName" "Column"; then
                continue
            fi

            if grep -q "^$colName:" "./$WDB/$tableName.meta"; then
                echo "$colName column already exists."
                continue
            fi

            read -p "Enter data type (string/number): " colType
            if [ "$colType" != "number" ] && [ "$colType" != "string" ]; then
                echo "Invalid column type. Must be 'string' or 'number'."
                continue
            fi

            echo "$colName:$colType" >> "./$WDB/$tableName.meta"
            echo "$colName column has been added."
            ((counter++))
        done

        touch "./$WDB/$tableName"

        # Add header row based on meta
        awk -F: '{print $1}' "./$WDB/$tableName.meta" | paste -sd':' - >> "./$WDB/$tableName"

        echo "Table '$tableName' created successfully with $col columns."
        break
    done
}

# Function to drop a table
drop_table(WDB="$1") {
    while true; do
        read -p "Enter the name of the table: " tableName

        if [ -z "$tableName" ]; then
            echo "The name of the table can't be empty!"
            continue
        fi

        if [ -e "./$WDB/$tableName" ] && [ ! -d "./$WDB/$tableName" ]; then
            read -p "Are you sure you want to delete the table '$tableName'? (y/n): " confirm

            if [[ $confirm == [Yy] ]]; then
                rm -r "./$WDB/$tableName"
                rm -r "./$WDB/$tableName.meta"
                echo ""
                echo "$tableName table has been removed."
            else
                echo "Cancelled."
            fi
            break
        else
            echo "The $tableName table doesn't exist."
            continue
        fi
    done
}

# Function to list all tables
list_tables(WDB="$1") {
    tables=$(find "$WDB" -maxdepth 1 -type f ! -name "*.meta" -exec basename {} \;)

    if [ -z "$tables" ]; then
        echo "No tables found in database '${WDB}'."
    else
        echo "Tables in '${WDB}':"
        echo "$tables"
    fi
}

# Main script to choose which function to run
echo "Choose an action:"
echo "1. Add a table"
echo "2. Drop a table"
echo "3. List tables"
read -p "Enter your choice (1/2/3): " choice

case $choice in
    1)
        add_table
        ;;
    2)
        drop_table
        ;;
    3)
        list_tables
        ;;
    *)
        echo "Invalid choice. Exiting."
        exit 1
        ;;
esac
