MCU = atmega328p
PARTNO = $(MCU)
F_CPU = 16000000UL
PROGRAM_FILE = program.hex
BACKUP_FILE = backup.hex

CC = avr-gcc -DTARGET -DF_CPU=$(F_CPU) -mmcu=$(MCU) -Iinclude/ -Wall -Os -c
LD = avr-gcc -mmcu=$(MCU)
OBJCOPY = avr-objcopy
PROGRAM = avrdude -F -V -c arduino -p $(PARTNO) -P $(SERIAL_PORT) -b 115200

OBJFILES = $(patsubst %.c,build/%.o,$(wildcard src/*.c))

.PHONY: default program clean

default: program

build/src:
	mkdir -p build/src

build/%.o: %.c build/src
	$(CC) -o $@ $<

%.hex: %.bin
	$(OBJCOPY) -O ihex -R .eeprom $< $@

%.bin: $(OBJFILES)
	$(LD) $^ -o $@

serial_port:
	@/usr/bin/test $(SERIAL_PORT) ||\
		(echo "Error: SERIAL_PORT is not defined" && false)

program: serial_port $(PROGRAM_FILE)
	$(PROGRAM) -U flash:w:$(PROGRAM_FILE)

backup:
	$(PROGRAM) -U flash:r:$(BACKUP_FILE):i

clean:
	rm -f program.hex program.bin build/src/*.o 
