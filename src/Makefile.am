bin_PROGRAMS = gitsh
gitsh_SOURCES = gitsh.c
AM_CPPFLAGS = -DGITSH_RB_PATH="\"$(rubydir)/$(PACKAGE).rb\""

ruby_SCRIPTS = gitsh.rb
CLEANFILES = $(ruby_SCRIPTS)
EXTRA_DIST = gitsh.rb.in

edit = sed \
	-e 's|@RUBY[@]|$(RUBY)|g' \
	-e 's|@rubydir[@]|$(rubydir)|g' \
	-e 's|@gemsetuppath[@]|$(gemsetuppath)|g'

gitsh.rb: Makefile gitsh.rb.in
	$(edit) $(srcdir)/$@.in > $@
	chmod +x $@
