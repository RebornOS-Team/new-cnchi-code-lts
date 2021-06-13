#  Copyright © 2016-2019 Reborn OS
#
#  This file is part of Reborn OS.
#
#  Reborn OS is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 3 of the License, or
#  (at your option) any later version.
#
#  Reborn OS is distributed in the hope that it will be useful,
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
#  along with Reborn OS; If not, see <http://www.gnu.org/licenses/>.

#!/bin/bash
# -*- coding: utf-8 -*-
#

wget --spider www.google.com
if [ "$?" = 0 ]; then

yad --image="gtk-help" --title "Flatpak" --height=100 --width=300 --center --buttons-layout=center \
        --text="Click the button below to get started using flatpak packages. These are extra packages that are distro independent, adding more available packages to your system. However, an internet connection is required. Please connect to the internet before proceeding. Thank you." --text-align=center \
        --button="Add Flatpak Repository":pkcon.sh \
        --button="Remove From Startup":pkcon2.sh

else exec /usr/bin/flatpak.sh
fi
