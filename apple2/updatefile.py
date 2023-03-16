import pyautogui as p
import os
import time
from subprocess import Popen, PIPE
import datetime

filename   = [ "FUJIAPPLE" ]
pconvert   = [   0x2000    ] # If entry is zero, it will get the address from pfilenames entry (dos 3 file)
pfilenames = [ "FUJIAPPLE" ] # SOURCE
pfilenamed = [ "FUJIAPPLE" ] # DESTINATION

dosdisk   = "FUJIAPPLE.dsk"
prodisk   = "FUJIAPPLE.po"

global checked

checked = False

window_speed = 0.5
my_speed     = 0.0
tab_speed    = 0.0

debug = False
debug_small = debug or False

global ciderpress_window

def run(cmdlist):
    if debug:
        for i in cmdlist:
            print(i+" ", end='')
        print()
    
    process = Popen(cmdlist, stdout=PIPE)
    output, error = process.communicate()
        
    if output == None:
        output = ""
    else:
        output = output.decode().strip()
    if error == None:
        error = ""
    else:
        error = error.decode().strip()
    return [output,error]

#**************************************************
def set_focus(windowname):
    if debug_small:
        print("set_focus")

    end_program = False
    focus_set = False
    while not focus_set:

        error = ""
        retry = 1
        process_id1 = None
        while retry > 0:
            
            #************** FIND THE WINDOW
            if process_id1 == None:
                # Run the console application with Popen
                output, error = run(['xdotool', 'search', '--name', windowname])
                    
                if output == "":
                    end_program = True
                    print(error)
                    exit(0)
                    continue

                # Print the output of the console application
                process_id1 = output

            #**************** set the window active
            output, error = run(['xdotool', 'windowactivate', process_id1])
                
            if error != "":
                process_id1 = None
                print(error)
                retry = 2
                time.sleep(10)
                end_program = True
                
            retry -= 1

            time.sleep(1)
            
        
        output, error = run(['xdotool', 'getwindowname', process_id1])
        currentwindowname = output
        
        output, error = run(['wmctrl', '-a', currentwindowname])
        
        output, error = run(['xdotool', 'getactivewindow'])
        process_id2 = output
        
        focus_set = process_id1 == process_id2
 
        if focus_set:
            print(f"focus given to {windowname} - {process_id1}")
            print(f"{output}")
            
        else:
            print("focus failed!")
            exit(0)
        
        if end_program:
            exit(0)

#**************************************************
def give_focus(windowname):
      
    if debug_small:
        print(f"give_focus {windowname}")
    time.sleep(window_speed)
    output, error = run(['wmctrl', '-a', windowname])
    
    for i in range(2):
        output, error = run(['xdotool', 'getactivewindow'])
        process_id = output
        if debug:
            print(output)
        
        output, error = run(['xdotool', 'getwindowname', process_id])
        currentwindowname = output
        if debug:
            print(f"current window: {currentwindowname}")
    
        if currentwindowname.find(windowname) != 0:
            print(f"Not expected window '{currentwindowname}'")
            output, err = run(['wmctrl', '-l'])
            print(output)
            print(error)
            exit(0)
    
#**************************************************
def start_ciderpress(disk):
    global ciderpress_window

    if debug_small:
        print("start_ciderpress")

    disk = "/home/ndavie/Documents/Projects/fujiapple-ampersand/" + disk
    cmd_str = "wine /home/ndavie/Documents/Windows\ Programs/CiderPress/ciderpress.exe "+disk

    proc = Popen([cmd_str], shell=True,
             stdin=None, stdout=None, stderr=None, close_fds=True)
    
    time.sleep(1)
    
    ciderpress_window = "CiderPress"
    give_focus(ciderpress_window)
    
    
#**************************************************
def erase_field():
    
    if debug_small:
        print("erase_field")

    p.keyDown("ctrl")
    p.press("a")
    p.keyUp("ctrl")
    time.sleep(my_speed)
    p.press('del')
    time.sleep(my_speed)
    

#**************************************************
def do_tabs(count):
    if debug_small:
        print("do_tabs")

    for i in range(count):
        if debug:
            print(f"{i+1}/{count} tab ", end='')
        p.press("tab")
        time.sleep(tab_speed)
    if debug:
        print()
    time.sleep(my_speed)
    
