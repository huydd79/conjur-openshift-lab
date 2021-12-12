#/bin/sh
source 00.config.sh

if [[ "$READY" != true ]]; then
    echo "Your configuration are not ready. Set READY=true in 00.config.sh when you are done"
    exit
fi

set -x
cd $UPLOAD_DIR
crc_dir=$(tar xvf $crc_zip_file | head -n 1)

mv $UPLOAD_DIR/$crc_dir/crc /usr/local/bin/crc
echo "Creating crcuser for crc start up and operation"
useradd crcuser
passwd  crcuser
usermod -aG wheel crcuser
usermod -aG docker crcuser

set +x