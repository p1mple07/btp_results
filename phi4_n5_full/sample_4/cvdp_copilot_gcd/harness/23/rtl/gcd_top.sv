rtl/gcd_top.sv
----------------------------------------------------------------
// Modified RTL file implementing Stein’s (binary) GCD algorithm
// using SystemVerilog. This version removes the unused “greater_than” port
// and introduces a register to track the number of 2’s factored out.
// The datapath now performs right shifts and conditional subtractions
// according to Stein’s algorithm. The control FSM has been