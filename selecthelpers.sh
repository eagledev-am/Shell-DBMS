#!/bin/bash


select_row() {
    local col="$1"
    local val="$2"

    # 1. Find column index from meta
    local col_index=0
    local found=0
    while IFS=: read -r name type; do
        col_index=$((col_index+1))
        if [[ "$name" == "$col" ]]; then
            found=1
            break
        fi
    done < "$META"

    if [[ $found -eq 0 ]]; then
        echo "[ERROR] Column '$col' not found in schema"
        return 1
    fi

    # 2. Search in data file
    local line_no=0
    while IFS= read -r line; do
        line_no=$((line_no+1))
        IFS=: read -ra fields <<< "$line"
        if [[ "${fields[$((col_index-1))]}" == "$val" ]]; then
            echo "$line_no:$line"
        fi
    done < "$DATA"
}


display_rows() {
    local results=("$@")  # take all rows passed as args

    if [[ ${#results[@]} -eq 0 ]]; then
        echo "[INFO] No rows found"
        return 0
    fi

    # 1. Load column names from meta
    local headers=()
    while IFS=: read -r name type; do
        headers+=("$name")
    done < "$META"

    # 2. Print header
    printf "%-5s" "Line"
    for h in "${headers[@]}"; do
        printf "| %-12s" "$h"
    done
    echo
    echo "---------------------------------------------------------"

    # 3. Print each row
    for entry in "${results[@]}"; do
        local line_no="${entry%%:*}"
        local row="${entry#*:}"

        IFS=: read -r -a fields <<< "$row"

        printf "%-5s" "$line_no"
        for f in "${fields[@]}"; do
            printf "| %-12s" "$f"
        done
        echo
    done
}


select_menu() {
    local cols=()
    # 1. Load columns from meta
    while IFS=: read -r name type; do
        cols+=("$name")
    done < "$META"

    # 2. Display menu (stderr so not captured)
    echo "Select a column :" >&2
    for i in "${!cols[@]}"; do
        echo "$((i+1)). ${cols[$i]}" >&2
    done

    # 3. Read choice (stderr prompt, user input on stdin)
    read -p "Enter choice [1-${#cols[@]}]: " choice >&2
    if ! [[ "$choice" =~ ^[0-9]+$ ]] || ((choice < 1 || choice > ${#cols[@]})); then
        echo "[ERROR] Invalid choice" >&2
        return 1
    fi

    local col="${cols[$((choice-1))]}"

    # 4. Ask for value
    read -p "Enter value for column '$col': " val >&2

    # 5. Return the choice, column, and value
    echo "$choice $col $val"
}


