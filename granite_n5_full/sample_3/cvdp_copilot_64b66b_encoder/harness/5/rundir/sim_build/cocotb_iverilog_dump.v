module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/encoder_64b66b.fst");
    $dumpvars(0, encoder_64b66b);
end
endmodule
