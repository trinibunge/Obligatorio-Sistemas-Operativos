# myBackup, Sistema de Respaldo Automático

## **Proyecto Obligatorio de Sistemas Operativos**

[![Maximiliano López](https://img.shields.io/badge/GitHub-Maximiliano_López-B7E3FF?logo=github&logoColor=black)](https://github.com/maaxilopp)
[![Trinidad Bunge](https://img.shields.io/badge/GitHub-Trinidad_Bunge-FFD966?logo=github&logoColor=black)](https://github.com/trinibun)

---

## Tabla de Contenidos

- [Descripción](#descripción)
- [Arquitectura](#arquitectura)
- [Características](#características)
- [Requisitos](#requisitos)
- [Instalación](#instalación)
- [Uso](#uso)
- [Configuración](#configuración)
- [Benchmarks](#benchmarks)
  - [Parte 2 — Entorno 1 (VM principal)](#parte-2--entorno-1-vm-principal)
  - [Parte 2 — Entorno 2 (VM recortada)](#parte-2--entorno-2-vm-recortada)
  - [Parte 2 — Metodología](#parte-2--metodología)
  - [Parte 2 — Dataset de benchmark](#parte-2--dataset-de-benchmark)
  - [Parte 2 — Resultados (performance)](#parte-2--resultados-performance)
  - [Parte 2 — Verificación de restauración (integridad)](#parte-2--verificación-de-restauración-integridad)
  - [Parte 2 — Casos de borde / Robustez](#parte-2--casos-de-borde--robustez)
  - [Parte 2 — Conclusiones](#parte-2--conclusiones)

---

## Descripción

myBackup es un sistema de respaldo automático completo para Linux, diseñado para simplificar y automatizar la creación, gestión y restauración de copias de seguridad. Desarrollado como entrega obligatoria de la asignatura Sistemas Operativos, combina scripting Bash avanzado con utilidades C compiladas.

El sistema permite:
- Crear backups comprimidos (gzip) o sin comprimir
- Automatizar backups en intervalos personalizables mediante cron
- Encriptar backups con GPG (criptografía asimétrica)
- Interfaz interactiva con menú mediante dialog
- Logs detallados de todas las operaciones (INFO, WARN, ERROR)
- Eliminar automáticamente backups antiguos (gestión de retención)

---

## Arquitectura

### Componentes
- **myBackup.sh**: Script principal en Bash
  - Manejo de parámetros CLI
  - Carga de configuración
  - Lógica de backup y encriptación
  - Interfaz menú con dialog
  - Gestión de cron

- **backup_log.c**: Programa auxiliar en C
  - Escritura eficiente de logs
  - Validación de niveles (INFO, WARN, ERROR)
  - Timestamps precisos

- **myBackup.conf**: Archivo de configuración
  - Variables configurables
  - Precedencia: archivo config → CLI → defaults

- **myBackup.1**: Manual en formato Roff
  - Compatible con `man myBackup`
  - Documentación estándar Unix

### Flujo de Ejecución
<img width="1257" height="1919" alt="mermaid-diagram" src="https://github.com/user-attachments/assets/12b2aa92-8ec7-4198-9925-16cae3e98507" />

---

## Características

- **Backup Automático**: Crea respaldos en intervalos configurables (horas/días)
- **Múltiples Formatos**: Soporta tar.gz (comprimido) y tar sin comprimir
- **Configuración Flexible**: Línea de comandos + archivo de configuración
- **Restauración Completa**: Recupera datos desde cualquier backup
- **Gestión de Retención**: Elimina automáticamente backups antiguos
- **Interfaz Menú**: Modo interactivo para usuarios no avanzados

### Características Avanzadas
- **Encriptación GPG**: Protege datos sensibles con GPG (criptografía asimétrica)
- **Logs Detallados**: Registro completo de operaciones con niveles (INFO, WARN, ERROR)
- **Utilidad en C**: Programa auxiliar compilado (backup_log) para logging eficiente
- **Integridad de Datos**: Preservación automática de permisos, propietarios y metadatos mediante tar

---

## Requisitos

### Sistema Operativo
- Linux (Ubuntu, Debian, CentOS, etc.)
- Bash 4.0+

### Dependencias
- tar (empaquetado)
- gzip (compresión)
- gpg (encriptación)
- cron (automatización)
- gcc + make (para compilar utilidad C)
- dialog (opcional, para menú)

---

## Instalación

### Dependencias por sistema

Ubuntu/Debian:
```bash
sudo apt update
sudo apt install tar gzip bzip2 cron gcc make dialog openssl gnupg
```

CentOS/RHEL:
```bash
sudo yum install tar gzip bzip2 cronie gcc make dialog openssl gnupg
```

Arch Linux:
```bash
sudo pacman -S tar gzip bzip2 cronie gcc make dialog openssl gnupg
```

### Instalación rápida

```bash
# 1. Clonar o descargar el repositorio
git clone <repository-url> mybackup
cd mybackup

# 2. Compilar el programa auxiliar C
make

# 3. Instalar el sistema
sudo make install

# 4. Copiar archivo de configuración al HOME
cp myBackup.conf ~/.myBackup.conf

# 5. Instalar el script principal globalmente
sudo cp myBackup.sh /usr/local/bin/myBackup
sudo chmod +x /usr/local/bin/myBackup

# 6. Verificar instalación
which backup_log
which myBackup
myBackup -h
```

---

## Instalación manual

```bash
# 1. Compilar backup_log.c
gcc -Wall -Wextra -std=c99 backup_log.c -o backup_log

# 2. Copiar el binario compilado a /usr/local/bin
sudo cp backup_log /usr/local/bin/
sudo chmod +x /usr/local/bin/backup_log

# 3. Hacer el script principal ejecutable
chmod +x myBackup.sh

# 4. Copiar el script principal a /usr/local/bin
sudo cp myBackup.sh /usr/local/bin/myBackup
sudo chmod +x /usr/local/bin/myBackup

# 5. Copiar configuración por defecto
cp myBackup.conf ~/.myBackup.conf
```

---

## Verificación post instalación

```bash
which backup_log
which myBackup
myBackup -h
```

---

## Uso

> Por defecto, el sistema utiliza `$HOME/Documents` como directorio origen.
> Este valor puede modificarse en `~/.myBackup.conf` o sobrescribirse mediante `-d`.

### Ejemplos de uso básico

```bash
Uso básico

# Backup usando la configuración por defecto
./myBackup.sh

# Backup de otro directorio
./myBackup.sh -d ~/Downloads

# Backup a ubicación específica
./myBackup.sh -o ~/mis_backups

# Modo verbose (muestra detalles)
./myBackup.sh -v

# Sin compresión (útil para archivos ya comprimidos)
./myBackup.sh -n
```

---
### Ayuda y documentación

```bash
#El sistema incluye una página de manual accesible desde la terminal:
man myBackup
#Ademas está la ayuda rapida : myBackup -h
```
### Uso avanzado

```bash
# Backup encriptado con GPG
./myBackup.sh -e

# Retención personalizada (15 días)
./myBackup.sh -r 15

# Crear configuración alternativa
sudo mkdir -p /etc/mybackup
sudo cp myBackup.conf /etc/mybackup/config.conf

# Editar configuración alternativa
sudo nano /etc/mybackup/config.conf

# Ejecutar usando esa configuración
./myBackup.sh -c /etc/mybackup/config.conf

# Instalar tarea automática en cron
./myBackup.sh -i

# Interfaz interactiva (menú)
./myBackup.sh -m
```

### Opciones de línea de comandos

Opciones:
  -d <directorio>   Directorio origen del backup (sobrescribe ORIGEN del config)
  -o <destino>      Directorio destino (default: ~/backups)
  -v                Verbose: mostrar detalles en pantalla
  -n                No comprimir (por defecto comprime con gzip)
  -e                Encriptar con GPG
  -r <días>         Retención: días a guardar backups (default: 7)
  -c <archivo>      Archivo de configuración alternativo
  -i                Instalar en cron con frecuencia FRECUENCIA
  -m                Abrir menú interactivo (requiere dialog)
  -h                Mostrar esta ayuda
- `-d <directorio>` Directorio origen del backup
- `-o <destino>` Directorio destino
- `-v` Verbose
- `-n` No comprimir
- `-e` Encriptar con GPG
- `-r <días>` Retención
- `-c <archivo>` Config alternativo
- `-i` Instalar en cron
- `-m` Menú interactivo
- `-h` Ayuda

---
---

## Configuración

El archivo de configuración se carga desde:

```bash
~/.myBackup.conf
```

Ejemplo:

```bash
ORIGEN="$HOME/Documents"
DESTINO="$HOME/backups"
RETENCION=7
COMPRIMIR=true
ENCRIPTAR=false
GPG_RECIPIENT="tu-email@ejemplo.com"
FRECUENCIA="0 2 * * *"
LOG_FILE="$HOME/.mybackup.log"
```

---

## Benchmarks

### Metodología de Testing

- Se utilizó `/usr/bin/time -v` para medir tiempo, CPU, memoria e I/O.
- Evidencia guardada con `2>&1 | tee archivo.txt`.

> Nota: por tratarse de un dataset con datos aleatorios (`/dev/urandom`), la compresión gzip aporta poca reducción; por eso los tamaños se mantienen altos.

---

## Parte 2 — Entorno 1 (VM principal)

**Host:** macOS + UTM (QEMU)  
**Guest:** Ubuntu (aarch64)  

**Recursos:** 4 vCPU, ~3.3GiB RAM *(VM principal)*

---

## Parte 2 — Entorno 2 (VM recortada)

Se duplicó la VM y se redujeron recursos para evaluar performance bajo restricciones (segundo entorno de pruebas).

**Host:** macOS + UTM (QEMU)  
**Guest:** Ubuntu (aarch64)

**Recursos:** 1 vCPU, ~945MiB RAM *(VM recortada)*

---

## Parte 2 — Metodología

- Medición principal: `/usr/bin/time -v`
- Métricas relevantes:
  - Elapsed (wall clock)
  - User/System time
  - Percent of CPU
  - Max RSS (memoria pico)
  - File system inputs/outputs
  - Exit status

**Nota sobre configuración:** durante estas pruebas, el archivo `~/.myBackup.conf` estaba configurado con `ENCRIPTAR=true` (y con un `GPG_RECIPIENT` válido).  
Por ese motivo, incluso en ejecuciones sin `-e`, el comportamiento “por defecto” en este entorno generó backups con extensión `.gpg`.

---

## Parte 2 — Dataset de benchmark

Dataset mixto “realista”:

- 2 archivos binarios aleatorios (~200MB total)
- 2000 archivos pequeños
- symlinks
- para stress: archivo adicional de 1GiB (`big_interrupt.bin` / `big_env2.bin`)

Comandos (ejemplo base):

```bash
dd if=/dev/urandom of=~/test_data/file1.bin bs=1M count=100
dd if=/dev/urandom of=~/test_data/file2.bin bs=1M count=100

mkdir -p ~/test_data/small_files
for i in $(seq 1 2000); do
  echo "archivo de prueba $i" > ~/test_data/small_files/f_$i.txt
done

ln -s ~/test_data/file1.bin ~/test_data/link_test
```

---

## Parte 2 — Resultados (performance)

### Entorno 1 — Resultados (dataset base)

| Test | Flags | Formato final | Tamaño | Elapsed | User | Sys | CPU | Max RSS | Exit |
|------|-------|---------------|--------|---------|------|-----|-----|--------:|:----:|
| 1 | `-v` | `.tar.gz.gpg` | 203M | 4.70s | 3.89s | 0.67s | 96% | 6940 KB | 0 |
| 2 | (config `ENCRIPTAR=true`) | `.tar.gz.gpg` | 203M | 4.54s | 3.82s | 0.54s | 96% | 6960 KB | 0 |
| 3 | `-n -v` | `.tar.gpg` | 203M | 4.18s | 3.31s | 0.54s | 92% | 6968 KB | 0 |
| 4 | `-e -v` | `.tar.gz.gpg` | 203M | 4.60s | 3.85s | 0.50s | 94% | 6920 KB | 0 |
### Entorno 2 — Resultados (VM recortada)

En esta VM se usó el mismo árbol de pruebas, que incluye un archivo grande (`big_interrupt.bin` ~1GiB). Además, se agregó un archivo adicional `big_env2.bin` (~1GiB) para incrementar carga en el Test 3.

| Test | Flags | Formato final | Tamaño | Elapsed | User | Sys | CPU | Max RSS | Exit |
|------|-------|---------------|--------|---------|------|-----|-----:|--------:|:----:|
| 1 | `-v` | `.tar.gz.gpg` | 1.2G | 28.85s | 23.27s | 1.74s | 86% | 6952 KB | 0 |
| 2 | `-n -v` | `.tar.gpg` | 1.3G | 26.80s | 19.95s | 1.72s | 80% | 6940 KB | 0 |
| 3 | `-v` (+1GiB extra) | `.tar.gz.gpg` | 2.2G | 48.62s | 42.76s | 2.01s | 92% | 6960 KB | 0 |

**Conclusión (comparación de entornos):**
- Con recursos recortados (1 vCPU y ~1GiB RAM) y mayor volumen de datos, el tiempo total aumenta significativamente (decenas de segundos), manteniendo un uso de memoria pico similar (~7MB), consistente con un proceso dominado por CPU/I/O (tar+gzip+gpg).

---

## Parte 2 — Verificación de restauración (integridad)

Se verificó que el backup encriptado:
1) se decripta correctamente,
2) se lista correctamente,
3) y al restaurar, el contenido coincide con el origen por checksums.

### Listado del contenido

```bash
BACKUP_GPG=$(ls -1t ~/backups/*.gpg | head -n 1)
echo "Backup usado: $BACKUP_GPG"
gpg -d "$BACKUP_GPG" 2>/dev/null | tar -tzf - | head -n 20
```

### Restauración + checksums

```bash
BACKUP_GPG=$(ls -1t ~/backups/*.gpg | head -n 1)

rm -rf /tmp/restore_test
mkdir -p /tmp/restore_test
gpg -d "$BACKUP_GPG" 2>/dev/null | tar -xzf - -C /tmp/restore_test

( cd ~/test_data && find . -type f -exec sha256sum {} \; | sort ) > /tmp/orig.sha
( cd /tmp/restore_test/test_data && find . -type f -exec sha256sum {} \; | sort ) > /tmp/rest.sha
diff /tmp/orig.sha /tmp/rest.sha && echo "OK: checksums coinciden"
```

Salida:
```text
OK: checksums coinciden
```

**Nota:** `diff -r` sobre el árbol completo falla en presencia de symlinks circulares (`Too many levels of symbolic links`), por lo que se utilizó verificación por checksums de archivos regulares.

---

## Parte 2 — Casos de borde / Robustez

### Caso A — Destino casi lleno (97%)
- Resultado: **backup exitoso**

### Caso B — Permisos (chmod 000)
- Resultado: **falla controlada** (tar falla y el script retorna error)

### Caso C — Symlink fuera del árbol + symlink circular
- Resultado: **backup exitoso** (no se cuelga)

### Caso D — Interrupción manual (Ctrl+C) (fix aplicado)

**Problema detectado en testing:** al interrumpir el proceso durante la creación del tar, la señal `SIGINT` llegaba directamente a `tar` (proceso en primer plano), lo que lo mataba antes de que el trap del script pudiera actuar. El archivo `.part` quedaba en disco sin ser eliminado.

**Fix aplicado:** `tar` ahora corre en background (`&`) seguido de `wait`, de forma que el script intercepta la señal primero en `cleanup_parcial`, mata a `tar` explícitamente con `kill $TAR_PID`, y luego elimina el `.part`. Se agregó además un `rm -f $DESTINO/*.part` de red para cubrir cualquier caso.

**Test ejecutado:**

```bash
./myBackup.sh -d ~/test_data -v &
PID=$!; sleep 2; kill -INT $PID; wait $PID 2>/dev/null
ls ~/backups/*.part 2>/dev/null || echo "✓ Sin parciales"
```

Salida obtenida:

```text
[INFO]  Iniciando backup: /home/trini/test_data -> /home/trini/backups
[WARN]  Backup interrumpido (SIGINT/SIGTERM/SIGHUP). Archivos parciales eliminados.
[ABORT] Backup interrumpido. Limpieza realizada.
✓ Sin parciales
```

**Conclusión:** tras el fix, interrumpir el backup durante la compresión no deja archivos `.part` ni backups corruptos con nombre final.

### Caso E — Stress: 50.000 archivos pequeños
- Resultado: **backup exitoso**

### Caso F — Carga alta (archivo grande ~1GiB)
- Resultado: **backup exitoso**

---

## Parte 2 — Conclusiones

- Se cumplieron pruebas en **dos entornos** (VM principal y VM recortada).
- Dataset con datos aleatorios (`/dev/urandom`) explica tamaños altos pese a compresión.
- El sistema genera backups, los encripta (según configuración) y se verificó restauración con checksums.
- Bajo restricciones de CPU/RAM y mayor volumen de datos, aumenta el tiempo total, manteniendo bajo uso de RAM.
- Robustez:
  - Disco casi lleno: OK
  - Permisos insuficientes: falla controlada
  - Symlinks especiales: OK
  - Interrupción Ctrl+C: **arreglado** (trap + `.part`)
