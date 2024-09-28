cmake_minimum_required(VERSION 3.13)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

include(pico_sdk_import.cmake)

project(main C CXX ASM)
set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 17)
file(GLOB_RECURSE SOURCES RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} "src/*.c")
file(GLOB_RECURSE PICOLIB2 RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} "pico-lib2/*.c")


pico_sdk_init()

add_executable(main    
    ${SOURCES}
    ${PICOLIB2}
)

pico_enable_stdio_usb(main 0)
pico_enable_stdio_uart(main 1)

target_include_directories(main PRIVATE
        ${CMAKE_CURRENT_LIST_DIR}
        pico-lib2/sys/include
        # add other folders as needed
)

add_subdirectory(pico-lib2)

pico_add_extra_outputs(main)

# if NOT using a PICO_W board comment the following line
add_compile_definitions(RP_PICO_W_BOARD)

target_link_libraries(main
	pico_stdlib
    pico_cyw43_arch_none # if NOT using a PICO_W board comment this line
    pico_multicore
    hardware_irq
    hardware_i2c
    hardware_spi
    hardware_pwm
    hardware_adc
    hardware_pio
    hardware_dma
    hardware_divider
    hardware_flash
    hardware_sync
    hardware_timer
    hardware_clocks
    hardware_watchdog
    hardware_vreg
    hardware_rtc
    hardware_uart
    
	# other libs as needed
)

add_custom_target(flash
    COMMAND /bin/bash ../flash main.elf
    DEPENDS main
)
add_custom_target(reset
    COMMAND /bin/bash ../reset
    DEPENDS main
)
add_custom_target(strip
    COMMAND arm-none-eabi-strip main.elf
    DEPENDS main
)
