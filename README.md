# Arduino C scaffold

## Usage

```sh
$ make        # build the project and flash to the Arduino
$ make clean  # remove compiled and intermediate files
$ make backup # dump the flash from the target into backup.hex
```

## Board Resources

* ATMega328P datasheet - http://www.atmel.com/dyn/resources/prod_documents/doc8161.pdf
* Arduino UNO Schematic - http://arduino.cc/en/uploads/Main/arduino-uno-schematic.pdf

## Getting Started

Getting the environment up and running on Ubuntu Linux is quite simple. One
need only install 5 packages. These are all supported in the Ubuntu package
manager. Open a terminal and run the following command:

```sh
$ sudo apt-get install make binutils-avr avr-libc avrdude gcc-avr
```

## Building and Running

The scaffold can be built, linked, and flashed by running the following
command:

    rake SERIAL_PORT=[serial port name]

The name of the serial port used by the Arduino UNO needs to be defined as an
environment variable or passed on the make command line. See below for how to
determine the value to use.

The following is an example of the output one can expect to see when running
make.

    $ make SERIAL_PORT=/dev/ttyACM0
    avr-gcc -DTARGET -DF_CPU=16000000UL -mmcu=atmega328p -Iinclude/ -Wall -Os -c -o build/src/main.o src/main.c
    avr-gcc -mmcu=atmega328p build/src/main.o -o program.bin
    avr-objcopy -O ihex -R .eeprom program.bin program.hex
    avrdude -F -V -c arduino -p atmega328p -P /dev/ttyACM0 -b 115200 -U flash:w:program.hex

    avrdude: AVR device initialized and ready to accept instructions

    Reading | ################################################## | 100% 0.00s

    avrdude: Device signature = 0x1e950f
    avrdude: NOTE: FLASH memory has been specified, an erase cycle will be performed
             To disable this feature, specify the -D option.
    avrdude: erasing chip
    avrdude: reading input file "program.hex"
    avrdude: input file program.hex auto detected as Intel Hex
    avrdude: writing flash (306 bytes):

    Writing | ################################################## | 100% 0.06s

    avrdude: 306 bytes of flash written

    avrdude: safemode: Fuses OK

    avrdude done.  Thank you.

If the file at `src/main.c` hasn't been altered, you should notice that
the yellow surface-mount LED on the Arduino UNO has begun to blink. It should
be cycling on and off with durations of about 1 second.

## Identifying the serial port

The easiest way to find the serial port is to type

```sh
$ ls /dev/serial/by-id/*Arduino*
```

You can set up the `SERIAL_PORT` environment variable in most shells by typing

```sh
$ export SERIAL_PORT=`ls /dev/serial/by-id/*Arduino*`
```

The serial port must also be accessible to the user. If your user is already a
member of the `dialout` group, you can stop there. Otherwise, just change the
group of the serial port for now:

```sh
$ sudo chown :sudo /dev/serial/by-id/*Arduino*
```

You can add yourself to the `dialout` group for next time, but it won't take
effect until you've logged out and in again:

```sh
$ sudo usermod -aG dialout `whoami`
```
