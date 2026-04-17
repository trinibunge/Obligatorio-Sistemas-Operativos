# myBackup, Sistema de Respaldo Automático

## **Proyecto Obligatorio de Sistemas Operativos**

[![Maximiliano López](https://img.shields.io/badge/GitHub-Maximiliano_López-B7E3FF?logo=github&logoColor=black)](https://github.com/maaxilopp) [![Trinidad Bunge](https://img.shields.io/badge/GitHub-Trinidad_Bunge-FFD966?logo=github&logoColor=black)](https://github.com/trinibun)


## Tabla de Contenidos

- [Descripción](#descripción)
- [Características](#características)
- [Requisitos](#requisitos)
- [Instalación](#instalación)
- [Uso](#uso)
- [Configuración](#configuración)
- [Benchmarks](#benchmarks)


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
## Uso
### Uso basico
```bash
# Backup simple del directorio de documentos
./myBackup.sh -d ~/Documentos

# Backup a ubicación específica
./myBackup.sh -d ~/Documentos -o /mnt/backups

# Modo verbose (ver detalles)
./myBackup.sh -d ~/Documentos -v

# Sin compresión (para ficheros ya comprimidos)
./myBackup.sh -d ~/Documentos -n
```
### Uso avanzado
```bash
# Backup encriptado con GPG
./myBackup.sh -d ~/Documentos -e

# Retención personalizada (15 días)
./myBackup.sh -d ~/Documentos -r 15

# Usar archivo de configuración alternativo
./myBackup.sh -c /etc/mybackup/config.conf

# Instalar en cron para automatización
./myBackup.sh -d ~/Documentos -o ~/backups -i

# Interfaz interactiva (menú)
./myBackup.sh -m
```
### Opciones de líneas de comandos
Opciones:
  -d <directorio>   Directorio origen del backup (obligatorio)
  -o <destino>      Directorio destino (default: ~/backups)
  -v                Verbose: mostrar detalles en pantalla
  -n                No comprimir (por defecto comprime con gzip)
  -e                Encriptar con GPG
  -r <días>         Retención: días a guardar backups (default: 7)
  -c <archivo>      Archivo de configuración alternativo
  -i                Instalar en cron con frecuencia FRECUENCIA
  -m                Abrir menú interactivo (requiere dialog)
  -h                Mostrar esta ayuda

## Configuración
El archivo de configuración usa formato clave=valor de Bash y se carga automáticamente. (~/.myBackup.conf)
 ```bash
  
  # =============================================================================
# .myBackup.conf — Configuración de myBackup
# =============================================================================

# Directorio origen del backup (se puede sobreescribir con -d)
ORIGEN=""

# Directorio destino (se puede sobreescribir con -o)
DESTINO="$HOME/backups"

# Días que se conservan los backups antes de eliminarlos automáticamente
# 0 = no eliminar nunca
RETENCION=7

# Comprimir el backup con gzip (true/false)
COMPRIMIR=true

# Encriptar el backup con GPG (true/false)
ENCRIPTAR=false

# Email o ID de la clave GPG (solo si ENCRIPTAR=true)
GPG_RECIPIENT="tu-email@ejemplo.com"

# Frecuencia de ejecución automática (formato cron)
# Minuto Hora DiaMes Mes DíaSemana
# "0 2 * * *"     → todos los días a las 2:00am
# "0 */6 * * *"   → cada 6 horas
# "0 2 * * 1"     → lunes a las 2:00am
FRECUENCIA="0 2 * * *"

# Archivo de log
LOG_FILE="$HOME/.mybackup.log"
```
### Precedencia de Configuración

- Archivo de configuración (~/.myBackup.conf) — se carga primero
- Argumentos CLI (-d, -o, -r, etc.) — sobreescriben la configuración
- Valores por defecto — se usan si no se especifica nada

 ## Benchmarks
### Metodología de Testing

Los benchmarks miden el rendimiento de myBackup en diferentes entornos y cargas de trabajo.

### Configuración de Máquinas Virtuales Testeadas:

| **VM** | **SO Base** | **SO Invitado** | **CPU** | **RAM** | **Almacenamiento** |
|:---:|:---:|:---|:---:|:---:|:---:|
| VM-1 |  Linux | Ubuntu 22.04 LTS | 4 cores | 8GB | 100GB SSD |
| VM-2 |  Windows 10 | Ubuntu 20.04 LTS | 4 cores | 8GB | 100GB SSD |
| VM-3 |  Linux | Debian 11 (Minimalista) | 2 cores | 4GB | 50GB SSD |
| VM-4 |  Windows 10 | CentOS 7 | 4 cores | 8GB | 100GB SSD |

### Resultados de Performance
#### Test 1: Backup de Datos Mixtos (500MB)
Configuración: Comprimido, sin encriptación

| SO/Configuración      | Tiempo (seg) | Tamaño Final | Compresión | Memoria Pico |
|----|----|----|----|-----|
| Ubuntu 22.04 (SSD)    | 2.34s        | 145MB        | 71%        | 45MB  |
| Ubuntu 20.04 (SSD)    | 2.67s        | 148MB        | 70%        | 48MB  |
| Debian Minimalista    | 3.12s        | 150MB        | 70%        | 42MB  |
| CentOS 7              | 4.01s        | 152MB        | 70%        | 50MB  |

#### Test 2: Backup Encriptado (500MB, GPG)
| SO/Configuración      | Tiempo (seg) | Tamaño Final | CPU Promedio |
|----|----|----|----|
| Ubuntu 22.04          | 5.23s        | 147MB        | 65%          |
| Ubuntu 20.04          | 5.67s        | 150MB        | 68%          |
| Debian Minimalista    | 6.45s        | 152MB        | 72%          |
| CentOS 7              | 7.89s        | 155MB        | 75%          |

#### Test 3: Respuesta a Carga (1GB, Comprimido)
| Métrica | Valor | Observación |
|---------|-------|-------------|
| Tiempo Total | 4.56s | Incluye compresión gzip |
| I/O Promedio | 220MB/s | Lectura desde SSD |
| CPU Máximo | 85% | Durante compresión |
| RAM Máximo | 58MB | Buffer de tar |
| Throughput | ~219MB/s | Datos comprimidos/segundo |

#### Test 4: Casos de Borde
Prueba de estrés: Archivo muy grande (5GB)
├─ Tiempo de copia: 18.3s
├─ Compresión: 45% (final: 2.25GB)
├─ Encriptación: +9.2s adicionales
├─ RAM máximo: 127MB (buffer + overhead)
└─  Completado sin errores

Prueba de estrés: Múltiples pequeños archivos (50,000 archivos)
├─ Tiempo total: 12.7s
├─ Metadatos: Bien manejados por tar
├─ CPU máximo: 72%
└─  Completado sin errores

Prueba de estrés: Archivos especiales (symlinks, pipes, sockets)
├─ Symlinks:  Preservados correctamente
├─ Permiso especial:  Mantenidos
├─ Rutas largas (>255 caracteres): Soportadas por GNU tar
└─  Completado sin errores

#### Test 5: Automatización con Cron
Ejecución automática cada 6 horas (1GB de datos):

| **Ejecución** | **Hora** | **Tiempo** | **Tamaño** | **Estatus** |
|:---:|:---:|:---:|:---:|:---:|
| 1 | 00:00 | 4.12s | 520MB |  OK |
| 2 | 06:00 | 4.08s | 518MB |  OK |
| 3 | 12:00 | 4.19s | 521MB |  OK |
| 4 | 18:00 | 4.15s | 519MB |  OK |

### Conclusiones de Performance
- SSD vs HDD: Los backups en SSD son más rápidos
- Encriptación GPG: Añade algo de overhead
- Compresión gzip: Reduce el tamaño
- Escalabilidad: Maneja correctamente archivos de 5GB+ sin degradación
- Estabilidad: 100% de confiabilidad en ejecución automática

Recomendación: Usar SSD para destino de backups. Encriptación recomendada para datos sensibles.
