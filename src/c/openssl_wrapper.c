#include <openssl/evp.h>
#include <openssl/rand.h>
#include <openssl/err.h>
#include <lua.h>
#include <lauxlib.h>
#include <string.h>
#include <stdlib.h>
#include <stdio.h>

#define KEY_SIZE 32
#define IV_SIZE 16

// Error handling for OpenSSL functions
static void handleErrors() {
    unsigned long errCode;

    while ((errCode = ERR_get_error())) {
        char *err = ERR_error_string(errCode, NULL);
        fprintf(stderr, "OpenSSL error: %s\n", err);
    }
    abort();
}

// Encrypt function
static int encrypt(lua_State *L) {
    const char *plainText = luaL_checkstring(L, 1);
    const char *key = luaL_checkstring(L, 2);
    const char *iv = luaL_checkstring(L, 3);

    EVP_CIPHER_CTX *ctx = EVP_CIPHER_CTX_new();
    if (!ctx) handleErrors();

    if (EVP_EncryptInit_ex(ctx, EVP_aes_256_cbc(), NULL, (unsigned char *)key, (unsigned char *)iv) != 1)
        handleErrors();

    int plainTextLen = strlen(plainText);
    int cipherTextLen;
    unsigned char cipherText[plainTextLen + EVP_CIPHER_block_size(EVP_aes_256_cbc())];

    if (EVP_EncryptUpdate(ctx, cipherText, &cipherTextLen, (unsigned char *)plainText, plainTextLen) != 1)
        handleErrors();

    int len;
    if (EVP_EncryptFinal_ex(ctx, cipherText + cipherTextLen, &len) != 1)
        handleErrors();

    cipherTextLen += len;
    EVP_CIPHER_CTX_free(ctx);

    // Convert cipherText to hex string
    char hexCipherText[cipherTextLen * 2 + 1];
    for (int i = 0; i < cipherTextLen; i++) {
        sprintf(&hexCipherText[i * 2], "%02x", cipherText[i]);
    }

    lua_pushstring(L, hexCipherText);
    return 1;
}

// Decrypt function
static int decrypt(lua_State *L) {
    const char *hexCipherText = luaL_checkstring(L, 1);
    const char *key = luaL_checkstring(L, 2);
    const char *iv = luaL_checkstring(L, 3);

    int cipherTextLen = strlen(hexCipherText) / 2;
    unsigned char cipherText[cipherTextLen];

    // Convert hex string to binary
    for (int i = 0; i < cipherTextLen; i++) {
        sscanf(&hexCipherText[i * 2], "%02hhx", &cipherText[i]);
    }

    EVP_CIPHER_CTX *ctx = EVP_CIPHER_CTX_new();
    if (!ctx) handleErrors();

    if (EVP_DecryptInit_ex(ctx, EVP_aes_256_cbc(), NULL, (unsigned char *)key, (unsigned char *)iv) != 1)
        handleErrors();

    int plainTextLen;
    unsigned char plainText[cipherTextLen];

    if (EVP_DecryptUpdate(ctx, plainText, &plainTextLen, cipherText, cipherTextLen) != 1)
        handleErrors();

    int len;
    if (EVP_DecryptFinal_ex(ctx, plainText + plainTextLen, &len) != 1)
        handleErrors();

    plainTextLen += len;
    EVP_CIPHER_CTX_free(ctx);

    plainText[plainTextLen] = '\0';
    lua_pushstring(L, (char *)plainText);
    return 1;
}

// Register functions to Lua
int luaopen_openssl_wrapper(lua_State *L) {
    static const luaL_Reg openssl_funcs[] = {
        {"encrypt", encrypt},
        {"decrypt", decrypt},
        {NULL, NULL} // Sentinel to indicate the end of the array
    };

    luaL_newlib(L, openssl_funcs);
    return 1;
}
