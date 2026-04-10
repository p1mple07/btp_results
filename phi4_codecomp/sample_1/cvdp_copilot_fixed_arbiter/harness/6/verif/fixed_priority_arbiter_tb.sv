`timescale 1ns / 1ps
module fixed_priority_arbiter_tb;

    // Inputs
    reg clk;
    reg reset;
    reg [7:0] req;

    // Outputs
    wire [7:0] grant;

    // Instantiate the Device Under Test (DUT)
    fixed_priority_arbiter dut (
        .clk(clk),
        .reset(reset),
        .req(req),
        .grant(grant)
    );

    always #5 clk = ~clk;

    task apply_reset;
        begin
            reset = 1;
            #10;            
            reset = 0;
        end
    endtask

    // Task: Drive request and check expected grant
    task drive_request(input [7:0] request, input [7:0] expected_grant);
        begin
            req = request;          
            #10;                    
            if (grant !== expected_grant) begin
                $display("ERROR: Unexpected grant value at time %0t | req=%b | expected grant=%b | observed grant=%b",
                         $time, req, expected_grant, grant);
            end else begin
                $display("PASS: Correct grant value at time %0t | req=%b | grant=%b", $time, req, grant);
            end
        end
    endtask

    // Test procedure
    initial begin
        // Initialize signals
        clk = 0;
        req = 8'b00000000;

        // Apply reset
        apply_reset;

        // Test Case 1: Single request
        drive_request(8'b00000001, 8'b00000001);  
        drive_request(8'b00000010, 8'b00000010);  
        drive_request(8'b00000100, 8'b00000100);  
        drive_request(8'b00000000, 8'b00000000);  

        // Test Case 2: Multiple requests (check priority handling)
        drive_request(8'b00001101, 8'b00000001);  
        drive_request(8'b10000000, 8'b10000000);  

        // Test Case 3: No requests
        drive_request(8'b00000000, 8'b00000000);  

        // Test Case 4: Assert reset during active requests
        drive_request(8'b00011000, 8'b00001000);  
        apply_reset;                              // Apply reset and check
        if (grant !== 8'b00000000) begin
            $display("ERROR: Grant not reset after reset signal at time %0t | grant=%b", $time, grant);
        end else begin
            $display("PASS: Grant correctly reset at time %0t | grant=%b", $time, grant);
        end

        #20 $finish;
    end

    // Monitor for debugging
    initial begin
        $monitor("Time=%0d | reset=%b | req=%b | grant=%b",
                 $time, reset, req, grant);
    end

    // Dump waveforms for debugging
    initial begin
        $dumpfile("test.vcd");          
        $dumpvars(0, fixed_priority_arbiter_tb);     
    end

endmodule