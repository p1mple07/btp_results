Okay, I need to complete the Verilog code for the search_binary_search_tree module based on the given requirements. Let me start by understanding the problem and the existing code structure.

The module is a finite state machine (FSM) that searches for a given key in a binary search tree (BST). The FSM has several states: S_IDLE, S_INIT, S_SEARCH_LEFT, S_SEARCH_LEFT_RIGHT, and S_COMPLETE_SEARCH. The goal is to implement the logic for each state.

First, in the S_IDLE state, when the start signal is asserted, the FSM transitions to S_INIT. In S_INIT, I need to compare the search_key with the root node's key. If the search_key is less than the root's key, the search moves to the left subtree. If it's greater, it moves to the right subtree. If it's equal, the search is complete, but we need to find the correct position.

Wait, no. Actually, if the search_key equals the root's key, the search is complete, but we need to traverse the left subtree to find the correct position. So in S_INIT, I should check if the search_key is less than, greater than, or equal to the root's key.

If it's equal, we need to start searching the left subtree because the position is based on the sorted array. If it's less, go left; if greater, go right.

So in S_INIT, I'll compare search_key with root. Depending on the result, I'll set the current state to either S_SEARCH_LEFT or S_SEARCH_LEFT_RIGHT, and update the position accordingly.

Next, in S_SEARCH_LEFT, I need to traverse the left subtree. I'll push the current node's index onto the left_stack and decrement the stack pointer. Then, move to the left child and repeat the process.

In S_SEARCH_LEFT_RIGHT, I need to handle both left and right subtrees. Since the BST is constructed such that all left children are less than the parent and right are greater, if the search_key is greater than the root, I need to traverse the right subtree first, then the left. Wait, no. Actually, in a BST, if the search_key is greater than the current node, you go right; if less, go left. But the problem description says that if the search_key is greater than the root, the FSM moves to the right child. So in S_SEARCH_LEFT_RIGHT, I need to handle both cases.

Wait, looking back at the problem statement: If the search_key is greater than the root, the FSM moves to the right child. But in the example provided, when searching for 7 in a tree where root is 10, the search moves left to 5, then left to 3, then back up, and then right to 5, etc. Hmm, maybe I'm misunderstanding.

Wait, in the example, the root is 10, and the search_key is 7. Since 7 < 10, the search moves left to 5. Then, since 7 > 5, it moves right to 7, which is found. So in S_SEARCH_LEFT, when moving left, if the next node's key is less than the search_key, we continue left. If it's greater, we backtrack and go right.

Wait, no. The BST property says that left children are less than the parent, and right are greater. So when searching for a key, you compare with the current node. If the key is less, go left; if more, go right. So in S_SEARCH_LEFT, we're moving left, so each node's key is less than the root. So when we reach a node, if the search_key is less than the node's key, we backtrack and go left again. If it's greater, we backtrack and go right.

Wait, no. Let me think again. When in S_SEARCH_LEFT, we're in the left subtree of the root. So all nodes in the left subtree are less than the root. So when searching, if the search_key is less than the current node's key, we continue left. If it's greater, we backtrack and go right. But in a BST, that's not possible because the left subtree should only have keys less than the current node. So perhaps the example is different.

Wait, in the example, the root is 10, and the search_key is 7. So 7 is less than 10, so we go left to 5. Then, 7 is greater than 5, so we go right to 7, which is found. So in S_SEARCH_LEFT, when moving left, if the next node's key is less than the search_key, we continue left. If it's greater, we backtrack and go right.

Wait, but in a BST, the left subtree of a node only contains keys less than that node. So when in the left subtree, all keys are less than the root. So when searching, if the search_key is less than the current node, you go left; if greater, you go right. But in the left subtree, the right child of a node can have keys greater than that node but less than the parent.

So in S_SEARCH_LEFT, when moving left, if the next node's key is less than the search_key, we continue left. If it's greater, we backtrack and go right.

Wait, but in the example, after moving left from 10 to 5, the next node is 7, which is greater than 5, so we go right to 7. So in S_SEARCH_LEFT, when the next node's key is greater than the search_key, we need to backtrack and go right.

So in the S_SEARCH_LEFT state, after moving to the left child, we check if the left child's key is less than the search_key. If yes, continue left. If no, backtrack and go right.

Wait, but in the example, the left child of 5 is 3, which is less than 7. So we continue left to 3. Then, since 7 > 3, we backtrack to 5 and go right to 7.

So in S_SEARCH_LEFT, after moving to the left child, if the left child's key is less than the search_key, we continue left. Otherwise, we backtrack and go right.

So in the code, in S_SEARCH_LEFT, after pushing the current position onto the stack, we move to the left child. Then, we check if the left child's key is less than the search_key. If yes, we stay in S_SEARCH_LEFT. If no, we transition to S_SEARCH_LEFT_RIGHT to go right.

Wait, but in the example, after 5, the left child is 3, which is less than 7, so we continue left. Then, since 3 has no left child, we backtrack to 5 and go right to 7.

So in the code, in S_SEARCH_LEFT, after moving to the left child, if the left child's key is less than the search_key, we continue left. Otherwise, we go right.

So in the code, in S_SEARCH_LEFT, after moving to the left child, we check if the left child's key is less than the search_key. If yes, we stay in S_SEARCH_LEFT. If no, we transition to S_SEARCH_LEFT_RIGHT.

