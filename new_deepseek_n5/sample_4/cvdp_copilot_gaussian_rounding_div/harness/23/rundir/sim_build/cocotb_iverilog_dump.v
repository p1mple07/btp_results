module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/divider.fst");
    $dumpvars(0, divider);
end
endmodule
