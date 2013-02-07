#include <stdio.h> /* I/O functions: printf() ... */
#include <stdlib.h> /* rand(), srand() */
#include <unistd.h> /* read(), write() calls */
#include <assert.h> /* assert() */
#include <time.h>   /* time() */
#include <signal.h> /* kill(), raise() and SIG???? */

#include <sys/types.h> /* pid */
#include <sys/wait.h> /* waitpid() */

#include "common.h"

int main(int argc, char *argv[])
{
	/* TODO: you probably need some or all the following variables. */
	int i, seed;

	pid_t cpid[NUM_PLAYERS];
	int status; 
	int seed_fd[NUM_PLAYERS][2];
	int score_fd[NUM_PLAYERS][2];
	int score = 0, winning_score = 0, winner = 0;
	pid_t pid;

        /* TODO: Use the following variables in the exec system call. Using the
	 * function sprintf and the arg1 variable you can pass the id parameter
	 * to the children
	 */
	
	char arg0[] = "./shooter";
	char arg1[10];
	char *args[] = {arg0, arg1, NULL};
	
	/* TODO: this loop can be used to initialize the communication
	   with the players */
	
	for (i = 0; i < NUM_PLAYERS; i++) {
	  int check = pipe(seed_fd[i]);
	  

	  if(check == -1){
	    perror("Seed pipen funkar inte!");
	      exit(EXIT_FAILURE);
	  }

	  check = pipe(score_fd[i]);
	  
	  if(check == -1){
	    perror("Score pipen funkar inte!");
	    exit(EXIT_FAILURE);
	    }


	}

	for (i = 0; i < NUM_PLAYERS; i++) {
	  /* TODO: this loop will be used to spawn the processes
	     that will simulate each player */
	  
	  switch(pid = fork()){
	  case 0: // allt är ok
	    
	    // seed Master -> Barn
	    // score Barn -> Master
	    close(seed_fd[i][1]); //stänger så barnet inte kan skriva
	    close(score_fd[i][0]); // stänger så att barnet inte kan läsa

	    shooter(i, seed_fd[i][0], score_fd[i][1]);
	    /* 
	    sprintf(arg1,"%d",i);
	    dup2(seed_fd[i][0],STDIN_FILENO);
	    dup2(score_fd[i][1],STDOUT_FILENO);
	    execv(arg0,args);
	    */
	    exit(EXIT_SUCCESS);

	    
	  case -1: // Inget är bra.
	    perror("Fork Error!");
	    exit(EXIT_FAILURE);

	    
	  default:  //Förälderns
	    cpid[i] = pid;
	    
	    // seed Master -> Barn
	    // score Barn -> Master
	    close(seed_fd[i][0]); //stänger så föräldern inte kan läsa
	    close(score_fd[i][1]);//stänger så föräldern inte kan skriva
	    
	  }
	 

	}

	seed = time(NULL);
	for (i = 0; i < NUM_PLAYERS; i++) {
	  /* TODO: send the seed to the players */
	  write(seed_fd[i][1], &seed, sizeof(seed)); 
	  seed++;
	}

	/* TODO: get the results from the players, find the winner */
	for (i = 0; i < NUM_PLAYERS; i++) {
	  
	  
	  read(score_fd[i][0],&score,sizeof(score));
	  
	  if (score>winning_score){
	    winning_score = score;
	    winner = i;
	  }

	}
	printf("master: player %d WINS\n", winner);

	/* TODO: signal only the winner */

	kill(cpid[winner], SIGUSR1);


/* TODO: signal all that this is the end of game */
	for (i = 0; i < NUM_PLAYERS; i++) {

	  kill(cpid[i], SIGUSR2);

	}

	/* TODO: no more communication with the players */

	printf("master: the game ends\n");
	for (i = 0; i < NUM_PLAYERS; i++) {
	close(seed_fd[i]);
	close(score_fd[i]);
	
	}
	/* TODO: make sure that all resources are released and exit with
	   success */
	for (i = 0; i < NUM_PLAYERS; i++) {
	  
	  //wait(NULL);
	  //while( -1 == waitpid(cpid[i], &status, 0)); 
	  waitstat(cpid[i],status);
	  //wait(cpid[i]);
	  
	  
	}
	exit(EXIT_SUCCESS);
	return 0;
}
