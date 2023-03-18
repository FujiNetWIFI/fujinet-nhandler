import os
import datetime

def update_version(file, version_signature, new_version):
    

    updated = False
    
    full_file = os.getcwd() + "/" + file
    
    print(f"Reading file {full_file}...")
    fp = open(full_file, "rb")
    contents=fp.read()
    fp.close()
    
    content = bytearray(contents)
    
    version_signature = bytearray(version_signature.encode("ascii"))
    new_version = bytearray(new_version.encode("ascii"))
    position = contents.find(version_signature)

    if position > 0:
        print(f"Updating file {full_file}...")
        for i in range(len(new_version)):
            content[position+i] = new_version[i]
            
        fp = open(full_file, "wb")
        fp.write(content)
        fp.close()
        updated = True
    else:
        print("version signature not found")
    
    return updated
    
    
if __name__ == "__main__":
    
    version_signature = "YYYYMMDD.HHMM"
    now = datetime.datetime.now()
    new_version = now.strftime('%Y%m%d.%H%M')
    update_version("FUJIAPPLE", version_signature, new_version)
    