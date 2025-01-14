# Password Manager

This project is a simple password manager implemented using Lua and OpenSSL for encryption and decryption. The application encrypts passwords using AES-256-CBC and securely stores them in a file. It provides functionality to add and view saved passwords.

## Features

- AES-256-CBC encryption for secure password storage.
- Key and IV generation for encryption.
- Easy-to-use command-line interface.
- Stores passwords in a file securely.

## Project Structure

```
PasswordManagerLua/
├── src/
│   ├── c/
│   │   └── openssl_wrapper.c      # C file for the OpenSSL wrapper
│   └── lua/
│       ├── password_manager.lua  # Main Lua script for the password manager
│       └── utils.lua             # Utility functions (e.g., key and IV generation)
├── build/
│   ├── openssl_wrapper.so        # Compiled shared library from the C wrapper
├── data/
│   ├── passwords.txt             # Password storage file
│   └── key.bin                   # Binary file for encryption key
├── README.md                     # Documentation about the project
└── Makefile                      # Makefile for building the C library
```

## Prerequisites

- GCC compiler
- Lua (version 5.4 or compatible)
- OpenSSL development libraries

## Setup

1. Clone the repository:

   ```bash
   git clone https://github.com/mhdthariq/PasswordManagerLua.git
   cd password_manager_project
   ```

2. Build the OpenSSL wrapper:

   ```bash
   make
   ```

   This will compile the `openssl_wrapper.c` file into a shared library (`openssl_wrapper.so`) inside the `build/` directory.

3. Ensure the `data/` directory exists:

   ```bash
   mkdir -p data
   ```

4. Run the password manager:

   ```bash
   lua src/lua/password_manager.lua
   ```

## Usage

### Menu Options

1. **Add Password**: Allows you to add a new username-password pair. The password is encrypted before storage.
2. **View Passwords**: Displays all saved username-password pairs. Passwords are decrypted before being displayed.
3. **Quit**: Exit the password manager.

### Files Used

- `data/passwords.txt`: Stores encrypted passwords.
- `data/key.bin`: Stores the encryption key and IV.

## Error Handling

- If the key file (`data/key.bin`) does not exist, it is generated automatically.
- Errors during encryption/decryption or file operations are displayed with relevant messages.

## Limitations

- Passwords are stored in a plaintext-like format after decryption, which may be a security concern if displayed carelessly.
- No support for password update or deletion.

## License

This project is licensed under the MIT License.

## Acknowledgments

- OpenSSL: For providing robust cryptographic functionality.
- Lua: For its simplicity and flexibility.
