#ifndef _COMMON_H_
#define _COMMON_H_

#include <signal.h>
#include <unistd.h>

#define NUM_PLAYERS 6

void shooter(int pid, int seed_fd_rd, int score_fd_write);
void waitstat(pid_t pid, int status);

void end_handler(int signum);
void win_handler(int signum);

extern volatile sig_atomic_t winner;
extern volatile sig_atomic_t results;

#endif /* _COMMON_H_ */
