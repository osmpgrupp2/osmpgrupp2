/**
 * Binary search tree implementation, function and type definitions
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
 * included in all copies or substantial portions of the Software.
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

#ifndef _BST_H_
#define _BST_H_

#include <pthread.h>

/**
 * Type of the function use to define a comparison between data in the
 * binary search tree.
 * @return  < 0 when (left<right), 
 *          0   when (left==right), 
 *          > 0 when (left>right). 
 */
typedef int comparator(const void* left, const void* right);

/**
 * Type of the node of the BST 
 * NOTE: You can add more fields here.
 */
struct bst_node {
    void* data;
    struct bst_node* left;
    struct bst_node* right;
};



struct bst_node ** tree_init(void);
void tree_fini( struct bst_node **root);
struct bst_node* new_node(void* data);
void free_node(struct bst_node* node);
struct bst_node** search(struct bst_node** root, comparator compare, void* data);
int node_insert(struct bst_node** root, comparator compare, void* data);
int node_delete(struct bst_node** root, comparator compare, void* data);
int node_delete_ts_cg(struct bst_node** root, comparator compare, void* data);
int node_delete_ts_fg(struct bst_node** root, comparator compare, void* data);
#endif

/*
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * indent-tabs-mode: nil
 * c-file-style: "stroustrup"
 * End:
 */
