module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/JK_flipflop.fst");
    $dumpvars(0, JK_flipflop);
end
endmodule
