module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/hamming_rx.fst");
    $dumpvars(0, hamming_rx);
end
endmodule
