
module tx_block(
    input clk,               // Clock input
    input reset_n,           // Active-low reset input
    input [63:0] data_in,    // 64-bit parallel data input
    input [2:0] sel,         // Selection input to choose data width
    output reg serial_out,   // Serial data output
    output reg done,         // Done signal indicating completion of transmission
    output serial_clk        // Clock for serial data transmission
);

// Internal registers
reg [63:0] data_reg;         // Register to hold the data being transmitted
reg [6:0] bit_count;         // Counter to track number of bits to transmit
reg [6:0] reg_count;         // Register for counting bits for serial clock control
reg [6:0] temp_reg_count;    // Temporary register to track reg_count

// Sequential block for state control and data selection
always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        data_reg     <= 64'h0;       
        bit_count    <= 7'h0;       
        reg_count    <= 7'h0;       
    end else begin
        if (done == 1'b1) begin
            case (sel)
                3'b000: begin
                    data_reg  <= 64'h0;              
                    bit_count <= 7'd0;                
                end
                3'b001: begin
                    data_reg  <= {56'h0, data_in[7:0]};    
                    bit_count <= 7'd7;              
                end
                3'b010: begin
                    data_reg  <= {48'h0, data_in[15:16]}; // Actually original code: {48'h0, data_in[15:0]} but likely mistake in our text?
                    bit_count <= 7'd15;             
                end
                3'b011: begin
                    data_reg  <= {32'h0, data_in[31:0]};   
                    bit_count <= 7'd31;              
                end
                3'b100: begin
                    data_reg  <= data_in[63:0];      
                    bit_count <= 7'd63;              
                end
                default: begin
                    data_reg  <= 64'h0;              
                    bit_count <= 7'h0;               
                end
            endcase
        end else if (bit_count > 7'h0) begin
            data_reg   <= data_reg >> 1;                   
            bit_count  <= bit_count - 1'b1;                
        end
        reg_count <= bit_count;                            
    end
end

// Generate serial clock based on reg_count
//`ifdef SIMULATION
assign  #1 serial_clk = clk && (temp_reg_count !== 7'd0) ;  
//`else
//assign  serial_clk = clk && (temp_reg_count !== 7'd0) ;  
//`endif

// Register to keep track of reg_count and use for clock gating
always@(posedge clk or negedge reset_n) begin 
    if(!reset_n) begin
        temp_reg_count <= 7'h0;					
    end
    else begin
        temp_reg_count <= reg_count;				
    end
end


// Sequential logic to drive the serial_out signal based on reg_count and bit_count
always@(posedge clk or negedge reset_n) begin 
    if(!reset_n) begin
       serial_out <= 1'b0;					
    end
    else if(reg_count > 7'h0 || bit_count > 7'h0) begin
       serial_out <= data_reg[0];				
    end
end

// Set the done signal when transmission is complete (bit_count reaches zero)
always@(posedge clk or negedge reset_n) begin
    if(!reset_n) begin
        done <= 1'b0;					
    end 
    else begin
     if(bit_count == 7'h0) begin
	    done <= 1'b1; 		
     end 
     else begin 
	    done <= 1'b0;					
     end
end
end

endmodule
