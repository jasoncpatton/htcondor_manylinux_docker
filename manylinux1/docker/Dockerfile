FROM quay.io/pypa/manylinux1_x86_64:latest

MAINTAINER The HTCondor Project
LABEL maintainer = "The HTCondor Project"
LABEL maintainer_email = "htcondor-admin@cs.wisc.edu"
LABEL maintainer_url = "http://htcondor.org"
LABEL org.htcondor.name = "HTCondor manylinux1"
LABEL org.htcondor.description = "A manylinux1 image modified for building HTCondor Python bindings wheels."
LABEL org.htcondor.url = "http://htcondor.org"
LABEL org.htcondor.vendor = "The HTCondor Project"
LABEL org.htcondor.version = "8.9.6"
LABEL org.htcondor.schema-version = "1.0.1"

# Install packages
RUN yum install -y epel-release
RUN yum install -y readline-devel libicu-devel pam-devel cyrus-sasl-devel pcre-devel uuid-devel uuid-c++-devel libxml2-devel libtool byacc perl-Archive-Tar flex nss-devel c-ares-devel e2fsprogs-devel libselinux-devel expat-devel libuuid-devel libcurl-devel python-devel krb5-devel keyutils-libs-devel openldap-devel

# Install updated cmake
# manylinux1 is limited to version 3.13.3 or older
RUN /opt/python/cp37-cp37m/bin/pip install cmake==3.13.3
RUN ln -s /opt/python/cp37-cp37m/bin/cmake /usr/local/bin/cmake

# There is an updated autoconf but it was built without pkg-config, so we link
# in the pkg-config macros where the updated autoconf can see them.
RUN ln -s /usr/share/aclocal/pkg.m4 /usr/local/share/aclocal-1.16/pkg.m4

# Build external packages
COPY build_scripts /build_scripts
# Updated Perl and pkg-config are needed by openssl and gct
RUN build_scripts/build_opt.sh perl 5.14.1
RUN build_scripts/build_opt.sh pkgconfig 0.22
RUN PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:/usr/local/lib64/pkgconfig:/usr/lib64/pkgconfig build_scripts/build_external.sh pcre 8.43
RUN PATH=/opt/perl-5.14.1/bin:$PATH build_scripts/build_external.sh openssl 1.1.1d
RUN PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:/usr/local/lib64/pkgconfig:/usr/lib64/pkgconfig build_scripts/build_external.sh voms 2.1.0-rc0
RUN PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:/usr/local/lib64/pkgconfig:/usr/lib64/pkgconfig PATH=/opt/pkg-config-0.22/bin:$PATH build_scripts/build_external.sh gct 6.2.1541705016
RUN PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:/usr/local/lib64/pkgconfig:/usr/lib64/pkgconfig build_scripts/build_external.sh munge 0.5.13
RUN PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:/usr/local/lib64/pkgconfig:/usr/lib64/pkgconfig build_scripts/build_external.sh boost 1.66.0

# Cleanup
RUN rm -rf /opt/perl-5.14.1
RUN rm -rf /opt/pkg-config-0.22
RUN rm -rf build_scripts

CMD ["/bin/bash"]
