# Arduino C scaffold

## Usage

```sh
$ make              # build the project and flash to the Arduino
$ make program.hex  # build but don't flash
$ make clean        # remove compiled and intermediate files
$ make backup       # dump the flash from the target into backup.hex
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

    make

The name of the serial port used by the Arduino UNO needs to be defined as an
environment variable or passed on the make command line as `SERIAL_PORT`. See
below for how to determine the value to use.

The following is an example of the output one can expect to see when running
make.

    $ make
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

## Setting up the serial port

By default, the Makefile expects to find the Arduino at `/dev/arduino`. This
can be overridden on the command line:

```sh
$ make SERIAL_PORT=/dev/ttyACM0
```

The easier way, however, is to create a udev rule that will set up
`/dev/arduino` automatically every time you plug in the Arduino.

With the Arduino connected, type

```sh
$ sudo lsusb -v | less
```

Scroll down until you find the Arduino entry:

    Bus 002 Device 035: ID 2341:0043
      Device Descriptor:
        bLength                18
        bDescriptorType         1
        bcdUSB               1.10
        bDeviceClass            2 Communications
        bDeviceSubClass         0
        bDeviceProtocol         0
        bMaxPacketSize0         8
        idVendor           0x2341
        idProduct          0x0043
        bcdDevice            0.01
        iManufacturer           1 Arduino (www.arduino.cc)
        iProduct                2

Make a note of the `idVendor` and `idProduct` values.

Create a file in `/etc/udev/rules.d/90-arduino.rules` containing the same
values (without leading `0x`):

    SUBSYSTEMS=="usb", ATTRS{idVendor}=="2341", ATTRS{idProduct}=="0043", SYMLINK+="arduino arduino_$attr{serial}"

Unplug and replug the Arduino, and it should be visible as `/dev/arduino`.

The serial port must also be accessible to the user. If your user is already a
member of the `dialout` group, you can stop there.

You can add yourself to the `dialout` group for next time, but it won't take
effect until you've logged out and in again:

```sh
$ sudo usermod -aG dialout `whoami`
```

If you can't be bothered to log out and in, you can change the permissions of
the serial port for now:

```sh
$ sudo chown :sudo /dev/arduino
```
