module clock_divider(
    input clock,
    input rst_n,
    input sel,
    output clock_out
);
    // Counter for the division factor
    reg cnt = 0;
    // Signal to indicate division is active
    reg div_by = 0;
    
    // Clock edge trigger
    clock_edge clock;
    
    // Case statement for different division factors
    case (sel)
        2'b00: // Divide by 2
            div_by = 1;
            cnt = 0;
            #1;
        2'b01: // Divide by 4
            div_by = 3;
            cnt = 0;
            #3;
        2'b10: // Divide by 8
            div_by = 7;
            cnt = 0;
            #7;
        default:
            div_by = 0;
            cnt = 0;
            #0;
    endcase
    
    // When division is active, set output high
    if (div_by > 0)
        clock_out = 1;
    else
        clock_out = 0;
endmodule