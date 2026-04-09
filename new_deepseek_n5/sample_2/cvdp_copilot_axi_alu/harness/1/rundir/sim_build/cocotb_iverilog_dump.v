module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/axi_alu.fst");
    $dumpvars(0, axi_alu);
end
endmodule
