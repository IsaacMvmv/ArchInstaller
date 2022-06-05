#!/bin/bash

set -e

if [ "$1" = "" ];then
	clear
	echo Run the script like: \"sh install.sh /dev/sdX\"
	exit 1
fi

cd

clear
echo "Adding temporal pacman conf and installing deps..."

sudo cp /etc/pacman.conf /etc/pacman.conf.save
sudo echo '[options]
HoldPkg     = pacman glibc
Architecture = auto
Color
ParallelDownloads = 5
SigLevel    = Never
LocalFileSigLevel = Optional
[core]
Server = https://mirror.pkgbuild.com/$repo/os/$arch

[extra]
Server = https://mirror.pkgbuild.com/$repo/os/$arch

[community]
Server = https://mirror.pkgbuild.com/$repo/os/$arch

[chaotic-aur]
Server = https://geo-mirror.chaotic.cx/$repo/$arch' > pacman.conf
sudo mv pacman.conf /etc/pacman.conf


sudo pacman -Sy
sudo pacman -S --needed arch-install-scripts


sudo parted --script $1 mklabel gpt
sudo parted --script $1 mkpart primary 0% 1M
sudo parted --script $1 mkpart primary fat32 1M 101M
sudo parted --script $1 mkpart primary linux-swap 101M 2601M
sudo parted --script $1 mkpart primary btrfs 2601M 100%


(echo r; echo h; echo 1 2 3; echo N; echo EF02; echo N; echo ""; echo N;echo ""; echo Y; echo x; echo h; echo w; echo Y) | sudo gdisk $1

sudo mkfs.vfat -F32 $1\2
sudo mkswap $1\3
sudo mkfs.btrfs -f $1\4

(echo "") | sudo parted $1 set 1 grub_bios
(echo "") | sudo parted $1 set 4 boot

sudo mount $1\4 /mnt
sudo mkdir -p /mnt/boot
sudo mount $1\2 /mnt/boot
sudo mkdir -p /mnt/boot/EFI

touch $HOME/mounted

sudo pacstrap /mnt acpi alacritty alsa-card-profiles alsa-lib alsa-plugins alsa-topology-conf alsa-ucm-conf alsa-utils amd-ucode intel-ucode arch-install-scripts sudo archlinux-keyring base chaotic-keyring cmus bat bc binutils bluez bluez-libs brightnessctl bspwm btrfs-progs bzip2 tar unzip zip unrar ccache coreutils cpio create_ap curl discord dkms dosfstools dunst efibootmgr efivar elfutils fd feh file filesystem firefox flameshot fmt fuse-common fuse3 fuse2 fzf gamemode git glava glib-networking glib2 glibc glibmm glslang gnu-netcat gnupg gnutls gparted gptfdisk grep grub grub-customizer gtk-engines gtk-engine-murrine gtk-update-icon-cache gtk3 gtk2 gtkglext gtkmm3 gvfs gvfs-afc gzip haveged htop hwdata hwloc imagemagick inetutils iptables iproute2 iputils itstool iw jack2 jdk-openjdk libaio libao libappindicator-gtk3 linux-tkg-cfs linux-tkg-cfs-headers linux-api-headers linux-firmware lsb-release lsd lxappearance ly mesa-tkg-git mkinitcpio mkinitcpio-busybox mpg123 nano neofetch ncurses net-tools network-manager-applet networkmanager nm-connection-editor ntfs-3g openal openssh openssl pacman pacman-contrib pacman-mirrorlist chaotic-mirrorlist parted paru pavucontrol pciutils polybar pulseaudio pulseaudio-alsa pulseaudio-bluetooth rofi schedtool seabios sed simplescreenrecorder sublime-text-4 systemd systemd-libs systemd-sysvcompat tar thunar sxhkd translate-shell udisks2 update-grub unrar unzip util-linux util-linux-libs v4l-utils vlc vulkan-icd-loader vulkan-tools wget which wireless_tools wmctrl wpa_supplicant xarchiver xdotool xorg-drivers xfce4-taskmanager xfce4-terminal xfsprogs xkeyboard-config xorg-server xorg-server-common xorg-setxkbmap xorg-xauth xorg-xinit xorg-xkbcomp xorg-xmessage xorg-xrandr xorg-xsetroot xorgproto zip zlib zsh zsh-autosuggestions zsh-completions zsh-syntax-highlighting zstd
sudo mv /etc/pacman.conf.save /etc/pacman.conf
clear
echo "Old pacman config restored."

sudo arch-chroot /mnt wget https://github.com/IsaacMvmv/Stuff/releases/download/pkgs/picom-jonaburg-git-0.1-5-x86_64.pkg.tar.zst
sudo arch-chroot /mnt pacman -U --noconfirm picom-jonaburg-git-0.1-5-x86_64.pkg.tar.zst
sudo arch-chroot /mnt rm picom-jonaburg-git-0.1-5-x86_64.pkg.tar.zst

