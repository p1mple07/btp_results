module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/caesar_cipher.fst");
    $dumpvars(0, caesar_cipher);
end
endmodule
