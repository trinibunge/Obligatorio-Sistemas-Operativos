# myBackup - Sistema de Respaldo Automático

> **Proyecto Obligatorio - Sistemas Operativos**  
[![Maximiliano López](https://img.shields.io/badge/GitHub-Maximiliano_López-B7E3FF?logo=github&logoColor=black)](https://github.com/maaxilopp) [![Trinidad Bunge](https://img.shields.io/badge/GitHub-Trinidad_Bunge-FFD966?logo=github&logoColor=black)](https://github.com/trinibun)
> Profesor: Angel Caffa  
> 


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

**myBackup** es un script bash automatizado para crear, gestionar y restaurar copias de seguridad (backups) en sistemas Linux.

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
- **Checksum Verification**: Verifica integridad SHA256
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
