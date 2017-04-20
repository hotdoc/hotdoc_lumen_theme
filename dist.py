#!/usr/bin/env python3

import subprocess
import sys
import os

cmd = ["tar", "-cJf", sys.argv[2]] + os.listdir(sys.argv[1])

subprocess.check_call(cmd, cwd=sys.argv[1])
