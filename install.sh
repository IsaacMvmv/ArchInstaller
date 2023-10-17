#!/bin/bash

set -e

if [ "$1" = "" ];then
	clear
	echo Run the script like: \"sh install.sh /dev/sdX\"
	exit 1
fi

cd

clear

sudo echo '#
# /etc/pacman.conf
#
# See the pacman.conf(5) manpage for option and repository directives

#
# GENERAL OPTIONS
#
[options]
# The following paths are commented out with their default values listed.
# If you wish to use different paths, uncomment and update the paths.
#RootDir     = /
#DBPath      = /var/lib/pacman/
CacheDir = /var/cache/pacman/pkg/
#LogFile     = /var/log/pacman.log
#GPGDir      = /etc/pacman.d/gnupg/
#HookDir     = /etc/pacman.d/hooks/
HoldPkg      = pacman glibc
#XferCommand = /usr/bin/curl -L -C - -f -o %o %u
#XferCommand = /usr/bin/wget --passive-ftp -c -O %o %u
#CleanMethod = KeepInstalled
Architecture = auto

# Pacman wont upgrade packages listed in IgnorePkg and members of IgnoreGroup
#IgnorePkg   =
#IgnoreGroup =

#NoUpgrade   =
#NoExtract   =

# Misc options
#UseSyslog
Color
#NoProgressBar
CheckSpace
#VerbosePkgLists
ILoveCandy
ParallelDownloads = 5

# By default, pacman accepts packages signed by keys that its local keyring
# trusts (see pacman-key and its man page), as well as unsigned packages.
SigLevel    = Required DatabaseOptional
LocalFileSigLevel = Optional
#RemoteFileSigLevel = Required

# NOTE: You must run "pacman-key --init" before first using pacman; the local
# keyring can then be populated with the keys of all official Arch Linux
# packagers with "pacman-key --populate archlinux".

#
# REPOSITORIES
#   - can be defined here or included from another file
#   - pacman will search repositories in the order defined here
#   - local/custom mirrors can be added here or in separate files
#   - repositories listed first will take precedence when packages
#     have identical names, regardless of version number
#   - URLs will have $repo replaced by the name of the current repo
#   - URLs will have $arch replaced by the name of the architecture
#
# Repository entries are of the format:
#       [repo-name]
#       Server = ServerName
#       Include = IncludePath
#
# The header [repo-name] is crucial - it must be present and
# uncommented to enable the repo.
#

# The testing repositories are disabled by default. To enable, uncomment the
# repo name header and Include lines. You can add preferred servers immediately
# after the header, and they will be used before the default mirrors.

#[testing]
#Include = /etc/pacman.d/mirrorlist

[core]
Include = /etc/pacman.d/mirrorlist

[extra]
Include = /etc/pacman.d/mirrorlist

#[community-testing]
#Include = /etc/pacman.d/mirrorlist

[community]
Include = /etc/pacman.d/mirrorlist

#[multilib-testing]
#Include = /etc/pacman.d/mirrorlist

[multilib]
Include = /etc/pacman.d/mirrorlist

[chaotic-aur]
Server = https://repo.jkanetwork.com/repo/chaotic-aur/chaotic-aur/x86_64

[blackarch]
Server = http://mirror.cyberbits.eu/blackarch/$repo/os/$arch

[jlk]
SigLevel = Never
Server = https://jlk.fjfi.cvut.cz/arch/repo' > /tmp/pacman.conf

sudo pacman -Sy --needed arch-install-scripts parted wget archlinux-keyring unzip

sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
sudo pacman-key --lsign-key 3056513887B78AEB
sudo pacman -U https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst
wget http://mirror.cyberbits.eu/blackarch/blackarch/os/x86_64/blackarch-keyring-20180925-5-any.pkg.tar.zst
sudo pacman -U blackarch-keyring-20180925-5-any.pkg.tar.zst
rm blackarch-keyring-20180925-5-any.pkg.tar.zst

sudo parted --script $1 mklabel gpt
sudo parted --script $1 mkpart primary 0% 1M
sudo parted --script $1 mkpart primary fat32 1M 151M
sudo parted --script $1 mkpart primary linux-swap 151M 2601M
sudo parted --script $1 mkpart primary btrfs 2601M 100%


(echo r; echo h; echo 1 2 3; echo N; echo EF02; echo N; echo ""; echo N;echo ""; echo Y; echo x; echo h; echo w; echo Y) | sudo gdisk $1

sudo mkfs.vfat -F32 $1\2
sudo mkswap $1\3
sudo mkfs.btrfs -f $1\4

(echo "") | sudo parted $1 set 1 bios_grub on
(echo "") | sudo parted $1 set 4 boot on

sudo mount $1\4 /mnt
sudo mkdir -p /mnt/boot
sudo mount $1\2 /mnt/boot
sudo mkdir -p /mnt/boot/EFI

