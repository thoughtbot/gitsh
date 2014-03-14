pkgruby_DATA = version.rb
dist_pkgruby_DATA = $(libfiles)
CLEANFILES = version.rb
EXTRA_DIST = version.rb.in

replace_version = sed \
	-e 's|@PACKAGE_VERSION[@]|$(PACKAGE_VERSION)|g'

version.rb: Makefile version.rb.in
	$(replace_version) $(srcdir)/$@.in > $@
