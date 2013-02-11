#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <signal.h>
#include <unistd.h>

#include <sys/types.h>
#include <sys/wait.h>

#include "parse.h"

#define Errors(syscall, errormsg)		\
  if(syscall == -1){				\
    fprintf(stderr, errormsg);			\
    exit(EXIT_FAILURE);}			\


int main (int argc,char *argv[]){
  char* args[100];
  enum cmd_pos pos;
  pid_t pid;
  int i, q=0, n;
  char* temp = malloc(100);
  

  while(1){
    
    fprintf(stderr, ">");
    n = read(0, temp, 100);
    Errors(n, "bad input");
    temp[n-1] = '\0';


    i = 0;
    int counter = 1;
    while(temp[i]){
      if(temp[i] == '|'){
	counter++;}
      i++;
    
    }
    int pipes[counter][2];
    
    for(i = 0; i<counter; i++){
      Errors(pipe(pipes[i]),"Failar att göra pipes");
    } 
     
    i = 0;

    do{


      pid = fork();
      pos = next_command(temp, args);
      switch(pid){
    
      case -1: 
	perror("Forken fuckaur");
	exit(EXIT_FAILURE);
      case 0:
    
	switch(pos){
	case unknown:
	  perror("pos = unknown");
	  exit(EXIT_FAILURE);
	case single:
	  Errors(close(pipes[i][0]),"Close Single");
	  Errors(close(pipes[i][1]),"Close Single");
	  break;
	case first:
	  Errors(dup2(pipes[(i+1)][1], STDOUT_FILENO), "Dup First");
	  break;
	case middle:
      
	  Errors(close(pipes[i][1]), "close middle");      
	  Errors(dup2(pipes[i][0], STDIN_FILENO), "Dup Middle");
	  Errors(dup2(pipes[(i+1)][1], STDOUT_FILENO), "Dup Middle");
	  break;
	case last:
	  Errors(close(pipes[i][1]), "close last");
	  Errors(dup2(pipes[i][0], STDIN_FILENO), "Dup Last");
      
	  break;
	  default:
	  break;
	}
    
	Errors(q = execvp(args[0],args), "Execvp error"); 

    
      default:
	close(pipes[i][0]);
	close(pipes[i][1]);
	i++;
      }

 
    }while(pos != last && pos != single);
    
    //free (temp);
    int x;
    for(x=0;x<i;x++){
      wait(NULL);
    }
  
  }
  return 0;
}
