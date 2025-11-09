#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/time.h>
#include <unistd.h>

#define MAX_COMMANDS 32
#define MAX_LINE 1024
#define MAX_OUTPUT 256

struct command {
  char cmd[MAX_LINE];
  char out[MAX_OUTPUT];
  int interval;
  long long next;
};

static volatile sig_atomic_t refresh = 0;
static struct command commands[MAX_COMMANDS];
static int ncmds = 0;

static void sighandler(int sig) {
  (void)sig;
  refresh = 1;
}

static long long gettime(void) {
  struct timeval tv;
  gettimeofday(&tv, NULL);
  return tv.tv_sec * 1000LL + tv.tv_usec / 1000;
}

static void runcmd(struct command *c) {
  FILE *fp;

  if (!(fp = popen(c->cmd, "r")))
    return;

  if (fgets(c->out, sizeof(c->out), fp))
    c->out[strcspn(c->out, "\n")] = '\0';

  pclose(fp);
}

static void loadconfig(const char *path) {
  FILE *fp;
  char line[MAX_LINE], *p;
  int interval;

  if (!(fp = fopen(path, "r"))) {
    perror(path);
    exit(1);
  }

  while (fgets(line, sizeof(line), fp) && ncmds < MAX_COMMANDS) {
    line[strcspn(line, "\n")] = '\0';

    if (!(p = strchr(line, ','))) {
      fprintf(stderr, "invalid line: %s\n", line);
      exit(1);
    }
    *p++ = '\0';

    if ((interval = atoi(line)) <= 0) {
      fprintf(stderr, "invalid interval: %s\n", line);
      exit(1);
    }

    commands[ncmds].interval = interval;
    commands[ncmds].next = 0;
    snprintf(commands[ncmds].cmd, sizeof(commands[ncmds].cmd), "%s", p);
    commands[ncmds].out[0] = '\0';
    ncmds++;
  }

  fclose(fp);

  if (!ncmds) {
    fprintf(stderr, "no valid commands\n");
    exit(1);
  }
}

int main(int argc, char **argv) {
  long long now, next, sleep_ms;
  int i;
  char config_path[MAX_LINE];
  const char *home;

  if (argc > 1 && !strcmp(argv[1], "-r")) {
    signal(SIGUSR1, SIG_IGN);
    (void)system("killall -USR1 wstatus");
    return 0;
  }

  signal(SIGUSR1, sighandler);

  home = getenv("HOME");
  if (!home) {
    fprintf(stderr, "error: HOME not set\n");
    return 1;
  }
  snprintf(config_path, sizeof(config_path), "%s/.config/wstatus.cfg", home);
  loadconfig(config_path);

  for (;;) {
    now = gettime();

    if (refresh) {
      refresh = 0;
      for (i = 0; i < ncmds; i++)
        commands[i].next = 0;
    }

    for (i = 0; i < ncmds; i++) {
      if (now >= commands[i].next) {
        runcmd(&commands[i]);
        commands[i].next = now + commands[i].interval;
      }
    }

    for (i = 0; i < ncmds; i++) {
      if (i > 0)
        fputs(" | ", stdout);
      fputs(commands[i].out, stdout);
    }
    putchar('\n');
    fflush(stdout);

    next = commands[0].next;
    for (i = 1; i < ncmds; i++)
      if (commands[i].next < next)
        next = commands[i].next;

    sleep_ms = next - gettime();
    if (sleep_ms > 0)
      usleep(sleep_ms * 1000);
  }
}
