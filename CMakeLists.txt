cmake_minimum_required(VERSION 3.13)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

include(pico_sdk_import.cmake)

project(main C CXX ASM)
set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 17)
file(GLOB_RECURSE SOURCES RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} "src/*.c")

# if using a PICO_W board uncomment the following line
add_compile_definitions(RP_PICO_W_BOARD)

pico_sdk_init()

add_executable(main    
    ${SOURCES}
)

pico_enable_stdio_usb(main 0)
pico_enable_stdio_uart(main 1)

target_include_directories(main PRIVATE
        ${CMAKE_CURRENT_LIST_DIR}
        src/sys/include
        # add other folders as needed
)



pico_add_extra_outputs(main)

target_link_libraries(main
	pico_stdlib
    pico_cyw43_arch_none # comment out if not using a pico_w
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
