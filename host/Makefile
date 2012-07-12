TARGET = epp
OBJ = epp.o

#change this path to the location of your adept 2 installation
ADEPT2LIBDIR = /opt/digilent/adept/lib64/digilent/adept

CFLAGS = -std=gnu99 -Wall
CXXFLAGS = -Wall
LDFLAGS = -L$(ADEPT2LIBDIR) -ldepp -ldmgr

all: $(TARGET)

$(TARGET): $(OBJ)
	$(CC) $(CFLAGS) -o $@ $(OBJ) $(LDFLAGS)

clean:
	rm -f *.o
	rm -f $(TARGET)
