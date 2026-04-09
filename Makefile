BINARY     = adacrash
SRC_DIR    = src
OBJ_DIR    = obj
BIN_DIR    = bin
MAIN       = $(SRC_DIR)/adacrash.adb
GPR_FILE   = adacrash.gpr

ADAFLAGS   = -gnat2012 -O2 -gnatn -Wall
LDFLAGS    = -lSDL2

# Use gprbuild by default; override with: make USE_GNATMAKE=1
ifdef USE_GNATMAKE
BUILD_CMD  = gnatmake $(ADAFLAGS) -D $(OBJ_DIR) $(MAIN) -o $(BIN_DIR)/$(BINARY) -largs $(LDFLAGS)
else
BUILD_CMD  = gprbuild -P $(GPR_FILE)
endif

.PHONY: all clean run

all: $(BIN_DIR) $(OBJ_DIR)
	$(BUILD_CMD)

$(BIN_DIR):
	mkdir -p $(BIN_DIR)

$(OBJ_DIR):
	mkdir -p $(OBJ_DIR)

run: all
	./$(BIN_DIR)/$(BINARY)

clean:
	gprclean -P $(GPR_FILE)
	rm -f $(BIN_DIR)/$(BINARY)
