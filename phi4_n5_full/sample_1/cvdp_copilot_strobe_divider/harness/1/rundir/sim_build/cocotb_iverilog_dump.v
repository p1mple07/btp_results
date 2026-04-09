module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/strobe_divider.fst");
    $dumpvars(0, strobe_divider);
end
endmodule
