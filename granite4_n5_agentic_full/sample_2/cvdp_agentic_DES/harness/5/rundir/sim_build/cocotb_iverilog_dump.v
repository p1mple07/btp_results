module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/des3_enc.fst");
    $dumpvars(0, des3_enc);
end
endmodule
