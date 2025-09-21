# Shell-DBMS

A simple Database Management System (DBMS) implemented using Bash shell scripting. This project provides a Command-Line Interface (CLI) to create, manage, and manipulate databases and tables on the file system.

## 📂 Project Structure

The project is organized into several Bash script files, each responsible for specific functionalities:

- **`database-manager.sh`**: Handles database creation, deletion, and listing.
- **`tableManaging.sh`**: Manages table operations such as creation, deletion, and data insertion.
- **`helpers.sh`**: Contains utility functions used across the project.
- **`menus.sh`**: Defines the CLI menus for user interaction.
- **`screen.sh`**: Manages screen-related operations.
- **`selecthelpers.sh`**: Provides helper functions for selection operations.
- **`big_functions.sh`**: Contains larger, more complex functions used in the DBMS.
- **`main`**: The entry point of the application, initializing the DBMS.

## 🚀 Features

- **Database Operations**:
  - Create a new database.
  - List existing databases.
  - Delete a database.

- **Table Operations**:
  - Create a new table within a database.
  - Insert data into a table.
  - Select data from a table.
  - Update existing records.
  - Delete records from a table.

- **Data Validation**:
  - Enforces data types for each column.
  - Validates primary key uniqueness.

## 🛠️ Prerequisites

Ensure you have the following installed:

- A Unix-like operating system (Linux, macOS, or WSL on Windows).
- Bash shell (version 4.0 or higher recommended).

## 📥 Installation

1. Clone the repository:

   ```bash
   git clone https://github.com/eagledev-am/Shell-DBMS.git
   cd Shell-DBMS
   ```
2. Make the scripts executable:
   
   ```
   chmod +x *.sh
   ```
3. Run the main script:
   
   ```bash
   ./main
   ```



