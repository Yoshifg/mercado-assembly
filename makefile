CC = gcc
CFLAGS = -m32 -no-pie
TARGET = supermercado
SRC = supermercado.s
DATA = produtos.bin

all: $(TARGET)
$(TARGET): $(SRC)
	$(CC) $(CFLAGS) -o $(TARGET) $(SRC)
	
run: $(TARGET)
	./$(TARGET)

clean:
	rm -f $(TARGET) $(DATA)