#**************************************************
def find_file(file):
    global checked
    
    if debug_small:
        print("find_file")

    give_focus(ciderpress_window)
    
    if debug:
        print(f"find_file {file}")
    
    if debug:
        print("alt-e")
    p.keyDown("alt")
    time.sleep(window_speed)
    p.press("e")
    p.keyUp("alt")
    
    time.sleep(my_speed)
    if debug:
        print("F")
    p.press("f")
    time.sleep(my_speed)
    give_focus("Find")
    
    p.keyDown("alt")
    p.press("n")
    p.keyUp("alt")
    time.sleep(my_speed)

    erase_field()
        
    if debug:
        print(f"Searching for '{file}'")    
    p.write(file)

    time.sleep(my_speed)
    if not checked:
        if debug:
            print("not checked")
            print("alt-w")
        p.keyDown("alt")
        p.press("W")
        p.keyUp("alt")

        time.sleep(my_speed)
        checked = True 
        
    else:
        if debug:
            print("already checked")

    p.keyDown("alt")
    p.press("F")
    p.keyUp("alt")
    do_tabs(1)
    p.press("enter")
        
    time.sleep(my_speed)
    
    give_focus(ciderpress_window)

#**************************************************
def add_file(files):

    if debug_small:
        print("add_file")

    for file in files:
        
        time.sleep(my_speed)
        
        give_focus(ciderpress_window)
        
        if debug:
            print(f"add_file {file}")
        
            print("alt-a")
        p.keyDown("alt")
        p.press("A")
        p.keyUp("alt")
        time.sleep(my_speed)
        if debug:
            print("F")
        p.press("F")
        time.sleep(window_speed)
        
        give_focus("Add")
        
        p.keyDown("alt")
        p.press("d")
        p.keyUp("alt")
        time.sleep(my_speed)
        
        p.keyDown("alt")
        p.press("n")
        p.keyUp("alt")
        time.sleep(my_speed)
        			
        erase_field()
        time.sleep(my_speed)
        
        if debug:
            print(f"add file '{file}'")
        p.write(file)

        time.sleep(my_speed)
        
        p.press("enter")
        time.sleep(0.5)
        
    give_focus(ciderpress_window)
        
#**************************************************
def del_file(files):

    
    if debug_small:
        print("del_file")

    for file in files:
        
        find_file(file)
        
        give_focus(ciderpress_window)
        
        if debug:
            print(f"del_file {file}")
            print("alt-a")
        p.keyDown("alt")
        p.press("A")
        p.keyUp("alt")
        time.sleep(my_speed)
        if debug:
            print("d")
        p.press("d")
        time.sleep(window_speed)
        
        p.press("enter")
        p.sleep(0.5)
        
        give_focus(ciderpress_window)

#**************************************************
def leave():
    if debug_small:
        print("leave")

    give_focus(ciderpress_window)
    
    if debug:
        print("alt-f")
    p.keyDown("alt")
    p.press("F")
    p.keyUp("alt")
    time.sleep(my_speed)
    if debug:
        print("E")
    p.press("E")
    time.sleep(my_speed)
    
#**************************************************
def prodos_bin_file(files, address):

    if debug_small:
        print("prodos_bin_file")

    for file in files:
        find_file(file)
        
        if debug:
            print(f"bin_file {file}")
        
            print("alt-a")
        give_focus(ciderpress_window)
        p.press("alt")
        p.press("A")
        time.sleep(my_speed)
        
        if debug:
            print("a")
        p.press("a")
        time.sleep(my_speed)
        
        
        do_tabs(4)
        '''
        for i in range(10):
            print(f"{i+1}/10 up ", end='')
            p.press("up")
            time.sleep(tab_speed)
        print()
        
        for i in range(6):
            print(f"{i+1}/6 down ", end='')
            p.press("down")
            time.sleep(my_speed)
        print()
        '''
        p.press('b')
        time.sleep(my_speed)
        p.press('b')
        time.sleep(my_speed)
        
        do_tabs(1)
        
        erase_field()
        p.write(address)
        time.sleep(my_speed)
        
        if debug:
            print("enter")
        p.press("enter")
        time.sleep(my_speed)
        
        if debug:
            print("enter")
        p.press("enter")
        time.sleep(0.5)

