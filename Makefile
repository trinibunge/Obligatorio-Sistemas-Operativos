CC = gcc
CFLAGS = -Wall -Wextra -std=c99

.PHONY: all clean install

all: backup_log

backup_log: backup_log.c
	$(CC) $(CFLAGS) backup_log.c -o backup_log

install: backup_log
	chmod +x myBackup.sh
	# Copiar backup_log a un directorio en PATH para que el script lo encuentre
	sudo cp backup_log /usr/local/bin/backup_log
	sudo chmod +x /usr/local/bin/backup_log
	@echo "backup_log instalado en /usr/local/bin"
	@echo "Copiá .myBackup.conf a tu HOME: cp .myBackup.conf ~/.myBackup.conf"

clean:
	rm -f backup_log
