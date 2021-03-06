#!/bin/sh
#script - gutosie 

KERNEL=`uname -r` 
IMAGE=/media/neoboot/ImageBoot
IMAGENEXTBOOT=/media/neoboot/ImageBoot/.neonextboot
BOXNAME=$( cat /etc/hostname)   

if [ -f /proc/stb/info/vumodel ];  then  
    VUMODEL=$( cat /proc/stb/info/vumodel )     
fi 

if [ -f /proc/stb/info/boxtype ];  then  
    BOXTYPE=$( cat /proc/stb/info/boxtype )    
fi

if [ -f /proc/stb/info/chipset ];  then  
    CHIPSET=$( cat /proc/stb/info/chipset )    
fi

if [ -f /tmp/zImage.ipk ];  then  
    rm -f /tmp/zImage.ipk    
fi

if [ -f /tmp/zImage ];  then  
    rm -f /tmp/zImage    
fi

if [ -f $IMAGENEXTBOOT ]; then
  TARGET=`cat $IMAGENEXTBOOT`
else
  TARGET=Flash              
fi
                   
if [ $TARGET = "Flash" ]; then                    
                if [ -e /.multinfo ]; then                                                
                        if [ $VUMODEL = "solo2" ] || [ $VUMODEL = "duo2" ] || [ $VUMODEL = "solose" ] || [ $VUMODEL = "zero" ]; then 
                            if [ -f /proc/stb/info/vumodel ] || [ ! -e /proc/stb/info/boxtype ] ; then
                                if [ -e /media/neoboot/ImagesUpload/.kernel/vmlinux.gz ] ; then
                                    echo "Kasowanie kernel z /dev/mtd2..."                                    
                                    flash_eraseall /dev/mtd2 
                                    sleep 2 
                                    echo "Instalacja kernel do /dev/mtd2..."                
		                    nandwrite -p /dev/mtd2 //media/neoboot/ImagesUpload/.kernel/vmlinux.gz 
                                    update-alternatives --remove vmlinux vmlinux-$KERNEL || true
                                fi
                                if [ -e /media/neoboot/ImagesUpload/.kernel/zImage.$VUMODEL.ipk ] ; then
                                    echo "Przenoszenie pliku kernel do /tmp..."
                                    sleep 2
                                    cp -fR /media/neoboot/ImagesUpload/.kernel/zImage.$VUMODEL.ipk /tmp/zImage.ipk  
                                    echo "Instalacja kernel do /dev/mtd2..."                                 
                                    opkg install --force-reinstall --force-overwrite --force-downgrade --nodeps /tmp/zImage.ipk

                                fi                            
                        fi
                        update-alternatives --remove vmlinux vmlinux-`uname -r` || true                                          
                        echo "NEOBOOT is booting image from " $TARGET
                        echo "Used Kernel: " $TARGET > /media/neoboot/ImagesUpload/.kernel/used_flash_kernel                          

                elif [ ! -e /.multinfo ]; then
                            if [ -f /proc/stb/info/vumodel ] || [ ! -e /proc/stb/info/boxtype ]; then 
                                if [ $VUMODEL = "solo2" ] || [ $VUMODEL = "duo2" ] || [ $VUMODEL = "solose" ] || [ $VUMODEL = "zero" ]; then 
                                    if [ -e /media/neoboot/ImagesUpload/.kernel/vmlinux.gz ] ; then
                                        echo "Kasowanie kernel z /dev/mtd2..."
                                        sleep 2                                
                                        flash_eraseall /dev/mtd2   
                                        echo "Wgrywanie kernel do /dev/mtd2..."
                                        sleep 2                                                    
		                        nandwrite -p /dev/mtd2 //media/neoboot/ImagesUpload/.kernel/vmlinux.gz 
                                        update-alternatives --remove vmlinux vmlinux-$KERNEL || true
                                    fi
                                    if [ -e /media/neoboot/ImagesUpload/.kernel/zImage.$VUMODEL.ipk ] ; then
                                        echo "Przenoszenie pliku kernel do /tmp..."
                                        sleep 2                                 
                                        cp -fR /media/neoboot/ImagesUpload/.kernel/zImage.$VUMODEL.ipk /tmp/zImage.ipk   
                                        echo "Instalacja kernel zImage.ipk..."                                                                      
                                        opkg install --force-reinstall --force-overwrite --force-downgrade --nodeps /tmp/zImage.ipk
                                    fi

                                fi                                
                            fi                            
                            update-alternatives --remove vmlinux vmlinux-`uname -r` || true
                            echo "Used Kernel: " $TARGET > /media/neoboot/ImagesUpload/.kernel/used_flash_kernel
                            echo " NEOBOOT - zainstalowano kernel-image - " $TARGET  "Za chwile nastapi restart systemu !!!"
                        fi 
                fi
                sleep 5 ; reboot -d -f -h -i
else              	    
    if [ $TARGET != "Flash" ]; then 
        if [ -f /proc/stb/info/vumodel ] || [ ! -e /proc/stb/info/boxtype ] ; then
            if [ $VUMODEL = "solo2" ] || [ $VUMODEL = "duo2" ] || [ $VUMODEL = "solose" ] || [ $VUMODEL = "zero" ]; then 	     
                        if [ -e /.multinfo ] ; then
                                INFOBOOT=$( cat /.multinfo )
                                if [ $TARGET = $INFOBOOT ] ; then
                                    echo "NEOBOOT is booting image from " $TARGET                                    
                                else                                  
                                    echo "Przenoszenie pliku kernel do /tmp"
                                    sleep 2
                                    cp -f $IMAGE/$TARGET/boot/$VUMODEL.vmlinux.gz /tmp/vmlinux.gz 
                                    echo "Kasowanie kernel z /dev/mtd2"
                                    sleep 2 
                                    flash_eraseall /dev/mtd2
                                    echo "Wgrywanie kernel do /dev/mtd2"                                    
                                    sleep 2
		                    nandwrite -p /dev/mtd2 //tmp/vmlinux.gz 
		                    rm -f //tmp/vmlinux.gz
                                    update-alternatives --remove vmlinux vmlinux-`uname -r` || true
                                    echo "Kernel dla potrzeb startu systemu " $TARGET " z procesorem mips zostal zmieniony!!!"
                                    echo "Used Kernel: " $TARGET   > /media/neoboot/ImagesUpload/.kernel/used_flash_kernel
                                    echo "Typ procesora: " $CHIPSET " STB" 
                                fi
                        else
                                    echo "Przenoszenie pliku kernel do /tmp"
                                    sleep 2
                                    cp -f $IMAGE/$TARGET/boot/$VUMODEL.vmlinux.gz /tmp/vmlinux.gz
                                    echo "Kasowanie kernel z /dev/mtd2"
                                    sleep 2                                    
                                    flash_eraseall /dev/mtd2 
                                    echo "Wgrywanie kernel do /dev/mtd2"                                    
                                    sleep 2                                                                       
		                    nandwrite -p /dev/mtd2 /tmp/vmlinux.gz 
		                    rm -f /tmp/vmlinux.gz
                                    update-alternatives --remove vmlinux vmlinux-`uname -r` || true
                                    echo "Kernel dla potrzeb startu systemu " $TARGET " z procesorem mips zostal zmieniony!!!"
                                    echo "Used Kernel: " $TARGET   > /media/neoboot/ImagesUpload/.kernel/used_flash_kernel
                                    echo "Typ procesora: " $CHIPSET " STB"
                        fi                    
                        sleep 5; reboot -d -f -h -i
            fi
        fi
    fi                               
fi
exit 0
