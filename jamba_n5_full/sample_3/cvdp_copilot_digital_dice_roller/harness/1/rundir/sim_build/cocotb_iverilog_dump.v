module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/digital_dice_roller.fst");
    $dumpvars(0, digital_dice_roller);
end
endmodule
