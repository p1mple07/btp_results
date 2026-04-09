module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/kogge_stone_adder.fst");
    $dumpvars(0, kogge_stone_adder);
end
endmodule
