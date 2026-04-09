module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/jpeg_runlength_enc.fst");
    $dumpvars(0, jpeg_runlength_enc);
end
endmodule
