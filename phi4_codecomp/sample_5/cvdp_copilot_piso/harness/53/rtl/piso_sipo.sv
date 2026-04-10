module piso_sipo #(parameter DATA_WIDTH = 64, parameter SHIFT_RIGHT = 1)(
    input clk,                                              // Clock input
    input reg_load,                                         // Control signal for parallel loading
    input piso_load,                                        // Control signal for serial loading
    input piso_shift_en,                                    // Shift enable for PISO
    input sipo_shift_en,                                    // Shift enable for SIPO
    input rst,                                              // Active-low reset signal
    input  [DATA_WIDTH-1:0] data_in,                        // Parallel data input
    output reg [DATA_WIDTH-1:0]  parallel_out,              // parallel data out from sipo
    output  [DATA_WIDTH-1:0] b2g_out,                       // binary to gray data output
    output reg done                                         // Done signal indicating SIPO completion
);

    localparam COUNT_WIDTH = $clog2(DATA_WIDTH);            // Calculate width for shift_count
    // Internal wires
    reg  piso_done;                                         // Done signal from PISO    
    reg [DATA_WIDTH-1:0] regs;                              // Internal register to hold the parallel data_in
    reg  [DATA_WIDTH-1:0] register_block_data_out;          // Parallel output data from each register     
    reg [DATA_WIDTH-1:0] shift_reg;                         // Shift register to hold the data
    reg [COUNT_WIDTH:0] bit_counter;                        // Parameterized bit_counter to track number of shifts
    reg serial_out; 					                    // Serial output data 
    reg [DATA_WIDTH-1:0] piso_sipo_reg;                     // Register to hold the shifted data
    reg piso_sipo_data_out;                                 // reg_piso_sipo output data
    reg [COUNT_WIDTH:0] shift_count;                        // Parameterized shift_counter to track number of shifts
    

    always @(posedge clk or negedge rst) begin
        if (!rst)begin 
            regs                    <= {DATA_WIDTH{1'b0}};    
            register_block_data_out <= {DATA_WIDTH{1'b0}};
         end
        else if (reg_load)begin 
            regs                    <= data_in;
        end
        else if (!reg_load) begin
            register_block_data_out <= regs;
        end    
     end


    always @(posedge clk or negedge rst) begin
        if (!rst) begin                                         
            shift_reg        <= {DATA_WIDTH{1'b0}};             
            serial_out       <= 1'b0;                           
            bit_counter      <= {COUNT_WIDTH{1'b0}};            
            piso_done        <= 1'b0;                           
        end else if (piso_load) begin                           
            shift_reg        <= register_block_data_out;        
            bit_counter      <= DATA_WIDTH;                     
            piso_done        <= 1'b0;                           
        end else if (piso_shift_en && bit_counter > 0) begin    
            if (SHIFT_RIGHT) begin                              
               serial_out    <= shift_reg[DATA_WIDTH-1];        
                shift_reg    <= shift_reg << 1;                 
            end else begin 
                 serial_out  <= shift_reg[0];                   
                shift_reg    <= shift_reg >> 1;                 
            end
            bit_counter      <= bit_counter - 1;                
        end else if (bit_counter == 0) begin
            piso_done        <= 1'b1;                           
        end
    end


    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            piso_sipo_reg       <= {DATA_WIDTH{1'b0}};          
            piso_sipo_data_out  <= 1'b0;                        
        end else if (!piso_done) begin
            if(SHIFT_RIGHT) begin
            piso_sipo_reg        <= {piso_sipo_reg[DATA_WIDTH-2:0],serial_out};
            end  
            else begin
            piso_sipo_reg        <= {serial_out, piso_sipo_reg[DATA_WIDTH-1:1]};
            end
        end else begin
            piso_sipo_data_out   <= piso_sipo_reg[0];           
            piso_sipo_reg        <= piso_sipo_reg >> 1;         
        end
    end


    always @(posedge clk or negedge rst) begin
        if (!rst) begin                                     	
            parallel_out     <= {DATA_WIDTH{1'b0}};             
            done             <= 1'b0;                              
            shift_count      <= {DATA_WIDTH{1'b0}};             
        end else begin
            if (sipo_shift_en) begin
                if (SHIFT_RIGHT) begin 
                    parallel_out    <= {parallel_out[DATA_WIDTH-2:0], piso_sipo_data_out}; 
                end else begin
                    parallel_out    <= {piso_sipo_data_out, parallel_out[DATA_WIDTH-1:1]}; 
                end
                shift_count   <= shift_count + 1;               
            end
            if (shift_count == (DATA_WIDTH - 1)) begin
                done         <= 1'b1;                           
                shift_count  <= {COUNT_WIDTH{1'b0}};            
            end else begin
                done         <= 1'b0;                           
            end
        end
    end 

     assign b2g_out = parallel_out ^ (parallel_out >> 1);
endmodule 