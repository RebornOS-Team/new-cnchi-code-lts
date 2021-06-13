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
echo $(lspci -v | grep -A10 VGA | grep driver | awk '{print $5}') >/tmp/plymouth.txt
DEVICE=$(sed '1q;d' /tmp/plymouth.txt)
#echo $(grep -n "GRUB_CMDLINE_LINUX_DEFAULT" /etc/default/grub | grep -Eo '^[^:]+')s >/tmp/line.txt
#LINE1=$(sed '1q;d' /tmp/line.txt)
#SWAP_UUID=$(sudo blkid /dev/sd* | grep "swap" | awk '{print $2}' | sed 's/\"//g')
#echo $(cat /etc/mkinitcpio.conf | grep "keyboard keymap") >/tmp/hooks.txt
#HOOK=sed -n 's/.*base udev //p' /tmp/hooks.txt
#echo $(grep -n "keyboard keymap" /etc/mkinitcpio.conf | grep -Eo '^[^:]+')s >/tmp/line2.txt
#LINE2=$(sed '1q;d' /tmp/line2.txt)
#sed -i "$LINE2|.*|HOOKS=base udev plymouth $HOOK|" /etc/mkinitcpio.conf
# sed -i "$LINE1|.*|GRUB_CMDLINE_LINUX_DEFAULT=quiet splash resume=$SWAP_UUID|" /etc/default/grub
echo $(grep -n "MODULES=" /etc/mkinitcpio.conf | grep -Eo '^[^:]+')s | awk '{print $2}' >/tmp/line3.txt
LINE3=$(sed '1q;d' /tmp/line3.txt)
sed -i "$LINE3|.*|MODULES=\"$DEVICE\"|" /etc/mkinitcpio.conf
plymouth-set-default-theme -R arch-charge-big
mkinitcpio -p linux
grub-mkconfig -o /boot/grub/grub.cfg
rm -f /tmp/line.txt
rm -f /tmp/line2.txt
rm -f /tmp/plymouth.txt
rm -f /tmp/modules.txt
rm -f /tmp/hooks.txt
rm -f /etc/xdg/autostart/plymouth-reborn.desktop