sudo cp -rf /etc/pacman* /mnt/etc

clear
echo "How do you want to call the hostname?"
read htname
sudo arch-chroot /mnt hostnamectl set-hostname $htname

sudo swapon $1\3
sudo genfstab -U /mnt >> fstab
sudo mv fstab /mnt/etc/fstab
sudo swapoff $1\3

sudo arch-chroot /mnt pacman -Scc
sudo arch-chroot /mnt ln -sf /usr/share/zoneinfo/Europe/Madrid /etc/localtime
sudo arch-chroot /mnt hwclock --systohc
sudo arch-chroot /mnt systemctl enable haveged NetworkManager ly
sudo arch-chroot /mnt systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target


clear
echo "How do you want to name your user:"
read username
sudo arch-chroot /mnt useradd $username

clear
echo "Set $username passwd"
sudo arch-chroot /mnt passwd $username

clear
echo "Set root passwd"
sudo arch-chroot /mnt passwd root


sudo echo "%$username	ALL=(ALL:ALL) ALL" > $username 
sudo mv $username /mnt/etc/sudoers.d/$username
sudo arch-chroot /mnt chown 0 /etc/sudoers.d/$username

sudo arch-chroot /mnt usermod -s /bin/zsh root
sudo arch-chroot /mnt usermod -s /bin/zsh $username


sudo mkdir -p /tmp/dots
cd /tmp/dots
sudo wget https://github.com/IsaacMvmv/Stuff/releases/download/pkgs/customs.zip
sudo unzip customs.zip
sudo rm customs.zip

sudo chmod -R 777 /tmp/dots

sudo echo "/home/$username/background.jpg" > /tmp/wal
sudo mv /tmp/wal /tmp/dots/home/wal/wal
sudo cp -r /tmp/dots/usr/share/* /mnt/usr/share/
sudo mkdir -p /mnt/home/$username/.cache
sudo cp -r /tmp/dots/home/config /mnt/home/$username/.config
sudo cp -r /tmp/dots/home/background.jpg /mnt/home/$username
sudo cp -r /tmp/dots/home/powerlevel10k /mnt/home/$username
sudo cp /tmp/dots/home/.zshrc /mnt/home/$username
sudo cp /tmp/dots/home/.p10k.zsh /mnt/home/$username
sudo cp -r /tmp/dots/home/wal /mnt/home/$username/.cache


sudo arch-chroot /mnt ln -rfs /home/$username/.zsh* /root
sudo arch-chroot /mnt ln -rfs /home/$username/.p10k.zsh /root
sudo arch-chroot /mnt ln -rfs /home/$username/powerlevel10k /root
sudo arch-chroot /mnt mkdir -p /root/.cache
sudo arch-chroot /mnt ln -rfs /home/$username/.cache/wal /root/.cache/wal


clear
echo "Which language do you want: ES, EN, FR, NL"
read es

if [ "$es" = "ES" ]; then
	sudo echo "LANG=es_ES.UTF-8"> locale.conf
	sudo echo "es_ES.UTF-8 UTF-8" > locale.gen
	sudo echo "setxkbmap es" > /tmp/lang.sh
elif [ "$es" = "EN" ]; then
	sudo echo "LANG=en_GB.UTF-8" > locale.conf
	sudo echo "en_GB.UTF-8 UTF-8" > locale.gen
	sudo echo "" > /tmp/lang.sh
elif [ "$es" = "FR" ]; then
	sudo echo "LANG=fr_FR.UTF-8" > locale.conf
	sudo echo "fr_FR.UTF-8 UTF-8" > locale.gen
	sudo echo "setxkbmap fr" > /tmp/lang.sh
elif [ "$es" = "NL" ]; then
	sudo echo "LANG=nl_NL.UTF-8" > locale.conf
	sudo echo "nl_NL.UTF-8 UTF-8" > locale.gen
	sudo echo "" > /tmp/lang.sh
fi

sudo mv /tmp/lang.sh /mnt/home/$username/.config/bspwm/scripts/lang.sh
sudo chmod 777 /mnt/home/$username/.config/bspwm/bin/lang.sh
sudo mv locale* /mnt/etc

sudo arch-chroot /mnt locale-gen
sudo arch-chroot /mnt chown -R $username /home/$username

sudo grub-install --target=x86_64-efi --recheck --removable --efi-directory=/mnt/boot/EFI --boot-directory=/mnt/boot
sudo grub-install --target=i386-pc --recheck --removable --boot-directory=/mnt/boot $1
sudo arch-chroot /mnt update-grub

sudo umount -R /mnt

clear
echo "Installation finished. Go and test :D\!" 