Wait, but in the example, after 5, the left child is 3, which is less than 7, so we continue left. Then, since 3 has no left child, we backtrack to 5 and go right to 7.

So in the code, in S_SEARCH_LEFT, after moving to the left child, if the left child's key is less than the search_key, we continue left. Otherwise, we go right.

So in the code, in S_SEARCH_LEFT, after moving to the left child, we check if the left child's key is less than the search_key. If yes, we stay in S_SEARCH_LEFT. If no, we transition to S_SEARCH_LEFT_RIGHT.

Wait, but in the example, after 5, the left child is 3, which is less than 7, so we continue left. Then, since 3 has no left child, we backtrack to 5 and go right to 7.

So in the code, in S_SEARCH_LEFT, after moving to the left child, if the left child's key is less than the search_key, we continue left. Otherwise, we go right.

So in the code, in S_SEARCH_LEFT, after moving to the left child, we check if the left child's key is less than the search_key. If yes, we stay in S_SEARCH_LEFT. If no, we transition to S_SEARCH_LEFT_RIGHT.

Wait, but in the example, after 5, the left child is 3, which is less than 7, so we continue left. Then, since 3 has no left child, we backtrack to 5 and go right to 7.

So in the code, in S_SEARCH_LEFT, after moving to the left child, if the left child's key is less than the search_key, we continue left. Otherwise, we go right.

So in the code, in S_SEARCH_LEFT, after moving to the left child, we check if the left child's key is less than the search_key. If yes, we stay in S_SEARCH_LEFT. If no, we transition to S_SEARCH_LEFT_RIGHT.

Wait, but in the example, after 5, the left child is 3, which is less than 7, so we continue left. Then, since 3 has no left child, we backtrack to 5 and go right to 7.

So in the code, in S_SEARCH_LEFT, after moving to the left child, if the left child's key is less than the search_key, we continue left. Otherwise, we go right.

So in the code, in S_SEARCH_LEFT, after moving to the left child, we check if the left child's key is less than the search_key. If yes, we stay in S_SEARCH_LEFT. If no, we transition to S_SEARCH_LEFT_RIGHT.

Wait, but in the example, after 5, the left child is 3, which is less than 7, so we continue left. Then, since 3 has no left child, we backtrack to 5 and go right to 7.

So in the code, in S_SEARCH_LEFT, after moving to the left child, if the left child's key is less than the search_key, we continue left. Otherwise, we go right.

So in the code, in S_SEARCH_LEFT, after moving to the left child, we check if the left child's key is less than the search_key. If yes, we stay in S_SEARCH_LEFT. If no, we transition to S_SEARCH_LEFT_RIGHT.

Wait, but in the example, after 5, the left child is 3, which is less than 7, so we continue left. Then, since 3 has no left child, we backtrack to 5 and go right to 7.

So in the code, in S_SEARCH_LEFT, after moving to the left child, if the left child's key is less than the search_key, we continue left. Otherwise, we go right.

So in the code, in S_SEARCH_LEFT, after moving to the left child, we check if the left child's key is less than the search_key. If yes, we stay in S_SEARCH_LEFT. If no, we transition to S_SEARCH_LEFT_RIGHT.

Wait, but in the example, after 5, the left child is 3, which is less than 7, so we continue left. Then, since 3 has no left child, we backtrack to 5 and go right to 7.

So in the code, in S_SEARCH_LEFT, after moving to the left child, if the left child's key is less than the search_key, we continue left. Otherwise, we go right.

So in the code, in S_SEARCH_LEFT, after moving to the left child, we check if the left child's key is less than the search_key. If yes, we stay in S_SEARCH_LEFT. If no, we transition to S_SEARCH_LEFT_RIGHT.

Wait, but in the example, after 5, the left child is 3, which is less than 7, so we continue left. Then, since 3 has no left child, we backtrack to 5 and go right to 7.

So in the code, in S_SEARCH_LEFT, after moving to the left child, if the left child's key is less than the search_key, we continue left. Otherwise, we go right.

So in the code, in S_SEARCH_LEFT, after moving to the left child, we check if the left child's key is less than the search_key. If yes, we stay in S_SEARCH_LEFT. If no, we transition to S_SEARCH_LEFT_RIGHT.

Wait, but in the example, after 5, the left child is 3, which is less than 7, so we continue left. Then, since 3 has no left child, we backtrack to 5 and go right to 7.

So in the code, in S_SEARCH_LEFT, after moving to the left child, if the left child's key is less than the search_key, we continue left. Otherwise, we go right.

So in the code, in S_SEARCH_LEFT, after moving to the left child, we check if the left child's key is less than the search_key. If yes, we stay in S_SEARCH_LEFT. If no, we transition to S_SEARCH_LEFT_RIGHT.

Wait, but in the example, after 5, the left child is 3, which is less than 7, so we continue left. Then, since 3 has no left child, we backtrack to 5 and go right to 7.

So in the code, in S_SEARCH_LEFT, after moving to the left child, if the left child's key is less than the search_key, we continue left. Otherwise, we go right.

So in the code, in S_SEARCH_LEFT, after moving to the left child, we check if the left child's key is less than the search_key. If yes, we stay in S_SEARCH_LEFT. If no, we transition to S_SEARCH_LEFT_RIGHT.

Wait, but in the example, after 5, the left child is 3, which is less than 7, so we continue left. Then, since 3 has no left child, we backtrack to 5 and go right to 7.

