module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/Data_Reduction.fst");
    $dumpvars(0, Data_Reduction);
end
endmodule
