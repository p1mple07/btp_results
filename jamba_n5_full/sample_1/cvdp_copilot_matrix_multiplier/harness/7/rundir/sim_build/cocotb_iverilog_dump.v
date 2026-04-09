module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/matrix_multiplier.fst");
    $dumpvars(0, matrix_multiplier);
end
endmodule
