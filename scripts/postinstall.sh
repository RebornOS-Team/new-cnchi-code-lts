#!/usr/bin/bash
# -*- coding: utf-8 -*-
#
#  postinstall.sh
#
#  Copyright © 2013-2016 Antergos
#
# Modifications by Rafael from RebornOS in 2020/2021
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
#
# Set xorg config files
set_xorg_touchpad() {
    cp /usr/share/cnchi/scripts/postinstall/50-synaptics.conf ${CN_DESTDIR}/etc/X11/xorg.conf.d/50-synaptics.conf
    cp /usr/share/cnchi/scripts/postinstall/99-killX.conf ${CN_DESTDIR}/etc/X11/xorg.conf.d/99-killX.conf

    # Fix sensitivity for chromebooks
    if lsmod | grep -q cyapa; then
        cp /usr/share/cnchi/scripts/postinstall/50-cros-touchpad.conf ${CN_DESTDIR}/etc/X11/xorg.conf.d/50-cros-touchpad.conf
    fi
}

set_xscreensaver() {
    # xscreensaver config
    cp /usr/share/cnchi/scripts/postinstall/xscreensaver ${CN_DESTDIR}/home/${CN_USER_NAME}/.xscreensaver
    cp ${CN_DESTDIR}/home/${CN_USER_NAME}/.xscreensaver ${CN_DESTDIR}/etc/skel

    if [[ -f ${CN_DESTDIR}/etc/xdg/autostart/xscreensaver.desktop ]]; then
        rm ${CN_DESTDIR}/etc/xdg/autostart/xscreensaver.desktop
    fi
}

set_gsettings() {
    # Set gsettings input-source
    CN_KEYBOARD=""
    CN_INPUT_SCHEMA="${CN_DESTDIR}/usr/share/glib-2.0/schemas/90_rebornos.input-sources.gschema.override"
    if [[ "${CN_KEYBOARD_LAYOUT}" != '' ]]; then
        if [[ "${CN_KEYBOARD_VARIANT}" != '' ]]; then
            CN_KEYBOARD=${CN_KEYBOARD_LAYOUT}+${CN_KEYBOARD_VARIANT}
        else
            CN_KEYBOARD=${CN_KEYBOARD_LAYOUT}
        fi
        echo "[org.cinnamon.desktop.input-sources]" > ${CN_INPUT_SCHEMA}
        echo "sources=[('xkb','${CN_KEYBOARD}')]" >> ${CN_INPUT_SCHEMA}
        echo " " >> ${CN_INPUT_SCHEMA}
        echo "[org.gnome.desktop.input-sources]" >> ${CN_INPUT_SCHEMA}
        echo "sources=[('xkb','${CN_KEYBOARD}')]" >> ${CN_INPUT_SCHEMA}
    fi

    # Set default Internet browser
    for CN_SCHEMA_OVERRIDE in ${CN_DESTDIR}/usr/share/glib-2.0/schemas/90_rebornos*; do
        if [ "${CN_BROWSER}" != "" ]; then
            sed -i "s|chromium|${CN_BROWSER}|g" "${CN_SCHEMA_OVERRIDE}"
        else
            sed -i "s|'chromium.desktop',||g" "${CN_SCHEMA_OVERRIDE}"
        fi
    done

    glib-compile-schemas "${CN_DESTDIR}/usr/share/glib-2.0/schemas"
}

set_dmrc() {
    # Set session in .dmrc
    echo "[Desktop]" > ${CN_DESTDIR}/home/${CN_USER_NAME}/.dmrc
    echo "Session=$1" >> ${CN_DESTDIR}/home/${CN_USER_NAME}/.dmrc
    chroot ${CN_DESTDIR} chown ${CN_USER_NAME}:users /home/${CN_USER_NAME}/.dmrc
}

common_settings() {
    # Set skel directory (not needed, antergos-desktop-settings does this)
    #cp -R ${CN_DESTDIR}/home/${CN_USER_NAME}/.config ${CN_DESTDIR}/etc/skel

    # Set .bashrc (antergos-desktop-settings can't set it because it's already in bash package)
    if [[ -f "${CN_DESTDIR}/etc/skel/bashrc" ]]; then
        cp ${CN_DESTDIR}/etc/skel/bashrc ${CN_DESTDIR}/etc/skel/.bashrc
        cp ${CN_DESTDIR}/etc/skel/bashrc ${CN_DESTDIR}/home/${CN_USER_NAME}/.bashrc
    fi

    # Setup root defaults
    cp -R ${CN_DESTDIR}/etc/skel/. ${CN_DESTDIR}/root
}

gnome_settings() {
    set_gsettings
    set_xscreensaver

    set_dmrc gnome
}

cinnamon_settings() {
    set_gsettings
    set_xscreensaver

    # Copy menu@cinnamon.org.json to set menu icon
    mkdir -p ${CN_DESTDIR}/home/${CN_USER_NAME}/.cinnamon/configs/menu@cinnamon.org/
    cp -f /usr/share/cnchi/scripts/postinstall/menu@cinnamon.org.json ${CN_DESTDIR}/home/${CN_USER_NAME}/.cinnamon/configs/menu@cinnamon.org/

    # Copy panel-launchers@cinnamon.org.json to set launchers
    PANEL_LAUNCHER="/usr/share/cnchi/scripts/postinstall/panel-launchers@cinnamon.org.json"
    if [[ firefox = "${CN_BROWSER}" ]]; then
        sed -i 's|chromium|firefox|g' ${PANEL_LAUNCHER}
    elif [ "${CN_BROWSER}" == "" ]; then
        sed -i 's|"chromium.desktop",||g' ${PANEL_LAUNCHER}
    fi

    mkdir -p ${CN_DESTDIR}/home/${CN_USER_NAME}/.cinnamon/configs/panel-launchers@cinnamon.org/
    cp -f /usr/share/cnchi/scripts/postinstall/panel-launchers@cinnamon.org.json ${CN_DESTDIR}/home/${CN_USER_NAME}/.cinnamon/configs/panel-launchers@cinnamon.org/

    set_dmrc cinnamon
}

