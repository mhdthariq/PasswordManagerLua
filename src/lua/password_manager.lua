-- Ensure Lua can find the C and Lua modules
package.cpath = "./build/?.so;" .. package.cpath
package.path = "./src/lua/?.lua;" .. package.path

local openssl = require("openssl_wrapper")
local utils = require("utils")

local keyFile = "data/key.bin"
local passwordFile = "data/passwords.txt"

-- Load or generate encryption key and IV
local key, iv = utils.loadOrGenerateKey(keyFile)

local function savePassword(username, password)
    local encryptedPassword = openssl.encrypt(password, key, iv)

    local file = io.open(passwordFile, "a")
    if not file then
        error("Failed to open password file for writing.")
    end

    file:write(username .. "|" .. encryptedPassword .. "\n")
    file:close()
    print("Password for account '" .. username .. "' saved successfully.")
end

local function loadPasswords()
    local file = io.open(passwordFile, "r")
    if not file then
        print("No passwords stored yet.")
        return {}
    end

    local passwords = {}
    for line in file:lines() do
        local username, encryptedPassword = line:match("([^|]+)|(.+)")
        if username and encryptedPassword then
            local decryptedPassword = openssl.decrypt(encryptedPassword, key, iv)
            table.insert(passwords, { username = username, password = decryptedPassword })
        end
    end
    file:close()

    return passwords
end

local function displayPasswords()
    local passwords = loadPasswords()

    if #passwords == 0 then
        print("No passwords saved yet.")
        return
    end

    print("+-------------------+-------------------+")
    print("| Username          | Password          |")
    print("+-------------------+-------------------+")
    for _, entry in ipairs(passwords) do
        print(string.format("| %-17s | %-17s |", entry.username, entry.password))
    end
    print("+-------------------+-------------------+")
end

local function mainMenu()
    while true do
        print("\nPassword Manager Menu:")
        print("[1] Add password")
        print("[2] View passwords")
        print("[q] Quit")
        io.write("Select an option: ")
        local choice = io.read()

        if choice == "1" then
            io.write("Enter username: ")
            local username = io.read()
            io.write("Enter password: ")
            local password = io.read()

            if username and password and #username > 0 and #password > 0 then
                savePassword(username, password)
            else
                print("Invalid username or password. Try again.")
            end
        elseif choice == "2" then
            displayPasswords()
        elseif choice == "q" then
            print("Exiting Password Manager. Goodbye!")
            break
        else
            print("Invalid choice. Please try again.")
        end
    end
end

-- Start the password manager
mainMenu()
