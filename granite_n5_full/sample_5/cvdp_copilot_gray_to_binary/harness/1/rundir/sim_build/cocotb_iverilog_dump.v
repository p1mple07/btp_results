module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/gray_to_binary.fst");
    $dumpvars(0, gray_to_binary);
end
endmodule
