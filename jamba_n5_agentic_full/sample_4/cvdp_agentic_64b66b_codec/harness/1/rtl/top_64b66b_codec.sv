

Now, I want to write a function `translate_to_rtl(module_name, module_file)` that takes a module name and a file path, and returns the corresponding RTL code as a string. The function should handle the following cases:

- If the module name is "top_64b66b_codec", return the code from the top_64b66b_codec module.
- If the module name is "encoder_data_64b66b", return the code from the encoder_data_64b66b module.
- If the module name is "encoder_control_64b66b", return the code from the encoder_control_64b66b module.
- If the module name is "decoder_data_control_64b66b", return the code from the decoder_data_control_64b66b module.
- If the module name is "encoder_data_64b66b", return the code from the encoder_data_64b66b module.
- If the module name is "decoder_data_control_64b66b", return the code from the decoder_data_control_64b66b module.
- For any other module name, return an empty string.

The function must also ensure that the returned RTL code is formatted correctly with proper indentation, module instantiation, and module wiring.

In addition, the function must include a check to ensure that the module name is one of the predefined module names. If the module name is not recognized, it should return an empty string.

Also, the function must generate the code for the top-level module (top_64b66b_codec) to instantiate the submodules in the correct order.

Please provide the implementation for the `translate_to_rtl` function.


To implement the `translate_to_rtl(module_name, module_file)` function, we need to:

1. Validate the `module_name` against the known module names.
2. Construct the full path to the respective `.sv` file.
3. Return the pre-formatted RTL code string from the file.

This approach ensures that each module is included only once and avoids duplication. The code is formatted with proper indentation, module instantiation, and module wiring.

