#!/bin/bash
# Network Settings
Lan1=`grep Lan1 ./install.conf | awk '{print $3}'`
IP1=`grep IP1 ./install.conf | awk '{print $3}'`
MASK1=`grep MASK1 ./install.conf | awk '{print $3}'`
GW=`grep GW ./install.conf | awk '{print $3}'`
HOST=`grep HOST ./install.conf | awk '{print $3}'`
DOMAIN=`grep DOMAIN ./install.conf | awk '{print $3}'`
DISK1=`grep DISK1 ./install.conf | awk '{print $3}'`
PARTDISK=`grep PARTDISK ./install.conf | awk '{print $3}'`


# Compilation Settings
MAKECONF="/mnt/gentoo/etc/portage/make.conf"

# Console dialog
red=$(tput setf 4)
green=$(tput setf 2)
reset=$(tput sgr0)
toend=$(tput hpa $(tput cols))$(tput cub 6)

clear
sleep 1
echo '###################################################################'
echo ''
echo ' ______ _______ __   _ _______  _____   _____'
echo '|  ____ |______ | \  |    |    |     | |     |'
echo '|_____| |______ |  \_|    |    |_____| |_____|'
echo ''
sleep 1
echo '           _____ __   _ _     _ _     _'
echo '    |        |   | \  | |     |  \___/'
echo '    |_____ __|__ |  \_| |_____| _/   \_'
echo ''
echo ''
sleep 1
TMOUT=10
echo "Добро пожаловать в мастер установки!"
echo "Установка начнется автоматически через $TMOUT секунд."
read enter
if [ -z "$enter" ]
then

fi
   echo '###################################################################'
   
echo ''
echo ''
# Разметка диска
for i in 'Создание разделов диска...'; do printf "$i\r"; done
if [ "$PARTDISK" == "FS" ]
then
        wget http://public.t-brain.ru/conf/fs.conf > /dev/null 2>&1
        PARTDISKSCHEME="fs.conf"
else
        wget http://public.t-brain.ru/conf/lvm.conf > /dev/null 2>&1
        PARTDISKSCHEME="lvm.conf"
fi

while read line
do
parted -sa optimal $DISK1 "$line"   > /dev/null 2>&1
done < $PARTDISKSCHEME
if [ $? -eq 0 ]; then
    echo -n  "${toend}${reset}[${green}OK${reset}]"
else
    echo -n  "${toend}${reset}[${red}fail${reset}]"
    echo 'Произошла критическая ошибка! Продолжение установки невозможно...'
fi
echo -n "${reset}"
echo

# Форматирование разделов
for i in 'Форматирование разделов...'; do printf "$i\r"; done
mkfs.ext4 $DISK1[2]  > /dev/null 2>&1
mkfs.ext4 $DISK1[4]  > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo -n  "${toend}${reset}[${green}OK${reset}]"
else
    echo -n  "${toend}${reset}[${red}fail${reset}]"
fi
echo -n "${reset}"
echo


# Активация раздела подкачки
for i in 'Activating the Swap Partition...'; do printf "$i\r"; done
mkswap $DISK1[3] > /dev/null 2>&1
swapon $DISK1[3] > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo -n  "${toend}${reset}[${green}OK${reset}]"
else
    echo -n  "${toend}${reset}[${red}fail${reset}]"
fi
echo -n "${reset}"
echo

# Монтирование
for i in 'Mounting devices and partitions...'; do printf "$i\r"; done
mount /dev/sda4 /mnt/gentoo > /dev/null 2>&1
mkdir /mnt/gentoo/boot > /dev/null 2>&1
mount /dev/sda2 /mnt/gentoo/boot > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo -n  "${toend}${reset}[${green}OK${reset}]"
else
    echo -n  "${toend}${reset}[${red}fail${reset}]"
fi
echo -n "${reset}"
echo

# Синхронизация времени
for i in 'Time synchronization...'; do printf "$i\r"; done
/usr/sbin/ntpdate -u pool.ntp.org > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo -n  "${toend}${reset}[${green}OK${reset}]"
else
    echo -n  "${toend}${reset}[${red}fail${reset}]"
fi
echo -n "${reset}"
echo

