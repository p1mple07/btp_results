module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/perceptron_gates.fst");
    $dumpvars(0, perceptron_gates);
end
endmodule