xfce_settings() {
    set_gsettings
    set_xscreensaver

    # Set XFCE settings
    mkdir -p ${CN_DESTDIR}/home/${CN_USER_NAME}/.config/xfce4/xfconf/xfce-perchannel-xml
    cp -R ${CN_DESTDIR}/etc/xdg/xfce4/panel ${CN_DESTDIR}/etc/xdg/xfce4/helpers.rc ${CN_DESTDIR}/home/${CN_USER_NAME}/.config/xfce4

    HELPERS_RC="${CN_DESTDIR}/home/${CN_USER_NAME}/.config/xfce4/helpers.rc"
    if [[ ${CN_BROWSER} = "chromium" ]]; then
        sed -i "s/WebBrowser=firefox/WebBrowser=chromium/" ${HELPERS_RC}
    elif [ "${CN_BROWSER}" == "" ]; then
        sed -i "s/WebBrowser=firefox//" ${HELPERS_RC}
    fi

    set_dmrc xfce

    # Add lxpolkit to autostart apps
    cp /etc/xdg/autostart/lxpolkit.desktop ${CN_DESTDIR}/home/${CN_USER_NAME}/.config/autostart
}

openbox_settings() {
    set_gsettings
    set_xscreensaver

    set_dmrc openbox

    # Set Numix theme in oblogout
    if [[ -f /etc/oblogout.conf ]]; then
        sed -i 's|buttontheme = oxygen|buttontheme = Numix|g' "${CN_DESTDIR}/etc/oblogout.conf"
    fi
}

kde_settings() {
    set_gsettings
    set_xscreensaver

    set_dmrc kde-plasma

}

mate_settings() {
    set_gsettings
    set_xscreensaver

    set_dmrc mate

    # Set MintMenu Favorites
    APP_LIST="/usr/share/cnchi/scripts/postinstall/applications.list"
    if [[ "${CN_BROWSER}" = 'firefox' ]]; then
        sed -i 's|chromium|firefox|g' ${APP_LIST}
    elif [ "${CN_BROWSER}" == "" ]; then
        sed -i 's|location:/usr/share/applications/chromium.desktop||g' ${APP_LIST}
    fi

    cp ${APP_LIST} "${CN_DESTDIR}/usr/lib/linuxmint/mintMenu/applications.list"

}

nox_settings() {
    echo "Done"
}

# Experimental DE's

lxqt_settings() {
    set_gsettings
    set_xscreensaver

    set_dmrc razor
}


budgie_settings() {
    set_gsettings
    set_xscreensaver

    set_dmrc budgie
}

i3_settings() {
    set_gsettings
    set_xscreensaver

    set_dmrc i3
}

