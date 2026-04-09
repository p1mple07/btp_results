module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/hebb_gates.fst");
    $dumpvars(0, hebb_gates);
end
endmodule
