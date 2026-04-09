module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/findfasterclock.fst");
    $dumpvars(0, findfasterclock);
end
endmodule
