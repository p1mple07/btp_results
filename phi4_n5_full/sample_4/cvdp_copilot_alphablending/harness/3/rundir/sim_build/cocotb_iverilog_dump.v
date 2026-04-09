module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/alphablending.fst");
    $dumpvars(0, alphablending);
end
endmodule