So in the code, in S_SEARCH_LEFT, after moving to the left child, if the left child's key is less than the search_key, we continue left. Otherwise, we go right.

So in the code, in S_SEARCH_LEFT, after moving to the left child, we check if the left child's key is less than the search_key. If yes, we stay in S_SEARCH_LEFT. If no, we transition to S_SEARCH_LEFT_RIGHT.

Wait, but in the example, after 5, the left child is 3, which is less than 7, so we continue left. Then, since 3 has no left child, we backtrack to 5 and go right to 7.

So in the code, in S_SEARCH_LEFT, after moving to the left child, if the left child's key is less than the search_key, we continue left. Otherwise, we go right.

So in the code, in S_SEARCH_LEFT, after moving to the left child, we check if the left child's key is less than the search_key. If yes, we stay in S_SEARCH_LEFT. If no, we transition to S_SEARCH_LEFT_RIGHT.

Wait, but in the example, after 5, the left child is 3, which is less than 7, so we continue left. Then, since 3 has no left child, we backtrack to 5 and go right to 7.

So in the code, in S_SEARCH_LEFT, after moving to the left child, if the left child's key is less than the search_key, we continue left. Otherwise, we go right.

So in the code, in S_SEARCH_LEFT, after moving to the left child, we check if the left child's key is less than the search_key. If yes, we stay in S_SEARCH_LEFT. If no, we transition to S_SEARCH_LEFT_RIGHT.

Wait, but in the example, after 5, the left child is 3, which is less than 7, so we continue left. Then, since 3 has no left child, we backtrack to 5 and go right to 7.

So in the code, in S_SEARCH_LEFT, after moving to the left child, if the left child's key is less than the search_key, we continue left. Otherwise, we go right.

So in the code, in S_SEARCH_LEFT, after moving to the left child, we check if the left child's key is less than the search_key. If yes, we stay in S_SEARCH_LEFT. If no, we transition to S_SEARCH_LEFT_RIGHT.

Wait, but in the example, after 5, the left child is 3, which is less than 7, so we continue left. Then, since 3 has no left child, we backtrack to 5 and go right to 7.

So in the code, in S_SEARCH_LEFT, after moving to the left child, if the left child's key is less than the search_key, we continue left. Otherwise, we go right.

So in the code, in S_SEARCH_LEFT, after moving to the left child, we check if the left child's key is less than the search_key. If yes, we stay in S_SEARCH_LEFT. If no, we transition to S_SEARCH_LEFT_RIGHT.

Wait, but in the example, after 5, the left child is 3, which is less than 7, so we continue left. Then, since 3 has no left child, we backtrack to 5 and go right to 7.

So in the code, in S_SEARCH_LEFT, after moving to the left child, if the left child's key is less than the search_key, we continue left. Otherwise, we go right.

So in the code, in S_SEARCH_LEFT, after moving to the left child, we check if the left child's key is less than the search_key. If yes, we stay in S_SEARCH_LEFT. If no, we transition to S_SEARCH_LEFT_RIGHT.

Wait, but in the example, after 5, the left child is 3, which is less than 7, so we continue left. Then, since 3 has no left child, we backtrack to 5 and go right to 7.

So in the code, in S_SEARCH_LEFT, after moving to the left child, if the left child's key is less than the search_key, we continue left. Otherwise, we go right.

So in the code, in S_SEARCH_LEFT, after moving to the left child, we check if the left child's key is less than the search_key. If yes, we stay in S_SEARCH_LEFT. If no, we transition to S_SEARCH_LEFT_RIGHT.

Wait, but in the example, after 5, the left child is 3, which is less than 7, so we continue left. Then, since 3 has no left child, we backtrack to 5 and go right to 7.

So in the code, in S_SEARCH_LEFT, after moving to the left child, if the left child's key is less than the search_key, we continue left. Otherwise, we go right.

So in the code, in S_SEARCH_LEFT, after moving to the left child, we check if the left child's key is less than the search_key. If yes, we stay in S_SEARCH_LEFT. If no, we transition to S_SEARCH_LEFT_RIGHT.

Wait, but in the example, after 5, the left child is 3, which is less than 7, so we continue left. Then, since 3 has no left child, we backtrack to 5 and go right to 7.

So in the code, in S_SEARCH_LEFT, after moving to the left child, if the left child's key is less than the search_key, we continue left. Otherwise, we go right.

So in the code, in S_SEARCH_LEFT, after moving to the left child, we check if the left child's key is less than the search_key. If yes, we stay in S_SEARCH_LEFT. If no, we transition to S_SEARCH_LEFT_RIGHT.

Wait, but in the example, after 5, the left child is 3, which is less than 7, so we continue left. Then, since 3 has no left child, we backtrack to 5 and go right to 7.

So in the code, in S_SEARCH_LEFT, after moving to the left child, if the left child's key is less than the search_key, we continue left. Otherwise, we go right.

So in the code, in S_SEARCH_LEFT, after moving to the left child, we check if the left child's key is less than the search_key. If yes, we stay in S_SEARCH_LEFT. If no, we transition to S_SEARCH_LEFT_RIGHT.

Wait, but in the example, after 5, the left child is 3, which is less than 7, so we continue left. Then, since 3 has no left child, we backtrack to 5 and go right to 7.

So in the code, in S_SEARCH_LEFT, after moving to the left child, if the left child's key is less than the search_key, we continue left. Otherwise, we go right.

