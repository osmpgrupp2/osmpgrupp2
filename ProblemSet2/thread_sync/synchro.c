/**
 * multiple threads incrementing and decrementing the same variable -
 * skeleton code
 * 
 * Course: Process Oriented Programming
 * Lab assignment 2: Thread-safe common variable
 *
 * Author: Nikos Nikoleris <nikos.nikoleris@it.uu.se>
 *
 */

#include <stdio.h>     /* printf(), fprintf() */
#include <stdlib.h>    /* abort() */
#include <pthread.h>   /* pthread_... */

#define INCREMENTORS 5
#define INCREMENT_VALUE 2
#define DECREMENTORS 4
#define DECREMENT_VALUE 2

#define INCREMENTOR_ITERATIONS 2000000
#define DECREMENTOR_ITERATIONS (INCREMENTOR_ITERATIONS * INCREMENTORS * INCREMENT_VALUE / DECREMENTORS / DECREMENT_VALUE) 

#define COUNTER_INIT 0
volatile int counter;
pthread_t incrementor_tid[INCREMENTORS], decrementor_tid[DECREMENTORS];

pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER;

void *incrementor(void *param)
{
    /* TODO: Protect the shared variable */
    int i;

    i = INCREMENTOR_ITERATIONS;
    while (i--) {
        int temp;

        temp = counter;
        temp += INCREMENT_VALUE;
        counter = temp;
    }

    pthread_exit(0);
    (void)param; /* Suppress compiler warnings */
}


void *decrementor(void *param)
{
    /* TODO: Protect the shared variable */
    int i;

    i = DECREMENTOR_ITERATIONS;
    while (i--) {
        int temp;

        temp = counter;
        temp -= DECREMENT_VALUE;
        counter = temp;
    }

    pthread_exit(0);
    (void)param; /* Suppress compiler warnings */
}


int main()
{
    long int i;

    pthread_setconcurrency(3);

    counter = COUNTER_INIT;

    pthread_setconcurrency(INCREMENTORS + DECREMENTORS + 1);
    /* Create the threads */
    for (i = 0; i < INCREMENTORS; i++)
	if (pthread_create(&incrementor_tid[i], NULL, incrementor, NULL) != 0) {
	    perror("pthread_create");
	    abort();
	}
    for (i = 0; i < DECREMENTORS; i++)
	if (pthread_create(&decrementor_tid[i], NULL, decrementor, NULL) != 0) {
	    perror("pthread_create");
	    abort();
	}

    /* Wait for them to complete */
    for (i = 0; i < INCREMENTORS; i++)
	if (pthread_join(incrementor_tid[i], NULL) != 0) {
	    perror("pthread_join");
	    abort();
	}
    for (i = 0; i < DECREMENTORS; i++)
	if (pthread_join(decrementor_tid[i], NULL) != 0) {
	    perror("pthread_join");
	    abort();
	}

    printf("counter expected value:%10d\n", COUNTER_INIT);
    printf("counter actual value:  %10d\n", counter);
    if (counter != COUNTER_INIT) {
	printf("Failure\n");
	return -1;
    } else {
	printf("Success\n");
	return 0;
    }
}

/*
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * indent-tabs-mode: nil
 * c-file-style: "stroustrup"
 * End:
 */
