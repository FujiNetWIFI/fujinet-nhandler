def convert_dos_bin_to_prodos(src):
    
    file_in = open(src, 'rb')
    address = file_in.read(2)
    print(address)
    
    dec_address = address[1]*256 + address[0]

    address = hex(dec_address)[2:].zfill(4)
        
    size    = file_in.read(2)
    print(size)
    content = file_in.read()
    file_in.close()
    
    file_out = open(src, 'wb')
    file_out.write(content)
    file_out.close()
    
    return address

if __name__ == "__main__":
    
    convert_dos_bin_to_prodos("FUJIAPPLE")
