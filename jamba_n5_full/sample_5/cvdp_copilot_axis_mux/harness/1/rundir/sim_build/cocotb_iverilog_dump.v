module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/axis_mux.fst");
    $dumpvars(0, axis_mux);
end
endmodule
