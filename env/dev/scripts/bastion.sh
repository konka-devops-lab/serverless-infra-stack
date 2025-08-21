#!/bin/bash
sudo dnf update -y
sudo dnf install tmux git tree telnet mariadb105 redis6 -y
sudo systemctl enable redis6
sudo systemctl start redis6