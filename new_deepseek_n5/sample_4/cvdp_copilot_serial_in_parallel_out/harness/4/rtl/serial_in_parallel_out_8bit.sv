module serial_in_parallel_out_8bit (
    input clock,
    input serial_in,
    output parallel_out
);

reg [7:0] reg;

alwaysposedge clock begin
    parallel_out = (reg << 1) | serial_in;
    reg = parallel_out;
end

endmodule