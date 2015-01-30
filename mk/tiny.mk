RELEASE ?= debian/$(shell lsb_release -s -c)

CDROOT ?= gfxboot-turnkey
HOSTNAME ?= $(shell basename $(shell pwd))

CONF_VARS += HOSTNAME ROOT_PASS NONFREE
# these are needed to control styling of credits (e.g., conf/apache-credit)
CONF_VARS += CREDIT_STYLE CREDIT_STYLE_EXTRA CREDIT_ANCHORTEXT CREDIT_LOCATION
# tiny specials
CONF_VARS += DNS_NAMESERVERS

COMMON_OVERLAYS := tiny.d $(COMMON_OVERLAYS)
COMMON_CONF := tiny.d $(COMMON_CONF)
COMMON_REMOVELISTS += turnkey

FAB_SHARE_PATH ?= /usr/share/fab

DNS_NAMESERVERS ?= "8.8.8.8 8.8.4.4"

# below hacks allow inheritors to define their own hooks, which will be
# prepended. warning: first line *needs* to be empty for this to work

# setup apt and dns for root.build
define _bootstrap/post

	fab-apply-overlay $(COMMON_OVERLAYS_PATH)/turnkey.d/apt $O/bootstrap;
	fab-chroot $O/bootstrap --script $(COMMON_CONF_PATH)/turnkey.d/apt;
    for server in $$(echo $(DNS_NAMESERVERS) | tr " " "\n"); do \
		fab-chroot $O/bootstrap "echo nameserver $$server >> /etc/resolv.conf"; \
	done;
endef
bootstrap/post += $(_bootstrap/post)

# tag package management system with release package
# set /etc/turnkey_version and apt user-agent
define _root.patched/post
	
	# 
	# tagging package management system with release package
	# setting /etc/turnkey_version and apt user-agent
	#
	@if [ -f $(FAB_PATH)/products/core/changelog ]; then \
		echo $(FAB_SHARE_PATH)/make-release-deb.py $(FAB_PATH)/products/core/changelog $O/root.patched; \
		$(FAB_SHARE_PATH)/make-release-deb.py $(FAB_PATH)/products/core/changelog $O/root.patched; \
	fi
	@if [ -f ./changelog ]; then \
		echo $(FAB_SHARE_PATH)/make-release-deb.py ./changelog $O/root.patched; \
		$(FAB_SHARE_PATH)/make-release-deb.py ./changelog $O/root.patched; \
		turnkey_version=$$($(FAB_SHARE_PATH)/turnkey-version.py --dist=$(CODENAME) --tag=$(VERSION_TAG) ./changelog $(FAB_ARCH)); \
		turnkey_aptconf="Acquire::http::User-Agent \"TurnKey APT-HTTP/1.3 ($$turnkey_version)\";"; \
		echo $$turnkey_version > $O/root.patched/etc/turnkey_version; \
		echo $$turnkey_aptconf > $O/root.patched/etc/apt/apt.conf.d/01turnkey; \
	else \
		echo; \
		echo "WARNING: can't tag local release (./changelog doesn't exist)"; \
		echo; \
	fi

	fab-chroot $O/root.patched "dpkg -i *.deb && rm *.deb && rm -f /var/log/dpkg.log"

	fab-chroot $O/root.patched "which insserv >/dev/null && insserv"
	fab-chroot $O/root.patched "which postsuper >/dev/null && postsuper -d ALL || true"
endef
root.patched/post += $(_root.patched/post)

include $(FAB_SHARE_PATH)/product.mk

