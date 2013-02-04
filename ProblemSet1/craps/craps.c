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


        /* TODO: Use the following variables in the exec system call. Using the
	 * function sprintf and the arg1 variable you can pass the id parameter
	 * to the children
	 */
	/*
	char arg0[] = "./shooter";
	char arg1[10];
	char *args[] = {arg0, arg1, NULL};
	*/
	/* TODO: this loop can be used to initialize the communication
	   with the players */
	
	for (i = 0; i < NUM_PLAYERS; i++) {
	  

	  if(pipe(seed_fd[i]) == -1){
	    perror("Seed pipen funkar inte!");
	      exit(EXIT_FAILURE);
	  }
	  
	  if(pipe(score_fd[i]) == -1){
	    perror("Score pipen funkar inte!");
	    exit(EXIT_FAILURE);
	    }
	}

	for (i = 0; i < NUM_PLAYERS; i++) {
	  /* TODO: this loop will be used to spawn the processes
	     that will simulate each player */
	  switch(cpid[i] = fork()){
	  case 0: // allt är ok
	    
	    //printf("Child process has started!\n");
	    
	    printf("nu är vi i barn %d\n",i);
	    
	    

	    shooter(i, seed_fd[i][0], score_fd[i][1]);

	    // seed Master -> Barn
	    // score Barn -> Master
	    close(seed_fd[i][1]); //stänger så barnet inte kan skriva
	    close(score_fd[i][0]); // stänger så att barnet inte kan läsa
	    exit(EXIT_SUCCESS);

	    
	  case -1: // Inget är bra.
	    perror("Fork Error!");
	    exit(EXIT_FAILURE);

	    
	  default:  //Förälderns
	    //printf("Parent started\n");
	    // seed Master -> Barn
	    // score Barn -> Master
	    close(seed_fd[i][0]); //stänger så föräldern inte kan läsa
	    close(score_fd[i][1]);//stänger så föräldern inte kan skriva

	    if ((cpid[i] = wait(&status)) == -1){
	      perror("Wait failed\n");
	    }else {
	      if (WIFEXITED(status) != 0){
              printf("Child process ended normally; status = %d.n WEXITSTATUS= %d WIFEXITED ÄR =%d \n",
		     status, WEXITSTATUS(status), WIFEXITED(status));
	      }else{
		printf("Child process did not end normally.n\n");
	      }
	    }
	    printf("For loopen slut, börjar om\n");
	    //exit(EXIT_SUCCESS);
	 }
	 

	}

	seed = time(NULL);
	for (i = 0; i < NUM_PLAYERS; i++) {
		seed++;
		/* TODO: send the seed to the players */
		seed_fd[i][0] = seed;
	}

	/* TODO: get the results from the players, find the winner */
	for (i = 0; i < NUM_PLAYERS; i++) {
	  
	  
	  score = score_fd[i][0];
	  
	  if (score>winning_score){
	    winning_score = score;
	    winner = i;
	  }

	}
	printf("master: player %d WINS\n", winner);

	/* TODO: signal only the winner */

	


/* TODO: signal all that this is the end of game */
	for (i = 0; i < NUM_PLAYERS; i++) {

	}

	/* TODO: no more communication with the players */

	printf("master: the game ends\n");

	/* TODO: make sure that all resources are released and exit with
	   success */
	for (i = 0; i < NUM_PLAYERS; i++) {

	}

	return 0;
}
