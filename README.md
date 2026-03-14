# NextExplorer Enterprise Manager

![Windows 11](https://img.shields.io/badge/Windows-11-blue)
![PowerShell](https://img.shields.io/badge/PowerShell-5.1+-5391FE)
![Docker Desktop](https://img.shields.io/badge/Docker-Desktop-2496ED)
![Status](https://img.shields.io/badge/Status-Active-success)
![License](https://img.shields.io/badge/License-MIT-green)

PowerShell-based deployment and management tool for **NextExplorer** on **Windows 11** using **Docker Desktop**.

This project helps you:

- Install / configure / reconfigure NextExplorer
- Configure server IP and port
- Add and delete storage paths
- Start and stop the application
- Show current Docker Compose configuration
- Delete configuration, uninstall Docker image, or perform full dependency cleanup

---

## Features

- Menu-driven PowerShell script
- Supports local folders, external HDD, mapped drives, and NAS paths
- Automatic `docker-compose.yml` creation
- Automatic Windows Firewall rule creation
- Docker Desktop integration
- Full cleanup options for configuration and dependencies

---

## Main Menu

1. Install / Configure / Reconfigure  
2. Start NextExplorer  
3. Stop NextExplorer  
4. Show current server IP and port  
5. Configure server IP and port  
6. Add new storage path  
7. Delete storage path  
8. Show current docker-compose.yml  
9. Delete configuration / stop / uninstall / full dependency cleanup  
10. Show configured storage paths  
11. Exit  

---

## Delete Menu

1. Delete configuration only  
2. Stop only  
3. Delete complete docker image and uninstall Docker Desktop  
4. Delete all NextExplorer dependent application software files complete all  
5. Back  

---

## Requirements

- Windows 11
- PowerShell 5.1 or later
- Docker Desktop
- Administrator access
- WSL2 recommended for Docker Desktop backend

---

## How to Run

Create folder:

```powershell
New-Item -ItemType Directory -Path C:\NextExplorer1 -Force

Run command in Powershel :

```powershell
powershell -ExecutionPolicy Bypass -File "C:\NextExplorer1\NextExplorer-Enterprise-Manager.ps1"
