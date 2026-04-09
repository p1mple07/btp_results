module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/reverse_bits.fst");
    $dumpvars(0, reverse_bits);
end
endmodule
