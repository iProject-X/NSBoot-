/* Disabled from config/defaults/pcbios.h */

#undef SANBOOT_PROTO_ISCSI
#undef SANBOOT_PROTO_AOE
#undef SANBOOT_PROTO_IB_SRP
#undef SANBOOT_PROTO_FCP

/* Disabled from config/general.h */

#undef CRYPTO_80211_WEP
#undef CRYPTO_80211_WPA
#undef CRYPTO_80211_WPA2
#undef IWMGMT_CMD
#undef MENU_CMD

/* Disable unused protocols and commands to reduce ROM size below 56KB */

#undef NET_PROTO_IPV6
#undef DOWNLOAD_PROTO_HTTPS
#undef DOWNLOAD_PROTO_FTP
#undef DOWNLOAD_PROTO_SLAM
#undef DOWNLOAD_PROTO_NFS
#undef REBOOT_CMD
#undef POWEROFF_CMD
#undef IMAGE_SCRIPT
#undef PCI_CMD
#undef NEIGHBOUR_CMD
#undef VLAN_CMD
#undef DIGEST_CMD
#undef LOTEST_CMD
#undef NSTAT_CMD
#undef IOAPI_X86

/* Ensure ROM banner is not displayed */

#undef ROM_BANNER_TIMEOUT
#define ROM_BANNER_TIMEOUT 0
