module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/uart_rx_to_axis.fst");
    $dumpvars(0, uart_rx_to_axis);
end
endmodule
