FROM ubuntu:14.04.2

RUN apt-get update && \
    apt-get -q -y install bc curl xz-utils build-essential p7zip-full syslinux xorriso && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

ENV SRCDIR /usr/src
WORKDIR ${SRCDIR}

ENV KERNEL_VERSION 4.0.9
COPY linux-${KERNEL_VERSION}.tar.xz ${SRCDIR}/
RUN tar xJf linux-${KERNEL_VERSION}.tar.xz

COPY kernel.config ${SRCDIR}/linux-${KERNEL_VERSION}/.config
RUN cd ${SRCDIR}/linux-${KERNEL_VERSION} && \
    make oldconfig && \
    make prepare && make scripts && \
    make headers_install INSTALL_HDR_PATH=${SRCDIR}

ENV VBOX_VERSION 5.0.0
RUN mkdir -p /vboxguest
COPY vboxguest.iso /vboxguest/
RUN cd /vboxguest && \
    7z x vboxguest.iso -ir'!VBoxLinuxAdditions.run' && \
    sh VBoxLinuxAdditions.run --noexec --target . && \
    mkdir -p amd64 && tar -C amd64 -xjf VBoxGuestAdditions-amd64.tar.bz2 && \
    rm -rf amd64/src/vboxguest-${VBOX_VERSION}/vboxvideo && \
    KERN_DIR=${SRCDIR}/linux-${KERNEL_VERSION} KERN_INCL=${SRCDIR}/include \
        make -C amd64/src/vboxguest-${VBOX_VERSION}

COPY rootfs.tar.xz ${SRCDIR}/
RUN mkdir -p root && \
    tar xJf /usr/src/rootfs.tar.xz -C root

RUN cp /vboxguest/amd64/lib/VBoxGuestAdditions/mount.vboxsf root/sbin/ && \
    cp /vboxguest/amd64/src/vboxguest-${VBOX_VERSION}/*.ko root/lib/modules/${KERNEL_VERSION}-docker-root/ && \
    depmod -a -b /usr/src/root ${KERNEL_VERSION}-docker-root

ENV ISO /iso

RUN mkdir -p ${ISO}/boot && \
    cd root && find | cpio -H newc -o | lzma -c > ${ISO}/boot/initrd

COPY bzImage ${ISO}/boot/

RUN mkdir -p ${ISO}/boot/isolinux && \
    cp /usr/lib/syslinux/isolinux.bin ${ISO}/boot/isolinux/ && \
    cp /usr/lib/syslinux/linux.c32 ${ISO}/boot/isolinux/ldlinux.c32

COPY assets/isolinux.cfg ${ISO}/boot/isolinux/

# Copied from boot2docker, thanks.
RUN cd ${ISO} && \
    xorriso \
      -publisher "A.I. <ailis@paw.zone>" \
      -as mkisofs \
      -l -J -R -V "DOCKER_ROOT" \
      -no-emul-boot -boot-load-size 4 -boot-info-table \
      -b boot/isolinux/isolinux.bin -c boot/isolinux/boot.cat \
      -isohybrid-mbr /usr/lib/syslinux/isohdpfx.bin \
      -no-pad -o /docker-root.iso $(pwd)

CMD ["cat", "/docker-root.iso"]