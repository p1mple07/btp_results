


Now, consider that the task is to **translate the specification to RTL code** for the `cross_correlation` module, ensuring that the `cross_correlation.sv` is correctly implemented, and the top-level module `cross_correlation` is instantiated with correct parameters. The `cross_correlation` module should be designed with the following specifications:

1. The number of data input samples (NS_DATA_IN) is 5.
2. The bit width of each data sample (NBW_DATA_IN) is 2.
3. The number of integer bits in the data samples (NBI_DATA_IN) is 1.
4. The energy output bit width (NBW_ENERGY) is 5.
5. The correlation should be computed using a correlation algorithm that is implemented in a separate module `correlate`.
6. The cross-correlation module should use the `adder_2d_layers` module to perform 2D summation and energy computation.
7. The cross-correlation module should expose a top-level signal `o_energy` for the computed energy.

Ensure that all parameters are correctly passed and that the internal signals are properly connected. Also, the `cross_correlation` module should instantiate the `correlate` module, `adder_2d_layers`, and the top-level signal `o_energy` must be connected to the output of the `adder_2d_layers` module.

Finally, the top-level `cross_correlation` module must be placed in the rtl/ directory, and the generated RTL code should be correct, well-structured, and free of errors.


We need to translate the specification into the `cross_correlation.sv` module. Let's go step by step.

First, the module declaration:

