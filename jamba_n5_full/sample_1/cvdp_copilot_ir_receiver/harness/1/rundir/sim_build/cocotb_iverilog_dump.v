module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/ir_receiver.fst");
    $dumpvars(0, ir_receiver);
end
endmodule
