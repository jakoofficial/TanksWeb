#! /bin/bash

# EXPORT client and server
godot TanksWeb/project.godot --headless --export-release "Web" ../client-docker/export/index.html
godot TanksWeb/project.godot --headless --export-release "Linux/X11" ../client-docker/export/TanksWeb.x86_64

#Start docker containers
docker compose build
docker compose up -d