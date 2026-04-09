module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/cipher.fst");
    $dumpvars(0, cipher);
end
endmodule
