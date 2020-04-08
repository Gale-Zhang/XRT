#! /bin/bash --

# This configure file is used by src/runtime_src/tools/scripts/peta_build.sh
# You could override below functions in this configure script
#	config_peta     -- configure petalinux project.
#	config_kernel   -- configure linux kernel.
#	config_rootfs   -- configure rootfs.
#	config_dts      -- configure system user device tree.
#	install_recipes -- install recipes to petalinux.
#	rootfs_menu     -- update rootfsconfig to add package.
#	pre_build_hook  -- just before petalinux-build.
#	post_build_hook -- just after petalinux-build.

THIS_CONFIG_SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# PetaLinux template. Default is zynqMP
TEMPLATE=zynqMP

# peta_build.sh will set XRT_REPO_DIR pointed to the XRT repository.
# This would be helpful when you want to use some resources in XRT repo

# The first argument is the petalinux configure file
#  config_peta <petalinux_project>/project-spec/configs/config
#
config_peta()
{
	PETA_CONFIG_FILE=$1
    echo "CONFIG_SUBSYSTEM_MACHINE_NAME=\"zcu106-reva\"" >> $PETA_CONFIG_FILE
	# echo "CONFIG_YOCTO_ENABLE_DEBUG_TWEAKS=y" >> $PETA_CONFIG_FILE
	echo "CONFIG_SUBSYSTEM_REMOVE_PL_DTB=y" >> $PETA_CONFIG_FILE
	echo "CONFIG_YOCTO_LOCAL_SSTATE_FEEDS_URL=\"~/Xilinx/PetaLinux/sstate_aarch64_2019.2/aarch64\"" >> $PETA_CONFIG_FILE
	echo "CONFIG_PRE_MIRROR_URL=\"file://~/Xilinx/PetaLinux/downloads\"" >> $PETA_CONFIG_FILE
}

# The first argument is the linux kernel configure file
#  config_kernel recipes-kernel/linux/linux-xlnx/user.cfg
#
config_kernel()
{
	KERN_CONFIG_FILE=$1

	sed -i '/^# CONFIG_/d' $ROOTFSCONFIG
	sed -i '/^CONFIG_/d' $ROOTFSCONFIG

	# *** Enable or disable Linux kernel features as you need ***
	# AR# 69143 -- To avoid PetaLinux hang when JTAG connected.
	echo '# CONFIG_CPU_IDLE is not set' >> $KERN_CONFIG_FILE
	echo 'CONFIG_CONSOLE_LOGLEVEL_DEFAULT=1' >> $KERN_CONFIG_FILE
}

# The first argument is the rootfs configure file
#  config_rootfs project-spec/configs/rootfs_config
#
config_rootfs()
{
	ROOTFS_CONFIG_FILE=$1

	echo 'CONFIG_xrt=y'                                     >> $ROOTFS_CONFIG_FILE
	echo 'CONFIG_mnt-sd=y'                                  >> $ROOTFS_CONFIG_FILE
	echo 'CONFIG_xrt-dev=y'                                 >> $ROOTFS_CONFIG_FILE
	echo 'CONFIG_zocl=y'                                    >> $ROOTFS_CONFIG_FILE
	echo 'CONFIG_opencl-headers-dev=y'                      >> $ROOTFS_CONFIG_FILE
	echo 'CONFIG_opencl-clhpp-dev=y'                        >> $ROOTFS_CONFIG_FILE

	echo 'CONFIG_vim=y'                                     >> $ROOTFS_CONFIG_FILE
	echo 'CONFIG_file=y'                                    >> $ROOTFS_CONFIG_FILE
	echo 'CONFIG_unzip=y'                                   >> $ROOTFS_CONFIG_FILE

	echo 'CONFIG_ffmpeg=y'                                  >> $ROOTFS_CONFIG_FILE
	echo 'CONFIG_ffmpeg-dev=y'                              >> $ROOTFS_CONFIG_FILE

	echo 'CONFIG_v4l-utils=y'                               >> $ROOTFS_CONFIG_FILE
	echo 'CONFIG_libv4l=y'                                  >> $ROOTFS_CONFIG_FILE
	echo 'CONFIG_media-ctl=y'                               >> $ROOTFS_CONFIG_FILE

	echo 'CONFIG_gstreamer-vcu-examples=y'                  >> $ROOTFS_CONFIG_FILE
	echo 'CONFIG_gstreamer-vcu-notebooks=y'                 >> $ROOTFS_CONFIG_FILE
	echo 'CONFIG_gst-shark=y'                               >> $ROOTFS_CONFIG_FILE

	echo 'CONFIG_packagegroup-petalinux-opencv=y'           >> $ROOTFS_CONFIG_FILE
	echo 'CONFIG_packagegroup-petalinux-opencv-dev=y'       >> $ROOTFS_CONFIG_FILE
	echo 'CONFIG_packagegroup-petalinux-gstreamer=y'        >> $ROOTFS_CONFIG_FILE
	echo 'CONFIG_packagegroup-petalinux-gstreamer-dev=y'    >> $ROOTFS_CONFIG_FILE
	echo 'CONFIG_packagegroup-petalinux-v4lutils=y'         >> $ROOTFS_CONFIG_FILE
	echo 'CONFIG_packagegroup-petalinux-v4lutils-dev=y'     >> $ROOTFS_CONFIG_FILE
}

