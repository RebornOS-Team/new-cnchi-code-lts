#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
#  desktop_info.py
#
#  Copyright © 2013-2019 RebornOS - Modified by Rafael <rafael@rebornos.org> in 2020/2021
#
#  This file is part of Cnchi.
#
#  Cnchi is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 3 of the License, or
#  (at your option) any later version.
#
#  Cnchi is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  The following additional terms are in effect as per Section 7 of the license:
#
#  The preservation of all legal notices and author attributions in
#  the material or in the Appropriate Legal Notices displayed
#  by works containing it is required.
#
#  You should have received a copy of the GNU General Public License
#  along with Cnchi; If not, see <http://www.gnu.org/licenses/>.


""" Desktop Environments information """

# Disabled desktops(in DESKTOPS_DEV = DESKTOPS : "enlightenment", "windows", "apricity"
# Enabled desktops (added ukui and lxde in 2021.06.15)
# pantheon deleted

DESKTOPS = ["base", "cinnamon", "deepin",
            "gnome", "kde", "mate", "openbox", "xfce"]

DESKTOPS_DEV = DESKTOPS + ["budgie", "i3", "lxqt", "ukui", "lxde", "cutefish", "regolith"]

DESKTOPS_A11Y = ["gnome", "mate", "apricity"]

DESKTOP_ICONS_PATH = "/usr/share/cnchi/data/icons"

'''
MENU - Size appropriate for menus (16px).
SMALL_TOOLBAR - Size appropriate for small toolbars (16px).
LARGE_TOOLBAR - Size appropriate for large toolbars (24px)
BUTTON - Size appropriate for buttons (16px)
DND - Size appropriate for drag and drop (32px)
DIALOG - Size appropriate for dialogs (48px)
'''

# Descriptive names
NAMES = {
    'apricity': "Original Apricity Experience",
    'base': "Base",
    'cinnamon': "Cinnamon",
    'deepin': "Deepin",
    'windows':"Windows Interface",
    'gnome': "GNOME",
    'kde': "KDE",
    'mate': "MATE",
    'openbox': "Openbox",
    'xfce': "Xfce",
    'budgie': "Budgie",
    'enlightenment': "Enlightenment",
    'i3': "i3",
    'lxqt': "LXQt",
    'ukui': "UKUI",
    'lxde': "LXDE",
    'cutefish': "Cutefish",
    'regolith': "Regolith",
}

LIBS = {
    'gtk': ["apricity", "cinnamon", "deepin", "gnome", "mate", "openbox", "xfce", "budgie", "enlightenment", "i3", "windows", "lxde", "regolith"],
    'qt': ["kde", "lxqt", "ukui", "cutefish"]
}

ALL_FEATURES = ["a11y", "aur", "bluetooth", "broadcom", "maintenance", "cups", "chromium", "email", "dropbox", "firefox", "firefox-developer-edition", "google-chrome", "rtl8821ce-dkms-git", "megasync", "firewire", "opera", "hardinfo", "hunspell", "vivaldi", "games", "graphics", "gtk-play", "hardinfo", "qt-play", "movie", "graphic_drivers", "lamp", "lts", "freeoffice", "wps-office", "libreoffice", "onlyoffice", "redshift", "power", "sshd", "spotify", "visual", "vlc", "nautilus", "nemo", "qownnotes", "wallpapers", "wine"]

# Not all desktops have all features
EXCLUDED_FEATURES = {
    'base': ["bluetooth", "chromium", "maintenance", "dropbox", "email", "firefox", "firefox-developer-edition", "google-chrome", "firewire", "opera", "vivaldi", "games", "graphic_drivers", "graphics", "hardinfo", "hunspell", "freeoffice", "wps-office", "libreoffice", "onlyoffice", "visual", "vlc", "nautilus", "nemo", "qownnotes", "qt-play", "movie", "gtk-play", "qt-play", "power", "redshift", "spotify", "wallpapers", "wps-office", "libreoffice", "freeoffice"],
    'apricity': ["lamp", "visual", "nautilus", "qt-play"],
    'cinnamon': ["lamp", "visual", "nemo", "qt-play"],
    'deepin': ["lamp", "visual", "qt-play"],
    'windows': ["lamp", "visual", "qt-play", "nemo"],
    'gnome': ["lamp", "visual", "nautilus", "qt-play"],
    'kde': ["lamp", "visual", "gtk-play"],
    'mate': ["lamp", "visual", "qt-play"],
    'openbox': ["lamp", "qt-play"],
    'xfce': ["lamp", "visual", "qt-play"],
    'budgie': ["lamp", "visual", "qt-play"],
    'enlightenment': ["lamp", "visual", "qt-play"],
    'i3': ["lamp", "qt-play"],
    'lxqt': ["lamp", "visual", "gtk-play"],
    'ukui': ["lamp", "visual", "gtk-play"],
    'lxde': ["lamp", "visual", "gtk-play"],
    'cutefish': ["lamp", "visual", "gtk-play"],
    'regolith': ["lamp", "visual", "gtk-play"]
}

