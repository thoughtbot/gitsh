dist_bin_SCRIPTS = gitsh
CLEANFILES = $(dist_bin_SCRIPTS)
EXTRA_DIST = gitsh.in

edit = sed \
	-e 's|@RUBY[@]|$(RUBY)|g' \
	-e 's|@rubydir[@]|$(rubydir)|g' \
	-e 's|@gemsetuppath[@]|$(gemsetuppath)|g'

gitsh: Makefile gitsh.in
	$(edit) $(srcdir)/$@.in > $@
	chmod +x $@
