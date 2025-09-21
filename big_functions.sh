#!/bin/bash
select_fn() {
    echo "[INFO] Press Enter to preview all records"
    local menu_result
    menu_result=$(select_menu) || return 1

    local col val
    read -r choice col val <<< "$menu_result"

    local rows
    if [[ "$choice" == "0" ]]; then
        rows=$(get_all_rows)
        echo "[INFO] Displaying all records:"
    else
        rows=$(select_row "$col" "$val")
    fi

    if [[ -n "$rows" ]]; then
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
    read -r choice col val <<< "$menu_result"

    if [[ "$choice" == "0" ]]; then
        echo "[ERROR] Cannot delete all records. Please select a specific column and value."
        return 1
    fi

    local rows
    rows=$(select_row "$col" "$val")

    if [[ -z "$rows" ]]; then
        echo "[INFO] No record found for $col=$val"
        return 0
    fi

    mapfile -t rows_array <<< "$rows"
    display_rows "${rows_array[@]}"

    local line_no_to_delete=""

    if (( ${#rows_array[@]} > 1 )); then
        echo "[INFO] Multiple records found."
        read -p "Enter the line number you want to delete: " line_no_to_delete

        local found=false
        for entry in "${rows_array[@]}"; do
            local line_no="${entry%%:*}"
            if [[ "$line_no" == "$line_no_to_delete" ]]; then
                found=true
                rows_array=("$entry")  
                break
            fi
        done

        if [[ $found == false ]]; then
            echo "[ERROR] Invalid line number."
            return 1
        fi
    fi

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
    local menu_result
    menu_result=$(select_menu) || return 1

    local col val choice
    read -r choice col val <<< "$menu_result"

    if [[ "$choice" == "0" ]]; then
        echo "[ERROR] Cannot update all records. Please select a specific column and value."
        return 1
    fi

    local rows
    rows=$(select_row "$col" "$val")

    if [[ -z "$rows" ]]; then
        echo "[INFO] No record found for $col=$val"
        return 0
    fi

    mapfile -t rows_array <<< "$rows"
    display_rows "${rows_array[@]}"

    local line_no_to_update=""

    if (( ${#rows_array[@]} > 1 )); then
        echo "[INFO] Multiple records found."
        
        while true; do
            read -p "Enter the line number you want to update (or 'exit' to cancel): " line_no_to_update
            
            if [[ "$line_no_to_update" == "exit" ]]; then
                echo "[INFO] Update cancelled"
                return 0
            fi
            
            if [[ -z "$line_no_to_update" ]]; then
                echo "[ERROR] Please enter a line number or 'exit' to cancel."
                continue
            fi

            break

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
        line_no_to_update="${rows_array[0]%%:*}"
    fi

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

    echo "[INFO] Choose column to update:"
    
    local cols=()
    while IFS=: read -r name type; do
        cols+=("$name")
    done < "$META"
    
    for i in "${!cols[@]}"; do
        echo "$((i+1)). ${cols[$i]}"
    done
    
    local upd_col_no
    while true; do
        read -p "Enter choice [1-${#cols[@]}]: " upd_col_no
        if [[ "$upd_col_no" =~ ^[0-9]+$ ]] && ((upd_col_no >= 1 && upd_col_no <= ${#cols[@]})); then
            break
        else
            echo "[ERROR] Invalid choice. Please enter a number between 1 and ${#cols[@]}."
        fi
    done
    
    local upd_col_name
    upd_col_name=$(awk -F: -v n="$upd_col_no" 'NR==n {print $1}' "$META")

    local new_value=""
    
    if [[ "$upd_col_no" == "1" ]]; then
        while true; do
            read -p "Enter a new value for column '$upd_col_name' (or type 'exit' to cancel): " new_value

            if [[ -z "$new_value" ]]; then
                echo "[ERROR] Please enter a value or 'exit' to cancel."
                continue
            fi

            if [[ "$new_value" == "exit" ]]; then
                echo "[INFO] Update cancelled by user."
                return 0
            fi

            if check_pk "$new_value"; then
                break
            else
                echo "[ERROR] The value '$new_value' already exists. Please enter a different value."
            fi
        done
    else
        while true; do
            read -p "Enter a value for column '$upd_col_name' (or type 'exit' to cancel): " new_value

            if [[ -z "$new_value" ]]; then
                echo "[ERROR] Please enter a value or 'exit' to cancel."
                continue
            fi

            if [[ "$new_value" == "exit" ]]; then
                echo "[INFO] Update cancelled by user."
                return 0
            fi

            if check_type "$new_value" "$upd_col_name"; then
                break
            else
                echo "[ERROR] Invalid type for value '$new_value' in column '$upd_col_name'. Please enter a valid value."
            fi
        done
    fi

    echo "[INFO] Updating line $line_no_to_update: setting $upd_col_name = $new_value"
    update_row "$line_no_to_update" "$upd_col_no" "$new_value"
    echo "[INFO] Row $line_no_to_update updated successfully."
}

insert_fn() {
    echo "[INSERT] Adding new record"
    
    local cols=()
    local types=()
    
    while IFS=: read -r name type; do
        cols+=("$name")
        types+=("$type")
    done < "$META"
    
    if [[ ${#cols[@]} -eq 0 ]]; then
        echo "[ERROR] No schema found in $META"
        return 1
    fi
    
    echo "Schema loaded: ${#cols[@]} columns"
    
    local new_row_values=()
    
    for i in "${!cols[@]}"; do
        local col_name="${cols[$i]}"
        local col_type="${types[$i]}"
        local value=""
        
        echo ""
        echo "Column $((i+1))/${#cols[@]}: $col_name ($col_type)"
        
        # handling PK (first col)
        if [[ $i -eq 0 ]]; then
            while true; do
                read -p "Enter value for $col_name (Primary Key): " value
                
                if [[ -z "$value" ]]; then
                    echo "[ERROR] Primary key cannot be empty. Please enter a value."
                    continue
                fi
                
                if ! check_type "$value" "$col_name"; then
                    echo "[ERROR] Invalid data type for $col_name. Expected: $col_type"
                    continue
                fi
                
                if check_pk "$value"; then
                    echo "[INFO] Primary key '$value' is unique and valid."
                    break
                else
                    echo "[ERROR] Primary key '$value' already exists. Please enter a unique value."
                fi
            done
        else
            while true; do
                read -p "Enter value for $col_name ($col_type): " value
                
                if [[ -z "$value" ]]; then
                    read -p "Value is empty. Continue with empty value? (y/n): " confirm
                    if [[ "$confirm" == "y" ]]; then
                        break
                    else
                        continue
                    fi
                fi
                
                if [[ -n "$value" ]]; then
                    if check_type "$value" "$col_name"; then
                        break
                    else
                        echo "[ERROR] Invalid data type for $col_name. Expected: $col_type"
                    fi
                else
                    break
                fi
            done
        fi
        
        new_row_values+=("$value")
    done
    
    echo ""
    echo "New record to be inserted:"
    echo "-------------------------"
    for i in "${!cols[@]}"; do
        printf "%-12s: %s\n" "${cols[$i]}" "${new_row_values[$i]}"
    done
    echo "-------------------------"
    
    # Confirm
    while true; do
        read -p "Insert this record? (y/n): " confirm
        
        if [[ "$confirm" == "y" ]]; then
            local row_string=""
            for i in "${!new_row_values[@]}"; do
                if [[ $i -eq 0 ]]; then
                    row_string="${new_row_values[$i]}"
                else
                    row_string="${row_string}:${new_row_values[$i]}"
                fi
            done
            
            # Append to data file
            echo "$row_string" >> "$DATA"
            echo "[INFO] Record inserted successfully!"
            return 0
            
        elif [[ "$confirm" == "n" ]]; then
            echo "[INFO] Insert cancelled."
            return 0
        else
            echo "[ERROR] Please enter 'y' for yes or 'n' for no."
        fi
    done
}