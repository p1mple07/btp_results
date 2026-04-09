module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/binary_to_one_hot_decoder_sequential.fst");
    $dumpvars(0, binary_to_one_hot_decoder_sequential);
end
endmodule
