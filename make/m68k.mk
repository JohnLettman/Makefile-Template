
M68K_CPU ?= 5213

# Some useful flags for microcontroller development
M68K_BOTHFLAGS ?= -fshort-enums -funsigned-char -funsigned-bitfields -mcpu=$(M68K_CPU) \
  -DMOD$(M68K_CPU) -DMCF$(M68K_CPU) -Os
M68K_CFLAGS ?= -std=gnu99
M68K_CXXFLAGS ?= -fno-exceptions -std=gnu++11

# New targets.
M68KPROJ ?= $(PROJ:%=%.elf)
M68K_EXT_LISTING ?= $(M68KPROJ:%.elf=%.lss)
M68K_HEX ?= $(M68KPROJ:%.elf=%.hex)

# Compiler setup
M68K_PREFIX = m68k-elf
M68K_CC = $(M68K_PREFIX)-gcc
M68K_CXX = $(M68K_PREFIX)-g++
M68K_AR = $(M68K_PREFIX)-ar

.PHONY: m68k-lss m68k-hex m68k-ihex m68k-sizedummy m68k-subs m68k-all flash

$(M68K_EXT_LISTING): $(M68KPROJ)
	@echo OBJDUMP $(notdir $<)
	$(M68K_PREFIX)-objdump -h -S $(M68KPROJ) > $(M68K_EXT_LISTING)

$(M68K_HEX): $(M68KPROJ)
	@echo OBJCOPY $(notdir $<)
	$(M68K_PREFIX)-objcopy -R .eeprom -O ihex $(M68KPROJ) $(M68K_HEX)

m68k-sizedummy: $(M68KPROJ)
	@echo M68K-SIZE $(notdir $<)
	$(M68K_PREFIX)-size --mcpu=$(M68K_CPU) $(M68KPROJ)

m68k-all: $(M68KPROJ) m68k-subs
m68k-subs: m68k-lss m68k-hex m68k-sizedummy
m68k-lss: $(M68K_EXT_LISTING)
m68k-hex: $(M68K_HEX)
m68k-ihex: $(M68K_HEX)

# The default here is to use the AVRISP mkII.  Be sure to change the
# settings for other programmers.
flash: $(M68K_HEX)
	@echo NOT IMPLEMENTED YET

LDOPTFLAGS ?= -Wl,--gc-sections -O0 -Wl,-Map=$(PROJ).map,--cref

USERFLAGS += $(M68K_BOTHFLAGS)
USERCFLAGS += $(M68K_CFLAGS)
USERCXXFLAGS += $(M68K_CXXFLAGS)

CC = $(M68K_CC)
CXX = $(M68K_CXX)
AR = $(M68K_AR)