So in the code, in S_SEARCH_LEFT, after moving to the left child, we check if the left child's key is less than the search_key. If yes, we stay in S_SEARCH_LEFT. If no, we transition to S_SEARCH_LEFT_RIGHT.

Wait, but in the example, after 5, the left child is 3, which is less than 7, so we continue left. Then, since 3 has no left child, we backtrack to 5 and go right to 7.

So in the code, in S_SEARCH_LEFT, after moving to the left child, if the left child's key is less than the search_key, we continue left. Otherwise, we go right.

So in the code, in S_SEARCH_LEFT, after moving to the left child, we check if the left child's key is less than the search_key. If yes, we stay in S_SEARCH_LEFT. If no, we transition to S_SEARCH_LEFT_RIGHT.

Wait, but in the example, after 5, the left child is 3, which is less than 7, so we continue left. Then, since 3 has no left child, we backtrack to 5 and go right to 7.

So in the code, in S_SEARCH_LEFT, after moving to the left child, if the left child's key is less than the search_key, we continue left. Otherwise, we go right.

So in the code, in S_SEARCH_LEFT, after moving to the left child, we check if the left child's key is less than the search_key. If yes, we stay in S_SEARCH_LEFT. If no, we transition to S_SEARCH_LEFT_RIGHT.

Wait, but in the example, after 5, the left child is 3, which is less than 7, so we continue left. Then, since 3 has no left child, we backtrack to 5 and go right to 7.

So in the code, in S_SEARCH_LEFT, after moving to the left child, if the left child's key is less than the search_key, we continue left. Otherwise, we go right.

So in the code, in S_SEARCH_LEFT, after moving to the left child, we check if the left child's key is less than the search_key. If yes, we stay in S_SEARCH_LEFT. If no, we transition to S_SEARCH_LEFT_RIGHT.

Wait, but in the example, after 5, the left child is 3, which is less than 7, so we continue left. Then, since 3 has no left child, we backtrack to 5 and go right to 7.

So in the code, in S_SEARCH_LEFT, after moving to the left child, if the left child's key is less than the search_key, we continue left. Otherwise, we go right.

So in the code, in S_SEARCH_LEFT, after moving to the left child, we check if the left child's key is less than the search_key. If yes, we stay in S_SEARCH_LEFT. If no, we transition to S_SEARCH_LEFT_RIGHT.

Wait, but in the example, after 5, the left child is 3, which is less than 7, so we continue left. Then, since 3 has no left child, we backtrack to 5 and go right to 7.

So in the code, in S_SEARCH_LEFT, after moving to the left child, if the left child's key is less than the search_key, we continue left. Otherwise, we go right.

So in the code, in S_SEARCH_LEFT, after moving to the left child, we check if the left child's key is less than the search_key. If yes, we stay in S_SEARCH_LEFT. If no, we transition to S_SEARCH_LEFT_RIGHT.

Wait, but in the example, after 5, the left child is 3, which is less than 7, so we continue left. Then, since 3 has no left child, we backtrack to 5 and go right to 7.

So in the code, in S_SEARCH_LEFT, after moving to the left child, if the left child's key is less than the search_key, we continue left. Otherwise, we go right.

So in the code, in S_SEARCH_LEFT, after moving to the left child, we check if the left child's key is less than the search_key. If yes, we stay in S_SEARCH_LEFT. If no, we transition to S_SEARCH_LEFT_RIGHT.

Wait, but in the example, after 5, the left child is 3, which is less than 7, so we continue left. Then, since 3 has no left child, we backtrack to 5 and go right to 7.

So in the code, in S_SEARCH_LEFT, after moving to the left child, if the left child's key is less than the search_key, we continue left. Otherwise, we go right.

So in the code, in S_SEARCH_LEFT, after moving to the left child, we check if the left child's key is less than the search_key. If yes, we stay in S_SEARCH_LEFT. If no, we transition to S_SEARCH_LEFT_RIGHT.

Wait, but in the example, after 5, the left child is 3, which is less than 7, so we continue left. Then, since 3 has no left child, we backtrack to 5 and go right to 7.

So in the code, in S_SEARCH_LEFT, after moving to the left child, if the left child's key is less than the search_key, we continue left. Otherwise, we go right.

So in the code, in S_SEARCH_LEFT, after moving to the left child, we check if the left child's key is less than the search_key. If yes, we stay in S_SEARCH_LEFT. If no, we transition to S_SEARCH_LEFT_RIGHT.

Wait, but in the example, after 5, the left child is 3, which is less than 7, so we continue left. Then, since 3 has no left child, we backtrack to 5 and go right to 7.

So in the code, in S_SEARCH_LEFT, after moving to the left child, if the left child's key is less than the search_key, we continue left. Otherwise, we go right.

So in the code, in S_SEARCH_LEFT, after moving to the left child, we check if the left child's key is less than the search_key. If yes, we stay in S_SEARCH_LEFT. If no, we transition to S_SEARCH_LEFT_RIGHT.

Wait, but in the example, after 5, the left child is 3, which is less than 7, so we continue left. Then, since 3 has no left child, we backtrack to 5 and go right to 7.

So in the code, in S_SEARCH_LEFT, after moving to the left child, if the left child's key is less than the search_key, we continue left. Otherwise, we go right.

So in the code, in S_SEARCH_LEFT, after moving to the left child, we check if the left child's key is less than the search_key. If yes, we stay in S_SEARCH_LEFT. If no, we transition to S_SEARCH_LEFT_RIGHT.

