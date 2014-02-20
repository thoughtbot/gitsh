dist_pkgruby_DATA = $(libfiles) version.rb
CLEANFILES = version.rb
EXTRA_DIST = version.rb.in

replace_version = sed \
	-e 's|@PACKAGE_VERSION[@]|$(PACKAGE_VERSION)|g'

version.rb: Makefile version.rb.in
	$(replace_version) $(srcdir)/$@.in > $@
