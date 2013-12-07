EXTRA_DIST = gems vendorize

.PHONY: gems

dist-hook: gems

install-data-hook:
	cp -R $(abs_srcdir)/gems $(DEST_DIR)$(pkgdatadir)

uninstall-local:
	rm -rf $(DEST_DIR)$(pkgdatadir)/gems

gems:
	$(srcdir)/vendorize

maintainer-clean-local:
	-rm -rf gems
