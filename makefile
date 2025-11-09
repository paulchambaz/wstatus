CC = gcc
CFLAGS = -Wall -Wextra -Iinclude
PREFIX = /usr/local
MANPREFIX = $(PREFIX)/share/man

TARGET = wstatus
SRC = $(wildcard src/*.c)
OBJ = $(SRC:.c=.o)

$(TARGET): $(OBJ)
	$(CC) $(OBJ) -o $(TARGET)

src/%.o: src/%.c
	$(CC) $(CFLAGS) -c $< -o $@

install: $(TARGET)
	mkdir -p $(DESTDIR)$(PREFIX)/bin
	mkdir -p $(DESTDIR)$(MANPREFIX)/man1
	cp -f $(TARGET) $(DESTDIR)$(PREFIX)/bin
	chmod 755 $(DESTDIR)$(PREFIX)/bin/$(TARGET)
	scdoc < wstatus.1.scd | sed "s/1980-01-01/$(date '+%B %Y')/" > $(DESTDIR)$(MANPREFIX)/man1/wstatus.1
	chmod 644 $(DESTDIR)$(MANPREFIX)/man1/wstatus.1

uninstall:
	rm -f $(DESTDIR)$(PREFIX)/bin/$(TARGET)
	rm -f $(DESTDIR)$(MANPREFIX)/man1/wstatus.1

clean:
	rm -f src/*.o $(TARGET)

.PHONY: clean install uninstall
