#!/usr/bin/env python3
import pyudev
import os


def call_awesomewm_signal(device):
    os.system('awesome-client "awesome.emit_signal(\'utils::screenmanager:update\')"')

class udevMonitor(object):

    def __init__(self):
        self.context = pyudev.Context()
        self.monitor_drm = pyudev.Monitor.from_netlink(self.context)
        self.monitor_drm.filter_by(subsystem='drm')
        self.observer_drm = pyudev.MonitorObserver(self.monitor_drm, callback=call_awesomewm_signal, daemon=False)

    def start(self):
        self.observer_drm.start()  # First we start the observer
        self.observer_drm.join()  # Then we join it in order to keep it alive ^^


if __name__ == "__main__":
    udev_mon = udevMonitor()
    udev_mon.start()
