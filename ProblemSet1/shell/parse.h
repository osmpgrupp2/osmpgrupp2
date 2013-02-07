#ifndef __PARSE__
#define __PARSE__


enum cmd_pos {unknown, single, first, middle, last};

char const* pos2str(enum cmd_pos pos);

char* ltrim(char* s);
char* rtrim(char* s);
char* trim(char* s);
int empty_line(char* str);
enum cmd_pos next_command(char* line, char* argv[]);

// #define __DBG__

#ifdef __DBG__
#define DBG_PRINT_STRING(ptr, msg) dbg_print_string(ptr, #ptr, __FUNCTION__, msg)
#else 
#define DBG_PRINT_STRING(ptr, msg) 
#endif

void dbg_print_string(char* ptr, const char* name, const char* callee, const char* msg);

#endif
