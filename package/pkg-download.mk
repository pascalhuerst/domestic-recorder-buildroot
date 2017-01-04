################################################################################
#
# This file contains the download helpers for the various package
# infrastructures. It is used to handle downloads from HTTP servers,
# FTP servers, Git repositories, Subversion repositories, Mercurial
# repositories, Bazaar repositories, and SCP servers.
#
################################################################################

# Download method commands
export WGET := $(call qstrip,$(BR2_WGET))
export SVN := $(call qstrip,$(BR2_SVN))
export CVS := $(call qstrip,$(BR2_CVS))
export BZR := $(call qstrip,$(BR2_BZR))
export GIT := $(call qstrip,$(BR2_GIT))
export HG := $(call qstrip,$(BR2_HG))
export SCP := $(call qstrip,$(BR2_SCP))
SSH := $(call qstrip,$(BR2_SSH))
export LOCALFILES := $(call qstrip,$(BR2_LOCALFILES))
ARTIFACTORY_CLI := $(shell command type -p $(call qstrip,$(BR2_ARTIFACTORY_CLI)))

DL_WRAPPER = support/download/dl-wrapper

# DL_DIR may have been set already from the environment
ifeq ($(origin DL_DIR),undefined)
DL_DIR ?= $(call qstrip,$(BR2_DL_DIR))
ifeq ($(DL_DIR),)
DL_DIR := $(TOPDIR)/dl
endif
else
# Restore the BR2_DL_DIR that was overridden by the .config file
BR2_DL_DIR = $(DL_DIR)
endif

# ensure it exists and a absolute path
DL_DIR := $(shell mkdir -p $(DL_DIR) && cd $(DL_DIR) >/dev/null && pwd)

