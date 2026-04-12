`timescale 1ns / 1ps

module sync_serial_communication_tb();

// Declaration of registers and wires
reg clk;                        // Clock signal
reg reset_n;                    // Active-low reset signal
reg [2:0] sel;                  // Selection signal
reg [63:0] data_in;             // Data input signal
wire done;                      // Done signal (output from DUT)
wire [63:0] data_out;           // Data output signal

integer i;                      // Loop variable for tasks
reg [63:0] expected_data_out;   // Expected output for verification

integer sel_value;
integer range_value;
integer data_in_rand;

// Instantiation of the Device Under Test (DUT)
sync_serial_communication_tx_rx uut_sync_communication_top (
    .clk(clk),
    .reset_n(reset_n),
    .sel(sel),
    .data_in(data_in),
    .data_out(data_out),
    .done(done)
);


initial begin
    clk = 0;
    forever #5 clk = ~clk;
end


task initialization();
begin
    @(posedge clk);
    data_in <= 64'd0;           // Reset data_in to 0
    sel     <= 3'b000;          // Reset selection signal
end
endtask


task reset();
begin
    reset_n = 1'b0;            
    @(posedge clk);
    initialization();          
    @(negedge clk);
    reset_n = 1'b1;            
end
endtask


task drive_data(input integer sel_mode, input integer range, input integer data_in_val);
    integer i;
    begin
        @(posedge clk);
        data_in = data_in_val;   
        expected_data_out = data_in_val;
        for (i = 0; i < range; i = i + 1) begin
            sel = sel_mode[2:0];     
            @(posedge clk);
        end
              
        wait(done);
        @(posedge clk);
        $display("%t DRIVE_DATA:: sel = %h, data_in = %h, data_out = %h, done = %b", $time, sel, data_in, data_out, done);
    end
endtask

always @(posedge clk) begin
    if(done) begin
        if (data_out !== expected_data_out) begin
            $display("%t ERROR at: Mismatch detected. Expected data_out = %h, but got %h", $time, expected_data_out, data_out);
            $display("----------------------------------------------------------------------------------------------------------");
        end else begin
            $display("%t CHECKER PASS at : expected_data_out = %h, data_out = %h", $time, expected_data_out,data_out);
            $display("----------------------------------------------------------------------------------------------------------");
        end
    end
end

initial begin
    // Initialize signals
    reset_n = 1'b0;
    data_in = 64'd0;

    // Apply reset
    reset();

    repeat(10) begin  
        
        sel_value = $urandom_range(1,4);  
        case (sel_value)
            1: begin
                range_value = 8;
                data_in_rand = {$random()}%127;
            end
            2: begin
                range_value = 16;
                data_in_rand = {$random()}%4196;
            end
            3: begin
                range_value = 32;
                data_in_rand = {$random()}%18192;
            end
            4: begin
                range_value = 64;
                data_in_rand = {$random()}%154097;
            end
            default: begin
                range_value = 8;
                data_in_rand = 64'd0;
            end
        endcase
      
        drive_data(sel_value, range_value, data_in_rand);
        reset();
    end
    #100;
    $finish;
end

// Generate VCD file for waveform analysis
initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, sync_serial_communication_tb);
end

endmodule