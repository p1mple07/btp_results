module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/axis_to_uart_tx.fst");
    $dumpvars(0, axis_to_uart_tx);
end
endmodule
