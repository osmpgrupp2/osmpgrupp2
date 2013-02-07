#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <signal.h>
#include <unistd.h>

#include <sys/types.h>
#include <sys/wait.h>

#include "parse.c"

int main (int argc,char *argv[]){
  pid_t cpid[100];
  char* args[100];
  char *out[100];
  char in[100];
  char *hej[100] ={"parse.c", NULL} ;
  enum cmd_pos pos;
  pid_t pid;
  int i, p=0, q=0;
  
  fgets(in, 100, stdin);

  trim(in);
 
  printf("%s\n ", in);

  pos = next_command(in, args);
 
  trim(args[0]);
  for(i = 0; args[i] != NULL;i++){
printf("%s\n",args[i]);
  } 
printf("%d\n", pos);



 printf("Nu kör vi fork");
  switch(pid = fork()){

  case -1: 
    perror("Forken fuckaur");
    exit(EXIT_FAILURE);
  case 0:
    printf("case 0 \n");
    printf("HELLO!%s" ,args[0]);
    
    q = execvp(args[0],args); 

      printf("%d",q);
    
    exit(EXIT_SUCCESS);
  default:
    cpid[p] = pid;
    //OBS PÅ P!
    p++;
    wait(NULL);
  }
  
  return 0;
}
