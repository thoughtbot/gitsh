#include <err.h>
#include <ruby.h>
#include <sysexits.h>

int
main(int argc, char *argv[])
{
    int ruby_argc;
    char **ruby_argv;

    ruby_argc = argc + 2;
    ruby_argv = calloc(ruby_argc + 1, sizeof(char *));

    if (!ruby_argv) {
        err(EX_OSERR, GITSH_RB_PATH);
    }

    ruby_argv[0] = argv[0];
    ruby_argv[1] = "--disable-gems";
    ruby_argv[2] = GITSH_RB_PATH;
    memcpy(&ruby_argv[3], &argv[1], argc * sizeof(char *));

    ruby_sysinit(&argc, &argv);
    ruby_init();

    return ruby_run_node(ruby_options(ruby_argc, ruby_argv));
}
