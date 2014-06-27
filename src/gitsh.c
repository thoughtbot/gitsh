#include <err.h>
#include <sysexits.h>
#include <unistd.h>

int
main(int argc, char *argv[])
{
    if (execv(GITSH_RB_PATH, argv) == -1) {
        err(EX_SOFTWARE, GITSH_RB_PATH);
    }
    return EX_OK;
}
