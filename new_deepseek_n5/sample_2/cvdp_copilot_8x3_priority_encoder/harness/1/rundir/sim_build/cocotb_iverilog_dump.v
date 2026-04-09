module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/priority_encoder_8x3.fst");
    $dumpvars(0, priority_encoder_8x3);
end
endmodule