# Загрузка свежего среза системы
for i in 'Downloading the stage tarball'; do printf "$i\r"; done
cd /mnt/gentoo  > /dev/null 2>&1
wget http://mirror.yandex.ru/gentoo-distfiles/releases/amd64/autobuilds/`links -source http://mirror.yandex.ru/gentoo-distfiles/releases/amd64/autobuilds/latest-stage3-amd64.txt | grep stage3 | awk '{print $1}'`  > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo -n  "${toend}${reset}[${green}OK${reset}]"
else
    echo -n  "${toend}${reset}[${red}fail${reset}]"
fi
echo -n "${reset}"
echo

for i in 'Unpacking the stage tarball'; do printf "$i\r"; done
tar xvjpf stage3-*.tar.bz2  > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo -n  "${toend}${reset}[${green}OK${reset}]"
else
    echo -n  "${toend}${reset}[${red}fail${reset}]"
fi
echo -n "${reset}"
echo


# Настройка опции компиляции
for i in 'Configuring compile options...'; do printf "$i\r"; done
echo 'CFLAGS="-march=native -O2 -pipe"' > $MAKECONF > /dev/null 2>&1
echo 'CXXFLAGS="${CFLAGS}"' >> $MAKECONF > /dev/null 2>&1
echo 'CHOST="x86_64-pc-linux-gnu"' >> $MAKECONF > /dev/null 2>&1
echo " " >> $MAKECONF > /dev/null 2>&1
echo 'USE="-ipv6 bindist mmx sse sse2 vim-syntax symlink"' >> $MAKECONF > /dev/null 2>&1
echo " " >> $MAKECONF > /dev/null 2>&1
echo 'PORTDIR="/usr/portage"' >> $MAKECONF > /dev/null 2>&1
echo 'DISTDIR="${PORTDIR}/distfiles"' >> $MAKECONF > /dev/null 2>&1
echo 'PKGDIR="${PORTDIR}/packages"' >> $MAKECONF > /dev/null 2>&1
echo " " >> $MAKECONF > /dev/null 2>&1
echo MAKEOPTS=\"-j$((`cat /proc/cpuinfo | grep processor | wc -l` + 1))\" >> $MAKECONF > /dev/null 2>&1
echo " " >> $MAKECONF > /dev/null 2>&1
echo 'GENTOO_MIRRORS="http://mirror.yandex.ru/gentoo-distfiles/"' >> $MAKECONF > /dev/null 2>&1
echo 'SYNC="rsync://rsync2.ru.gentoo.org/gentoo-portage"' >> $MAKECONF > /dev/null 2>&1
echo " " >> $MAKECONF > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo -n  "${toend}${reset}[${green}OK${reset}]"
else
    echo -n  "${toend}${reset}[${red}fail${reset}]"
fi
echo -n "${reset}"
echo

# Копирование DNS настроек
for i in 'Copy DNS info...'; do printf "$i\r"; done
cp -L /etc/resolv.conf /mnt/gentoo/etc/ > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo -n  "${toend}${reset}[${green}OK${reset}]"
else
    echo -n  "${toend}${reset}[${red}fail${reset}]"
fi
echo -n "${reset}"
echo

# Монтирование необходимых файловых систем
for i in 'Mounting the necessary filesystems...'; do printf "$i\r"; done
mount -t proc proc /mnt/gentoo/proc > /dev/null 2>&1
mount --rbind /sys /mnt/gentoo/sys > /dev/null 2>&1
mount --make-rslave /mnt/gentoo/sys > /dev/null 2>&1
mount --rbind /dev /mnt/gentoo/dev > /dev/null 2>&1
mount --make-rslave /mnt/gentoo/dev > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo -n  "${toend}${reset}[${green}OK${reset}]"
else
    echo -n  "${toend}${reset}[${red}fail${reset}]"
fi
echo -n "${reset}"
echo

# Переход в новое окружение (chroot)
for i in 'Entering the new environment...'; do printf "$i\r"; done
cd /mnt/gentoo/tmp/ > /dev/null 2>&1
wget http://public.t-brain.ru/script/part-2.sh > /dev/null 2>&1
chmod +x ./part-2.sh > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo -n  "${toend}${reset}[${green}OK${reset}]"
else
    echo -n  "${toend}${reset}[${red}fail${reset}]"
fi
echo -n "${reset}"
echo

chroot /mnt/gentoo/ /bin/bash -c /tmp/part-2.sh


# Отмонтирование и перезагрузка
for i in 'Rebooting the system...'; do printf "$i\r"; done
cd > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo -n  "${toend}${reset}[${green}OK${reset}]"
else
    echo -n  "${toend}${reset}[${red}fail${reset}]"
fi
echo -n "${reset}"
echo
reboot

