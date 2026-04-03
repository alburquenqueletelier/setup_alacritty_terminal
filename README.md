# Setup Alacritty Terminal

Script de instalación para Debian 13. Instala: Alacritty, zsh, Oh My Zsh, Powerlevel10k y Meslo Nerd Font.

## Instalación

```bash
# 1. Dar permisos de ejecución
chmod +x install.sh

# 2. Ejecutar el script
./install.sh
```

## Configuración de Alacritty

Copia el archivo `alacritty.toml` a:

```
~/.config/alacritty/alacritty.toml
```

```bash
mkdir -p ~/.config/alacritty
cp alacritty.toml ~/.config/alacritty/alacritty.toml
```

## Notas

- Solo compatible con **Debian 13**.
- Reinicia la terminal al finalizar la instalación.