# The first argument is the rootfs configure file
#  config_dts recipes-bsp/device-tree/files/system-user.dtsi
#
config_dts()
{
	DTS_FILE=$1
	#GLOB_DTS=${XRT_REPO_DIR}/src/runtime_src/core/edge/fragments/xlnk_dts_fragment_mpsoc.dts
	#echo "cat ${XRT_REPO_DIR}/src/runtime_src/core/edge/fragments/xlnk_dts_fragment_mpsoc.dts >> recipes-bsp/device-tree/files/system-user.dtsi"
	#cat ${XRT_REPO_DIR}/src/runtime_src/core/edge/fragments/xlnk_dts_fragment_mpsoc.dts >> recipes-bsp/device-tree/files/system-user.dtsi
	echo "cat ${THIS_CONFIG_SCRIPT_DIR}/zcu106vcu_base.dts >> $DTS_FILE"
	cat ${THIS_CONFIG_SCRIPT_DIR}/zcu106vcu_base.dts >> $DTS_FILE
}

# The first argument is the rootfs configure file
#install_recipes ${PETALINUX_NAME}/project-spec/meta-user/
#
#install_recipes()
#{
#	META_USER_PATH=$1
#	cp -r ${XRT_REPO_DIR}/src/platform/recipes-xrt $META_USER_PATH
#	cp -r ${XRT_REPO_DIR}/src/platform/mnt-sd ${META_USER_PATH}/recipes-apps/
#	# if you are using petalinux 2018.3 or earlier, you will need to copy opencl-headers_git.bb from openembedded repo.
#}

# The first argument is the rootfsconfig file
#  rootfs_menu conf/user-rootfsconfig
#
rootfs_menu()
{
	ROOTFSCONFIG=$1
	sed -i '/^CONFIG_/d' $ROOTFSCONFIG

	echo 'CONFIG_xrt'                                       >> $ROOTFSCONFIG
	echo 'CONFIG_mnt-sd'                                    >> $ROOTFSCONFIG
	echo 'CONFIG_xrt-dev'                                   >> $ROOTFSCONFIG
	echo 'CONFIG_zocl'                                      >> $ROOTFSCONFIG
	echo 'CONFIG_opencl-clhpp-dev'                          >> $ROOTFSCONFIG
	echo 'CONFIG_opencl-headers-dev'                        >> $ROOTFSCONFIG

	echo 'CONFIG_vim'                                       >> $ROOTFSCONFIG
	echo 'CONFIG_file'                                      >> $ROOTFSCONFIG
	echo 'CONFIG_unzip'                                     >> $ROOTFSCONFIG

	echo 'CONFIG_ffmpeg'                                    >> $ROOTFSCONFIG
	echo 'CONFIG_ffmpeg-dev'                                >> $ROOTFSCONFIG

	echo 'CONFIG_v4l-utils'                                 >> $ROOTFSCONFIG
	echo 'CONFIG_libv4l'                                    >> $ROOTFSCONFIG
	echo 'CONFIG_media-ctl'                                 >> $ROOTFSCONFIG

	echo 'CONFIG_gstreamer-vcu-examples'                    >> $ROOTFSCONFIG
	echo 'CONFIG_gstreamer-vcu-notebooks'                   >> $ROOTFSCONFIG
	echo 'CONFIG_gst-shark'                                 >> $ROOTFSCONFIG

	echo 'CONFIG_packagegroup-petalinux-opencv'             >> $ROOTFSCONFIG
	echo 'CONFIG_packagegroup-petalinux-opencv-dev'         >> $ROOTFSCONFIG
	echo 'CONFIG_packagegroup-petalinux-gstreamer'          >> $ROOTFSCONFIG
	echo 'CONFIG_packagegroup-petalinux-gstreamer-dev'      >> $ROOTFSCONFIG
	echo 'CONFIG_packagegroup-petalinux-v4lutils'           >> $ROOTFSCONFIG
	echo 'CONFIG_packagegroup-petalinux-v4lutils-dev'       >> $ROOTFSCONFIG
}

# The first argument is the petalinux project path
#  pre_build_hook <PETALINUX_PROJECT_DIR>
#
pre_build_hook()
{
	PETA_DIR=$1
	# Replace the original pl.dtsi. Remove axi intc IP.
	cp -f ${THIS_CONFIG_SCRIPT_DIR}/pl.dtsi ${PETA_DIR}/components/plnx_workspace/device-tree/device-tree/pl.dtsi
	cp -f ${THIS_CONFIG_SCRIPT_DIR}/device-tree.mss ${PETA_DIR}/components/plnx_workspace/device-tree/device-tree/device-tree.mss
	# Remove u-boot 128MB image size limited
	echo '/* TRD customizations */' >> ${PETA_DIR}/project-spec/meta-user/recipes-bsp/u-boot/files/platform-top.h
	echo '#undef CONFIG_SYS_BOOTMAPSZ' >> ${PETA_DIR}/project-spec/meta-user/recipes-bsp/u-boot/files/platform-top.h
	echo '#undef CONFIG_PREBOOT' >> ${PETA_DIR}/project-spec/meta-user/recipes-bsp/u-boot/files/platform-top.h
}

# The first argument is the petalinux project path
#  post_build_hook <PETALINUX_PROJECT_DIR>
#
#post_build_hook()
#{
#	PETA_DIR=$1
#	# Nothing needs to do
#}

