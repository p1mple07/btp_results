import os
from subprocess import Popen, PIPE

def divider(width):
    if width == 32:
        # Divider for 32-bit wide data
        proc = Popen(['iverilog', '-Wall', '-o', 'rtl/divider.sv'], stdout=PIPE). communicate() 
        # Divider using 32-bit wide data. 
        # The function divide(dividend, divisor). 
        # The function divide(dividend, divisor). 
        # The functions generate_files(dividend, divisor). 
        # The functions generate_code(dividend, divisor). 
        # The functions print_code(code)

        # Divider for 32-bit wide data
        div_code = '''

    /**
     * Divide the input "dividend" by "divisor".
     */
    module divider(
    /**
     * Divide the input "dividend" by "divisor"
     * @param {string} dividend
     * @param {int} divisor
     * @return {int} quotient
     */
     input string dividend,
     input int divisor,
     output int quotient ) ;

    // Insert code to implement non-restoring division algorithm
'''

    return div_code