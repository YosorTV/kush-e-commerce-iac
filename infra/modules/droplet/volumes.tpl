mkdir -p ${MOUNTPOINT}
mount -L ${LABEL}
grep -q ${LABEL} /etc/fstab || printf 'LABEL=${LABEL}  ${MOUNTPOINT}    ${FS_TYPE}    defaults 0 0\n' >> /etc/fstab
