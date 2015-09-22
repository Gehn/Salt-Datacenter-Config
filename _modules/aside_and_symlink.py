import os
import shutil

def aside_and_symlink(target, symlink_source):
    '''
    Moves aside the target, and makes a symlink at the original position to the symlink_source.
    '''
    if os.path.exists(target + ".aside"):
        return True

    try:
        shutil.move(target, target+".aside")
        os.symlink(symlink_source, target)
    except:
        return False

    return True
