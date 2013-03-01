/**
 * Binary search tree implementation
 *
 * Copyright (c) 2013 the authors listed at the following URL, and/or
 * the authors of referenced articles or incorporated external code:
 * http://en.literateprograms.org/Binary_search_tree_(C)?action=history&offset=20121127201818
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use, copy,
 * modify, merge, publish, distribute, sublicense, and/or sell copies
 * of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 *  included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT.  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 *
 * Retrieved from: http://en.literateprograms.org/Binary_search_tree_(C)?oldid=18734
 * Modified: Nikos Nikoleris <nikos.nikoleris@it.uu.se>
 */


/***********************************************************/
/* NOTE: You can modify/add any piece of code that will    */
/* make your algorithm work                                */
/***********************************************************/


#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <assert.h>

#include "bst.h"

pthread_mutex_t mutexCG = PTHREAD_MUTEX_INITIALIZER; //creates a mutex lock
struct bst_node** parent = NULL;

/**
 * Searches for the node which points to the requested data.
 *
 * @param root       root of the tree
 * @param comparator function used to compare nodes
 * @param data       pointer to the data to be search for
 * @return           the node containg the data
 */
struct bst_node**
search(struct bst_node** root, comparator compare, void* data)
{
    /* TODO: For the Step 2 you will have to make this function thread-safe */

    struct bst_node** node = root;
 
    if(node){
        if(*node)
            assert(pthread_mutex_lock(&(*node)->nodeMutex) == 0); //lock node (if any)
    }

    while (*node != NULL) {
        int compare_result = compare(data, (*node)->data);
        if (compare_result < 0){
            if((*node)->left){
                assert(pthread_mutex_lock(&(*node)->left->nodeMutex) == 0); //lock left child
            }
            if(parent && *parent){
                    assert(pthread_mutex_unlock(&(*parent)->nodeMutex) == 0);///unlock parent (if any)
            }
            parent = node; 
            node = &(*node)->left;
        }
        else if (compare_result > 0){
            if((*node)->right){
                assert(pthread_mutex_lock(&(*node)->right->nodeMutex) == 0); //lock right child
            }
            if(parent && *parent){
                    assert(pthread_mutex_unlock(&(*parent)->nodeMutex) == 0);//unlock parent (if any)
            }
            parent = node;
            node = &(*node)->right;
        }
        else
            break;
    }

    //node and parent is locked
    return node;
}


/**
 * Deletes the requested node.
 *
 * @param node       node to be deleted
 */
static void
node_delete_aux(struct bst_node** node)
{
    /* TODO: For Step 2 you will have to make this function thread-safe */
    //node and parent (if they exist) are locked
    struct bst_node* old_node = *node;

        if ((*node)->left == NULL) {
            *node = (*node)->right;
            free_node(old_node);
        } else if ((*node)->right == NULL) {
            *node = (*node)->left;
            free_node(old_node);
        } else {
            assert(pthread_mutex_lock(&(*node)->left->nodeMutex) == 0); //lock pred
            struct bst_node** pred = &(*node)->left;
            while ((*pred)->right != NULL) {
                assert(pthread_mutex_lock(&(*pred)->right->nodeMutex) == 0); //lock right child
                assert(pthread_mutex_unlock(&(*pred)->nodeMutex) == 0); //unlock pred
                pred = &(*pred)->right;
            }

            /* Swap values */
            void* temp = (*pred)->data;
            (*pred)->data = (*node)->data;
            (*node)->data = temp;

            

            /*delete pred, vi får problem med global parent om vi kör rekursivt*/
            //node_delete_aux(pred);
            struct bst_node* temp42 = *pred;
            *pred = (*pred)->left;
            free_node(temp42);/////////////////////////
            assert(pthread_mutex_unlock(&(*node)->nodeMutex) == 0); //unlock node
        }
    
//får vi inte problem med detta när vi kör rekursivt?????????
        if(parent && *parent){
                assert(pthread_mutex_unlock(&((**parent).nodeMutex)) == 0); //unlock parent
        }
}

/**
 * Deletes the node which points to the requested data.
 *
 * @param root       root of the tree
 * @param comparator function used to compare nodes
 * @param data       pointer to the data to be deleted
 * @return           1 if data is not found, 0 otherwise
 */
