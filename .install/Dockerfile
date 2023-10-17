FROM docker.io/archlinux:base-devel

RUN pacman -Sy
RUN pacman -S --needed --noconfirm git cmake less
RUN pacman -S --needed --noconfirm openssh
RUN pacman -S --needed --noconfirm tmux xorgproto libx11 fontconfig freetype2 libxft
RUN pacman -Fy

# FROM docker.io/ubuntu:22.04

# RUN apt update
# RUN echo y | unminimize
# RUN apt update
# RUN apt upgrade
# RUN apt install -y git
# RUN apt install -y cmake
# RUN apt install -y build-essential
# RUN apt install -y sudo
# RUN apt install -y man-db

# WORKDIR /usr/share/doc/git/contrib/diff-highlight
# RUN make clean
# RUN make

# # RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