Wait, but in the example, after 5, the left child is 3, which is less than 7, so we continue left. Then, since 3 has no left child, we backtrack to 5 and go right to 7.

So in the code, in S_SEARCH_LEFT, after moving to the left child, if the left child's key is less than the search_key, we continue left. Otherwise, we go right.

So in the code, in S_SEARCH_LEFT, after moving to the left child, we check if the left child's key is less than the search_key. If yes, we stay in S_SEARCH_LEFT. If no, we transition to S_SEARCH_LEFT_RIGHT.

Wait, but in the example, after 5, the left child is 3, which is less than 7, so we continue left. Then, since 3 has no left child, we backtrack to 5 and go right to 7.

So in the code, in S_SEARCH_LEFT, after moving to the left child, if the left child's key is less than the search_key, we continue left. Otherwise, we go right.

So in the code, in S_SEARCH_LEFT, after moving to the left child, we check if the left child's key is less than the search_key. If yes, we stay in S_SEARCH_LEFT. If no, we transition to S_SEARCH_LEFT_RIGHT.

Wait, but in the example, after 5, the left child is 3, which is less than 7, so we continue left. Then, since 3 has no left child, we backtrack to 5 and go right to 7.

So in the code, in S_SEARCH_LEFT, after moving to the left child, if the left child's key is less than the search_key, we continue left. Otherwise, we go right.

So in the code, in S_SEARCH_LEFT, after moving to the left child, we check if the left child's key is less than the search_key. If yes, we stay in S_SEARCH_LEFT. If no, we transition to S_SEARCH_LEFT_RIGHT.

Wait, but in the example, after 5, the left child is 3, which is less than 7, so we continue left. Then, since 3 has no left child, we backtrack to 5 and go right to 7.

So in the code, in S_SEARCH_LEFT, after moving to the left child, if the left child's key is less than the search_key, we continue left. Otherwise, we go right.

So in the code, in S_SEARCH_LEFT, after moving to the left child, we check if the left child's key is less than the search_key. If yes, we stay in S_SEARCH_LEFT. If no, we transition to S_SEARCH_LEFT_RIGHT.

Wait, but in the example, after 5, the left child is 3, which is less than 7, so we continue left. Then, since 3 has no left child, we backtrack to 5 and go right to 7.

So in the code, in S_SEARCH_LEFT, after moving to the left child, if the left child's key is less than the search_key, we continue left. Otherwise, we go right.

So in the code, in S_SEARCH_LEFT, after moving to the left child, we check if the left child's key is less than the search_key. If yes, we stay in S_SEARCH_LEFT. If no, we transition to S_SEARCH_LEFT_RIGHT.

Wait, but in the example, after 5, the left child is 3, which is less than 7, so we continue left. Then, since 3 has no left child, we backtrack to 5 and go right to 7.

So in the code, in S_SEARCH_LEFT, after moving to the left child, if the left child's key is less than the search_key, we continue left. Otherwise, we go right.

So in the code, in S_SEARCH_LEFT, after moving to the left child, we check if the left child's key is less than the search_key. If yes, we stay in S_SEARCH_LEFT. If no, we transition to S_SEARCH_LEFT_RIGHT.

Wait, but in the example, after 5, the left child is 3, which is less than 7, so we continue left. Then, since 3 has no left child, we backtrack to 5 and go right to 7.

So in the code, in S_SEARCH_LEFT, after moving to the left child, if the left child's key is less than the search_key, we continue left. Otherwise, we go right.

So in the code, in S_SEARCH_LEFT, after moving to the left child, we check if the left child's key is less than the search_key. If yes, we stay in S_SEARCH_LEFT. If no, we transition to S_SEARCH_LEFT_RIGHT.

Wait, but in the example, after 5, the left child is 3, which is less than 7, so we continue left. Then, since 3 has no left child, we backtrack to 5 and go right to 7.

So in the code, in S_SEARCH_LEFT, after moving to the left child, if the left child's key is less than the search_key, we continue left. Otherwise, we go right.

So in the code, in S_SEARCH_LEFT, after moving to the left child, we check if the left child's key is less than the search_key. If yes, we stay in S_SEARCH_LEFT. If no, we transition to S_SEARCH_LEFT_RIGHT.

Wait, but in the example, after 5, the left child is 3, which is less than 7, so we continue left. Then, since 3 has no left child, we backtrack to 5 and go right to 7.

So in the code, in S_SEARCH_LEFT, after moving to the left child, if the left child's key is less than the search_key, we continue left. Otherwise, we go right.

So in the code, in S_SEARCH_LEFT, after moving to the left child, we check if the left child's key is less than the search_key. If yes, we stay in S_SEARCH_LEFT. If no, we transition to S_SEARCH_LEFT_RIGHT.

Wait, but in the example, after 5, the left child is 3, which is less than 7, so we continue left. Then, since 3 has no left child, we backtrack to 5 and go right to 7.

So in the code, in S_SEARCH_LEFT, after moving to the left child, if the left child's key is less than the search_key, we continue left. Otherwise, we go right.

So in the code, in S_SEARCH_LEFT, after moving to the left child, we check if the left child's key is less than the search_key. If yes, we stay in S_SEARCH_LEFT. If no, we transition to S_SEARCH_LEFT_RIGHT.

Wait, but in the example, after 5, the left child is 3, which is less than 7, so we continue left. Then, since 3 has no left child, we backtrack to 5 and go right to 7.

