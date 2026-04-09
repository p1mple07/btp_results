module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/SR_flipflop.fst");
    $dumpvars(0, SR_flipflop);
end
endmodule
