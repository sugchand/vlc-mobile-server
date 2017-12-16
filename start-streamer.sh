#!/bin/bash

LISTEN_PORT=8080

function is_bin_present() {
    if ! type "$1" > /dev/null; then
        return 1
    else
        return 0
    fi
}

function start-server() {
    is_bin_present "vlc"
	if [ "$?" = 1 ]; then
		echo "vlc is not installed, exiting.."
        exit 1
    fi
    vlc screen:// --screen-fps=30 --input-slave=alsa:// --live-caching=6000 --sout "#transcode{vcodec=mp4v,fps=30,scale=0.5,acodec=mp4a,ab=48,channels=2,samplerate=8000}:http{mux=ts,dst=:${LISTEN_PORT}/}" --sout-keep --sout-avcodec-strict -2
}

# Try 3 different port numbers before exiting.
port_try=3
function set_listen_port() {
    # Find a free listen port, and use it for the server.
    res=$(netstat -antu |grep $LISTEN_PORT)
    if [ -z "$res" ] ; then
        return 0
    fi
    if [ "$port_try" -le 0 ]; then
        return 1
    fi
    # Socket is in Use, Try a different one.
    LISTEN_PORT=$RANDOM
    port_try=$((port_try-1))
    set_listen_port
    return $?
}

function print_console_msg() {
    ip_addrs=($(ip addr show | awk '/inet / {print $2}' | cut -d '/' -f1))

    echo "*******************************************************************"
    echo -e "\n\t **** WELCOME TO MEDIA STREAMER ****\n"
    echo "*******************************************************************"
    echo -e "Streaming is available on following URLs :-\n"
    num_if=${#ip_addrs[@]}
	for (( i=0; i<${num_if}; i++ ));
	do
        if [ "${ip_addrs[$i]}" == "127.0.0.1" ]; then
            # Local host ip.
            continue
        fi
        echo -e "\t\t http://${ip_addrs[$i]}:$LISTEN_PORT"
    done
    echo -e "\n Press Ctrl + C to exit the application."
}

function main() {
    set_listen_port
    if [ "$?" = 1 ]; then
        # Cannot find a free socket for listen.
        echo "Cannot find a free socket, Try different socket than $LISTEN_PORT"
        exit 1
    fi
    print_console_msg
    start-server
}

main
