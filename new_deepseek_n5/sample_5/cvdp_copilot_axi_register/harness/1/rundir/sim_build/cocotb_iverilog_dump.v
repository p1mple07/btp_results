module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/axi_register.fst");
    $dumpvars(0, axi_register);
end
endmodule
