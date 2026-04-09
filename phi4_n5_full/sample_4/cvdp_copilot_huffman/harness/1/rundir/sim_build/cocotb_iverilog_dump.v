module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/huffman_encoder.fst");
    $dumpvars(0, huffman_encoder);
end
endmodule
