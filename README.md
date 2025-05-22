# Networth (WIP)

Networth is a personal finance tracking tool that consolidates account balances from multiple financial institutions into a single Flutter-based interface. 
It includes web automation scripts (scrapers) for retrieving account balances from DEGIRO, XTB, and CGD (Caixa Geral de Depósitos), and offers a scalable foundation for future expansion into transaction-level tracking.

**Note**: This project is still a work in progress. The MVP (Minimum Viable Product) is functional.

## Project Motivation

This project was created to solve a personal need: having a centralized and private overview of financial positions spread across different platforms. 
Existing solutions were either too limited, required exposing sensitive data to third parties, or lacked extensibility. It aims to:

- Be fully self-hosted
- Maintain full control over sensitive data
- Allow full customization and scaling, including support for transaction imports
- Support daily and historical balance tracking globally or per-source

---

## Architecture

### 1. Python Scrapers

The `source/scrapers` directory includes three scraper scripts, each responsible for logging into a financial service and retrieving the account balance:

#### DEGIRO

- Uses `selenium` to automate login and navigation.
- Fetches the total portfolio value from the profile settings page.
- Waits for the correct DOM elements to be present before scraping.

#### CGD (Caixa Geral de Depósitos)

- Uses `selenium` to simulate user login on the Caixa Direta portal.
- Navigates to the account summary page and extracts the current account value.
- Handles optional warning dialogs if they appear during login.

#### XTB (xStation 5)

- Uses `pyautogui`, `pyperclip`, and `pytesseract` to automate GUI interaction.
- Automates login and uses OCR to read the balance from a specific screen region.
- Due to the nature of the platform (bot detection), scraping must be done via screen capture.

All scrapers expect encrypted credentials, which are generated using the population script described below.

---

### 2. Secrets Population Script

The `populate.py` script prepares a temporary JSON file containing encrypted login credentials for all three services.

#### Usage

```
python populate.py
```

You will be prompted to:

- Enter and confirm a master password
- Provide usernames and passwords for:
  - DEGIRO
  - XTB
  - CGD
 
Sensitive user credentials are **never stored in plain text**. They are encrypted using the following approach:

- **PBKDF2-HMAC-SHA256** with 310,000 iterations is used to derive a secure key from a user-defined master password.
- A **random 16-byte salt** is generated for each secret file and stored alongside the encrypted data.
- The key is used with **Fernet symmetric encryption** to encrypt/decrypt credentials.

---

### 3. Flutter Application

The frontend is built using Flutter and provides a visual overview of account performance and value trends.

#### Features

- Daily net worth deltas visualized with color-coded indicators
- Overview list with collapsible sections for daily changes
- Support for per-account value tracking
- Prepared for future integration with transactional data

The app reads processed data and displays it using a heatmap and detailed views. It is modular and designed to expand as the data model grows.

---

### 4. Supabase Integration

Supabase is used as the backend to persist historical financial data collected from the scrapers.
This allows the frontend to remain lightweight while still accessing a reliable source of truth for balances over time.

Main supabase table: ```daily_source_balance```
- id: Auto-incremented unique ID
- run_id: Associates records from the same run batch
- source: Name of the financial source (e.g. "DEGIRO", "XTB")
- balance: The balance value captured
- date: Timestamp of when the value was collected

---

## Running the Project

### 1. Scraping (inside ```source\scrapers```)

Prepare encrypted secrets:
```
python populate.py
```

Execute scrapers:
```
python main.py
```

---

### 2. Viewing the dashboard (inside ```source\application```):
```
flutter run
```

The application will read the latest account values and generate a visual overview.

---

## TODO / Future Plans

A lot more integration, transaction support, tax overviews, etc.