int
node_delete(struct bst_node** root, comparator compare, void* data)
{
    struct bst_node** node = search(root, compare, data);

    if (*node == NULL)
        return -1;

    node_delete_aux(node);

    return 0;
}

/**
 * Deletes the node which points to the requested data.
 *
 * Should be safe when called in parallel with other threads that
 * might call the same functions. Uses fine grained locking.
 *
 * @param root       root of the tree
 * @param comparator function used to compare nodes
 * @param data       pointer to the data to be deleted
 * @return           1 if data is not found, 0 otherwise
 */
int
node_delete_ts_cg(struct bst_node** root, comparator compare, void* data)
{
    /* TODO: Fill-in the body of this function */

    assert(pthread_mutex_lock(&mutexCG) == 0); //lock mutexCG

    struct bst_node** node = search(root, compare, data); //find the node (if any) to delete
    node_delete_aux(node);

    assert(pthread_mutex_unlock(&mutexCG) == 0); //unlock mutexCG
    return 0;
}

/**
 * Deletes the node which points to the requested data.
 *
 * Should be safe when called in parallel with other threads that
 * might call the same functions. Uses fine grained locking.
 *
 * @param root       root of the tree
 * @param comparator function used to compare nodes
 * @param data       pointer to the data to be deleted
 * @return           1 if data is not found, 0 otherwise
 */
int
node_delete_ts_fg(struct bst_node** root, comparator compare, void* data)
{
    /* TODO: Fill-in the body of this function */
    struct bst_node** node = search(root, compare, data); //find node to delete

    if (*node == NULL)
        return -1;

    node_delete_aux(node); //delete node
    return 0;
}


/**
 * Allocate resources and initialize a BST.
 *
 * @return           root of the BST
 */
struct bst_node **
tree_init(void)
{
    struct bst_node** root = malloc(sizeof(*root));
    if (root == NULL) {
        fprintf(stderr, "Out of memory!\n");
        exit(1);
    }
    *root = NULL;

    /* TODO: Initialize any global variables you use for the BST */
     pthread_mutex_init(&mutexCG, NULL); //initialize mutexCG 


    return root;
}

/**
 * Remove resources for the tree.
 *
 * @param root       root of the tree
 */
void
tree_fini(struct bst_node ** root)
{
    /* TODO: Free any global variables you used for the BST */
    pthread_mutex_destroy(&mutexCG); //destroy mutexCG
    if (root != NULL)
        free(root);
}


/**
 * Inserts a new node with the requested data if not already in the tree.
 *
 * @param root       root of the tree
 * @param comparator function used to compare nodes
 * @param data       pointer to the data to be inserted
 * @return           1 if data is in the BST already, 0 otherwise
 */
int
node_insert(struct bst_node** root, comparator compare, void* data)
{
    struct bst_node** node = search(root, compare, data);
    if(parent && *parent)
        assert(pthread_mutex_unlock(&((*parent)->nodeMutex)) == 0);//unlock parent (if any)
    if (*node == NULL) {
        *node = new_node(data);
        return 0;
    } else{
        assert(pthread_mutex_unlock(&((*node)->nodeMutex)) == 0);//unlock node
        return 1;
        }
}


/**
 * Creates a new node with the requested data.
 *
 * @param data       pointer to the data pointed be the new node
 */
struct bst_node* 
new_node(void* data)
{
    struct bst_node* node = malloc(sizeof(struct bst_node));
    if (node == NULL) {
        fprintf(stderr, "Out of memory!\n");
        exit(1);
    } else {
        /* TODO: Initialize any per node variables you use for the BST */
        pthread_mutex_init(&((*node).nodeMutex), NULL); //initialize nodeMutex
        node->left = NULL;
        node->right = NULL;
        node->data = data;
    }

    return node;
}


/**
 * Deletes a node.
 *
 * @param node       node to be freed
 */
void
free_node(struct bst_node* node) 
{
    if (node == NULL)
        fprintf(stderr, "Invalid node\n");
    else {
        /* TODO: Finalize any per node variables you use for the BST */
        pthread_mutex_destroy(&((*node).nodeMutex)); //destroy nodeMutex

        free(node);
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
