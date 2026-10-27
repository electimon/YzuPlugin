PLUGIN_NAME = 99_yzu

all:
	objfw-compile -I/usr/local/include/mayushii --arc --lib 1.0 plugin.m -o $(PLUGIN_NAME)