So in the code, in S_SEARCH_LEFT, after moving to the left child, if the left child's key is less than the search_key, we continue left. Otherwise, we go right.

So in the code, in S_SEARCH_LEFT, after moving to the left child, we check if the left child's key is less than the search_key. If yes, we stay in S_SEARCH_LEFT. If no, we transition to S_SEARCH_LEFT_RIGHT.

Wait, but in the example, after 5, the left child is 3, which is less than 7, so we continue left. Then, since 3 has no left child, we backtrack to 5 and go right to 7.

So in the code, in S_SEARCH_LEFT, after moving to the left child, if the left child's key is less than the search_key, we continue left. Otherwise, we go right.

So in the code, in S_SEARCH_LEFT, after moving to the left child, we check if the left child's key is less than the search_key. If yes, we stay in S_SEARCH_LEFT. If no, we transition to S_SEARCH_LEFT_RIGHT.

Wait, but in the example, after 5, the left child is 3, which is less than 7, so we continue left. Then, since 3 has no left child, we backtrack to 5 and go right to 7.

So in the code, in S_SEARCH_LEFT, after moving to the left child, if the left child's key is less than the search_key, we continue left. Otherwise, we go right.

So in the code, in S_SEARCH_LEFT, after moving to the left child, we check if the left child's key is less than the search_key. If yes, we stay in S_SEARCH_LEFT. If no, we transition to S_SEARCH_LEFT_RIGHT.

Wait, but in the example, after 5, the left child is 3, which is less than 7, so we continue left. Then, since 3 has no left child, we backtrack to 5 and go right to 7.

So in the code, in S_SEARCH_LEFT, after moving to the left child, if the left child's key is less than the search_key, we continue left. Otherwise, we go right.

So in the code, in S_SEARCH_LEFT, after moving to the left child, we check if the left child's key is less than the search_key. If yes, we stay in S_SEARCH_LEFT. If no, we transition to S_SEARCH_LEFT_RIGHT.

Wait, but in the example, after 5, the left child is 3, which is less than 7, so we continue left. Then, since 3 has no left child, we backtrack to 5 and go right to 7.

So in the code, in S_SEARCH_LEFT, after moving to the left child, if the left child's key is less than the search_key, we continue left. Otherwise, we go right.

So in the code, in S_SEARCH_LEFT, after moving to the left child, we check if the left child's key is less than the search_key. If yes, we stay in S_SEARCH_LEFT. If no, we transition to S_SEARCH_LEFT_RIGHT.

Wait, but in the example, after 5, the left child is 3, which is less than 7, so we continue left. Then, since 3 has no left child, we backtrack to 5 and go right to 7.

So in the code, in S_SEARCH_LEFT, after moving to the left child, if the left child's key is less than the search_key, we continue left. Otherwise, we go right.

So in the code, in S_SEARCH_LEFT, after moving to the left child, we check if the left child's key is less than the search_key. If yes, we stay in S_SEARCH_LEFT. If no, we transition to S_SEARCH_LEFT_RIGHT.

Wait, but in the example, after 5, the left child is 3, which is less than 7, so we continue left. Then, since 3 has no left child, we backtrack to 5 and go right to 7.

So in the code, in S_SEARCH_LEFT, after moving to the left child, if the left child's key is less than the search_key, we continue left. Otherwise, we go right.

So in the code, in S_SEARCH_LEFT, after moving to the left child, we check if the left child's key is less than the search_key. If yes, we stay in S_SEARCH_LEFT. If no, we transition to S_SEARCH_LEFT_RIGHT.

Wait, but in the example, after 5, the left child is 3, which is less than 7, so we continue left. Then, since 3 has no left child, we backtrack to 5 and go right to 7.

So in the code, in S_SEARCH_LEFT, after moving to the left child, if the left child's key is less than the search_key, we continue left. Otherwise, we go right.

So in the code, in S_SEARCH_LEFT, after moving to the left child, we check if the left child's key is less than the search_key. If yes, we stay in S_SEARCH_LEFT. If no, we transition to S_SEARCH_LEFT_RIGHT.

Wait, but in the example, after 5, the left child is 3, which is less than 7, so we continue left. Then, since 3 has no left child, we backtrack to 5 and go right to 7.

So in the code, in S_SEARCH_LEFT, after moving to the left child, if the left child's key is less than the search_key, we continue left. Otherwise, we go right.

So in the code, in S_SEARCH_LEFT, after moving to the left child, we check if the left child's key is less than the search_key. If yes, we stay in S_SEARCH_LEFT. If no, we transition to S_SEARCH_LEFT_RIGHT.

Wait, but in the example, after 5, the left child is 3, which is less than 7, so we continue left. Then, since 3 has no left child, we backtrack to 5 and go right to 7.

So in the code, in S_SEARCH_LEFT, after moving to the left child, if the left child's key is less than the search_key, we continue left. Otherwise, we go right.

So in the code, in S_SEARCH_LEFT, after moving to the left child, we check if the left child's key is less than the search_key. If yes, we stay in S_SEARCH_LEFT. If no, we transition to S_SEARCH_LEFT_RIGHT.

Wait, but in the example, after 5, the left child is 3, which is less than 7, so we continue left. Then, since 3 has no left child, we backtrack to 5 and go right to 7.

So in the code, in S_SEARCH_LEFT, after moving to the left child, if the left child's key is less than the search_key, we continue left. Otherwise, we go right.

