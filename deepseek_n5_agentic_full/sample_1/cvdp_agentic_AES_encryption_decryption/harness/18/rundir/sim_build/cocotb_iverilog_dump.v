module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/padding_top.fst");
    $dumpvars(0, padding_top);
end
endmodule
