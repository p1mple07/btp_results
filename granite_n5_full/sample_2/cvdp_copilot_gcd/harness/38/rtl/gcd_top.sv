Here's how you can implement a function to determine the GCD of two integers without leaving a remainder. The function should accept two integers as input and return the GCD of the input integers.

First, we need to create a function to determine the GCD. We can use a recursive approach to find the GCD. 

In the given code snippet, we have a module called gcd_top.sv. You can change it to gcd.sv.

Now, let's write a function to compute the GCD recursively.

Here's an example of a function to calculate the GCD.sv.

function int unsigned GCD(int unsigned g1, int unsigned g2) {
    if (g1 and g2 are equal, then return g1.
    Otherwise, return the maximum of the two numbers.
    return max(g1, g2).
}