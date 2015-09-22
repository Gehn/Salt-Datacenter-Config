import os
import shutil

def make_usr_symlinks():
    if os.path.exists("/usr/local.aside"):
        return True

    try:
        shutil.move("/usr/local", "/usr/local.aside")
    except:
        return False

    return True