postinstall() {
    # Specific user configurations
    if [[ -f /usr/share/applications/firefox.desktop ]]; then
        export CN_BROWSER=firefox
    elif [[ -f /usr/share/applications/chromium.desktop ]]; then
        export CN_BROWSER=chromium
    else
        export CN_BROWSER=""
    fi

    # Workaround for LightDM bug https://bugs.launchpad.net/lightdm/+bug/1069218
    sed -i 's|UserAccounts|UserList|g' "${CN_DESTDIR}/etc/lightdm/users.conf"

    ## Unmute alsa channels
    #chroot "${CN_DESTDIR}" amixer -c 0 -q set Master playback 50% unmute

    # Configure touchpad. Skip with base installs
    if [[ "base" != "${CN_DESKTOP}" ]]; then
        set_xorg_touchpad
    fi

    # Fix ugly styles for Qt applications when running under GTK-based desktops and Qt 5.7+
    if [[ kde != "${CN_DESKTOP}" && lxqt != "${CN_DESKTOP}" ]]; then
        mkdir -p "${CN_DESTDIR}/home/${CN_USER_NAME}/.config/qt5ct" "${CN_DESTDIR}/etc/skel/qt5ct"
        cp /usr/share/cnchi/scripts/postinstall/qt5ct.conf "${CN_DESTDIR}/etc/skel/qt5ct"
        cp /usr/share/cnchi/scripts/postinstall/qt5ct.conf "${CN_DESTDIR}/home/${CN_USER_NAME}/.config/qt5ct"
    fi

    # Monkey patch session wrapper
    cp /usr/share/cnchi/scripts/postinstall/Xsession "${CN_DESTDIR}/etc/lightdm"
    chmod +x "${CN_DESTDIR}/etc/lightdm/Xsession"

    # Configure fontconfig
    FONTCONFIG_FILE="/usr/share/cnchi/scripts/fonts.conf"
    if [[ -f "${FONTCONFIG_FILE}" ]]; then
        FONTCONFIG_DIR="${CN_DESTDIR}/home/${CN_USER_NAME}/.config/fontconfig"
        mkdir -p "${FONTCONFIG_DIR}"
        cp "${FONTCONFIG_FILE}" "${FONTCONFIG_DIR}"
    fi



    # Set common desktop settigns
    common_settings

    # Set desktop-specific settings
    ${CN_DESKTOP}_settings

    # Set some environment vars
    env_files=("${CN_DESTDIR}/etc/environment"
        "${CN_DESTDIR}/home/${CN_USER_NAME}/.bashrc"
        "${CN_DESTDIR}/etc/skel/.bashrc"
    "${CN_DESTDIR}/etc/profile")

    for file in "${env_files[@]}"
    do
        echo "# ---> Added by Cnchi RebornOS Installer Gnome based <--- #" >> "${file}"
        if [ "${CN_BROWSER}" != "" ]; then
            echo "BROWSER=/usr/bin/${CN_BROWSER}" >> "${file}"
        fi
        echo "EDITOR=/usr/bin/nano" >> "${file}"
        echo "# ---> End added by Cnchi RebornOS Installer Gnome based <--- #" >> "${file}"
    done






    # ===>>> Start RebornOS SP Changes: <<<=== #
    
    # Copy pacman.conf file over
    rm ${CN_DESTDIR}/etc/pacman.conf
    cp /usr/share/cnchi/pacman.conf ${CN_DESTDIR}/etc/
    cp /etc/pacman.d/reborn-mirrorlist ${CN_DESTDIR}/etc/pacman.d/

    # pamac default configuration file
    rm ${CN_DESTDIR}/etc/pamac.conf
    cp /usr/share/cnchi/pamac.conf ${CN_DESTDIR}/etc/

    # Start cups.service
    chroot ${CN_DESTDIR} systemctl enable cups.service
    
    # Start bluetooth service with options: always discoverable and active
    rm ${CN_DESTDIR}/etc/bluetooth/main.conf
    cp /usr/share/cnchi/scripts/postinstall/bluetooth/main.conf ${CN_DESTDIR}/etc/bluetooth/
    chmod 644 ${CN_DESTDIR}/etc/bluetooth/main.conf
    chroot ${CN_DESTDIR} systemctl enable bluetooth.service
    
    # Change os-release file:
    rm ${CN_DESTDIR}/usr/lib/os-release
    cp /usr/share/cnchi/os-release ${CN_DESTDIR}/usr/lib/
    chmod 644 ${CN_DESTDIR}/usr/lib/os-release
    # Set RebornOS name in arch-release file
    rm ${CN_DESTDIR}/etc/arch-release
    cp /usr/share/cnchi/arch-release ${CN_DESTDIR}/etc/
    chmod 644 ${CN_DESTDIR}/etc/arch-release
    
    # reborn-mirrorlist permission change
    chroot ${CN_DESTDIR} chmod 644 /etc/pacman.d/reborn-mirrorlist
    
    # Used for flatpak selection:
    # cp /usr/share/cnchi/flatpak.sh ${CN_DESTDIR}/usr/bin/
    # cp /usr/share/cnchi/pkcon.sh ${CN_DESTDIR}/usr/bin/
    # cp /usr/share/cnchi/pkcon2.sh ${CN_DESTDIR}/usr/bin/
    # cp /usr/share/cnchi/flatpak.desktop ${CN_DESTDIR}/usr/share/applications/
    # cp /usr/share/cnchi/update.desktop ${CN_DESTDIR}/etc/xdg/autostart/
    
    # ==>>> End RebornOS SP Changes <<<=== #






    # Configure makepkg so that it doesn't compress packages after building.
    # Most users are building packages to install them locally so there's no need for compression.
    sed -i "s|^PKGEXT='.pkg.tar.xz'|PKGEXT='.pkg.tar'|g" "${CN_DESTDIR}/etc/makepkg.conf"

    # Set lightdm-webkit2-greeter in lightdm.conf. This should have been done here (not in the pkg) all along.
    if [[ deepin = "${CN_DESKTOP}" ]]; then
        rm ${CN_DESTDIR}/etc/lightdm/lightdm.conf
        cp /etc/lightdm/lightdm.conf ${CN_DESTDIR}/etc/lightdm/
	chroot ${CN_DESTDIR} systemctl -fq disable lightdm
	chroot ${CN_DESTDIR} systemctl -fq enable sddm
        #cp /usr/share/cnchi/updating.sh ${CN_DESTDIR}/usr/bin/
        #cp /usr/share/cnchi/deepin-fix.sh ${CN_DESTDIR}/usr/bin/
        #cp /usr/share/cnchi/deepin-fix.service ${CN_DESTDIR}/etc/systemd/system/
        #chroot ${CN_DESTDIR} sudo systemctl enable deepin-fix.service
        chroot ${CN_DESTDIR} systemctl enable earlyoom
        chroot ${CN_DESTDIR} systemctl enable ufw
    fi

    if [[ gnome = "${CN_DESKTOP}" ]]; then
        chroot ${CN_DESTDIR} systemctl -fq enable gdm
        #cp /usr/share/cnchi/updating.sh ${CN_DESTDIR}/usr/bin/
        echo "# ---> Added by Cnchi RebornOS Installer Gnome based for Gnome Desktop <--- #" >> ${CN_DESTDIR}/etc/environment
        echo "QT_QPA_PLATFORMTHEME=qt5ct" >> ${CN_DESTDIR}/etc/environment
        echo "# ---> End added by Cnchi RebornOS Installer Gnome based for Gnome Desktop <--- #" >> ${CN_DESTDIR}/etc/environment
        chroot ${CN_DESTDIR} systemctl enable earlyoom
        chroot ${CN_DESTDIR} systemctl enable ufw
        cp /usr/share/cnchi/101_gnome.gschema.override ${CN_DESTDIR}/usr/share/glib-2.0/schemas/
        chroot ${CN_DESTDIR} /usr/bin/glib-compile-schemas /usr/share/glib-2.0/schemas
        # Delete a remnant of lightdm
        # If at any time you want to use lightdm as access, you should comment on this line:
        # rm ${CN_DESTDIR}/etc/lightdm
        rm ${CN_DESTDIR}/etc/lightdm/lightdm.conf
        cp /usr/share/cnchi/lightdm.conf ${CN_DESTDIR}/etc/lightdm/
        chmod 644 ${CN_DESTDIR}/etc/lightdm/lightdm.conf
        rm ${CN_DESTDIR}/etc/lightdm/lightdm-gtk-greeter.conf
        cp /usr/share/cnchi/lightdm-gtk-greeter.conf ${CN_DESTDIR}/etc/lightdm/
        chmod 644 ${CN_DESTDIR}/etc/lightdm/lightdm-gtk-greeter.conf
        rm ${CN_DESTDIR}/usr/share/backgrounds/gnome/adwaita-day.jpg
        cp /usr/share/backgrounds/gnome/adwaita-day.jpg ${CN_DESTDIR}/usr/share/backgrounds/gnome/
        rm ${CN_DESTDIR}/usr/share/backgrounds/gnome/adwaita-morning.jpg
        cp /usr/share/backgrounds/gnome/adwaita-morning.jpg ${CN_DESTDIR}/usr/share/backgrounds/gnome/
        rm ${CN_DESTDIR}/usr/share/backgrounds/gnome/adwaita-night.jpg
        cp /usr/share/backgrounds/gnome/adwaita-night.jpg ${CN_DESTDIR}/usr/share/backgrounds/gnome/
        #echo "[greeter]" >> ${CN_DESTDIR}/etc/lightdm/lightdm-gtk-greeter.conf
        #echo "theme-name = Flat-Plat-Blue" >> ${CN_DESTDIR}/etc/lightdm/lightdm-gtk-greeter.conf
        #echo "icon-theme-name = Flat-Remix-Green" >> ${CN_DESTDIR}/etc/lightdm/lightdm-gtk-greeter.conf
        #echo "background = /usr/share/pixmaps/rebornos.jpg" >> ${CN_DESTDIR}/etc/lightdm/lightdm-gtk-greeter.conf
        #echo "default-user-image = /usr/share/pixmaps/avatar.png" >> ${CN_DESTDIR}/etc/lightdm/lightdm-gtk-greeter.conf
    fi


    if [[ kde = "${CN_DESKTOP}" ]]; then
        chroot ${CN_DESTDIR} systemctl -fq enable sddm
        cp /usr/share/cnchi/sddm.conf ${CN_DESTDIR}/etc/
        #cp /usr/share/cnchi/updating.sh ${CN_DESTDIR}/usr/bin/
        chroot ${CN_DESTDIR} systemctl enable earlyoom
        chroot ${CN_DESTDIR} systemctl enable ufw
        #==>> KDE customization removed as it does not install properly >>==#
        # chroot ${CN_DESTDIR} pacman -S rebornos-kde-customization --noconfirm
        # Delete a remnant of lightdm
        # If at any time you want to use lightdm as access, you should comment on this line:
        # rm ${CN_DESTDIR}/etc/lightdm
        rm ${CN_DESTDIR}/etc/lightdm/lightdm.conf
        cp /usr/share/cnchi/lightdm.conf ${CN_DESTDIR}/etc/lightdm/
        chmod 644 ${CN_DESTDIR}/etc/lightdm/lightdm.conf
        rm ${CN_DESTDIR}/etc/lightdm/lightdm-gtk-greeter.conf
        cp /usr/share/cnchi/lightdm-gtk-greeter.conf ${CN_DESTDIR}/etc/lightdm/
        chmod 644 ${CN_DESTDIR}/etc/lightdm/lightdm-gtk-greeter.conf        
        # Changing default sddm screen to Breeze
        mkdir -p ${CN_DESTDIR}/etc/sddm.conf.d/
        rm ${CN_DESTDIR}/etc/sddm.conf.d/kde_settings.conf
        cp /usr/share/cnchi/scripts/postinstall/kde/etc/sddm.conf.d/kde_settings.conf ${CN_DESTDIR}/etc/sddm.conf.d/
        chroot ${CN_DESTDIR} chmod 644 /etc/sddm.conf.d/kde_settings.conf
    fi

    if [[ budgie = "${CN_DESKTOP}" ]]; then
        chroot ${CN_DESTDIR} systemctl -fq enable lightdm.service
	# sed -i 's/^webkit_theme\s*=\s*\(.*\)/webkit_theme = lightdm-webkit-theme-aether #\1/g' ${CN_DESTDIR}/etc/lightdm/lightdm-webkit2-greeter.conf
	# sed -i 's/^\(#?greeter\)-session\s*=\s*\(.*\)/greeter-session = lightdm-webkit2-greeter #\1/ #\2g' ${CN_DESTDIR}/etc/lightdm/lightdm.conf
        #cp /usr/share/cnchi/updating.sh ${CN_DESTDIR}/usr/bin/
        echo "# ---> Added by Cnchi RebornOS Installer Gnome based for Budgie Desktop <--- #" >> ${CN_DESTDIR}/etc/environment
        echo "QT_QPA_PLATFORMTHEME=qt5ct" >> ${CN_DESTDIR}/etc/environment
        echo "# ---> End added by Cnchi RebornOS Installer Gnome based for Budgie Desktop <--- #" >> ${CN_DESTDIR}/etc/environment
        chroot ${CN_DESTDIR} systemctl enable earlyoom
        chroot ${CN_DESTDIR} systemctl enable ufw
        # Copy config files to use lightdm-gtk-greeter
        rm ${CN_DESTDIR}/etc/lightdm/lightdm.conf
        cp /usr/share/cnchi/lightdm.conf ${CN_DESTDIR}/etc/lightdm/
        chmod 644 ${CN_DESTDIR}/etc/lightdm/lightdm.conf
        rm ${CN_DESTDIR}/etc/lightdm/lightdm-gtk-greeter.conf
        cp /usr/share/cnchi/lightdm-gtk-greeter.conf ${CN_DESTDIR}/etc/lightdm/
        chmod 644 ${CN_DESTDIR}/etc/lightdm/lightdm-gtk-greeter.conf
    fi

    if [[ i3 = "${CN_DESKTOP}" ]]; then
        # chroot ${CN_DESTDIR} systemctl -fq enable sddm
        chroot ${CN_DESTDIR} systemctl -fq enable lightdm.service
        cp /usr/share/cnchi/sddm.conf ${CN_DESTDIR}/etc/
        #cp /usr/share/cnchi/updating.sh ${CN_DESTDIR}/usr/bin/
        echo "# ---> Added by Cnchi RebornOS Installer Gnome based for i3 Desktop <--- #" >> ${CN_DESTDIR}/etc/environment
        echo "QT_QPA_PLATFORMTHEME=qt5ct" >> ${CN_DESTDIR}/etc/environment
        echo "# ---> End added by Cnchi RebornOS Installer Gnome based for i3 Desktop <--- #" >> ${CN_DESTDIR}/etc/environment
        chroot ${CN_DESTDIR} systemctl enable earlyoom
        chroot ${CN_DESTDIR} systemctl enable ufw
        # Copy config files to use lightdm-gtk-greeter
        rm ${CN_DESTDIR}/etc/lightdm/lightdm.conf
        cp /usr/share/cnchi/lightdm.conf ${CN_DESTDIR}/etc/lightdm/
        chmod 644 ${CN_DESTDIR}/etc/lightdm/lightdm.conf
        rm ${CN_DESTDIR}/etc/lightdm/lightdm-gtk-greeter.conf
        cp /usr/share/cnchi/lightdm-gtk-greeter.conf ${CN_DESTDIR}/etc/lightdm/
        chmod 644 ${CN_DESTDIR}/etc/lightdm/lightdm-gtk-greeter.conf
        mkdir -p ${CN_DESTDIR}/home/${CN_USER_NAME}/.config/i3/
        mkdir -p ${CN_DESTDIR}/home/${CN_USER_NAME}/.config/bauh/
        mkdir -p ${CN_DESTDIR}/home/${CN_USER_NAME}/.config/nitrogen/
        rm ${CN_DESTDIR}/home/${CN_USER_NAME}/.config/nitrogen/bg-saved.cfg
        rm ${CN_DESTDIR}/home/${CN_USER_NAME}/.config/nitrogen/nitrogen.cfg
        cp /usr/share/cnchi/scripts/postinstall/i3/config ${CN_DESTDIR}/home/${CN_USER_NAME}/.config/i3/config
        cp -r /usr/share/cnchi/scripts/postinstall/i3/bauh/* ${CN_DESTDIR}/home/${CN_USER_NAME}/.config/bauh/
        cp -r /usr/share/cnchi/scripts/postinstall/i3/nitrogen/* ${CN_DESTDIR}/home/${CN_USER_NAME}/.config/nitrogen/
        find ${CN_DESTDIR}/home/${CN_USER_NAME}/.config/bauh -type f -exec chmod 644 {} \;
        find ${CN_DESTDIR}/home/${CN_USER_NAME}/.config/nitrogen -type f -exec chmod 644 {} \;
        find ${CN_DESTDIR}/home/${CN_USER_NAME}/.config/bauh -type d -exec chmod 755 {} \;
        find ${CN_DESTDIR}/home/${CN_USER_NAME}/.config/nitrogen -type d -exec chmod 755 {} \;
        chmod 644 ${CN_DESTDIR}/home/${CN_USER_NAME}/.config/i3/config
    fi

    if [[ lxqt = "${CN_DESKTOP}" ]]; then
        # chroot ${CN_DESTDIR} systemctl -fq enable sddm.service
        chroot ${CN_DESTDIR} systemctl -fq enable lightdm.service
        # cp /usr/share/cnchi/sddm.conf ${CN_DESTDIR}/etc/
        #cp /usr/share/cnchi/updating.sh ${CN_DESTDIR}/usr/bin/
        chroot ${CN_DESTDIR} systemctl enable earlyoom
        chroot ${CN_DESTDIR} systemctl enable ufw
        # Delete a remnant of lightdm
        # If at any time you want to use lightdm as access, you should comment on this line:
        # rm ${CN_DESTDIR}/etc/lightdm
        rm ${CN_DESTDIR}/etc/lightdm/lightdm.conf
        cp /usr/share/cnchi/lightdm.conf ${CN_DESTDIR}/etc/lightdm/
        chmod 644 ${CN_DESTDIR}/etc/lightdm/lightdm.conf
        rm ${CN_DESTDIR}/etc/lightdm/lightdm-gtk-greeter.conf
        cp /usr/share/cnchi/lightdm-gtk-greeter.conf ${CN_DESTDIR}/etc/lightdm/
        chmod 644 ${CN_DESTDIR}/etc/lightdm/lightdm-gtk-greeter.conf
        rm ${CN_DESTDIR}/home/${CN_USER_NAME}/.config/pavucontrol.ini
        rm -r ${CN_DESTDIR}/home/${CN_USER_NAME}/.config/lxqt
        rm -r ${CN_DESTDIR}/home/${CN_USER_NAME}/.config/pcmanfm-qt
        rm -r ${CN_DESTDIR}/home/${CN_USER_NAME}/.config/pavucontrol-qt
        mkdir -p ${CN_DESTDIR}/home/${CN_USER_NAME}/.config/lxqt
        mkdir -p ${CN_DESTDIR}/home/${CN_USER_NAME}/.config/pcmanfm-qt
        mkdir -p ${CN_DESTDIR}/home/${CN_USER_NAME}/.config/pavucontrol-qt
        cp -r /usr/share/cnchi/scripts/postinstall/lxqt/lxqt/* ${CN_DESTDIR}/home/${CN_USER_NAME}/.config/lxqt/
        cp -r /usr/share/cnchi/scripts/postinstall/lxqt/pcmanfm-qt/* ${CN_DESTDIR}/home/${CN_USER_NAME}/.config/pcmanfm-qt/
        cp -r /usr/share/cnchi/scripts/postinstall/lxqt/pavucontrol-qt/* ${CN_DESTDIR}/home/${CN_USER_NAME}/.config/pavucontrol-qt/
        cp /usr/share/cnchi/scripts/postinstall/lxqt/pavucontrol.ini ${CN_DESTDIR}/home/${CN_USER_NAME}/.config/pavucontrol.ini
        find ${CN_DESTDIR}/home/${CN_USER_NAME}/.config -type f -exec chmod 644 {} \;
        find ${CN_DESTDIR}/home/${CN_USER_NAME}/.config -type d -exec chmod 755 {} \;
    fi

    
    if [[ openbox = "${CN_DESKTOP}" ]]; then
        chmod go=rx ${CN_DESTDIR}/var/lib/lightdm-data
        chroot ${CN_DESTDIR} systemctl -fq enable lxdm
        # cp /usr/share/cnchi/updating.sh ${CN_DESTDIR}/usr/bin/
        chroot ${CN_DESTDIR} systemctl enable earlyoom
        chroot ${CN_DESTDIR} systemctl enable ufw
        # Copy config files to use lightdm-gtk-greeter
        # rm ${CN_DESTDIR}/etc/lightdm/lightdm.conf
        # cp /usr/share/cnchi/lightdm.conf ${CN_DESTDIR}/etc/lightdm/
        # rm ${CN_DESTDIR}/etc/lightdm/lightdm-gtk-greeter.conf
        # cp /usr/share/cnchi/lightdm-gtk-greeter.conf ${CN_DESTDIR}/etc/lightdm/
        # chroot ${CN_DESTDIR} mmaker -tGTerm -f OpenBox
        # Use: obmenu-generator -p -i
        mkdir -p ${CN_DESTDIR}/home/${CN_USER_NAME}/.config/nitrogen
        mkdir -p ${CN_DESTDIR}/home/${CN_USER_NAME}/.config/obmenu-generator
        mkdir -p ${CN_DESTDIR}/home/${CN_USER_NAME}/.config/openbox
        mkdir -p ${CN_DESTDIR}/home/${CN_USER_NAME}/.config/pcmanfm
        mkdir -p ${CN_DESTDIR}/home/${CN_USER_NAME}/.config/tint2
        cp -r /usr/share/cnchi/scripts/postinstall/openbox/config/nitrogen/* ${CN_DESTDIR}/home/${CN_USER_NAME}/.config/nitrogen/
        cp -r /usr/share/cnchi/scripts/postinstall/openbox/config/obmenu-generator/* ${CN_DESTDIR}/home/${CN_USER_NAME}/.config/obmenu-generator/
        cp -r /usr/share/cnchi/scripts/postinstall/openbox/config/openbox/* ${CN_DESTDIR}/home/${CN_USER_NAME}/.config/openbox/
        cp -r /usr/share/cnchi/scripts/postinstall/openbox/config/pcmanfm/* ${CN_DESTDIR}/home/${CN_USER_NAME}/.config/pcmanfm/
        cp -r /usr/share/cnchi/scripts/postinstall/openbox/config/tint2/* ${CN_DESTDIR}/home/${CN_USER_NAME}/.config/tint2/
        find ${CN_DESTDIR}/home/${CN_USER_NAME}/.config -type f -exec chmod 644 {} \;
        find ${CN_DESTDIR}/home/${CN_USER_NAME}/.config -type d -exec chmod 755 {} \;
    fi

    if [[ mate = "${CN_DESKTOP}" ]]; then
        # chroot ${CN_DESTDIR} systemctl -fq enable sddm
        chroot ${CN_DESTDIR} systemctl -fq enable lightdm.service
        # cp /usr/share/cnchi/sddm.conf ${CN_DESTDIR}/etc/
        #cp /usr/share/cnchi/updating.sh ${CN_DESTDIR}/usr/bin/
        # MATE panel bug fixed:
        chroot ${CN_DESTDIR} mate-panel --reset --layout default
        echo "# ---> Added by Cnchi RebornOS Installer Gnome based for MATE Desktop <--- #" >> ${CN_DESTDIR}/etc/environment
        echo "QT_QPA_PLATFORMTHEME=qt5ct" >> ${CN_DESTDIR}/etc/environment
        echo "# ---> End added by Cnchi RebornOS Installer Gnome based for MATE Desktop <--- #" >> ${CN_DESTDIR}/etc/environment
        chroot ${CN_DESTDIR} systemctl enable earlyoom
        chroot ${CN_DESTDIR} systemctl enable ufw
        # Copy config files to use lightdm-gtk-greeter
        rm ${CN_DESTDIR}/etc/lightdm/lightdm.conf
        cp /usr/share/cnchi/lightdm.conf ${CN_DESTDIR}/etc/lightdm/
        chmod 644 ${CN_DESTDIR}/etc/lightdm/lightdm.conf
        rm ${CN_DESTDIR}/etc/lightdm/lightdm-gtk-greeter.conf
        cp /usr/share/cnchi/lightdm-gtk-greeter.conf ${CN_DESTDIR}/etc/lightdm/
        chmod 644 ${CN_DESTDIR}/etc/lightdm/lightdm-gtk-greeter.conf        
    fi

if [[ xfce = "${CN_DESKTOP}" ]]; then
        # chroot ${CN_DESTDIR} systemctl -fq enable sddm
        chroot ${CN_DESTDIR} systemctl -fq enable lightdm.service
        # cp /usr/share/cnchi/sddm.conf ${CN_DESTDIR}/etc/
        #cp /usr/share/cnchi/updating.sh ${CN_DESTDIR}/usr/bin/
        echo "# ---> Added by Cnchi RebornOS Installer Gnome based for XFCE Desktop <--- #" >> ${CN_DESTDIR}/etc/environment
        echo "QT_QPA_PLATFORMTHEME=qt5ct" >> ${CN_DESTDIR}/etc/environment
        echo "# ---> End added by Cnchi RebornOS Installer Gnome based for XFCE Desktop <--- #" >> ${CN_DESTDIR}/etc/environment
        chroot ${CN_DESTDIR} systemctl enable earlyoom
        chroot ${CN_DESTDIR} systemctl enable ufw
        # Copy config files to use lightdm-gtk-greeter
        rm ${CN_DESTDIR}/etc/lightdm/lightdm.conf
        cp /usr/share/cnchi/lightdm.conf ${CN_DESTDIR}/etc/lightdm/
        chmod 644 ${CN_DESTDIR}/etc/lightdm/lightdm.conf
        rm ${CN_DESTDIR}/etc/lightdm/lightdm-gtk-greeter.conf
        cp /usr/share/cnchi/lightdm-gtk-greeter.conf ${CN_DESTDIR}/etc/lightdm/
        chmod 644 ${CN_DESTDIR}/etc/lightdm/lightdm-gtk-greeter.conf        
fi

if [[ cinnamon = "${CN_DESKTOP}" ]]; then
        # chroot ${CN_DESTDIR} systemctl -fq enable sddm
        chroot ${CN_DESTDIR} systemctl -fq enable lightdm.service
        # cp /usr/share/cnchi/sddm.conf ${CN_DESTDIR}/etc/
        #cp /usr/share/cnchi/updating.sh ${CN_DESTDIR}/usr/bin/
        echo "# ---> Added by Cnchi RebornOS Installer Gnome based for Cinnamon Desktop <--- #" >> ${CN_DESTDIR}/etc/environment
        echo "QT_QPA_PLATFORMTHEME=qt5ct" >> ${CN_DESTDIR}/etc/environment
        echo "# ---> End added by Cnchi RebornOS Installer Gnome based for Cinnamon Desktop <--- #" >> ${CN_DESTDIR}/etc/environment
        chroot ${CN_DESTDIR} systemctl enable earlyoom
        chroot ${CN_DESTDIR} systemctl enable ufw
        cp /usr/share/cnchi/95_cinnamon.gschema.override ${CN_DESTDIR}/usr/share/glib-2.0/schemas/
        chroot ${CN_DESTDIR} /usr/bin/glib-compile-schemas /usr/share/glib-2.0/schemas
        # Copy config files to use lightdm-gtk-greeter
        rm ${CN_DESTDIR}/etc/lightdm/lightdm.conf
        cp /usr/share/cnchi/lightdm.conf ${CN_DESTDIR}/etc/lightdm/
        chmod 644 ${CN_DESTDIR}/etc/lightdm/lightdm.conf
        rm ${CN_DESTDIR}/etc/lightdm/lightdm-gtk-greeter.conf
        cp /usr/share/cnchi/lightdm-gtk-greeter.conf ${CN_DESTDIR}/etc/lightdm/
        chmod 644 ${CN_DESTDIR}/etc/lightdm/lightdm-gtk-greeter.conf
fi

if [[ pantheon = "${CN_DESKTOP}" ]]; then
        # chroot ${CN_DESTDIR} systemctl -fq enable sddm
        chroot ${CN_DESTDIR} systemctl -fq enable lightdm.service
        cp /usr/share/cnchi/sddm.conf ${CN_DESTDIR}/etc/
        #cp /usr/share/cnchi/updating.sh ${CN_DESTDIR}/usr/bin/
        echo "# ---> Added by Cnchi RebornOS Installer Gnome based for Pantheon Desktop <--- #" >> ${CN_DESTDIR}/etc/environment
        echo "QT_QPA_PLATFORMTHEME=qt5ct" >> ${CN_DESTDIR}/etc/environment
        echo "# ---> End added by Cnchi RebornOS Installer Gnome based for Pantheon Desktop <--- #" >> ${CN_DESTDIR}/etc/environment
        chroot ${CN_DESTDIR} systemctl enable earlyoom
        chroot ${CN_DESTDIR} systemctl enable ufw
        # Copy config files to use lightdm-gtk-greeter
        rm ${CN_DESTDIR}/etc/lightdm/lightdm.conf
        cp /usr/share/cnchi/lightdm.conf ${CN_DESTDIR}/etc/lightdm/
        chmod 644 ${CN_DESTDIR}/etc/lightdm/lightdm.conf
        rm ${CN_DESTDIR}/etc/lightdm/lightdm-gtk-greeter.conf
        cp /usr/share/cnchi/lightdm-gtk-greeter.conf ${CN_DESTDIR}/etc/lightdm/
        chmod 644 ${CN_DESTDIR}/etc/lightdm/lightdm-gtk-greeter.conf
fi

    if [[ ukui = "${CN_DESKTOP}" ]]; then
        chroot ${CN_DESTDIR} systemctl -fq enable lightdm.service
        #cp /usr/share/cnchi/sddm.conf ${CN_DESTDIR}/etc/
        #cp /usr/share/cnchi/updating.sh ${CN_DESTDIR}/usr/bin/
        echo "# ---> Added by Cnchi RebornOS Installer Gnome based for UKUI Desktop <--- #" >> ${CN_DESTDIR}/etc/environment
        echo "QT_QPA_PLATFORMTHEME=qt5ct" >> ${CN_DESTDIR}/etc/environment
        echo "# ---> End added by Cnchi RebornOS Installer Gnome based for UKUI Desktop <--- #" >> ${CN_DESTDIR}/etc/environment
        chroot ${CN_DESTDIR} systemctl enable earlyoom
        chroot ${CN_DESTDIR} systemctl enable ufw
        # Copy config files to use lightdm-gtk-greeter
        rm ${CN_DESTDIR}/etc/lightdm/lightdm.conf
        cp /usr/share/cnchi/lightdm.conf ${CN_DESTDIR}/etc/lightdm/
        chmod 644 ${CN_DESTDIR}/etc/lightdm/lightdm.conf
        rm ${CN_DESTDIR}/etc/lightdm/lightdm-gtk-greeter.conf
        cp /usr/share/cnchi/lightdm-gtk-greeter.conf ${CN_DESTDIR}/etc/lightdm/
        chmod 644 ${CN_DESTDIR}/etc/lightdm/lightdm-gtk-greeter.conf
        rm ${CN_DESTDIR}/home/${CN_USER_NAME}/.config/dconf/user
        mkdir -p ${CN_DESTDIR}/home/${CN_USER_NAME}/.config/dconf
        cp /usr/share/cnchi/scripts/postinstall/ukui/config/dconf/* ${CN_DESTDIR}/home/${CN_USER_NAME}/.config/dconf
        chmod 644 ${CN_DESTDIR}/home/${CN_USER_NAME}/.config/dconf/user
    fi

    if [[ lxde = "${CN_DESKTOP}" ]]; then
        chroot ${CN_DESTDIR} systemctl -fq enable lightdm.service
        #cp /usr/share/cnchi/sddm.conf ${CN_DESTDIR}/etc/
        #cp /usr/share/cnchi/updating.sh ${CN_DESTDIR}/usr/bin/
        echo "# ---> Added by Cnchi RebornOS Installer Gnome based for LXDE Desktop <--- #" >> ${CN_DESTDIR}/etc/environment
        echo "QT_QPA_PLATFORMTHEME=qt5ct" >> ${CN_DESTDIR}/etc/environment
        echo "# ---> End added by Cnchi RebornOS Installer Gnome based for LXDE Desktop <--- #" >> ${CN_DESTDIR}/etc/environment
        chroot ${CN_DESTDIR} systemctl enable earlyoom
        chroot ${CN_DESTDIR} systemctl enable ufw
        # Copy config files to use lightdm-gtk-greeter
        rm ${CN_DESTDIR}/etc/lightdm/lightdm.conf
        cp /usr/share/cnchi/lightdm.conf ${CN_DESTDIR}/etc/lightdm/
        chmod 644 ${CN_DESTDIR}/etc/lightdm/lightdm.conf
        rm ${CN_DESTDIR}/etc/lightdm/lightdm-gtk-greeter.conf
        cp /usr/share/cnchi/lightdm-gtk-greeter.conf ${CN_DESTDIR}/etc/lightdm/
        chmod 644 ${CN_DESTDIR}/etc/lightdm/lightdm-gtk-greeter.conf        
    fi
    
    if [[ regolith = "${CN_DESKTOP}" ]]; then
        chroot ${CN_DESTDIR} systemctl -fq enable lightdm.service
        #cp /usr/share/cnchi/sddm.conf ${CN_DESTDIR}/etc/
        #cp /usr/share/cnchi/updating.sh ${CN_DESTDIR}/usr/bin/
        echo "# ---> Added by Cnchi RebornOS Installer Gnome based for Regolith Desktop <--- #" >> ${CN_DESTDIR}/etc/environment
        echo "QT_QPA_PLATFORMTHEME=qt5ct" >> ${CN_DESTDIR}/etc/environment
        echo "# ---> End added by Cnchi RebornOS Installer Gnome based for Regolith Desktop <--- #" >> ${CN_DESTDIR}/etc/environment
        chroot ${CN_DESTDIR} systemctl enable earlyoom
        chroot ${CN_DESTDIR} systemctl enable ufw
        # Copy config files to use lightdm-gtk-greeter
        rm ${CN_DESTDIR}/etc/lightdm/lightdm.conf
        cp /usr/share/cnchi/lightdm.conf ${CN_DESTDIR}/etc/lightdm/
        chmod 644 ${CN_DESTDIR}/etc/lightdm/lightdm.conf
        rm ${CN_DESTDIR}/etc/lightdm/lightdm-gtk-greeter.conf
        cp /usr/share/cnchi/lightdm-gtk-greeter.conf ${CN_DESTDIR}/etc/lightdm/
        chmod 644 ${CN_DESTDIR}/etc/lightdm/lightdm-gtk-greeter.conf        
    fi    

    if [[ cutefish = "${CN_DESKTOP}" ]]; then
        chroot ${CN_DESTDIR} systemctl -fq enable lightdm.service
        #cp /usr/share/cnchi/sddm.conf ${CN_DESTDIR}/etc/
        #cp /usr/share/cnchi/updating.sh ${CN_DESTDIR}/usr/bin/
        echo "# ---> Added by Cnchi RebornOS Installer Gnome based for Cutefish Desktop <--- #" >> ${CN_DESTDIR}/etc/environment
        echo "QT_QPA_PLATFORMTHEME=qt5ct" >> ${CN_DESTDIR}/etc/environment
        echo "# ---> End added by Cnchi RebornOS Installer Gnome based for Cutefish Desktop <--- #" >> ${CN_DESTDIR}/etc/environment
        chroot ${CN_DESTDIR} systemctl enable earlyoom
        chroot ${CN_DESTDIR} systemctl enable ufw
        # Copy config files to use lightdm-gtk-greeter
        rm ${CN_DESTDIR}/etc/lightdm/lightdm.conf
        cp /usr/share/cnchi/lightdm.conf ${CN_DESTDIR}/etc/lightdm/
        chmod 644 ${CN_DESTDIR}/etc/lightdm/lightdm.conf
        rm ${CN_DESTDIR}/etc/lightdm/lightdm-gtk-greeter.conf
        cp /usr/share/cnchi/lightdm-gtk-greeter.conf ${CN_DESTDIR}/etc/lightdm/
        chmod 644 ${CN_DESTDIR}/etc/lightdm/lightdm-gtk-greeter.conf        
    fi

if [[ base = "${CN_DESKTOP}" ]]; then
        rm ${CN_DESTDIR}/etc/lightdm
fi



    #Copy blacklist.conf file over
    cp /etc/modprobe.d/blacklist.conf ${CN_DESTDIR}/etc/modprobe.d/

    #Copy Plymouth Files over if the Plymouth feature has been selected
    if [ -f "${CN_DESTDIR}/usr/bin/plymouth" ]; then
    echo "[STATUS] Plymouth selected. Configuring now..." >${CN_DESTDIR}/var/log/cnchi/plymouth.log
    echo "[STATUS] Plymouth selected. Configuring now..." >/tmp/cnchi.log
    cp /usr/share/cnchi/plymouth.sh ${CN_DESTDIR}/usr/bin/
    cp /usr/share/cnchi/plymouth-reborn.desktop ${CN_DESTDIR}/etc/xdg/autostart/
    chroot ${CN_DESTDIR} plymouth-set-default-theme -R arch-charge-big
    echo "[SUCCESS] Plymouth has been installed and configured" >${CN_DESTDIR}/var/log/cnchi/plymouth.log
    echo "[SUCCESS] Plymouth has been installed and configured" >/tmp/cnchi.log
    else
    echo "[STATUS] Plymouth not selected" >${CN_DESTDIR}/var/log/cnchi/plymouth.log
    echo "[STATUS] Plymouth not selected" >/tmp/postinstall.log
    fi

    # Ensure user permissions are set in /home
    chroot "${CN_DESTDIR}" chown -R "${CN_USER_NAME}:users" "/home/${CN_USER_NAME}"

    # Remove reborn user if it still exists
    if [ -d "${CN_DESTDIR}/home/reborn" ]; then
    chroot ${CN_DESTDIR} sudo rm -rf /home/reborn
    fi
    
    # Remove rebornos user if it still exists
    if [ -d "${CN_DESTDIR}/home/rebornos" ]; then
    chroot ${CN_DESTDIR} sudo rm -rf /home/reborn
    fi

    # Start vbox client services if we are installed in vbox
    if [[ ${CN_IS_VBOX} = "True" ]] || { [[ $(systemd-detect-virt) ]] && [[ 'oracle' = $(systemd-detect-virt -v) ]]; }; then
        # TODO: This should be done differently
        sed -i 's|echo "X|/usr/bin/VBoxClient-all \&\necho "X|g' "${CN_DESTDIR}/etc/lightdm/Xsession"
    fi
}

touch /tmp/.postinstall.lock
echo "Called installation script with these parameters: [$1] [$2] [$3] [$4] [$5] [$6] [$7]" > /tmp/postinstall.log
CN_USER_NAME=$1
CN_DESTDIR=$2
CN_DESKTOP=$3
CN_LOCALE=$4
CN_IS_VBOX=$5
CN_KEYBOARD_LAYOUT=$6
CN_KEYBOARD_VARIANT=$7

# Use this to test this script (remember to mount /install manually before testing)
#chroot_setup "${CN_DESTDIR}"

{ postinstall; } >> /tmp/postinstall.log 2>&1
rm /tmp/.postinstall.lock

