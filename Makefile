MCU = atmega328p
PARTNO = $(MCU)
F_CPU = 16000000UL
BACKUP_FILE = backup.hex
SERIAL_PORT = /dev/arduino
PROGRAMMER = arduino

ifeq ($(PROGRAMMER),arduino)
AVRDUDE_OPTS = -P $(SERIAL_PORT) -b 115200
endif

CC = avr-gcc -mmcu=$(MCU) -DF_CPU=$(F_CPU) -DTARGET -Wall -Os -c
LD = avr-gcc -mmcu=$(MCU)
OBJCOPY = avr-objcopy
FLASH = avrdude -F -V -p $(PARTNO) -c $(PROGRAMMER) $(AVRDUDE_OPTS)

OBJFILES = $(patsubst %.c,%.o,$(wildcard src/*.c))

.PHONY: all flash backup clean

all: flash

%.o: %.c
	$(CC) -o $@ $<

%.hex: %.bin
	$(OBJCOPY) -O ihex -R .eeprom $< $@

program.bin: $(OBJFILES)
	$(LD) $^ -o $@

flash: program.hex
	$(FLASH) -U flash:w:program.hex

backup:
	$(FLASH) -U flash:r:$(BACKUP_FILE):i

clean:
	@echo "Cleaning up"
	-rm -f program.hex program.bin src/*.o
