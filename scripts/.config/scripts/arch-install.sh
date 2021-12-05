#!/bin/bash

core=(
'xorg'
'xorg-xinit'
'firefox'
'nautilus'
'nitrogen'
'picom'
'alacritty'
'base-devel'
)

wm=(
'awesome'
)

loginManager=(
'lightdm'
'lightdm-gtk-greeter'
'lightdm-gtk-greeter-settings'
)

amdGaming=(
'steam'
'xf86-video-amdgpu'
)

editor=(
'neovim'
'tmux'
)

# nodejs npm
development=(

)

aur=(
'ttf-ms-fonts'
)

systemUpdate() {
  sudo pacman -Syu git --noconfirm
}

pacmanNoVerify() {
  local deps=("$@")
  for i in ${deps[@]}; do
    sudo pacman -S $i --noconfirm
  done
}

installYay() {
  git clone https://aur.archlinux.org/yay.git
  cd yay
  makepkg -si
  cd ..
}

yayNoVerify() {
  local deps=("$@")
  for i in ${deps[@]}; do
    yay -Syu $i --noconfirm
  done
}

enableLightDm() {
  systemctl enable lightdm
}


systemUpdate
pacmanNoVerify "${core[@]}"
pacmanNoVerify "${loginManager[@]}"
pacmanNoVerify "${wm[@]}"
pacmanNoVerify "${amdGaming[@]}"
pacmanNoVerify "${editor[@]}"
installYay "${aur[@]}"
enableLightDm