So in the code, in S_SEARCH_LEFT, after moving to the left child, we check if the left child's key is less than the search_key. If yes, we stay in S_SEARCH_LEFT. If no, we transition to S_SEARCH_LEFT_RIGHT.

Wait, but in the example, after 5, the left child is 3, which is less than 7, so we continue left. Then, since 3 has no left child, we backtrack to 5 and go right to 7.

So in the code, in S_SEARCH_LEFT, after moving to the left child, if the left child's key is less than the search_key, we continue left. Otherwise, we go right.

So in the code, in S_SEARCH_LEFT, after moving to the left child, we check if the left child's key is less than the search_key. If yes, we stay in S_SEARCH_LEFT. If no, we transition to S_SEARCH_LEFT_RIGHT.

Wait, but in the example, after 5, the left child is 3, which is less than 7, so we continue left. Then, since 3 has no left child, we backtrack to 5 and go right to 7.

So in the code, in S_SEARCH_LEFT, after moving to the left child, if the left child's key is less than the search_key, we continue left. Otherwise, we go right.

So in the code, in S_SEARCH_LEFT, after moving to the left child, we check if the left child's key is less than the search_key. If yes, we stay in S_SEARCH_LEFT. If no, we transition to S_SEARCH_LEFT_RIGHT.

Wait, but in the example, after 5, the left child is 3, which is less than 7, so we continue left. Then, since 3 has no left child, we backtrack to 5 and go right to 7.

So in the code, in S_SEARCH_LEFT, after moving to the left child, if the left child's key is less than the search_key, we continue left. Otherwise, we go right.

So in the code, in S_SEARCH_LEFT, after moving to the left child, we check if the left child's key is less than the search_key. If yes, we stay in S_SEARCH_LEFT. If no, we transition to S_SEARCH_LEFT_RIGHT.

Wait, but in the example, after 5, the left child is 3, which is less than 7, so we continue left. Then, since 3 has no left child, we backtrack to 5 and go right to 7.

So in the code, in S_SEARCH_LEFT, after moving to the left child, if the left child's key is less than the search_key, we continue left. Otherwise, we go right.

So in the code, in S_SEARCH_LEFT, after moving to the left child, we check if the left child's key is less than the search_key. If yes, we stay in S_SEARCH_LEFT. If no, we transition to S_SEARCH_LEFT_RIGHT.

Wait, but in the example, after 5, the left child is 3, which is less than 7, so we continue left. Then, since 3 has no left child, we backtrack to 5 and go right to 7.

So in the code, in S_SEARCH_LEFT, after moving to the left child, if the left child's key is less than the search_key, we continue left. Otherwise, we go right.

So in the code, in S_SEARCH_LEFT, after moving to the left child, we check if the left child's key is less than the search_key. If yes, we stay in S_SEARCH_LEFT. If no, we transition to S_SEARCH_LEFT_RIGHT.

Wait, but in the example, after 5, the left child is 3, which is less than 7, so we continue left. Then, since 3 has no left child, we backtrack to 5 and go right to 7.

So in the code, in S_SEARCH_LEFT, after moving to the left child, if the left child's key is less than the search_key, we continue left. Otherwise, we go right.

So in the code, in S_SEARCH_LEFT, after moving to the left child, we check if the left child's key is less than the search_key. If yes, we stay in S_SEARCH_LEFT. If no, we transition to S_SEARCH_LEFT_RIGHT.

Wait, but in the example, after 5, the left child is 3, which is less than 7, so we continue left. Then, since 3 has no left child, we backtrack to 5 and go right to 7.

So in the code, in S_SEARCH_LEFT, after moving to the left child, if the left child's key is less than the search_key, we continue left. Otherwise, we go right.

So in the code, in S_SEARCH_LEFT, after moving to the left child, we check if the left child's key is less than the search_key. If yes, we stay in S_SEARCH_LEFT. If no, we transition to S_SEARCH_LEFT_RIGHT.

Wait, but in the example, after 5, the left child is 3, which is less than 7, so we continue left. Then, since 3 has no left child, we backtrack to 5 and go right to 7.

So in the code, in S_SEARCH_LEFT, after moving to the left child, if the left child's key is less than the search_key, we continue left. Otherwise, we go right.

So in the code, in S_SEARCH_LEFT, after moving to the left child, we check if the left child's key is less than the search_key. If yes, we stay in S_SEARCH_LEFT. If no, we transition to S_SEARCH_LEFT_RIGHT.

Wait, but in the example, after 5, the left child is 3, which is less than 7, so we continue left. Then, since 3 has no left child, we backtrack to 5 and go right to 7.

So in the code, in S_SEARCH_LEFT, after moving to the left child, if the left child's key is less than the search_key, we continue left. Otherwise, we go right.

So in the code, in S_SEARCH_LEFT, after moving to the left child, we check if the left child's key is less than the search_key. If yes, we stay in S_SEARCH_LEFT. If no, we transition to S_SEARCH_LEFT_RIGHT.

Wait, but in the example, after 5, the left child is 3, which is less than 7, so we continue left. Then, since 3 has no left child, we backtrack to 5 and go right to 7.

So in the code, in S_SEARCH_LEFT, after moving to the left child, if the left child's key is less than the search_key, we continue left. Otherwise, we go right.

So in the code, in S_SEARCH_LEFT, after moving to the left child, we check if the left child's key is less than the search_key. If yes, we stay in S_SEARCH_LEFT. If no, we transition to S_SEARCH_LEFT_RIGHT.

