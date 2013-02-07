#include <stdio.h>
#include <stdlib.h>
#include <signal.h>
#include <sys/types.h>
#include <sys/wait.h>
#include "parse.c"

int main(int argc, char *argv[]){
  int i, p, q;
  char* args[100];
  pid_t pID;
  enum cmd_pos pos;
  char in[100];
  char* out[100];
  pid_t cpid[100];
  
  fgets(in, 100, stdin);
  
  pos = next_command(in,args);
  
  i = 1;
  p = 0;
  while(args[i] != NULL){
    out[p] = args[i];
    p++;
    i++;
  }
  
  switch(pID = fork()){
  case -1:
    perror("dra åt helvete!!");
    exit(EXIT_FAILURE);
  case 0:
    execvp(args[0], out);
    exit(EXIT_SUCCESS);
  default:
    pID = wait(NULL);
    cpid[q];
    q++;
  }
  
  printf("%s, %s\n", args[0], args[1]);
  
  
  return 0;
}
