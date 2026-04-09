module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/signedadder.fst");
    $dumpvars(0, signedadder);
end
endmodule
