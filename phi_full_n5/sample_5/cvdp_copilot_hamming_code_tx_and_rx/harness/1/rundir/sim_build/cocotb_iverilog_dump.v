module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/hamming_code_tx_for_4bit.fst");
    $dumpvars(0, hamming_code_tx_for_4bit);
end
endmodule
