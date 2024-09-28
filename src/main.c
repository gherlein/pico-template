/*
    This code originates from the Getting started with Raspberry Pi Pico document
    https://datasheets.raspberrypi.org/pico/getting-started-with-pico.pdf
    CC BY-ND Raspberry Pi (Trading) Ltd
*/

#include <stdio.h>

#include "hardware/gpio.h"
#include "pico/binary_info.h"
#include "pico/stdlib.h"
#include "sys_fn.h"
#ifdef RP_PICO_W_BOARD
#include "pico/cyw43_arch.h"
#endif

const uint LED_PIN = 25;

int main() {
    bi_decl(bi_program_description("PROJECT DESCRIPTION"));

    sys_init();

    sys_led(1);

    while (1) {
        sys_led(0);
        sleep_ms(250);
        sys_led(1);
        puts("Hello World\n");
        sleep_ms(1000);
    }
}