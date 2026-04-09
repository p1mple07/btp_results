module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/Bit_Difference_Counter.fst");
    $dumpvars(0, Bit_Difference_Counter);
end
endmodule
