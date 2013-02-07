#include<stdio.h>
#include <string.h>
#include "parse.h"

#define MAX_ARGV_SIZE 50 
#define MAX_CMD_SIZE 50 

void print_position(enum cmd_pos pos)
{
	switch(pos)
	{
		case unknown:
			puts("unknown\n");
			break;
		case single:
			puts("single\n");
			break;
		case first:
			puts("first\n");
			break;
		case middle:
			puts("middle\n");
			break;
		case last:
			puts("last\n");
	}
	return;
}

int main(void)
{
	enum cmd_pos pos;
	char* argv[MAX_ARGV_SIZE];
	char str[MAX_CMD_SIZE] = "cat parse.c | grep argv | wc -l";
	do{
		int i;
		pos = next_command(str, argv);
		for(i = 0; argv[i] != NULL; i++)
		{
			printf("argv[%d]: %s\n", i, argv[i]);
		}
		print_position(pos);
	}while(pos != single && pos != last);
	return 0;
}
