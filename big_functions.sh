#!/bin/bash
select_fn() {
    local menu_result
    menu_result=$(select_menu) || return 1

    local col val
    # safer split into two vars
    read -r choice col val <<< "$menu_result"

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
    local menu_result
    menu_result=$(select_menu) || return 1

    local col val choice
    # safer split into two vars
    read -r choice col val <<< "$menu_result"

    local rows
    rows=$(select_row "$col" "$val")

    if [[ -z "$rows" ]]; then
        echo "[INFO] No record found for $col=$val"
        return 0
    fi

    # Convert to array
    mapfile -t rows_array <<< "$rows"
    display_rows "${rows_array[@]}"

    local line_no_to_delete=""

    if (( ${#rows_array[@]} > 1 )); then
        echo "[INFO] Multiple records found."
        read -p "Enter the line number you want to delete: " line_no_to_delete

        # Validate input
        local found=false
        for entry in "${rows_array[@]}"; do
            local line_no="${entry%%:*}"
            if [[ "$line_no" == "$line_no_to_delete" ]]; then
                found=true
                rows_array=("$entry")  # keep only chosen one
                break
            fi
        done

        if [[ $found == false ]]; then
            echo "[ERROR] Invalid line number."
            return 1
        fi
    fi

    # If only one row, auto-pick
    if (( ${#rows_array[@]} == 1 )); then
        local entry="${rows_array[0]}"
        local line_no="${entry%%:*}"

        read -p "Delete this record (line $line_no)? (y/n): " confirm
        if [[ "$confirm" != "y" ]]; then
            echo "[INFO] Delete cancelled"
            return 0
        fi

        remove_row "$line_no"
        echo "[INFO] Row $line_no deleted."
    fi
}

update_fn() {
    # First, get the records to select from
    local menu_result
    menu_result=$(select_menu) || return 1

    local col val choice
    # Safer split into vars
    read -r choice col val <<< "$menu_result"

    local rows
    rows=$(select_row "$col" "$val")

    if [[ -z "$rows" ]]; then
        echo "[INFO] No record found for $col=$val"
        return 0
    fi

    # Convert to array
    mapfile -t rows_array <<< "$rows"
    display_rows "${rows_array[@]}"

    local line_no_to_update=""

    # Handle multiple records case
    if (( ${#rows_array[@]} > 1 )); then
        echo "[INFO] Multiple records found."
        
        while true; do
            read -p "Enter the line number you want to update (or 'exit' to cancel): " line_no_to_update
            
            # Check if user wants to exit
            if [[ "$line_no_to_update" == "exit" ]]; then
                echo "[INFO] Update cancelled"
                return 0
            fi
            
            # Check if input is empty
            if [[ -z "$line_no_to_update" ]]; then
                echo "[ERROR] Please enter a line number or 'exit' to cancel."
                continue
            fi

            # Validate that the line number exists in our results
            local found=false
            for entry in "${rows_array[@]}"; do
                local line_no="${entry%%:*}"
                if [[ "$line_no" == "$line_no_to_update" ]]; then
                    found=true
                    break
                fi
            done

            if [[ $found == true ]]; then
                break
            else
                echo "[ERROR] Invalid line number. Please choose from the displayed lines."
            fi
        done
    else
        # Only one record found
        line_no_to_update="${rows_array[0]%%:*}"
    fi

    # Confirm before proceeding with the update
    while true; do
        read -p "Update this record (line $line_no_to_update)? (y/n): " confirm
        
        if [[ -z "$confirm" ]]; then
            echo "[ERROR] Please enter 'y' for yes or 'n' for no."
            continue
        fi
        
        if [[ "$confirm" == "y" ]]; then
            break
        elif [[ "$confirm" == "n" ]]; then
            echo "[INFO] Update cancelled"
            return 0
        else
            echo "[ERROR] Please enter 'y' for yes or 'n' for no."
        fi
    done

    # Choose column to update
    echo "[INFO] Choose column to update:"
    local update_menu_result
    update_menu_result=$(select_menu) || return 1

    local update_choice update_col update_val
    read -r update_choice update_col update_val <<< "$update_menu_result"

    # Now handle the value input based on column type
    local new_value=""
    
    # If choice is 1 (assuming it's the primary key column)
    if [[ "$update_choice" == "1" ]]; then
        # Loop until user enters a valid, unique value or decides to exit
        while true; do
            read -p "Enter a new value for column '$update_col' (or type 'exit' to cancel): " new_value

            # Check if input is empty
            if [[ -z "$new_value" ]]; then
                echo "[ERROR] Please enter a value or 'exit' to cancel."
                continue
            fi

            # Check if the user wants to exit
            if [[ "$new_value" == "exit" ]]; then
                echo "[INFO] Update cancelled by user."
                return 0
            fi

            # Check if the value already exists (using check_pk function)
            if check_pk "$new_value"; then
                # If check_pk succeeds (returns 0), the value is unique
                break
            else
                # If check_pk fails (returns 1), the value already exists
                echo "[ERROR] The value '$new_value' already exists. Please enter a different value."
            fi
        done
    else
        # For other columns, check the type
        while true; do
            read -p "Enter a value for column '$update_col' (or type 'exit' to cancel): " new_value

            # Check if input is empty
            if [[ -z "$new_value" ]]; then
                echo "[ERROR] Please enter a value or 'exit' to cancel."
                continue
            fi

            # Check if the user wants to exit
            if [[ "$new_value" == "exit" ]]; then
                echo "[INFO] Update cancelled by user."
                return 0
            fi

            # Check if the value is of the correct type for this column
            if check_type "$new_value" "$update_col"; then
                # If check_type succeeds (returns 0), the value is valid
                break
            else
                # If check_type fails (returns 1), show error and continue loop
                echo "[ERROR] Invalid type for value '$new_value' in column '$update_col'. Please enter a valid value."
            fi
        done
    fi

    # Proceed with updating the record
    echo "[INFO] Updating line $line_no_to_update: setting $update_col = $new_value"
    update_row "$line_no_to_update" "$update_choice" "$new_value"
    echo "[INFO] Row $line_no_to_update updated successfully."
}
