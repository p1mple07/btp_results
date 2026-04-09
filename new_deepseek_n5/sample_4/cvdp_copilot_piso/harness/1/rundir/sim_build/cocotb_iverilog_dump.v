module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/piso_8bit.fst");
    $dumpvars(0, piso_8bit);
end
endmodule
