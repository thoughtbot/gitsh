nobase_dist_pkgdata_DATA = $(vendorfiles)
EXTRA_DIST = vendorize

.PHONY: gems

dist-hook: gems

gems:
	$(srcdir)/vendorize

distclean-local:
	-rm -rf gems
