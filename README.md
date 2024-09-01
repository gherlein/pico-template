A template project for quick-starting C-based RP2040 Raspberry Pi Pico projects in Visual Studio Code, using the picoprobe programmer.

## Why Use a PicoProbe?

### No-Touch Flashing the Pico

You can manually flash the Pico (see below). The PicoProbe can let you debug using OpenOCD and GDB, but that's outside the scope of this repo/README. The biggest advantage of using the PicoProbe (or another Pico set up to be a PicoProve) is DEVELPMENT SPEED. You can work at the command line and flash your Pico. No fumbling for the 'bootsel' button and plugging and unplugging your Pico. This can be a big deal since microUSB plugs do wear out!

### Holding a Serial Connection

If you use the USB for both power and serial connection then you will need to reconnect after every reset. When you connect to the UART0 pins (GP0, GP1, GND) using the serial on the PicoProbe then your connection stays open through resets.

### Restarting the Pico Without a Power Cycle

It's often useful to restart your program. For example, if you are debugging a chip initialization sequence over SPI. You don't need to flash the program just to get a restart. The included script "reset" uses openocd to send a command to the Pico to restart. Saves time and flash cycles!

## Prerequisites

This assumes that

1. You have already installed OpenOCD with picoprobe, according to the steps in [Getting Started](https://datasheets.raspberrypi.org/pico/getting-started-with-pico.pdf), Appendix A
2. Your VSCode has already been configured according to the steps in [Getting Started](https://datasheets.raspberrypi.org/pico/getting-started-with-pico.pdf), Chapter 7
3. You have installed the picoprobe uf2 to one Pico, and it is connected to the other Pico with the correct wiring (refer again to Appendix A).
4. OR, you bought a [PicoProbe](https://www.raspberrypi.com/products/debug-probe/) - [Amozon Link](https://www.amazon.com/GeeekPi-Raspberry-Connetor-RP2040-Microcontroller/dp/B0C5XNQ7FD)
5. You have added yourself to the plugdev group so that you don't need root privledges to use the PicoProbe.

## Pico SDK installation and references

The easiest is if you are using Ubuntu or Debian Linux (which includes the RPi - Raspberry Pi recommends just using a Pi as your dev box). Follow these instructions to use a great script to do 99% of the work for you:

[Installation Insructuons](https://learn.arm.com/learning-paths/microcontrollers/rpi_pico/sdk/)

Take special note to get your ENV variables set. If you don't set them in your .bashrc you can just "source" them in your working terminal. The "envrc" file in this repo has the variables to be set, defaulting to the locations the setup script uses. The current example envrc file:

```bash
export PICO_SDK_PATH=$HOME/src/pico/pico-sdk
export PICO_BOARD=pico
export PICO_PLAYGROUND_PATH=$HOME/src/pico/pico-playground
export PICO_EXAMPLES_PATH=$HOME/src/pico/pico-examples
export PICO_EXTRAS_PATH=$HOME/src/pico/pico-extras
```

### Direnv

You really should consider using [direnv](https://direnv.net/) to handle environment variable management. You can take a file like the "envrc" file and make it a dotfile in your working folder and direnv with AUTOMATICALLY source it for you when you enter that directory. So if you need different variables for different repos, it's EASY. Especially for PICO_BOARD.

### Plugdev Group

Add a file like /etc/udev/rules.d/ (perhaps called 99-picotool.rules) with contents like this:

```
SUBSYSTEM=="usb", \
    ATTRS{idVendor}=="2e8a", \
    ATTRS{idProduct}=="000c", \
    TAG+="uaccess" \
    MODE="666", \
    GROUP="plugdev"
```

NOTE: you may need to verify the values. Do a "tail -f /var/log/syslog" (or equivalent for your linux flavor) and note the idVendor and idProduct codes for YOUR PicoProbe and make the file match.

You can reload the rules with "sudo udevadm trigger" - no reboot required. After that it's going to be automatically loaded at boot. You should no longer need sudo to run any PicoProbe commands.

## Usage of this Template

1. Make a project directory in your pico-sdk parent directory (usually `~/pico/projects`, with sdk at `~/pico/pico-sdk`), e.g. make `~/pico/projects`.
2. Press [Use this template], or, download this template as a zip.
3. Clone your repository/Unzip the downloaded folder to your new project directory.
4. Write whatever you want in main.c, add more files, go wild...
5. Create a "build" directory (mkdir build) - or just type 'make prep'
6. Edit the Cmake file to include dependencies and such (see below)
7. Build! (make or make -JX where X is the number of cores you have)

## Changing the CMake file for your own use

The templace CMakeLists.txt file is extremely basic and looks like this:

```bash
make_minimum_required(VERSION 3.13)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

include(pico_sdk_import.cmake)

project(main C CXX ASM)
set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 17)

pico_sdk_init()

add_executable(main
    main.c
)

pico_enable_stdio_usb(main 1)
pico_enable_stdio_uart(main 1)

target_include_directories(main PRIVATE
        ${CMAKE_CURRENT_LIST_DIR}
)

pico_add_extra_outputs(main)

target_link_libraries(main
 pico_stdlib
 # other libs as needed
)

add_custom_target(flash
    COMMAND /bin/bash ../flash
    DEPENDS main
)
```

If you use any of the hardware other than serial you are going to have to configure the libraries into CMakeLists.txt. Add the needed library to this line:

```
target_link_libraries(main
        pico_stdlib
        # other libs as needed
)
```

CMake will include headers as well.

This README cannot substitute for learning more about CMake.

## Optional Raspberry Pi Tool to Created CMake Project Config

To go beyond the basics outlined here, a great tool to help you build configurations is the [Pico Project Generator](https://github.com/raspberrypi/pico-project-generator). You should at least be aware of it, even if you are manually handling your cmake configuration.

### Print Output over serial

Edit the CMakeLists.txt file to include serial or not. Set a 1 for incuded, 0 for disabled, in these two lines:

'''
pico_enable_stdio_usb(main 0)
pico_enable_stdio_uart(main 1)
'''

USB is over the power/usb port, and uart is for the uart1 on physical pins 1 and 2.

This template assumes you are using the picoprobe, and you have the picoprobes serial pins attached to pins 1-2-3. You can then use the uart and choose to either not use the usb port at all or only use it for power.

## Building

To build:

```
make build
```

This will delete everything in the build folder, redo the CMake step and build the binary. It is set up to always build "main" and later flash that binary. The name of the binary will be "main.\_\_\_" with the file extension identifying the type. The two you care about most are:

- build/main.elf - the file that gets installed by the 'make flash' tool (see below)
- build/main.uf2 - the file you can manually copy to the Pico using the 'bootsel' method (see below)

## Flashing the Pico using the PicoProbe

The makefile supports direct flashing of the pico (make flash) - see the script "flash" to see what it does

```
make flash
```

## Flashing the Pico manually

You can also install the binary on the pico using it's native bootloader:

1. Unplug the USB from the Pico
2. Press and hold the "bootsel" button on the Pico
3. Plug in the USB
4. Wait for a beep. Optionally verify the Pico was mounted by using the command line "df" tool
5. Copy the build/main.uf2 file to the mounted Pico - on Ubuntu it's mounted at /media/$USER/RPI-RP2
6. Once copied the Pico will reboot and run your program

## Resetting the Pico using the PicoProbe

The makefile supports direct reset of the pico (make reset) - see the script "reset" to see what it does.  This script will reset BOTH cores, so be sure that's what you want.

```
make reset
```

## Seeing the Serial Output

The default cmake configuration (see above) will output serial from the Pico over UART via the PicoProbe. I generally use the UART. This makes it easy to just keep a serial connection open in a window at all times.

You can use any serial program you like, but "screen" is super easy:

```bash
screen /dev/ttyACM0 115200
```

The PicoProbe will use /dev/ttyACM0 for the flashing over Serial Wire Debug (SWD) but ACM1 should be your USB or UART. NOTE: I've seen these get backwards, so pay attention. OpenOCD just figures out what port to use, but if you get nothing on serial you may have the wrong port specified.

This is another reason to just use the PicoProbe for serial. One less thing to think about!

### Common Cause of No Serial Output

If you didn't use the setup script and manually installed the SDK you MUST follow the instructions exactly. If you miss the " git submodule update --init" step then it won't include the TinyUSB library and you will NEVER get any output over serial. It just fails silently.

### Flashing By PicoProbe Fails and the Pico Won't Boot!

I've seen a bunch of cases where my code has resulted in an image on the Pico that turns it into a completely unresonsive paperweight. Can't flash it using the PicoProbe, no serial, etc.

DON'T WORRY!

Go back and make one of the exampes - perhap "blinky" - but any known good working example. Use the manual flashing method described above to install that image on the Pico. Reboot. You have now recovered the Pico.

I'm planning on really understanding how the bootloader part works, but for now, this recovery method will save you WHEN you bork your Pico with bad code. :)

## References

## Official Documentation

- [Getting Started with the Raspberry Pi Pico](https://datasheets.raspberrypi.com/pico/getting-started-with-pico.pdf)
- [Raspberry Pi Pico C/C++ SDK](https://datasheets.raspberrypi.com/pico/raspberry-pi-pico-c-sdk.pdf)

## Official Examples

The [official example repo](https://github.com/raspberrypi/pico-examples) is useful to look at, and to run the examples if you want to make sure you are set up. However, they are really crap if you want to use them as a template to work from. This is because none of the examples can be used standalone. To build them you must build the whole tree, since they use parent directory CMakeLists.txt files. This flaw is a major reason I wrote this template!

## Pico Books I Recommend

These two books are really best in print since the author does not publish them to Amazon in ePub. So there's no indexing or jumping using the ToC.

- [Programming The Raspberry Pi Pico/W In C, Second Edition](https://www.amazon.com/dp/187196279X?psc=1&ref=ppx_yo2ov_dt_b_product_details)
- [Master the Raspberry Pi Pico in C: WiFi with lwIP & mbedtls](https://www.amazon.com/dp/1871962072?psc=1&ref=ppx_yo2ov_dt_b_product_details)

These are both really useful as a starting point and really pretty critical if you want to try to figure out how WiFi works on the Pico W.

## Other Great Books on Embedded Systems

- [Making Embedded Systems: Design Patterns for Great Software](https://www.amazon.com/dp/1098151542?psc=1&ref=ppx_yo2ov_dt_b_product_details) - Elicia White is amazing. MUST read.
- [Applied Embedded Electronics: Design Essentials for Robust Systems](https://www.amazon.com/dp/1098144791?psc=1&ref=ppx_yo2ov_dt_b_product_details) - lessons for the REAL WORLD

## Excellent Public Lectures on the Pico

V. Hunter Adams of Cornell has put his entire course online:

- [Raspberry Pi Pico Lectures](https://www.youtube.com/playlist?list=PLDqMkB5cbBA5oDg8VXM110GKc-CmvUqEZ)
- [GitHub repo for the class examples](https://github.com/vha3/Hunter-Adams-RP2040-Demos)
- [Course Outline and Links](https://ece4760.github.io/)

NOTE: these all assume you have the rig they have in their lab, and that you use the examples right out of their repo. They use an internally hacked/derived version of a threading library that makes it harder to just lift code examples out, but all of this material is amazing as a learning resource. And damn, I wish all teachers were like Hunter Adams! He's astounding. Should win professor of the year!

By the way, the threading library they use is not on GitHub, so I put it there in hope of adding it to my toolbox and making it useful. [Protothreads](https://github.com/gherlein/protothreads) is here, with full credit to it's actual author Adam Dunkels. The email address in his code now bounces so if you have a better one please contact me!

## Credits

I derived this repo from the excellent work done ealier [here](https://github.com/kiwih/rp2040-vscode-picoprobe-project-c-template)
