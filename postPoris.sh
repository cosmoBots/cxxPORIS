#!/bin/bash
echo "Lanzando el post proceso de poris2Dev..."
python3 PORIS/postPoris.py $1  || { echo 'postPoris.py failed' ; exit 1; }
echo "Creando los links para que la clase PORIS se pueda compilar con tu device"
cd $1/$1.l
ln -s ../../PORIS/cxxPORIS/PORIS.cpp PORIS.cpp
ln -s ../../PORIS/cxxPORIS/PORIS.h PORIS.h
ln -s ../../$1_user/$1_user.l/$1_user.cpp $1_user.cpp
ln -s ../../$1_user/$1_user.l/$1_user.h $1_user.h
cd ../..
