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
#undef NET_PROTO_STP
#undef NET_PROTO_LACP
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
#undef IBMGMT_CMD
#undef FCMGMT_CMD
#undef LOGIN_CMD
#undef NVO_CMD
#undef SYNC_CMD
#undef SHELL_CMD
#undef CONFIG_CMD
#undef DOWNLOAD_PROTO_HTTP
#undef ROUTE_CMD
#undef IMAGE_CMD
#undef DHCP_CMD
#undef SANBOOT_CMD
#undef DNS_RESOLVER
#undef IMAGE_PNG
#undef IMAGE_DER
#undef IMAGE_PEM
#undef HTTP_AUTH_BASIC
#undef HTTP_AUTH_DIGEST
#undef IFMGMT_CMD
#undef VNIC_IPOIB

/* Ensure ROM banner is not displayed */

#undef ROM_BANNER_TIMEOUT
#define ROM_BANNER_TIMEOUT 0
