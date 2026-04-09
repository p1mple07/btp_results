module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/static_branch_predict.fst");
    $dumpvars(0, static_branch_predict);
end
endmodule
