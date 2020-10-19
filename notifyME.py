#!/bin/python
import sys
import notify2
import subprocess
from time import sleep


def notification(message: str):
    """
    Display notification to the desktop
    Task:
        1. show() -> it will generate a complete new pop
        2. update() -> it will update the payload part of same notification pop-up, not issuing any new one.
    Usage : python <filename.py> typeObj:str value:int objective:str
    typeObj: RAM/SWAP/NORMAL
    value: current usage of RAM or SWAP (for NORMAL, the value = 0)
    objective: show/update    
    """
    # initialize the notification
    notify2.init("notifywhenLOAD")
    notifyObj = notify2.Notification("Emergency Alert!", message)
    notifyObj.set_timeout(12000)
    return notifyObj


def main():
    a = notification(f"{sys.argv[1]} exceeds {sys.argv[2]}")
    if sys.argv[1] in ["RAM", "SWAP"] and sys.argv[3] == "update":
        a.update(f"{sys.argv[1]} Alert!! Warning for death")
        # a.update('river')
        a.set_urgency(2)
        a.show()
    elif sys.argv[1] in ["RAM", "SWAP"] and sys.argv[3] == "show":
        a.set_timeout(10000)
        a.set_urgency(1)
        a.show()
    elif sys.argv[1] == "NORMAL":
        a.update("ChiLLax!!! Nothing to worry about")
        a.set_urgency(0)
        a.show()


main()
