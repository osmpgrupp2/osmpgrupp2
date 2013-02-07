#include <stdio.h>  // printf() 
#include <string.h> // strlen()
#include <ctype.h>  // isspace()

#include "parse.h"

void dbg_print_string(char* ptr, const char* name, const char* callee, const char* msg) {
  fprintf(stderr, "%s()::%s (%s) \n  [0x%p] = \"%s\"\n\n", callee, name, msg, ptr, ptr);
}

/**
 *  Strip whitespace (tabs, spaces, etc) from the beginning of a
 *  string.
 * 
 */
char* ltrim(char* s) {
  while (isspace((int)*s)) ++s;
  return s;
}

/**
 *  Strip whitespace (tabs, spaces, etc) from the end of a
 *  string.
 */
char* rtrim(char* str) {
  if(*str == 0 )
    return str;
  else {
    char* back = str + strlen(str)-1;  // Pointer to last char in str.
    
    while( isspace( *back) ) back--;   // While trailing whitespace move pointer-
      
    *(back+1) = 0; // Done, add terminating '\0'.
    
    return str;
    
  }
}

/**
 *  Strip whitespace (tabs, spaces, etc) from the beginning and the
 *  end of a string.
 */
char* trim(char* str) {
  if (str != NULL)
    return(ltrim(rtrim(str)));
  else return NULL;
}

int empty_line(char* str) {
  while (*str) {
    if (!isspace(*str++)) 
      return 0;
  }
  return 1;
}
  
/*
 * Returns the number of times the character c occurs in the string str. 
 */
int count(char* str, char c) {
  int n = 0;
  while(*str) {
    if (*str++ == c) n++;
  }
  return n;
}


/**
 * DESCRIPTION: 
 *
 * Parses a string looking for pipe characters '|'. Everything between
 * pipe characters is considered to be a bash command.  Each call to
 * this function will search the string for a new command (left to
 * right) and populate the provided argv wiht command data.
 * 
 * INPUT:
 *
 *    line - a string with bash like commands separated with pipe
 *	     characters. After calling this function, the line string
 *	     will be altered since terminating nulls are insterted
 *	     (see argv bellow).
 * 
 *    argv - an array of string pointers. On return, this array will
 *           be populated with the argv for the current command. The
 *           argv will be populated with pointers within the orginal
 *           input line.
 *
 * OUTPUT: 
 *
 *    The possition of the returned command is returned. 
 * 
 *	single - a single command. 
 *	first  - the first command in a chain of commands. 
 *      middle - not the first and not the last command in a chain of command. 
 *      last   - the last command in a chain of commands. 
 *
 * EXAMPLE USAGE: 
 *
 *   str = "  ls -i -l | grep foo " 
 * 
 *   pos =  next_command(str, argv) ==> 
 * 
 *	pos     = first
 *	argv[0] = "ls"
 *	argv[1] = "-i"
 *	argv[2] = "-l
 *	argv[1] = NULL"
 *
 *   pos =  next_command(str, argv) ==> 
 * 
 *	pos     = last
 *	argv[0] = "grep"
 *	argv[1] = "foo"
 *	argv[2] = NULL
 */
enum cmd_pos  next_command(char* line, char* argv[]) // , char* sptr1, char* sptr2) {
{
  enum parse_state {reset, resume};
  
  DBG_PRINT_STRING(line, "before calling strtok_r");

  // Allocate storage used for calls to strtok_()
  
  // NOTE: These pointers must be declared static inside this function
  // for the calls to strtok_r() to work.
  

  static char* save_ptr1;  // Storage needed by strtok_r().
  static char* save_ptr2;  // Storage needed by strtok_r().
  
  char* cmd;  // Pointer to start of command within command line. 
  char* arg;  // Pointer to start of argument withing a single command. 

  // Command position within the original command line. 
  enum cmd_pos pos;  
  
  // Number of '|' characters in the orignal string.   
  static int unparsed_cmds = 0;	 

  static enum parse_state state = reset;  // Parser state. 

  
  
  if (state == reset) {
    // This is the first time the parser is called for this string. 
    cmd = line; 
    unparsed_cmds = count(line, '|'); // Are there more commands in the command line?
    state = resume;  // Switch state
    
    if (unparsed_cmds == 0) 
      // No more commands ==> the command line consists of a single command. 
      pos = single;
    else 
      // There are more commands ==> this is the first of many commands. 
      pos = first;
  }  else {
    
    // The parser is being called again for the same string. 
    
    cmd = NULL; // tell strtok_r to continue to parse the same string as last call...
    unparsed_cmds--;
    
    if (unparsed_cmds > 0) 
      // There are more commands ==> this is command is in the middle of the command chain.
      pos = middle;
    else
      // No more commands ==> this is the last command in a chain of commands.
      pos = last;
  }
  
  // Use strtok_r() to get the command string. 
  cmd = trim(strtok_r(cmd, "|", &save_ptr1));

  
  // Parse the command string and populate argv.
  
  int i; // argv index.

  for (i=0, arg=cmd; ; i++, arg = NULL) {
    arg = trim(strtok_r(arg, " \t", &save_ptr2));
    if (arg == NULL) {
      // done, no more command data
      argv[i] = NULL;
      break;
    } else {
      argv[i] = arg;
    }
  }
  
  // Last command?
  if (pos == single || pos == last) state = reset;
  
  return pos;

}

