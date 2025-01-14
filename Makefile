CC = gcc
CFLAGS = -shared -fPIC -I/usr/include/lua5.1 -Wall -Wextra
LDFLAGS = -L/usr/lib -lcrypto -lssl
TARGET = ../PasswordManager/build/openssl_wrapper.so
SRC = src/c/openssl_wrapper.c

all: $(TARGET)

$(TARGET): $(SRC)
	$(CC) $(CFLAGS) $(SRC) -o $(TARGET) $(LDFLAGS)

clean:
	rm -f $(TARGET)

.PHONY: all clean