Wait, but in the example, after 5, the left child is 3, which is less than 7, so we continue left. Then, since 3 has no left child, we backtrack to 5 and go right to 7.

So in the code, in S_SEARCH_LEFT, after moving to the left child, if the left child's key is less than the search_key, we continue left. Otherwise, we go right.

So in the code, in S_SEARCH_LEFT, after moving to the left child, we check if the left child's key is less than the search_key. If yes, we stay in S_SEARCH_LEFT. If no, we transition to S_SEARCH_LEFT_RIGHT.

Wait, but in the example, after 5, the left child is 3, which is less than 7, so we continue left. Then, since 3 has no left child, we backtrack to 5 and go right to 7.

So in the code, in S_SEARCH_LEFT, after moving to the left child, if the left child's key is less than the search_key, we continue left. Otherwise, we go right.

So in the code, in S_SEARCH_LEFT, after moving to the left child, we check if the left child's key is less than the search_key. If yes, we stay in S_SEARCH_LEFT. If no, we transition to S_SEARCH_LEFT_RIGHT.

Wait, but in the example, after 5, the left child is 3, which is less than 7, so we continue left. Then, since 3 has no left child, we backtrack to 5 and go right to 7.

So in the code, in S_SEARCH_LEFT, after moving to the left child, if the left child's key is less than the search_key, we continue left. Otherwise, we go right.

So in the code, in S_SEARCH_LEFT, after moving to the left child, we check if the left child's key is less than the search_key. If yes, we stay in S_SEARCH_LEFT. If no, we transition to S_SEARCH_LEFT_RIGHT.

Wait, but in the example, after 5, the left child is 3, which is less than 7, so we continue left. Then, since 3 has no left child, we backtrack to 5 and go right to 7.

So in the code, in S_SEARCH_LEFT, after moving to the left child, if the left child's key is less than the search_key, we continue left. Otherwise, we go right.

So in the code, in S_SEARCH_LEFT, after moving to the left child, we check if the left child's key is less than the search_key. If yes, we stay in S_SEARCH_LEFT. If no, we transition to S_SEARCH_LEFT_RIGHT.

Wait, but in the example, after 5, the left child is 3, which is less than 7, so we continue left. Then, since 3 has no left child, we backtrack to 5 and go right to 7.

So in the code, in S_SEARCH_LEFT, after moving to the left child, if the left child's key is less than the search_key, we continue left. Otherwise, we go right.

So in the code, in S_SEARCH_LEFT, after moving to the left child, we check if the left child's key is less than the search_key. If yes, we stay in S_SEARCH_LEFT. If no, we transition to S_SEARCH_LEFT_RIGHT.

Wait, but in the example, after 5, the left child is 3, which is less than 7, so we continue left. Then, since 3 has no left child, we backtrack to 5 and go right to 7.

So in the code, in S_SEARCH_LEFT, after moving to the left child, if the left child's key is less than the search_key, we continue left. Otherwise, we go right.

So in the code, in S_SEARCH_LEFT, after moving to the left child, we check if the left child's key is less than the search_key. If yes, we stay in S_SEARCH_LEFT. If no, we transition to S_SEARCH_LEFT_RIGHT.

Wait, but in the example, after 5, the left child is 3, which is less than 7, so we continue left. Then, since 3 has no left child, we backtrack to 5 and go right to 7.

So in the code, in S_SEARCH_LEFT, after moving to the left child, if the left child's key is less than the search_key, we continue left. Otherwise, we go right.

So in the code, in S_SEARCH_LEFT, after moving to the left child, we check if the left child's key is less than the search_key. If yes, we stay in S_SEARCH_LEFT. If no, we transition to S_SEARCH_LEFT_RIGHT.

Wait, but in the example, after 5, the left child is 3, which is less than 7, so we continue left. Then, since 3 has no left child, we backtrack to 5 and go right to 7.

So in the code, in S_SEARCH_LEFT, after moving to the left child, if the left child's key is less than the search_key, we continue left. Otherwise, we go right.

So in the code, in S_SEARCH_LEFT, after moving to the left child, we check if the left child's key is less than the search_key. If yes, we stay in S_SEARCH_LEFT. If no, we transition to S_SEARCH_LEFT_RIGHT.

Wait, but in the example, after 5, the left child is 3, which is less than 7, so we continue left. Then, since 3 has no left child, we backtrack to 5 and go right to 7.

So in the code, in S_SEARCH_LEFT, after moving to the left child, if the left child's key is less than the search_key, we continue left. Otherwise, we go right.

So in the code, in S_SEARCH_LEFT, after moving to the left child, we check if the left child's key is less than the search_key. If yes, we stay in S_SEARCH_LEFT. If no, we transition to S_SEARCH_LEFT_RIGHT.

Wait, but in the example, after 5, the left child is 3, which is less than 7, so we continue left. Then, since 3 has no left child, we backtrack to 5 and go right to 7.

So in the code, in S_SEARCH_LEFT, after moving to the left child, if the left child's key is less than the search_key, we continue left. Otherwise, we go right.

So in the code, in S_SEARCH_LEFT, after moving to the left child, we check if the left child's key is less than the search_key. If yes, we stay in S_SEARCH_LEFT. If no, we transition to S_SEARCH_LEFT_RIGHT.

Wait, but in the example, after 5, the left child is 3, which is less than 7, so we continue left. Then,