module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/unpack_one_hot.fst");
    $dumpvars(0, unpack_one_hot);
end
endmodule
