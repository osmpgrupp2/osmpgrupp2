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
  //pid_t cpid[100];
  char* args[100];
  //char *out[100];
  //char in[100];
  //char *hej[100] ={"parse.c", NULL} ;
  enum cmd_pos pos;
  pid_t pid;
  int i, p=0, q=0, n;
  //char temp[100];

  char* temp = malloc(100);
  
  

  //trim(in);
 
  //printf("%s\n ", in);


  while(1){
    
    fprintf(stderr, ">");
    //fgets(in, 100, stdin);
    n = read(0, temp, 100);
    Errors(n, "bad input");
    temp[n-1] = '\0';
    //strcpy(temp, in);
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
  
 
  
  /*for(i = 0; args[i] != NULL;i++){
    printf("args[%d]: %s\n",i, args[i]);
  } 
   printf("pos: %d\n", pos);
  */

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
      //fprintf(stdout, "SINGLE!");
      break;
    case first:
      //fprintf(stdout, "FIRST!");
      Errors(dup2(pipes[(i+1)][1], STDOUT_FILENO), "Dup First");
      //dup2(pipes[i+1][1], STDOUT_FILENO);
      //close(pipes[i][0]);
      break;
    case middle:
      //fprintf("MIDDLE!");
      Errors(close(pipes[i][1]), "close middle");      
      Errors(dup2(pipes[i][0], STDIN_FILENO), "Dup Middle");
      Errors(dup2(pipes[(i+1)][1], STDOUT_FILENO), "Dup Middle");
      break;
    case last:
      //fprintf("LAST!");
      Errors(close(pipes[i][1]), "close last");
      Errors(dup2(pipes[i][0], STDIN_FILENO), "Dup Last");
      //dup2(STDOUT_FILENO, pipes[i][1]);
      break;
      // default:
      //break;
    }
    
    Errors(q = execvp(args[0],args), "Execvp error"); 

    if(q == -1){
      perror("execvp funkar inte!");
      exit(EXIT_FAILURE);
    }
    
    //exit(EXIT_SUCCESS);
  default:
    // cpid[p] = pid;
    //OBS PÅ P!
    //p++;
    //wait(NULL);
    close(pipes[i][0]);
    close(pipes[i][1]);
    i++;
  }

 
    }while(pos != last && pos != single);
    
    //wait(NULL) på alla i (barnen)
    
    int x;
    for(x=0;x<i;x++){
      wait(NULL);
    }
  
  }
return 0;
}
