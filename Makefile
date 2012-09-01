MCU = atmega328p
PARTNO = $(MCU)
F_CPU = 16000000UL
BACKUP_FILE = backup.hex
SERIAL_PORT = /dev/arduino

CC = avr-gcc -mmcu=$(MCU) -DF_CPU=$(F_CPU) -DTARGET -Wall -Os -c
LD = avr-gcc -mmcu=$(MCU)
OBJCOPY = avr-objcopy
FLASH = avrdude -F -V -c arduino -p $(PARTNO) -P $(SERIAL_PORT) -b 115200

OBJFILES = $(patsubst %.c,%.o,$(wildcard src/*.c))

.PHONY: all flash backup clean

all: flash

%.o: %.c
	$(CC) -o $@ $<

%.hex: %.bin
	$(OBJCOPY) -O ihex -R .eeprom $< $@

program.bin: $(OBJFILES)
	$(LD) $^ -o $@

serial_port:
	@/usr/bin/test $(SERIAL_PORT) ||\
		(echo "Error: SERIAL_PORT is not defined" && false)

flash: serial_port program.hex
	$(FLASH) -U flash:w:program.hex

backup:
	$(FLASH) -U flash:r:$(BACKUP_FILE):i

clean:
	@echo "Cleaning up"
	-rm -f program.hex program.bin src/*.o
