module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/cascaded_encoder.fst");
    $dumpvars(0, cascaded_encoder);
end
endmodule
