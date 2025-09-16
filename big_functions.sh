#!/usr/bin/env bash

# Load helpers
source ./selection_helpers.sh

select_fn() {
    local menu_result
    menu_result=$(select_menu) || return 1

    local col val
    # safer split into two vars
    read -r col val <<< "$menu_result"

    local rows
    rows=$(select_row "$col" "$val")

    if [[ -n "$rows" ]]; then
        # Convert into array safely
        mapfile -t rows_array <<< "$rows"
        display_rows "${rows_array[@]}"
    else
        echo "[INFO] No matching rows found"
    fi
} 


delete_fn() {
    # Ask user for ID directly
    read -p "Enter the ID of the record to delete: " id_val

    # Step 1. Search for row with this id
    local rows
    rows=$(select_row "id" "$id_val")

    if [[ -z "$rows" ]]; then
        echo "[INFO] No record found with id=$id_val"
        return 0
    fi

    # Step 2. Convert to array (should usually be 1 row)
    mapfile -t rows_array <<< "$rows"
    display_rows "${rows_array[@]}"

    # Step 3. Confirm deletion
    read -p "Delete this record? (y/n): " confirm
    if [[ "$confirm" != "y" ]]; then
        echo "[INFO] Delete cancelled"
        return 0
    fi

    # Step 4. Remove (reverse loop still safe even if one row)
    for (( i=${#rows_array[@]}-1; i>=0; i-- )); do
        local entry="${rows_array[$i]}"
        local line_no="${entry%%:*}"
        remove_row "$line_no"
    done
}