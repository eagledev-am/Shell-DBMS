#!/bin/bash

# File paths
# META="table.meta"
# DATA="table.data"

check_pk() {
    local value="$1"

    if grep -q "^$value:" "$DATA"; then
        echo "Can't Insert this value as it's duplicated"
        return 1
    else
        #echo "Unique"
        return 0
    fi
}

check_type() {
    local value="$1"
    local column="$2"

    local col_type

    
    col_type=$(grep "^$column:" "$META" | cut -d':' -f2)


    case "$col_type" in
        int)
            if [[ "$value" =~ ^[0-9]+$ ]]; then
                return 0
            else
                echo "[check_type] '$value' is not a valid INT"
                return 1
            fi
            ;;
        str)
            if [[ "$value" =~ ^[A-Za-z]+$ ]]; then
                return 0  # valid string
            else
                echo "[check_type] '$value' is not a valid STR"
                return 1
            fi
            ;;
    esac
}

remove_row() {
    local line_no="$1"
    if [[ -z "$line_no" ]]; then
        echo "[remove_row] Error: no line number given"
        return 1
    fi

    if ! [[ "$line_no" =~ ^[0-9]+$ ]]; then
        echo "[remove_row] Error: '$line_no' is not a valid number"
        return 1
    fi

    sed -i "${line_no}d" "$DATA"
    echo "[remove_row] Removed line $line_no from $DATA"
}

delete() {
    echo "[DELETE]"

    local res
    res=$(select_menu)
    local col="${res%%|*}"
    local val="${res##*|}"

    mapfile -t rows < <(select_row "$col" "$val")

    if [[ ${#rows[@]} -eq 0 ]]; then
        echo "[DELETE] No rows match '$col=$val'. Aborting."
        return 1
    fi

    if [[ ${#rows[@]} -eq 1 ]]; then
        echo "[DELETE] Found one row:"
        display_rows "${rows[@]}"
        read -p "Confirm delete? (y/n): " ans
        if [[ "$ans" == "y" ]]; then
            local line_no="${rows[0]%%:*}"  
            remove_row "$line_no"
        else
            echo "[DELETE] Cancelled."
        fi
        return 0
    fi

    echo "[DELETE] Multiple rows found:"
    display_rows "${rows[@]}"

    read -p "Enter line number to delete: " line_no
    if [[ -n "$line_no" ]]; then
        remove_row "$line_no"
    else
        echo "[DELETE] Cancelled."
    fi
}

update_row() {
    local line_num=$1
    local field_num=$2
    local new_val=$3
    local tmpf=$DATA+'.tmp'

    awk -F: -v line="$line_num" -v field="$field_num" -v val="$new_val" '
    BEGIN { OFS=FS }
    NR == line { $field = val }
    { print }
    ' $DATA > $tmpf && mv $tmpf $DATA
}
