/**
 * Simple test cases to profile a binary search tree
 *
 * Course: Operating Systems and Multicore Programming - OSM-vt13 Lab
 * assignment 2: A binary search tree which allows for parallel
 * node removals.
 *
 * Author: Nikos Nikoleris <nikos.nikoleris@it.uu.se>
 *
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include <time.h>
#include <pthread.h>

#include "bst.h"
#include "timing.h"

struct conf_t {
    struct bst_node **root;
    int iterations;
    int (*delete)(struct bst_node**, comparator, void*);
    int *data;
    int errors;
    double run_time;
};

struct thread_conf_t {
    pthread_t pthread;
    struct conf_t conf;
};


int
compare_int(const void *a, const void *b)
{
    const int *da = (const int *)a;
    const int *db = (const int *)b; 

    return (*da > *db) - (*da < *db);
}


struct bst_node **
bst_tree_init(int *data, int len)
{
    struct bst_node** root = tree_init();
    assert(root);

    int n = 0;
    while (n < len) {
        data[n] = random();
        if (node_insert(root, compare_int, &data[n]) == 0)
            n += 1;
    }

    return root;
}


void
bst_tree_fini(struct bst_node ** root)
{
    tree_fini(root);
}


void *
run(void *_conf)
{
    struct timespec ts;
    struct conf_t *conf = (struct conf_t *)_conf;

    timing_start(&ts);
    for (int i = 0; i < conf->iterations; i += 1) {
	if ((*conf->delete)(conf->root, compare_int, &conf->data[i]))
	    conf->errors += 1;
    }
    conf->run_time = timing_stop(&ts);

    return NULL;
}


void
profile_single_threaded(struct bst_node **root, int *data, int iterations)
{
    struct conf_t conf;

    conf.root = root;
    conf.iterations = iterations;
    conf.delete = node_delete;
    conf.data = data;
    conf.errors = 0;
    conf.run_time = 0;

    run(&conf);
    assert(conf.errors == 0);
    assert(*conf.root == NULL);

    printf("\nStatistics:\n");
    printf("\tThread 0: %.4f sec (%.4e iterations/s)\n",
           conf.run_time, iterations / conf.run_time);
    printf("\tThroughput (iterations/second): %.4e\n\n",
           iterations / conf.run_time);
}


void
print_stats(struct thread_conf_t *threads, int nthreads, int thread_iterations)
{
    double run_time_sum = 0;

    printf("Statistics:\n");
    for (int i = 0; i < nthreads; i++) {
	struct thread_conf_t *t = &threads[i];
	printf("\tThread %i: %.4f sec (%.4e iterations/s)\n",
	       i, t->conf.run_time,
	       thread_iterations / t->conf.run_time);
	run_time_sum += t->conf.run_time;
    }

    printf("\tAverage execution time: %.4f s\n"
	   "\tThroughput (iterations/second): %.4e\n\n",
	   run_time_sum / nthreads,
	   thread_iterations / run_time_sum);
}


void
profile_mutli_threaded(struct bst_node **root, int *data,
                       int nthreads, int thread_iterations,
                       int (*del)(struct bst_node**, comparator, void*))
{
    struct conf_t conf;
    struct thread_conf_t *threads = malloc(sizeof(*threads) * nthreads);
    if (threads == NULL) {
        fprintf(stderr, "Out of memory!\n");
        exit(1);
    }

    conf.root = root;
    conf.iterations = thread_iterations;
    conf.delete = del;
    conf.data = data;
    conf.errors = 0;
    conf.run_time = 0;

    /* Spawn the test threads */
    for (int i = 0; i < nthreads; i++) {
	struct thread_conf_t *t = &threads[i];
        memcpy(&t->conf, &conf, sizeof(conf));
        t->conf.data += (i * thread_iterations);
	if (pthread_create(&t->pthread, NULL, &run, &t->conf)) 
	    abort();
    }

    /* Join the threads. Causes an implicit barrier since the
     * pthread_join() call waits until the exits. */
    for (int i = 0; i < nthreads; i++)
	pthread_join(threads[i].pthread, NULL);

    int errors = 0;
    for (int i = 0; i < nthreads; i++)
	errors += threads[i].conf.errors;

    if (errors == 0 && (*root == NULL)) {
	printf("Passed!\n");
	print_stats(threads, nthreads, thread_iterations);
    } else {
        printf("Failed!\n\n");
    }

    free(threads);
}

int main()
{
    int *data;
    struct bst_node** root = NULL;
    const int nthreads = 4;
    const int thread_iterations = 1000000;
    const int iterations = nthreads * thread_iterations;
    const int n = iterations;

    data = malloc(sizeof(int) * n);
    if (data == NULL) {
        fprintf(stderr, "Out of memory!\n");
        exit(1);
    }

    printf("Single threaded run: ");
    root = bst_tree_init(data, n);
    assert(root != NULL);
    profile_single_threaded(root, data, iterations);
    bst_tree_fini(root);

    printf("Multi threaded run (Coarse-grained locking): ");
    root = bst_tree_init(data, n);
    assert(root != NULL);
    profile_mutli_threaded(root, data, nthreads, thread_iterations,
                           node_delete_ts_cg);
    bst_tree_fini(root);

    printf("Multi threaded run (Fine-grained locking): ");
    root = bst_tree_init(data, n);
    assert(root != NULL);
    profile_mutli_threaded(root, data, nthreads, thread_iterations,
                           node_delete_ts_fg);
    bst_tree_fini(root);

    free(data);

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
