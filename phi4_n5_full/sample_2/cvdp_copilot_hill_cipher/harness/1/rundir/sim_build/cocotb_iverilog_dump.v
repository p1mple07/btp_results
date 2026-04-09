module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/hill_cipher.fst");
    $dumpvars(0, hill_cipher);
end
endmodule
