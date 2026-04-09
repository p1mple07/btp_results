module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/hamming_code_receiver.fst");
    $dumpvars(0, hamming_code_receiver);
end
endmodule