# Session names for lightDM setup (/usr/share/xsessions)
SESSIONS = {
    'apricity' : 'gnome',
    'cinnamon': 'cinnamon',
    'deepin': 'deepin',
    'gnome': 'gnome',
    'kde': 'plasma',
    'mate': 'mate',
    'openbox': 'openbox',
    'xfce': 'xfce',
    'budgie': 'budgie-desktop',
    'enlightenment': 'enlightenment',
    'i3': 'i3',
    'lxqt': 'lxsession',
    'windows': 'windows',
    'ukui': 'ukui-session',
    'lxde': 'startlxde',
    'cutefish': 'cutefish',
    'regolith': 'regolith'
}


# See http://docs.python.org/2/library/gettext.html "22.1.3.4. Deferred translations"
def _(message):
    return message


DESCRIPTIONS = {
    'base': _("This option will install RebornOS as command-line only system, "
              "without any type of graphical interface. After the installation you can "
              "customize RebornOS by installing packages with the command-line package manager."),
              
   'apricity': _("Apricity OS is a now discontinued Linux distro in the Arch Linux family that simply  "
                        "offered a highly customized GNOME dekstop experience that combined beauty with "
                        "funcionality. With this option, the original Apricity look and feel is finally revivied! Experience "
                         "it now on RebornOS."),
                         
    'cinnamon': _("Cinnamon is a Linux desktop which provides advanced, "
                  "innovative features and a traditional desktop user experience. "
                  "Cinnamon aims to make users feel at home by providing them with "
                  "an easy-to-use and comfortable desktop experience."),
                  
    'deepin': _("IMPORTANT: Keep in mind that the Deepin desktop can often be unstable. "
                "This does not depend on us, but on the developers of Deepin who "
                "usually upload BETA versions of the desktop or some components in the "
                "stable repositories of Arch Linux."),
                
    'gnome': _("GNOME 3 is an easy and elegant way to use your "
               "computer. It features the Activities Overview which "
               "is an easy way to access all your basic tasks."),

    'kde': _("If you are looking for a familiar working environment, KDE's "
             "Plasma Desktop offers all the tools required for a modern desktop "
             "computing experience so you can be productive right from the start."),

    'mate': _("MATE is an intuitive, attractive, and lightweight desktop "
              "environment which provides a more traditional desktop "
              "experience. Accelerated compositing is supported, but not "
              "required to run MATE making it suitable for lower-end hardware."),

    'openbox': _("Not actually a desktop environment, Openbox is a highly "
                 "configurable window manager. It is known for its "
                 "minimalistic appearance and its flexibility. It is the most "
                 "lightweight graphical option offered by RebornOS. Please "
                 "Note: Openbox is not recommended for users who are new to Linux."),

    'xfce': _("Xfce is a lightweight desktop environment. It aims to "
              "be fast and low on system resources, while remaining visually "
              "appealing and user friendly. It suitable for use on older "
              "computers and those with lower-end hardware specifications. "),

    'budgie': _("Budgie is the flagship desktop of Solus and is a Solus project. "
                "It focuses on simplicity and elegance. Written from scratch with "
                "integration in mind, the Budgie desktop tightly integrates with "
                "the GNOME stack, but offers an alternative desktop experience."),

    'enlightenment': _("Enlightenment is not just a window manager for Linux/X11 "
                       "and others, but also a whole suite of libraries to help "
                       "you create beautiful user interfaces with much less work"),

    'i3': _("Is a tiling window manager, completely written from scratch. "
                    "i3 is primarily targeted at advanced users and developers. "
                    "Target platforms are GNU/Linux and BSD operating systems."),

    'lxqt': _("LXQt is the next-generation of LXDE, the Lightweight Desktop "
              "Environment. It is lightweight, modular, blazing-fast, and "
              "user-friendly."),
   
   'windows': _("While I am sure you have all heard of Windows, this option "
                           "does NOT truly offer you straight up Windows. This is Linux after all, " 
                           "not Microsoft. However, what this option DOES allow you to experience, "
                           "is a Windows-like desktop running Cinnamon underneath, made to look "
                           "and act like the Windows 10 you are already familiar with. Made with Linux "
                          "newbies specifically in mind, this option should hopefully ensure you have "
                          "an easy, hassle free transition to Linux."),
            
    'ukui': _("UKUI is simple and intuitive interface adapted to the habit of users. "
              "Files category speed up file search. Favorite apps shortcut makes starting "
              "up application more convenient. User management makes a more concise and "
              "friendly interaction for system."),
    
    'lxde': _("LXDE, which stands for Lightweight X11 Desktop Environment, is a desktop "
              "environment which is lightweight and fast. It is designed to be user friendly "
              "and slim, while keeping the resource usage low. LXDE uses less RAM and less "
              "CPU while being a feature rich desktop environment."),
    'cutefish': _("Cutefish tries to give the best experience on a desktop. To do this, "
                  "KDE Frameworks, Qt, and KDE Plasma 5 are used. The desktop experience "
                  "caters to beginners, rather than power users. As such, the devs have no "
                  "(current) plans to add complex, edge-case, or convoluted settings and "
                  "features. The aim is to provide a basic set of sane defaults that just "
                  "work for most users."),
                  
    'regolith': _("It is a minimalist Desktop Environment with a functional user interface, "
                  "which easily allows its modification and expansion, in many of its "
                  "elements. And all thanks to its excellent balance of mixing the features "
                  "of the administration of a GNOME System with the productive workflow of "
                  "i3-wm.")
}

# Delete previous _() dummy declaration
del _
