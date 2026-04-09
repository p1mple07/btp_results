module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/bcd_adder.fst");
    $dumpvars(0, bcd_adder);
end
endmodule
