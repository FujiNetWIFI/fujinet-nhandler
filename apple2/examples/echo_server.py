#!/usr/bin/env python3
# March 17, 2023 09:30
# echo_server.py

# Echo server by Norman Davie
#
# open port 6502 on local machine
# wait for a connection
# when connected, display the ip
#   address of the connected device
# wait for someone to
#   send us some something
# when something arrives, send it
#   back to the sender.
# close the port if the connected
#   device "disappears"

import socket
import time
import errno

hostname = socket.gethostname()


local_ip = socket.gethostbyname(hostname)

HOST = local_ip    # Standard loopback interface address (localhost)
PORT = 6502        # Port to listen on (non-privileged ports are > 1023)

# found this code here: https://stackoverflow.com/questions/166506/finding-local-ip-addresses-using-pythons-stdlib

def get_ip():
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    s.settimeout(0)
    try:
        # doesn't even have to be reachable
        s.connect(('8.8.8.8', 1))
        IP = s.getsockname()[0]
    except Exception:
        IP = '127.0.0.1'
    finally:
        s.close()
    return IP

private_ip = get_ip()

print("Echo Server Started at: "+hostname + ":"+str(PORT)+" or "+ private_ip +":"+str(PORT))

while True:
    
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        s.bind((HOST, PORT))
        s.listen()
        conn, addr = s.accept()
        with conn:
            print("connected by" + str(addr))
            while True:
                try:
                    
                    data = conn.recv(1024)
                    if data != b'':
                        print(data)
                        conn.sendall(data)
                    else:
                        break
                except socket.error as error:
                    print(error)
                    if error.errno in [errno.EPIPE, errno.ECONNRESET]:
                        break
    print("disconnected.")
    
                    
