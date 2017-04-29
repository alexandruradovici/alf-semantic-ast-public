#!/bin/bash

for folder in verify/alfy/*
do
	for file in $folder/*.json
	do
		rm $file
	done
done
