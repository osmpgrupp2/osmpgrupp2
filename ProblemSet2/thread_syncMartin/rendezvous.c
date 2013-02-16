/**
 * Two threads executing chunks of work in a lock step - skeleton code
 * 
 * Course: Process Oriented Programming
 * Lab assignment 2: Rendezvous locking.
 *
 * Author: Nikos Nikoleris <nikos.nikoleris@it.uu.se>
 *
 */

#include <stdio.h>     /* printf() */
#include <stdlib.h>    /* abort(), [s]rand() */
#include <unistd.h>    /* sleep() */
#include <semaphore.h> /* sem_...() */
#include <pthread.h>   /* pthread_...() */

#define LOOPS 5
#define NTHREADS 3
#define MAX_SLEEP_TIME 1

sem_t sem_tidA, sem_tidB;



/* TODO: Make the two threads perform their iterations in a
 * predictable way. Both should perform iteration 1 before iteration 2
 * and then 2 before 3 etc. */

void *threadA(void *param)
{ 
    int i;
	
    for (i = 0; i < LOOPS; i++) {
        
        sem_wait(&sem_tidA);
	printf("threadA --> %d iteration\n", i);
	sleep(rand() % MAX_SLEEP_TIME);
        sem_post(&sem_tidB);
    } 

    pthread_exit(0);
    (void)param; /* Suppress compiler warnings */
}


void *threadB(void *param)
{ 
    int i;
	
    for (i = 0; i < LOOPS; i++) {
	
        sem_wait(&sem_tidB);
        printf("threadB --> %d iteration\n", i);
	sleep(rand() % MAX_SLEEP_TIME);
        sem_post(&sem_tidA);
    } 
    

    pthread_exit(0);
    (void)param; /* Suppress compiler warnings */
}

int main()
{
    pthread_t tidA, tidB;
    
    sem_init(&sem_tidA, 0, 1);  // 1 = öppen 
    sem_init(&sem_tidB, 0, 0);  // 0 = stängd

    srand(time(NULL));
    pthread_setconcurrency(3);

    if (pthread_create(&tidA, NULL, threadA, NULL) || 
	pthread_create(&tidB, NULL, threadB, NULL)) {
	perror("pthread_create");
	abort();
    }
    if (pthread_join(tidA, NULL) != 0 || 
        pthread_join(tidB, NULL) != 0) {
	perror("pthread_join");
	abort();
    }

    return 0;
}

/*
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * indent-tabs-mode: nil
 * c-file-style: "stroustrup"
 * End:
 */
