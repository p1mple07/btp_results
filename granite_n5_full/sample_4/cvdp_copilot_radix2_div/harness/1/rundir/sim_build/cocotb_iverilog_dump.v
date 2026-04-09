module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/radix2_div.fst");
    $dumpvars(0, radix2_div);
end
endmodule
