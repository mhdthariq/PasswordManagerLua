local utils = {}

local function generateRandomBytes(size)
    local random = io.open("/dev/urandom", "rb")
    if not random then
        error("Failed to open /dev/urandom for random byte generation.")
    end

    local bytes = random:read(size)
    random:close()

    if not bytes or #bytes ~= size then
        error("Failed to generate random bytes of required size.")
    end

    return bytes
end

function utils.loadOrGenerateKey(keyFile)
    local file = io.open(keyFile, "rb")
    if file then
        local key = file:read(32)
        local iv = file:read(16)
        file:close()

        if not key or not iv then
            error("Failed to read key or IV from the key file.")
        end

        return key, iv
    else
        print("Key file not found. Generating a new key and IV...")
        local key = generateRandomBytes(32)
        local iv = generateRandomBytes(16)

        local success, err = pcall(function()
            file = io.open(keyFile, "wb")
            if not file then
                error("Failed to create key file for saving key and IV.")
            end
            file:write(key)
            file:write(iv)
            file:close()
        end)

        if not success then
            error("Failed to save key and IV: " .. tostring(err))
        end

        print("Key and IV generated and saved successfully.")
        return key, iv
    end
end

return utils
