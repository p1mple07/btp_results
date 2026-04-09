module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/neuromorphic_array.fst");
    $dumpvars(0, neuromorphic_array);
end
endmodule
