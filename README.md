# myBackup - Sistema de Respaldo Automático

## **Proyecto Obligatorio - Sistemas Operativos**

[![Maximiliano López](https://img.shields.io/badge/GitHub-Maximiliano_López-B7E3FF?logo=github&logoColor=black)](https://github.com/maaxilopp) [![Trinidad Bunge](https://img.shields.io/badge/GitHub-Trinidad_Bunge-FFD966?logo=github&logoColor=black)](https://github.com/trinibun)


## Tabla de Contenidos

- [Descripción](#descripción)
- [Características](#características)
- [Requisitos](#requisitos)
- [Instalación](#instalación)
- [Uso](#uso)
- [Configuración](#configuración)
- [Benchmarks (PARTE 2)](#benchmarks-parte-2)


---

##  Descripción

myBackup es un sistema de respaldo automático completo para Linux, diseñado para simplificar y automatizar la creación, gestión y restauración de copias de seguridad. Desarrollado como entrega obligatoria de la asignatura Sistemas Operativos, combina scripting Bash avanzado con utilidades C compiladas.

El sistema permite:
- Crear backups comprimidos o sin comprimir
- Automatizar backups en intervalos personalizables
- Restaurar datos desde backups anteriores
- Verificar integridad con checksums SHA256
- Encriptar backups con OpenSSL (AES-256)
- Excluir patrones de archivos
- Interfaz interactiva con menú
- Logs detallados de todas las operaciones

---

## Características

- **Backup Automático**: Crea respaldos en intervalos configurables (horas/días)
- **Múltiples Formatos**: Soporta tar.gz, tar.bz2, tar sin comprimir
- **Configuración Flexible**: Línea de comandos + archivo de configuración
- **Restauración Completa**: Recupera datos desde cualquier backup
- **Gestión de Retención**: Elimina automáticamente backups antiguos
- **Interfaz Menú**: Modo interactivo para usuarios no avanzados

### Características Avanzadas
- **Checksum Verification**: Verifica integridad de datos, tiene como requisito sha256sum
- **Encriptación AES-256**: Protege datos sensibles con OpenSSL
- **Exclusiones**: Omite archivos/carpetas específicas
- **Logs Detallados**: Registro completo de operaciones
- **Utilidad en C**: Programa auxiliar compilado para operaciones críticas

---

## Requisitos

### Sistema Operativo
- Linux (Ubuntu, Debian, CentOS, etc.)
- Bash 4.0+

### Dependencias
```bash
# Herramientas esenciales
- tar (empaquetado)
- gzip/bzip2 (compresión)
- openssl (encriptación)
- sha256sum (checksums)
- cron (automatización)
- gcc + make (para compilar utilidad C)
```
## Instalación

### Dependencias por sistema:

Ubuntu/Debian:
```bash
sudo apt update
sudo apt install tar gzip bzip2 cron gcc make dialog openssl gnupg
```
CentOS/RHEL:
```bash
sudo yum install tar gzip bzip2 cronie gcc make dialog openssl gnupg
```
Linux:
```bash
sudo pacman -S tar gzip bzip2 cronie gcc make dialog openssl gnupg
```

### Instalación rápida:
```bash
# 1. Clonar o descargar el repositorio
git clone <repository-url> mybackup
cd mybackup

# 2. Compilar el programa auxiliar C
make

# 3. Instalar el sistema (requiere sudo)
sudo make install

# 4. Copiar archivo de configuración al HOME
cp .myBackup.conf ~/.myBackup.conf

# 5. Verificar instalación
which backup_log
myBackup.sh -h
```
### Instalación manual
```bash
# 1. Compilar backup_log.c
gcc -Wall -Wextra -std=c99 backup_log.c -o backup_log

# 2. Copiar el binario compilado a /usr/local/bin
sudo cp backup_log /usr/local/bin/
sudo chmod +x /usr/local/bin/backup_log

# 3. Hacer el script principal ejecutable
chmod +x myBackup.sh

# 4. (Opcional) Copiar a /usr/local/bin para usar desde cualquier lugar
sudo cp myBackup.sh /usr/local/bin/myBackup
sudo chmod +x /usr/local/bin/myBackup

# 5. Copiar configuración por defecto
cp .myBackup.conf ~/.myBackup.conf
```

### Verificación post instalación
```bash
#Confirmar que backup_log está en PATH
$ which backup_log
/usr/local/bin/backup_log

# Confirmar que el script es ejecutable
$ ls -la myBackup.sh
-rwxr-xr-x 1 usuario grupo 12345 Apr 16 2026 myBackup.sh

# Ver la ayuda
$ ./myBackup.sh -h
```




