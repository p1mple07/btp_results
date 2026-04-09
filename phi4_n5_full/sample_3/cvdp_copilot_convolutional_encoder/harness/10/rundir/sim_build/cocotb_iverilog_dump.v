module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/convolutional_encoder.fst");
    $dumpvars(0, convolutional_encoder);
end
endmodule
