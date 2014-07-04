AUTOMAKE_OPTIONS = foreign
SUBDIRS = src man vendor spec ext/gitsh lib/gitsh
EXTRA_DIST = LICENSE README.md INSTALL

.PHONY: release \
	release_build release_push release_clean \
	release_build_tarball release_build_homebrew release_build_arch \
	release_push_tarball release_push_homebrew release_push_arch \
	release_clean_tarball release_clean_homebrew release_clean_arch

edit_package = sed \
	-e 's|@PACKAGE[@]|$(PACKAGE)|g' \
	-e 's|@PACKAGE_VERSION[@]|$(PACKAGE_VERSION)|g' \
	-e 's|@DIST_ARCHIVES[@]|$(DIST_ARCHIVES)|g' \
	-e 's|@DIST_SHA[@]|$(DIST_SHA)|g'

release: release_build release_push release_clean

release_build: release_build_tarball release_build_homebrew release_build_arch

release_push: release_push_tarball release_push_homebrew release_push_arch

release_clean: release_clean_tarball release_clean_homebrew release_clean_arch

release_build_tarball: Makefile distcheck
	git clone --branch gh-pages git@github.com:thoughtbot/gitsh.git gh-pages
	cp $(DIST_ARCHIVES) gh-pages
	cd gh-pages &&\
		git add $(DIST_ARCHIVES) &&\
		git commit -m "Release version $(PACKAGE_VERSION)"

release_push_tarball:
	cd gh-pages &&\
		git push

release_clean_tarball:
	rm -rf gh-pages

release_build_homebrew: DIST_SHA
	git clone git@github.com:thoughtbot/homebrew-formulae.git homebrew-formulae
	$(edit_package) homebrew/gitsh.rb.in > homebrew-formulae/Formula/gitsh.rb
	cd homebrew-formulae &&\
		git commit -am "gitsh: Release version $(PACKAGE_VERSION)"

release_push_homebrew:
	cd homebrew-formulae &&\
		git push

release_clean_homebrew:
	rm -rf homebrew-formulae

release_build_arch: DIST_SHA
	git clone --branch master git@github.com:thoughtbot/gitsh.git release-arch
	cd release-arch &&\
		$(edit_package) arch/PKGBUILD.in > arch/PKGBUILD &&\
		git commit -m "Arch package for version $(PACKAGE_VERSION)" -- arch/PKGBUILD &&\
		git tag v$(PACKAGE_VERSION)

release_push_arch:
	cd release-arch &&\
		git push --tags &&\
		git push

release_clean_arch:
	rm -rf release-arch

DIST_SHA: Makefile distcheck
	$(eval DIST_SHA := $(shell shasum $(srcdir)/$(DIST_ARCHIVES) | cut -d' ' -f1))
