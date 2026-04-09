module unpack_one_hot (
    input logic [1:0] one_hot_selector,
    input logic sign,
    input logic [2:0] size,
    input logic [255:0] source_reg,
    output logic [511:0] destination_reg
);
