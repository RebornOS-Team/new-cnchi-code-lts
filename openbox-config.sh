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


pacman -S openbox-theme --force --noconfirm
wget --spider www.google.com
if [ "$?" = 0 ]; then
echo "$(ls /home/)" >/home.txt
sed -i '/timeshift/d' /home.txt
sed -i '/root/d' /home.txt
if [[ $(wc -l /home.txt | awk '{print $1}') -ge 2 ]]; then
sed -i '/reborn/d' /home.txt
else
echo "Continuing on..."
fi
mkdir /home/$(cat /home.txt)/.config/gtk-3.0
cp -f /tmp/settings.ini /home/$(cat /home.txt)/.config/gtk-3.0/
cp -f /tmp/rc.xml /home/$(cat /home.txt)/.config/openbox/
mkdir /home/$(cat /home.txt)/.config/conky
cp -f /tmp/conky.conf /home/$(cat /home.txt)/.config/conky/
rm -f /tmp/conky.conf
chmod ugo=rw /home/$(cat /home.txt)/.config/conky/conky.conf
chmod ugo=rw /home/$(cat /home.txt)/.config/openbox/rc.xml
chmod ugo=rw /home/$(cat /home.txt)/.config/gtk-3.0/settings.ini
git clone https://github.com/addy-dclxvi/openbox-theme-collections.git /temp
rm -rf /temp/.git
mv -f /temp/* /usr/share/themes/
rm -rf /temp
git clone https://github.com/addy-dclxvi/gtk-theme-collections.git /temp2
rm -rf /temp2/.git
mv -f /temp2/* /usr/share/themes/
rm -rf /temp2
mv -f /tmp/settings.ini /usr/share/gtk-3.0/
mv -f /tmp/rc.xml /etc/xdg/openbox/
rm -f /etc/xdg/autostart/obmenu-gen.desktop
sudo -u $(cat /home.txt) obmenu-generator -p -i
sudo -u $(cat /home.txt) openbox --reconfigure
yad --title "Conky" --height=100 --width=300 --center --text="Your Openbox setup has now been fully configured! To experience the improvements fully, please log out and then back in. Thank you, and enjoy!" --text-align=center
sudo -u root rm -f /home.txt
else exec /usr/bin/openbox-config.sh
fi