sudo pacstrap -C /tmp/pacman.conf /mnt acpi alacritty alsa-card-profiles unzip alsa-lib alsa-plugins alsa-topology-conf alsa-ucm-conf alsa-utils wget amd-ucode intel-ucode arch-install-scripts sudo blackarch-keyring archlinux-keyring base chaotic-keyring cmus bat bc binutils bluez bluez-libs brightnessctl bspwm btrfs-progs bzip2 tar unzip zip unrar ccache coreutils cpio create_ap curl discord dkms dosfstools dunst efibootmgr efivar elfutils fd feh file filesystem firefox flameshot fmt fuse-common fuse3 fuse2 fzf gamemode git glava glib-networking glib2 glibc glibmm glslang gnu-netcat gnupg gnutls gparted gptfdisk grep grub grub-customizer gtk-engines gtk-engine-murrine gtk-update-icon-cache gtk3 gtk2 gtkglext gtkmm3 gvfs gvfs-afc gzip haveged htop hwdata hwloc imagemagick inetutils iptables iproute2 iputils itstool iw jack2 jdk-openjdk libaio libao libappindicator-gtk3 linux-tkg-pds linux-tkg-pds-headers linux-api-headers linux-firmware lsb-release lsd lxappearance ly mesa-tkg-git mkinitcpio mkinitcpio-busybox mpg123 nano neofetch ncurses net-tools network-manager-applet networkmanager nm-connection-editor ntfs-3g openal openssh openssl pacman pacman-contrib blackarch-mirrorlist pacman-mirrorlist chaotic-mirrorlist parted paru pavucontrol pciutils polybar pulseaudio pulseaudio-alsa pulseaudio-bluetooth rofi schedtool seabios sed sublime-text-4 systemd systemd-libs systemd-sysvcompat tar thunar sxhkd translate-shell udisks2 update-grub unrar unzip util-linux util-linux-libs v4l-utils vlc vulkan-icd-loader vulkan-tools wget which wireless_tools wmctrl wpa_supplicant xarchiver xdotool xorg-drivers xfce4-taskmanager xfce4-terminal xfsprogs xkeyboard-config xorg-server xorg-server-common xorg-setxkbmap xorg-xauth xorg-xinit xorg-xkbcomp xorg-xmessage xorg-xrandr xorg-xsetroot xorgproto zip zlib zsh zsh-autosuggestions zsh-completions zsh-syntax-highlighting zstd

sudo arch-chroot /mnt wget https://github.com/IsaacMvmv/Stuff/releases/download/pkgs/picom-jonaburg-git-0.1-5-x86_64.pkg.tar.zst
sudo arch-chroot /mnt pacman -U --noconfirm picom-jonaburg-git-0.1-5-x86_64.pkg.tar.zst
sudo arch-chroot /mnt rm picom-jonaburg-git-0.1-5-x86_64.pkg.tar.zst

sudo cp -rf /tmp/pacman.conf /mnt/etc

clear
echo "How do you want to call the hostname?"
read htname
sudo echo $htname > hostname
sudo mv hostname /mnt/etc/hostname

sudo swapon $1\3
sudo genfstab -U /mnt > fstab
sudo mv fstab /mnt/etc/fstab
sudo swapoff $1\3

sudo arch-chroot /mnt pacman -Scc
sudo arch-chroot /mnt ln -sf /usr/share/zoneinfo/Europe/Madrid /etc/localtime
sudo arch-chroot /mnt hwclock --systohc
sudo arch-chroot /mnt systemctl enable haveged NetworkManager ly
sudo arch-chroot /mnt systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target
sudo echo 'Section "InputClass"
    Identifier "touchpad"
    Driver "libinput"
    MatchIsTouchpad "on"
    Option "Tapping" "on"
    Option "TappingButtonMap" "lmr"
    Option "NaturalScrolling" "true"
EndSection' > 30-touchpad.conf
sudo mv 30-touchpad.conf /mnt/etc/X11/xorg.conf.d/30-touchpad.conf

clear
echo "How do you want to name your user:"
echo "Capital letters causes an error, dont use them"
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
sudo chmod 777 /mnt/home/$username/.config/bspwm/scripts/lang.sh
sudo mv locale* /mnt/etc

cd
sudo rm -rf /tmp/dots

sudo arch-chroot /mnt locale-gen
sudo arch-chroot /mnt chown -R $username /home/$username

sudo grub-install --target=x86_64-efi --recheck --removable --efi-directory=/mnt/boot/EFI --boot-directory=/mnt/boot
sudo grub-install --target=i386-pc --recheck --removable --boot-directory=/mnt/boot $1
sudo arch-chroot /mnt update-grub

sudo umount -R /mnt

clear
echo "Installation finished. Go and test :D\!"
