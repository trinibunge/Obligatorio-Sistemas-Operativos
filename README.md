# myBackup - Sistema de Respaldo Automático

> **Proyecto Obligatorio - Sistemas Operativos**  
> Participantes: Trinidad Bunge, Maximiliano Lopez
> Profesor: Angel Caffa  


## Tabla de Contenidos

- [Descripción](#descripción)
- [Características](#características)
- [Requisitos](#requisitos)
- [Instalación](#instalación)
- [Uso](#uso)
- [Configuración](#configuración)
- [Estructura del Proyecto](#estructura-del-proyecto)
- [Ejemplos](#ejemplos)
- [Benchmarks (PARTE 2)](#benchmarks-parte-2)
- [Solución de Problemas](#solución-de-problemas)


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
