#!/bin/bash

select_row() {
    local col="$1"
    local val="$2"

    local col_num
    col_num=$(grep -n "^$col:" "$META" | cut -d: -f1)

    if [[ -z "$col_num" ]]; then
        echo "[ERROR] Column '$col' not found in schema" >&2
        return 1
    fi

    awk -F: -v col_num="$col_num" -v val="$val" '
        $col_num == val { print NR ":" $0 }
    ' "$DATA"
}


display_rows() {
    local results=("$@")  

    if [[ ${#results[@]} -eq 0 ]]; then
        echo "[INFO] No rows found"
        return 0
    fi

    headers=($(cut -d: -f1 "$META"))
    

    printf "%-5s" "Line"
    for h in "${headers[@]}"; do
        printf "| %-12s" "$h"
    done
    echo
    echo "---------------------------------------------------------"

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
    echo "Select a column :" >&2

    num_cols=$(cat "$META" | wc -l)
    awk -F: '{print NR ". " $1}' "$META" >&2

    read -p "Enter choice [1-$num_cols]: " choice >&2

    if [[ -z "$choice" ]]; then
        echo "0 ALL_ROWS ALL_VALUES"
        return 0
    fi

    if ! [[ "$choice" =~ ^[0-9]+$ ]] || ((choice < 1 || choice > $num_cols)); then
        echo "[ERROR] Invalid choice" >&2
        return 1
    fi

    local col
    col=$(awk -F: -v n="$choice" 'NR==n {print $1}' "$META")

    read -p "Enter value for column '$col': " val >&2

    echo "$choice $col $val"
}


get_all_rows() {
    awk '{print NR ":" $0}' "$DATA"
}
