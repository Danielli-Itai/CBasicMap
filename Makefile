#-----------------------------------------------#
#         Makefile for template                 #
# for host native & cross compilation           #
#-----------------------------------------------#
include sources.mk

#GCC apps
# size	- Sections size for object & executable files
# nm	- Symbols list for object files
# objcopy	- Copy and translate object files (hex to elf)
# objdump	- Display information from object files.
# readelf	- Display infromation from elf files.
# gdb	- GNU Debugger.

# CC	- Compiler
# CPP	- Preprocessor.
# AS	- Assembler.
# LD	- Linker.
# CFLAGS -	C program flags.
# CPPFLAGS	- C preprosessor flags.
# ASFLAGS	- Assembler flags.
# LDFLAGS	- Linker flags.
# LDLIBS	- Extra flags for libraries.
CWD:=$(shell pwd)
OS:=$(shell uname)
ARC:=$(shell arch)

# as - assembler.
# ld - linker.
# gcc - compiler.
#Target name executable.
TARGET = ./c1m2.out
MAP_FILE = map.map





MACROS = $(PLATFORM)
INC_MACROS = $(foreach d, $(MACROS), -D$d)

#include directories.
#INCLUDES = $(shell find "./inc"	-type "d")
INC_PARAMS = $(foreach d, $(INCLUDES), -I$d)

#Create objets list from all .cpp files in current directory.
#SC1 = $(shell find "./src"	-name "*.c")
#SOURCES = $(SC1)

# obj files.
OBJ_FILES = $(SOURCES:%.c=%.o)
CPP_FILES = $(SOURCES:%.c=%.i)
ASM_FILES = $(CPP_FILES:%.i=%.asm)





# Compilation only ignore warnings (ignore/-w, show all/-Wall).
# -c compile and assemble file, donot link.
# -o compile and assemble and link.
# -g generate debugging.
# -Wall enable all warning.
# -Werror treat all warnings as errors.
# -v Verbose output from GCC.
# -E Generate preprocessed file <*.i>
# -S Generate assembly files <*.s>
ifeq ($(PLATFORM), MSP432)
	CC = arm-none-eabi-gcc
	PLATFORM_FLAGS = -mcpu=cortex-m4 -mthumb -march=armv7e-m -mfloat-abi=hard -mfpu=fpv4-sp-d16 --specs=nosys.specs
else
	AS = as
	CC = gcc
endif
CFLAGS = -c -g -std=c99 -Wall -Werror -O0





#linker
# -map <name> 	Outputs a memory map file <name>.
# -T <name>	Specifies linker script <name>
# -0 <name>	Specifies output file <name>.
# -O<#>	Optimization level<0...3>
# -Os		Optimize for memory size.
# -z stacksize=<size>	Amount of spaceto reserve for the stack.
# -shared	Link as shared library.
# -l<name>	Library <name> for linking
# -L<dir>	Library Include path <dir>.
# -Wl,<option>		Pass option from compiler to linker.
# -Xlinker,<option>	Pass option from compiler to linker.
ifeq ($(PLATFORM), MSP432)
	LINK_LIBS = 
	LINKER_FILE = msp432p401r.lds
	LNK_PARAMS = -T$(LINKER_FILE) -Map=$(MAP_FILE)
	LDFLAGS = $(foreach d, $(LNK_PARAMS), -Wl,$d)
else
endif










#-----------------------------------------------#
#	 		Makefile Make Executable			#
#-----------------------------------------------#
# $@ - Target
# $^ - All preuisits.
# $< - First prequisit.
# %.o:%.c - Patternmatch target object with source files.
# use phoney to set my own target file name.
.PHONY: all
.SUFFIXES: .c


# Build rules begin.
all: $(SOURCES) $(TARGET)
compile: $(CPP_FILES) $(ASM_FILES)
	
#Main target executable: requires object files for generating output.
$(TARGET): $(CPP_FILES) $(ASM_FILES) $(OBJ_FILES)
	@echo 'Link executable'
	$(CC) $(LDFLAGS) $(LINK_LIBS)  $(PLATFORM_FLAGS) $(OBJ_FILES) -o $@ 


#Compilation rule for generating preprocessor files.
%.i: %.c
	@echo 'Source preprocessor files'
	$(CC) $(CFLAGS) $(INC_MACROS) $(INC_PARAMS) $(PLATFORM_FLAGS) -E $< -o $@

##Compilation rule for generating assembly files.
%.asm: %.i
	@echo 'Source assembly files'
	$(CC) $(CFLAGS) $(INC_MACROS) $(INC_PARAMS) $(PLATFORM_FLAGS) -S $< -o $@


#Compilation rule for each source to object.
%.o: %.c
	@echo 'Source compile'
	$(CC) $(CFLAGS) $(INC_MACROS) $(INC_PARAMS) $(PLATFORM_FLAGS) $< -o $@

 
#Cleanup object files target and Make file backup.
clean:
	@echo 'Cleanning'
	rm -f $(CPP_FILES) $(ASM_FILES) $(OBJ_FILES) $(TARGET) $(MAP_FILE) Makefile.bak





#-----------------------------------------------#
#	 		Print Make Parameters				#
#-----------------------------------------------#
print:
	@echo "PLATFORM=$(PLATFORM)\n"
	@echo "SOURCES=$(SOURCES)\n"
	@echo "OBJ_FILES=$(OBJECTS)\n"
	@echo "INC_PARAMS=$(INC_PARAMS)\n"





