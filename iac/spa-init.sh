#!/bin/bash

apt update
apt install -y python3 python3-pip git
pip3 install flask
mkdir /data
git clone https://github.com/alirionx/eacdemo /data/eacdemo
chmod +x /data/eacdemo/eacdemo.py
/data/eacdemo/eacdemo.py