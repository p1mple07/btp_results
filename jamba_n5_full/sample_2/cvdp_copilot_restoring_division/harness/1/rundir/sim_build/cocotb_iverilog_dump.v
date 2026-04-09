module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/restoring_division.fst");
    $dumpvars(0, restoring_division);
end
endmodule
