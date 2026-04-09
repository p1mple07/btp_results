module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/axi_tap.fst");
    $dumpvars(0, axi_tap);
end
endmodule
