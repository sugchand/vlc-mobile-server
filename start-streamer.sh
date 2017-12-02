#!/bin/bash -x

function start-server {
    vlc screen:// --screen-fps=30 --input-slave=alsa:// --live-caching=600 --sout "#transcode{vcodec=mp4v,vb=1500,fps=30,scale=0.25,acodec=mp4a,ab=48,channels=2,samplerate=8000}:http{mux=ts,dst=:8080/}" --sout-keep --sout-avcodec-strict -2

}

start-server
