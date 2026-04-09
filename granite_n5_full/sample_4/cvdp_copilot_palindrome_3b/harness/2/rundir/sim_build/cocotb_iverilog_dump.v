module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/palindrome_detect.fst");
    $dumpvars(0, palindrome_detect);
end
endmodule
