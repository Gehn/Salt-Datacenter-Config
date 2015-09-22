import os
import shutil
from subprocess import Popen
from subprocess import PIPE, STDOUT

def install_repository(repository):
    ret = {'result':True}

    if os.path.exists('/etc/yum.repos.d/' + repository + '.repo'):
        ret['comment']='repo already exists in yum.repos.d'
        return ret

    if "not installed" not in Popen(('rpm -q' + repository).split(), stdout=PIPE, stderr=STDOUT).stdout.read():
        ret['comment']='repo already installed via rpm'
        return ret

    p = Popen(('yum install -y ' + repository).split(), stdout=PIPE, stderr=STDOUT)

    ret['comment']='repo has been installed via yum'
    return ret
