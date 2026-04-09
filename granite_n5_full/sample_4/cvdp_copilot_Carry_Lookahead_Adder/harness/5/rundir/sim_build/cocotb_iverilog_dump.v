module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/pipelined_adder_32bit.fst");
    $dumpvars(0, pipelined_adder_32bit);
end
endmodule