#
# URI scheme helper functions
# Example URIs:
# * http://www.example.com/dir/file
# * scp://www.example.com:dir/file (with domainseparator :)
#
# geturischeme: http
geturischeme = $(firstword $(subst ://, ,$(call qstrip,$(1))))
# stripurischeme: www.example.com/dir/file
stripurischeme = $(lastword $(subst ://, ,$(call qstrip,$(1))))
# domain: www.example.com
domain = $(firstword $(subst $(call domainseparator,$(2)), ,$(call stripurischeme,$(1))))
# notdomain: dir/file
notdomain = $(patsubst $(call domain,$(1),$(2))$(call domainseparator,$(2))%,%,$(call stripurischeme,$(1)))
#
# default domainseparator is /, specify alternative value as first argument
domainseparator = $(if $(1),$(1),/)

# github(user,package,version): returns site of GitHub repository
github = https://github.com/$(1)/$(2)/archive/$(3)

# Expressly do not check hashes for those files
# Exported variables default to immediately expanded in some versions of
# make, but we need it to be recursively-epxanded, so explicitly assign it.
export BR_NO_CHECK_HASH_FOR =

################################################################################
# The DOWNLOAD_* helpers are in charge of getting a working copy
# of the source repository for their corresponding SCM,
# checking out the requested version / commit / tag, and create an
# archive out of it. DOWNLOAD_SCP uses scp to obtain a remote file with
# ssh authentication. DOWNLOAD_WGET is the normal wget-based download
# mechanism.
#
# The SOURCE_CHECK_* helpers are in charge of simply checking that the source
# is available for download. This can be used to make sure one will be able
# to get all the sources needed for one's build configuration.
################################################################################

define DOWNLOAD_GIT
	$(EXTRA_ENV) $(DL_WRAPPER) -b git \
		-o $(DL_DIR)/$($(PKG)_SOURCE) \
		$(if $($(PKG)_GIT_SUBMODULES),-r) \
		$(QUIET) \
		-- \
		$($(PKG)_SITE) \
		$($(PKG)_DL_VERSION) \
		$($(PKG)_RAW_BASE_NAME) \
		$($(PKG)_DL_OPTS)
endef

# TODO: improve to check that the given PKG_DL_VERSION exists on the remote
# repository
define SOURCE_CHECK_GIT
	$(GIT) ls-remote --heads $($(PKG)_SITE) > /dev/null
endef

define DOWNLOAD_BZR
	$(EXTRA_ENV) $(DL_WRAPPER) -b bzr \
		-o $(DL_DIR)/$($(PKG)_SOURCE) \
		$(QUIET) \
		-- \
		$($(PKG)_SITE) \
		$($(PKG)_DL_VERSION) \
		$($(PKG)_RAW_BASE_NAME) \
		$($(PKG)_DL_OPTS)
endef

define SOURCE_CHECK_BZR
	$(BZR) ls --quiet $($(PKG)_SITE) > /dev/null
endef

define DOWNLOAD_CVS
	$(EXTRA_ENV) $(DL_WRAPPER) -b cvs \
		-o $(DL_DIR)/$($(PKG)_SOURCE) \
		$(QUIET) \
		-- \
		$(call stripurischeme,$(call qstrip,$($(PKG)_SITE))) \
		$($(PKG)_DL_VERSION) \
		$($(PKG)_RAWNAME) \
		$($(PKG)_RAW_BASE_NAME) \
		$($(PKG)_DL_OPTS)
endef

# Not all CVS servers support ls/rls, use login to see if we can connect
define SOURCE_CHECK_CVS
	$(CVS) -d:pserver:anonymous:@$(call stripurischeme,$(call qstrip,$($(PKG)_SITE))) login
endef

define DOWNLOAD_SVN
	$(EXTRA_ENV) $(DL_WRAPPER) -b svn \
		-o $(DL_DIR)/$($(PKG)_SOURCE) \
		$(QUIET) \
		-- \
		$($(PKG)_SITE) \
		$($(PKG)_DL_VERSION) \
		$($(PKG)_RAW_BASE_NAME) \
		$($(PKG)_DL_OPTS)
endef

define SOURCE_CHECK_SVN
	$(SVN) ls $($(PKG)_SITE)@$($(PKG)_DL_VERSION) > /dev/null
endef

# SCP URIs should be of the form scp://[user@]host:filepath
# Note that filepath is relative to the user's home directory, so you may want
# to prepend the path with a slash: scp://[user@]host:/absolutepath
define DOWNLOAD_SCP
	$(EXTRA_ENV) $(DL_WRAPPER) -b scp \
		-o $(DL_DIR)/$(2) \
		-H $(PKGDIR)/$($(PKG)_RAWNAME).hash \
		$(QUIET) \
		-- \
		'$(call stripurischeme,$(call qstrip,$(1)))' \
		$($(PKG)_DL_OPTS)
endef

define SOURCE_CHECK_SCP
	$(SSH) $(call domain,$(1),:) ls '$(call notdomain,$(1),:)' > /dev/null
endef

define DOWNLOAD_HG
	$(EXTRA_ENV) $(DL_WRAPPER) -b hg \
		-o $(DL_DIR)/$($(PKG)_SOURCE) \
		$(QUIET) \
		-- \
		$($(PKG)_SITE) \
		$($(PKG)_DL_VERSION) \
		$($(PKG)_RAW_BASE_NAME) \
		$($(PKG)_DL_OPTS)
endef

# TODO: improve to check that the given PKG_DL_VERSION exists on the remote
# repository
define SOURCE_CHECK_HG
	$(HG) incoming --force -l1 $($(PKG)_SITE) > /dev/null
endef

define DOWNLOAD_WGET
	$(EXTRA_ENV) $(DL_WRAPPER) -b wget \
		-o $(DL_DIR)/$(2) \
		-H $(PKGDIR)/$($(PKG)_RAWNAME).hash \
		$(QUIET) \
		-- \
		'$(call qstrip,$(1))' \
		$($(PKG)_DL_OPTS)
endef

define SOURCE_CHECK_WGET
	$(WGET) --spider '$(call qstrip,$(1))'
endef

define DOWNLOAD_LOCALFILES
	$(EXTRA_ENV) $(DL_WRAPPER) -b cp \
		-o $(DL_DIR)/$(2) \
		-H $(PKGDIR)/$($(PKG)_RAWNAME).hash \
		$(QUIET) \
		-- \
		$(call stripurischeme,$(call qstrip,$(1))) \
		$($(PKG)_DL_OPTS)
endef

define SOURCE_CHECK_LOCALFILES
	test -e $(call stripurischeme,$(call qstrip,$(1)))
endef

################################################################################
# DOWNLOAD -- Download helper. Will try to download source from:
# 1) BR2_PRIMARY_SITE if enabled
# 2) Download site, unless BR2_PRIMARY_SITE_ONLY is set
# 3) BR2_BACKUP_SITE if enabled, unless BR2_PRIMARY_SITE_ONLY is set
#
# Argument 1 is the source location
#
# E.G. use like this:
# $(call DOWNLOAD,$(FOO_SITE))
#
# For PRIMARY and BACKUP site, any ? in the URL is replaced by %3F. A ? in
# the URL is used to separate query arguments, but the PRIMARY and BACKUP
# sites serve just plain files.
################################################################################

define DOWNLOAD
	$(call DOWNLOAD_INNER,$(1),$(notdir $(1)),DOWNLOAD)
endef

define SOURCE_CHECK
	$(call DOWNLOAD_INNER,$(1),$(notdir $(1)),SOURCE_CHECK)
endef

define DOWNLOAD_INNER
	$(Q)if test -n "$(call qstrip,$(BR2_ARTIFACTORY_URL))" ; then \
		$(call $(3)_WGET,$(BR2_ARTIFACTORY_URL)$(BR2_ARTIFACTORY_REPO)/$($(PKG)_RAWNAME)/$($(PKG)_VERSION)/$(2),$(2)) ; \
		DOWNLOAD_FETCH_FAILED=$$? ; \
		if test $$DOWNLOAD_FETCH_FAILED -eq 0 ; then \
			echo " - Downloaded $(2) from artifactory" ; \
			exit ; \
		else \
			echo " - Failed to find $(2) on artifactory" ; \
		fi ; \
	fi ; \
	$(if $(filter bzr cvs git hg svn,$($(PKG)_SITE_METHOD)),export BR_NO_CHECK_HASH_FOR=$(2);) \
	if test -n "$(call qstrip,$(BR2_PRIMARY_SITE))" ; then \
		case "$(call geturischeme,$(BR2_PRIMARY_SITE))" in \
			file) $(call $(3)_LOCALFILES,$(BR2_PRIMARY_SITE)/$(2),$(2)) ;; \
			scp) $(call $(3)_SCP,$(BR2_PRIMARY_SITE)/$(2),$(2)) ;; \
			*) $(call $(3)_WGET,$(BR2_PRIMARY_SITE)/$(subst ?,%3F,$(2)),$(2)) ;; \
		esac ; \
		DOWNLOAD_FETCH_FAILED=$$? ; \
	fi ; \
	if test $$DOWNLOAD_FETCH_FAILED -eq 0 ; then \
		echo " - Downloaded from PRIMARY SITE ($(BR2_PRIMARY_SITE))" ; \
	else \
		echo " - Failed to find on PRIMARY SITE ($(BR2_PRIMARY_SITE))" ; \
		if test -n "$(1)" ; then \
			case "$($(PKG)_SITE_METHOD)" in \
				git) $($(3)_GIT) ;; \
				svn) $($(3)_SVN) ;; \
				cvs) $($(3)_CVS) ;; \
				bzr) $($(3)_BZR) ;; \
				file) $($(3)_LOCALFILES) ;; \
				scp) $($(3)_SCP) ;; \
				hg) $($(3)_HG) ;; \
				*) $(call $(3)_WGET,$(1),$(2)) ;; \
			esac ; \
			DOWNLOAD_FETCH_FAILED=$$? ; \
			if test $$DOWNLOAD_FETCH_FAILED -eq 0 ; then \
				echo " - Downloaded from PKG's SITE" ; \
			else \
				echo " - Failed to find on PKG's SITE" ; \
				if test -n "$(call qstrip,$(BR2_BACKUP_SITE))" ; then \
					$(call $(3)_WGET,$(BR2_BACKUP_SITE)/$(subst ?,%3F,$(2)),$(2)) ; \
					DOWNLOAD_FETCH_FAILED=$$? ; \
				fi ; \
				if test $$DOWNLOAD_FETCH_FAILED -eq 0 ; then \
					echo " - Downloaded from BACKUP SITE" ; \
				else \
					echo " - Failed to find on BACKUP SITE" ; \
				fi ; \
			fi ; \
		fi ; \
	fi ; \
	if test $$DOWNLOAD_FETCH_FAILED -eq 0 ; then \
		if test -n "$(call qstrip,$(BR2_ARTIFACTORY_URL))" ; then \
			if test -z "$(BR2_ARTIFACTORY_CLI)" ; then \
				echo "WARNING: Can't upload fetched source to artifactory source mirror:" ; \
				echo "  BR2_ARTIFACTORY_CLI is not set" ; \
				exit ; \
			fi ; \
			if test -z "$(ARTIFACTORY_CLI)" ; then \
				echo "WARNING: Can't upload fetched source to artifactory source mirror:" ; \
				echo "  $(BR2_ARTIFACTORY_CLI) is not available" ; \
				exit ; \
			fi ; \
			echo " - Uploading artifact" ; \
			(cd $(DL_DIR) ; $(ARTIFACTORY_CLI) rt upload $(2) $(call qstrip,$(BR2_ARTIFACTORY_REPO))/$($(PKG)_RAWNAME)/$($(PKG)_VERSION)/) && exit ; \
		else \
			exit ; \
		fi ; \
	fi ; \
	exit 1
endef
