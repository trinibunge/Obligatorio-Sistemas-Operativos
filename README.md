# myBackup, Sistema de Respaldo Automático

## **Proyecto Obligatorio de Sistemas Operativos**

[![Maximiliano López](https://img.shields.io/badge/GitHub-Maximiliano_López-B7E3FF?logo=github&logoColor=black)](https://github.com/maaxilopp) [![Trinidad Bunge](https://img.shields.io/badge/GitHub-Trinidad_Bunge-FFD966?logo=github&logoColor=black)](https://github.com/trinibun)

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
  - [Parte 2 — Entorno de pruebas (VM)](#parte-2--entorno-de-pruebas-vm)
  - [Parte 2 — Metodología](#parte-2--metodología)
  - [Parte 2 — Dataset de benchmark](#parte-2--dataset-de-benchmark)
  - [Parte 2 — Resultados (performance)](#parte-2--resultados-performance)
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
- gzip/bzip2 (compresión)
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

## Configuración de GPG (para backups encriptados)

Para utilizar la opción de encriptación (`-e`), es necesario contar con una clave GPG válida configurada localmente.

### Generar una clave GPG

```bash
gpg --full-generate-key
```

Configuración recomendada:
- Tipo de clave: RSA and RSA
- Tamaño: 4096 bits
- Expiración: 0 (sin expiración)

### Verificar claves disponibles

```bash
gpg --list-keys
```

### Configurar destinatario en `.myBackup.conf`

```bash
GPG_RECIPIENT="tu-email@ejemplo.com"
```

> Nota: si no existe una clave GPG válida para el destinatario configurado, la encriptación fallará.

---

## Uso

> Por defecto, el sistema utiliza `$HOME/Documents` como directorio origen.
> Este valor puede modificarse en `~/.myBackup.conf` o sobrescribirse mediante `-d`.

### Uso básico

```bash
./myBackup.sh
./myBackup.sh -d ~/Documents
./myBackup.sh -d ~/Documents -o ~/mis_backups
./myBackup.sh -d ~/Documents -v
./myBackup.sh -d ~/Documents -n
```

### Uso avanzado

```bash
./myBackup.sh -d ~/Documents -e
./myBackup.sh -d ~/Documents -r 15
./myBackup.sh -d ~/Documents -o ~/backups -i
./myBackup.sh -m
```

### Opciones de línea de comandos

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

## Configuración

El archivo de configuración utiliza formato clave=valor de Bash y se carga automáticamente desde:

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

Los benchmarks miden el rendimiento de myBackup en diferentes entornos y cargas de trabajo.

Herramientas usadas:
- `time` y `/usr/bin/time -v` para tiempo/CPU/memoria/I/O
- `iostat` (opcional) para I/O en paralelo

> Nota: los resultados de esta sección incluyen una Parte 2 con evidencia real en VM UTM/QEMU.

---

## Parte 2 — Entorno de pruebas (VM)

**Fecha:** 2026-05-13  
**Host:** macOS + **UTM (QEMU)**  
**Guest:** Ubuntu (aarch64)

Evidencia:

```bash
$ uname -a
Linux trini-QEMU-Virtual-Machine 6.17.0-23-generic #23-Ubuntu SMP PREEMPT_DYNAMIC Sat Apr 11 23:16:13 UTC 2026 aarch64 GNU/Linux

$ nproc
4

$ free -h
Mem:           3.3Gi       1.2Gi       215Mi        47Mi       2.1Gi       2.1Gi
Swap:          3.8Gi       296Ki       3.8Gi

$ df -h
/dev/vda3        27G   13G   14G  49% /
```

---

## Parte 2 — Metodología

- Medición principal: `/usr/bin/time -v`
- Evidencia guardada con: `2>&1 | tee <archivo>.txt`
- Métricas relevantes:
  - Elapsed (wall clock)
  - User/System time
  - Max RSS (memoria pico)
  - File system inputs/outputs
  - Exit status

---

## Parte 2 — Dataset de benchmark

Dataset mixto “realista”:

```bash
rm -rf ~/test_data
rm -rf ~/backups/*
rm -f ~/.mybackup.log ~/.myBackup.log
mkdir -p ~/test_data

# 2 archivos medianos (~200MB total)
dd if=/dev/urandom of=~/test_data/file1.bin bs=1M count=100
dd if=/dev/urandom of=~/test_data/file2.bin bs=1M count=100

# 2000 archivos pequeños
mkdir -p ~/test_data/small_files
for i in $(seq 1 2000); do
  echo "archivo de prueba $i" > ~/test_data/small_files/f_$i.txt
done

# symlink (caso especial)
ln -s ~/test_data/file1.bin ~/test_data/link_test
```

---

## Parte 2 — Resultados (performance)

| Test | Flags | Formato final | Tamaño | Elapsed | User | Sys | Max RSS | Exit |
|------|-------|---------------|--------|---------|------|-----|--------:|:----:|
| 1 | `-v` | `.tar.gz.gpg` | 201M | 4.19s | 3.89s | 0.44s | 6940 KB | 0 |
| 2 | (default) | `.tar.gz.gpg` | 201M | 4.07s | 3.83s | 0.38s | 6960 KB | 0 |
| 3 | `-n -v` | `.tar.gpg` | 202M | 3.92s | 3.44s | 0.47s | 6968 KB | 0 |
| 4 | `-e -v` | `.tar.gz.gpg` | 201M | 4.04s | 3.82s | 0.36s | 6920 KB | 0 |

---

## Parte 2 — Casos de borde / Robustez

### Caso A — Destino casi lleno (97%)

- Se llenó el filesystem con un archivo “filler” hasta dejar ~1GB libre:
  ```bash
  /dev/vda3        27G   25G  1.0G  97% /
  ```
- Resultado: **backup exitoso**
  - Backup: `backup_20260513_134538.tar.gz.gpg` (201M)
  - Elapsed: 4.52s
  - Exit: 0

**Conclusión:** el sistema funciona correctamente con el destino al 97% de uso.

---

### Caso B — Permisos (chmod 000)

- Archivos/directorios sin permisos:
  ```bash
  d--------- no_list_dir
  ---------- no_read.txt
  ```
- Resultado: **falla controlada**
  - Mensaje: `[ERROR] Falló la creación del backup`
  - Exit status (time): 1

**Nota:** en pipelines con `tee`, `$?` refleja el exit de `tee`; para obtener el del script usar `set -o pipefail` y `${PIPESTATUS[0]}`.

**Conclusión:** ante permisos insuficientes, el script detiene el backup y retorna error (comportamiento robusto).

---

### Caso C — Symlink fuera del árbol + symlink circular

- Symlink fuera del árbol: `link_outside_hosts -> /etc/hosts`
- Symlink circular: `a -> b`, `b -> a`
- Resultado: **backup exitoso**
  - Backup: `backup_20260513_134816.tar.gz.gpg` (201M)
  - Exit: 0

**Conclusión:** no se cuelga y completa el backup con symlinks especiales.

---

### Caso D — Interrupción manual (Ctrl+C)

- Se agregó archivo grande para extender ejecución:
  ```bash
  dd if=/dev/urandom of=~/test_data/big_interrupt.bin bs=1M count=1024
  ```
- Se interrumpió el proceso con `Ctrl+C`:
  ```bash
  [INFO]  Iniciando backup...
  ^C
  ```

**Resultado observado:**
- Quedó un `.tar.gz` parcial:
  - `backup_20260513_135453.tar.gz` (**399M**)
- Se detectaron archivos `.tar.gz` sin cifrar en el destino:
  - `backup_20260513_134653.tar.gz` (201M)
  - `backup_20260513_135453.tar.gz` (399M)

**Conclusión:** el script no limpia automáticamente artefactos parciales ante interrupción.  

---

### Caso E — Stress: 50.000 archivos pequeños

- Cantidad confirmada:
  ```bash
  50000
  ```
- Resultado: **backup exitoso**
  - Backup: `backup_20260513_135605.tar.gz.gpg` (201M)
  - Elapsed: 4.45s
  - Max RSS: 7020 KB
  - Exit: 0

**Conclusión:** soporta 50k archivos sin errores, con leve incremento de tiempo respecto al baseline.

---

## Parte 2 — Conclusiones

- En UTM/QEMU (Ubuntu aarch64, 4 vCPU, 3.3GiB RAM), `myBackup.sh` tuvo tiempos estables (~4–4.5s) para el dataset de pruebas.
- Robustez validada:
  - **Disco casi lleno (97%)**: completó exitosamente.
  - **Permisos**: falla controlada con exit status 1.
  - **Symlinks (externo y circular)**: completa sin colgarse.
  - **Interrupción**: deja archivo parcial `.tar.gz` (mejora pendiente con `trap`).
  - **50k archivos**: completa correctamente.

Recomendaciones:
- Agregar `trap` para limpieza en interrupciones.
- Mejorar reporting de errores (indicar archivo/directorio que falla en permisos).
- Para mediciones con `tee`, usar `pipefail` + `PIPESTATUS` para capturar exit codes reales.
