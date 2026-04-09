

Now, I want you to generate the Verilog code for a top-level module named "TopModule" that instantiates these modules in the following order:

- First instantiate S1 with i_data as a wire named "i_data".
- Then instantiate S2 with i_data as a wire named "s2_in".
- Then instantiate S3 with i_data as a wire named "s3_in".
- Then instantiate S4 with i_data as a wire named "s4_in".
- Finally, instantiate S5 with i_data as a wire named "s5_in".

The TopModule should be placed in the same directory as the other files (rtl/), and it should include all necessary module instantiations and connections. Additionally, the TopModule should have an output port "o_top" connected to the output of S5 (o_data).

Make sure to follow the naming conventions and use appropriate syntax for the Verilog language.

Also, ensure that the top-level module is written in Verilog syntax and that it includes the necessary `module` and `endmodule` statements.


