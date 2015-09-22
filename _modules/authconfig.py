import os
import shutil
from subprocess import Popen
from subprocess import PIPE, STDOUT

def authconfig(enablenis=True, nisdomain=None, nisserver=None):
    ret = {'result':True}
    
    cmd = "authconfig"
    if enablenis:
        cmd += " --enablenis"
    if nisdomain:
        cmd += " --nisdomain=" + nisdomain
    if nisserver:
        cmd += " --nisserver=" + nisserver

    cmd += " --update"

    p = Popen(cmd.split(), stdout=PIPE, stderr=STDOUT)

    ret['comment']='authconfig has been run with nisdomain:' + nisdomain + '; nisserver:' + nisserver

    return ret

