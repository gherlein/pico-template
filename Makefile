.PHONY: build flash

ELF = build/main.elf

dummy:
	@echo "Please specify a target to build"

build: 
	@echo "Building the project"
	cd build;cmake ..;make -j8

prep:
	cp ${PICO_SDK_PATH}/external/pico_sdk_import.cmake .
	mkdir build;cd build;rm -rf *;cmake ..
	cat ${PICO_SDK_PATH}/pico_sdk_version.cmake | grep "set(" | grep -v "{" | grep -v "ID"


flash: build ${ELF}
	@echo "Flashing the project"
	@echo "Please make sure the board is connected to the picoprobe"
	./flash ${ELF}

clean:
	-@rm -rf build
	-@rm *~ || true

allow:
	# alternate:  source envrc	

git:
	-@git add *
	-@git commit -am"updated"
	-@git push origin main

debug:
	cd build;gdb-multiarch main.elf -x ../gdb-connect-ocd
#       target extended-remote :3333

openocd:
	openocd -f interface/cmsis-dap.cfg -c "set USE_CORE 0" -f target/rp2040.cfg -c "adapter speed 5000" 