#**************************************************
def dos_bin_file(files):

    if debug_small:
        print("dos_bin_file")

    for file in files:
        find_file(file)
        
        if debug:
            print(f"bin_file {file}")
        
            print("alt-a")
        give_focus(ciderpress_window)
        p.press("alt")
        p.press("A")
        time.sleep(my_speed)
        if debug:
            print("a")
        p.press("a")
        time.sleep(my_speed)
           
        do_tabs(4)
        
        for i in range(10):
            if debug:
                print(f"{i+1}/10 up ", end='')
            p.press("up")
            time.sleep(tab_speed)
        if debug:
            print()
        
        for i in range(1):
            if debug:
                print(f"{i+1}/1 down ", end='')
            p.press("down")
            time.sleep(my_speed)
        if debug:
            print()
        
        p.press("tab")
        
        if debug:
            print("enter")
        p.press("enter")
        time.sleep(my_speed)
        
        if debug:
            print("enter")
        p.press("enter")
        time.sleep(0.5)
        



        

def DOS3_version(disk, filename):
    #os.system("wine /home/ndavie/Documents/Windows\ Programs/CiderPress/ciderpress.exe /home/ndavie/Documents/Projects/fujiapple-ampersand/" + disk + " &")

    if debug_small:
        print("DOS3_version")

    start_ciderpress(disk)
    
    print("click the title bar")

    t = 5
    while t > 0:
        print(f"{t} ", end='')
        time.sleep(1)
        t -= 1
    
    print()

    del_file(filename)

    add_file(filename)

    dos_bin_file(filename)

    leave()
        
def ProDOS_version(disk, filename, address):
    #os.system("wine /home/ndavie/Documents/Windows\ Programs/CiderPress/ciderpress.exe /home/ndavie/Documents/Projects/fujiapple-ampersand/" + disk + " &")

    if debug_small:
        print("ProDOS_version")

    start_ciderpress(disk)

    
    print("**************************************")
    print("***** click the Ciderpress window ****")
    print("**************************************")
    
    checked = False

    t = 5
    while t > 0:
        print(f"{t} ", end='')
        time.sleep(1)
        t -= 1
    
    print()
    

    del_file(filename)

    add_file(filename)

    prodos_bin_file(filename, address)

    leave()
    


def convert_dos_bin_to_prodos(src, tgt):
    
    if debug_small:
        print("convert_dos_bin_to_prodos")

    file_in = open(src, 'rb')
    address = file_in.read(2)
    print(address)
    
    dec_address = address[1]*256 + address[0]

    address = hex(dec_address)[2:].zfill(4)
        
    size    = file_in.read(2)
    print(size)
    content = file_in.read()
    file_in.close()
    
    file_out = open(tgt, 'wb')
    file_out.write(content)
    file_out.close()
    
    return address

def update_version(file, version_signature, new_version):
    
    if debug_small:
        print("update_version")

    updated = False
    
    fp = open(file, "rb")
    contents=fp.read()
    fp.close()
    
    content = bytearray(contents)
    
    version_signature = bytearray(version_signature.encode("ascii"))
    new_version = bytearray(new_version.encode("ascii"))
    position = contents.find(version_signature)

    if position > 0:
        for i in range(len(new_version)):
            content[position+i] = new_version[i]
            
        fp = open(file, "wb")
        fp.write(content)
        fp.close()
        updated = True
    else:
        print("version signature not found")
    
    return updated
    
    
if __name__ == "__main__":
      
    
    # kill all running wine processes (ciderpress, applewin, etc.)
    # to prevent locked files
    cmd_str = "wineserver -k"

    proc = Popen([cmd_str], shell=True,
             stdin=None, stdout=None, stderr=None, close_fds=True)

    time.sleep(2)
    
    do_dos = False
    
    if do_dos:
        quit_program = False
        start_program = not quit_program
    
        DOS3_version(dosdisk, filename)
    else:
        start_program = True
    
    version_signature = "YYYYMMDD.HHMM"
    now = datetime.datetime.now()
    new_version = now.strftime('%Y%m%d.%H%M')
    
    
        
    for i in range(len(pfilenames)):
        
        updated = update_version(pfilenames[i], version_signature, new_version)

        if not updated:
            new_version = "Version not updated"
        else:    
            address = pconvert[i]
            if address == 0:
                address = convert_dos_bin_to_prodos(pfilenames[i], pfilenamed[i])
            else:
                address = hex(address)[2:]
            ProDOS_version(prodisk, [ pfilenamed[i] ], address)
    

        print("Copy to TNFS server...")

        cmd = "cp "+prodisk + " /run/user/1000/gvfs/smb-share:server=192.168.2.21,share=tnfs/apple"
        print(cmd)
        os.system(cmd)
        
        if do_dos:
            cmd = "cp "+dosdisk + " /run/user/1000/gvfs/smb-share:server=192.168.2.21,share=tnfs/apple"
            print(cmd)
            os.system(cmd)


        print("Completed.")
        print(f"New version: {new_version}")

   
   