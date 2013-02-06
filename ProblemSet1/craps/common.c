#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <signal.h>

#include <sys/types.h>
#include <sys/wait.h>

#include "common.h"

/* These flags control the termination of the main loop and indicate the winner. */
volatile sig_atomic_t winner = 0;
/* TODO: Change this to 0 to make the children spin in the for loop before they
   receive the SIGUSR2 signal */
volatile sig_atomic_t results = 0;

/**
 * end_handler - handle the SIGUSR2 signal, the player will receive
 * this signal when the game ends
 * @signum: the signal that triggered this handler
 */
void end_handler(int signum)
{
	/* TODO: Check that the signum is indeed SIGUSR2 */

	/* TODO: "leave the game" make the appropriate changes to let the
	   current process exit*/
  if(signum == SIGUSR2){
    results = 1;
    
  }
  signal(signum, end_handler);
}

/**
 * win_handler - handle the SIGUSR1 signal, player will receive the SIGUSR1 when
 * he is the winner
 * @signum: the signal that triggered this handler
 */
void win_handler(int signum)
{
	/* TODO - Check that the signum is indeed SIGUSR1 */
  if(signum == SIGUSR1){
    
    winner = 1;

    
}
  signal(signum, win_handler);
	/* TODO - receive the winning result make the appropriate changes to
	   let current process be notified upon the reception of this singal */

	
}


/**
 * shooter - it simulates the players action during a game of lack.
 * @id: id number of the player
 * @seed_rd_fd: file descriptor of the pipe used to read the seed from 
 * @score_wr_fd: file descriptor of the pipe used to write the scores to
 */
void shooter(int id, int seed_fd_rd, int score_fd_wr)
{
	pid_t pid;
	int score, seed = 0;
	
	/* TODO: Install SIGUSR1 handler */
	signal(SIGUSR1,win_handler);
	
	/* TODO: Install SIGUSR2 handler */
	signal(SIGUSR2,end_handler);
	
	pid = getpid();
	
	fprintf(stderr, "player %d: I'm in this game (PID = %ld)\n",
		id, (long)pid);

	/* TODO: roll the dice, but before that get a seed from the parent */
	
	read(seed_fd_rd, &seed,sizeof(seed));
	srand(seed);
	score = rand() % 10000;
	
	fprintf(stderr, "player %d: I scored %d (PID = %ld\n", id, score, (long)pid);
	/* TODO: send my score back */

	write(score_fd_wr, &score, sizeof(score));

	
	/* spin while I wait for the results */
	while (!results) ;

	if (winner)
		fprintf(stderr, "player %d: Walking away rich\n", id);

	fprintf(stderr, "player %d: Leaving the game (PID = %ld)\n",
		id, (long)pid);

	/* TODO: free resources and exit with success */
	

	exit(EXIT_SUCCESS);
}

/**
 * waitstat - explain the status returned by the wait()/waitpid() functions.
 * @pid: pid of the process returned by the wait()/waitpid()
 * @status: the status returned by the wait()/waitpid(), to be explained
 * This is function is not complete, but in our case it is enough to print the
 * exit value returned by each child process
 */
void waitstat(pid_t pid, int status)
{
	if (WIFEXITED(status))
		fprintf(stderr, "Child with PID = %ld terminated normally, exit"
			" status = %d\n", (long)pid, WEXITSTATUS(status));
	else {
		fprintf(stderr, "%s: Internal error: Unhandled case, PID = %ld,"
			" status = %d\n", __func__, (long)pid, status);
		exit(1);
	}
	fflush(stderr);
}
