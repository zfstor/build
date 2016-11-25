#-
# Copyright 2010-2015 iXsystems, Inc.
# All rights reserved
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted providing that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
# IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
# DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
# OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
# STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING
# IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
#
#####################################################################

BUILD_TIMESTAMP != date -u '+%Y%m%d%H%M' 
BUILD_STARTED != date '+%s'
BUILD_ROOT ?= ${.CURDIR}
BUILD_CONFIG := ${BUILD_ROOT}/build/config
BUILD_TOOLS := ${BUILD_ROOT}/build/tools
PYTHONPATH := ${BUILD_ROOT}/build/lib
BE_ROOT := ${BUILD_ROOT}/_BE
OBJDIR := ${BE_ROOT}/objs
PROFILE ?= zfstor
GIT_REPO_SETTING = ${BUILD_ROOT}/.git-repo-setting
PROFILE_SETTING = ${BUILD_ROOT}/.profile-setting
MK := ${MAKE} -f ${BUILD_ROOT}/Makefile.inc1
DOC_PATH := ${BUILD_ROOT}/_BE/freenas-docs
API_PATH := ${BUILD_ROOT}/_BE/freenas/docs

.if exists(${GIT_REPO_SETTING})
GIT_LOCATION != cat ${GIT_REPO_SETTING}
.endif

.if exists(${BUILD_ROOT}/.git-ref-path)
GIT_REF_PATH != cat ${BUILD_ROOT}/.git-ref-path
.elif exists(/build/gitrefs)
GIT_REF_PATH ?= /build/gitrefs
.endif

.if exists(${PROFILE_SETTING})
PROFILE != cat ${PROFILE_SETTING}
.endif

.export MK
.export GIT_LOCATION
.export BUILD_TIMESTAMP
.export BUILD_ROOT
.export BUILD_CONFIG
.export BUILD_TOOLS
.export BUILD_LOGLEVEL
.export PYTHONPATH
.export BE_ROOT
.export OBJDIR
.export BUILD_STARTED
.export GIT_REPO_SETTING
.export GIT_REF_PATH
.export PROFILE
.export API_PATH
.export DOC_PATH

.BEGIN:
.if !make(remote) && !make(sync) && !make(bootstrap-pkgs)
	@echo "[0:00:00] ==> NOTICE: Selected profile: ${PROFILE}"
	@echo "[0:00:00] ==> NOTICE: Build timestamp: ${BUILD_TIMESTAMP}"
.endif

.if !make(remote) && !make(sync) && !make(bootstrap-pkgs)
	@${BUILD_TOOLS}/buildenv.py ${BUILD_TOOLS}/check-host.py
.if !make(checkout) && !make(update) && !make(clean) && !make(cleandist) && !make(profiles) && !make(select-profile) && !make(docs) && !make(api-docs)
	@${BUILD_TOOLS}/buildenv.py ${BUILD_TOOLS}/check-sandbox.py
.endif
.endif

.PHONY: release ports tests

buildenv:
	@${BUILD_TOOLS}/buildenv.py sh

bootstrap-pkgs:
	pkg install -y archivers/pxz
	pkg install -y lang/python3
	pkg install -y ports-mgmt/poudriere-devel
	pkg install -y sysutils/grub2-pcbsd
	pkg install -y sysutils/xorriso
	pkg install -y sysutils/grub2-efi
	pkg install -y devel/gmake
	pkg install -y archivers/pigz

.DEFAULT:
	@mkdir -p ${OBJDIR}
	@${BUILD_TOOLS}/buildenv.py ${MK} ${.TARGET}
