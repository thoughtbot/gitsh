dist_bin_SCRIPTS = gitsh

edit = sed \
	-e 's|@RUBY[@]|$(RUBY)|g' \
	-e 's|@rubydir[@]|$(rubydir)|g'

gitsh: Makefile gitsh.in
	$(edit) $@.in > $@
	chmod +x $@
