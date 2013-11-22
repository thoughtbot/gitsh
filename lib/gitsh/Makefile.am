dist_pkgruby_DATA = $(libfiles)
dist_pkgruby_SCRIPTS = version.rb
CLEANFILES = $(dist_pkgruby_SCRIPTS)
EXTRA_DIST = version.rb.in

replace_version = sed \
	-e 's|@PACKAGE_VERSION[@]|$(PACKAGE_VERSION)|g'

version.rb: Makefile version.rb.in
	$(replace_version) $(srcdir)/$@.in > $@
