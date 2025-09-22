#!/bin/bash

  RED="\e[31m"
  GREEN="\e[32m"
  YELLOW="\e[33m"
  BLUE="\e[34m"
  MAGENTA="\e[35m"
  CYAN="\e[36m"
  BOLD="\e[1m"
  RESET="\e[0m"

function screenHeader(){
    clear
    echo -e "${CYAN}"
    echo "==========================================="
    echo -e "${BOLD}${YELLOW}          🗄️  Bash DBMS   🗄️ ${RESET}${CYAN}"
    echo "==========================================="
    echo
}

introScreen() {
  clear

  echo -e "${CYAN}"
  echo "================================================="
  echo -e "${BOLD}${YELLOW}         🗄️   Welcome to Bash DBMS   🗄️ ${RESET}${CYAN}"
  echo "================================================="
  echo
  echo -e "${GREEN}   A Simple Database Management System in Bash"
  echo -e "           ${MAGENTA}Manage · Store · Retrieve"
  echo
  echo -e "${BLUE}-----------------------------------------------"
  echo -e "          Created by: ${RED}M & A & K & Z"
  echo -e "${BLUE}-----------------------------------------------"
  
echo -e "${YELLOW}----------------------------------------------------${NC}"
echo -e "${CYAN}Version 1.0 | CLI-based | Store & Retrieve Data${NC}"
echo -e "${YELLOW}----------------------------------------------------${NC}"
echo -e "${RESET}"

  echo
  read -n 1 -s -r -p "✨ Press any key to continue..."
}

