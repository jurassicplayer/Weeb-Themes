#!/bin/bash
plasmapkg2 -t lookandfeel -r SnowyNightMiku_QT5; plasmapkg2 -t lookandfeel -i weeb-ksplashx-themes/SnowyNightMiku_QT5
sudo cp -rf weeb-sddm-themes/* /usr/share/sddm/themes/
sudo cp -rf weeb-gtk-themes/* /usr/share/themes/
sudo cp -rf weeb-ksplashx-themes/SnowyNightMiku_QT4 /usr/share/ksplash/Themes
