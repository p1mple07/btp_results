module cvdp_copilot_mem_allocator #(
    parameter SIZE  = 4,
    parameter ADDRW = $clog2(SIZE)
) (
    input  wire             clk,
    input  wire             reset,

    input  wire             acquire_en,    
    output wire [ADDRW-1:0] acquire_addr,      
    
    input  wire             release_en,
    input  wire [ADDRW-1:0] release_addr,    
    
    output wire             empty,
    output wire             full    
);

    // Internal registers for tracking free slots and allocation address
    reg [SIZE-1:0] free_slots;      // Current state: 1 = free, 0 = allocated
    reg [SIZE-1:0] free_slots_next; // Next state computed combinationally
    reg [ADDRW-1:0] acquire_addr_r;
    reg empty_r, full_r;    
    
    // Wires from the leading zero counter module
    wire [ADDRW-1:0] free_index;
    wire full_d;
    
    // Instantiate the leading zero counter.
    // It computes the index of the first available (free) slot in free_slots_next.
    cvdp_leading_zero_cnt #(
        .DATA_WIDTH(SIZE),
        .REVERSE(0)
    ) free_slots_sel (
        .data(free_slots_next),
        .leading_zeros(free_index),
        .all_zeros(full_d)
    );
    
    // Combinational logic: Compute the next state of free_slots based on requests.
    // Note: acquire_addr_r holds the slot to allocate in the current cycle.
    always @(*) begin
        free_slots_next = free_slots; // Default: no change.
        if (acquire_en) begin
            // Clear the bit corresponding to the current acquire address.
            free_slots_next[acquire_addr_r] = 1'b0;
        end
        if (release_en) begin
            // Set the bit corresponding to the released slot.
            free_slots_next[release_addr] = 1'b1;
        end
    end
    
    // Sequential logic: Update registers on the positive edge of clk.
    always @(posedge clk) begin
        if (reset) begin
            // Reset: All slots are free.
            free_slots      <= {SIZE{1'b1}};
            acquire_addr_r  <= 0;
            empty_r         <= 1;
            full_r          <= 0;
        end else begin
            // Update the free_slots register with the computed next state.
            free_slots      <= free_slots_next;
            // Update the acquire address register with the first available slot
            // computed by the leading zero counter.
            acquire_addr_r  <= free_index;
            // Update empty and full signals based on free_slots_next.
            empty_r         <= (free_slots_next == {SIZE{1'b1}});
            full_r          <= (free_slots_next == {SIZE{1'b0}});
        end
    end
    
    // Output assignments.
    assign acquire_addr = acquire_addr_r;
    assign empty        = empty_r;
    assign full         = full_r;
    
endmodule

// -------------------------------------------------------------------
// The following module implements a leading zero counter.
// It calculates the number of trailing zeros in the DATA_WIDTH-bit input.
// The module also asserts all_zeros high when the input is zero.
module cvdp_leading_zero_cnt #(
    parameter DATA_WIDTH = 32,
    parameter REVERSE = 0 
)(
    input  [DATA_WIDTH -1:0] data,
    output [$clog2(DATA_WIDTH)-1:0] leading_zeros,
    output all_zeros 
);
    localparam NIBBLES_NUM = DATA_WIDTH/4 ; 
    reg [NIBBLES_NUM-1 :0] all_zeros_flag ;
    reg [1:0]  zeros_cnt_per_nibble [NIBBLES_NUM-1 :0]  ;

    genvar i;
    integer k ;
    // Break the input data into 4-bit nibbles.
    reg [3:0]  data_per_nibble [NIBBLES_NUM-1 :0]  ;
    generate
        for (i=0; i < NIBBLES_NUM ; i=i+1) begin
            always @* begin
                data_per_nibble[i] = data[(i*4)+3: (i*4)] ;
            end
        end
    endgenerate
   
    generate
        for (i=0; i < NIBBLES_NUM ; i=i+1) begin
            if (REVERSE) begin
                always @* begin
                        zeros_cnt_per_nibble[i][1] = ~(data_per_nibble[i][1] | data_per_nibble[i][0]); 
                        zeros_cnt_per_nibble[i][0] = (~data_per_nibble[i][0]) &
                                                      ((~data_per_nibble[i][2]) | data_per_nibble[i][1]);
                        all_zeros_flag[i] = (data_per_nibble[i] == 4'b0000);
                end
            end else begin
                always @* begin
                    zeros_cnt_per_nibble[NIBBLES_NUM-1-i][1] = ~(data_per_nibble[i][3] | data_per_nibble[i][2]); 
                    zeros_cnt_per_nibble[NIBBLES_NUM-1-i][0] = (~data_per_nibble[i][3]) &
                                     ((~data_per_nibble[i][1]) | data_per_nibble[i][2]);
                    
                    all_zeros_flag[NIBBLES_NUM-1-i] = (data_per_nibble[i] == 4'b0000);
                end
            end
        end
    endgenerate

    reg [$clog2(NIBBLES_NUM)-1:0] index ; 
    reg [1:0]    choosen_nibbles_zeros_count ;
    reg [ $clog2(NIBBLES_NUM*4)-1:0] zeros_count_result ;
    wire [NIBBLES_NUM-1:0]         all_zeros_flag_decoded;
    
    assign all_zeros_flag_decoded[0] = all_zeros_flag[0] ;
    genvar j;
        generate
            for (j=1; j < NIBBLES_NUM; j=j+1) begin
                assign all_zeros_flag_decoded[j] = all_zeros_flag_decoded[j-1] & all_zeros_flag[j];
            end
        endgenerate

    always@ * begin
        index = 0 ;
        for ( k =0 ; k< NIBBLES_NUM ; k = k+1) begin
            index = index + all_zeros_flag_decoded[k] ;
        end
    end
    
    always@* begin
        choosen_nibbles_zeros_count = zeros_cnt_per_nibble[index]  ;  
        zeros_count_result = choosen_nibbles_zeros_count + (index << 2) ; 
    end
    
    assign leading_zeros = zeros_count_result ;
    assign all_zeros = (data == 0) ;

endmodule