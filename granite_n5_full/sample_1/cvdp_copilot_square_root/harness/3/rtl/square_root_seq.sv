module square_root_seq(
    parameter WIDTH = 16,
    
    input logic [WIDTH-1:0] num,       
    output logic [WIDTH/2-1:0] root     
);
    reg [WIDTH-1:0] remainder,square;         
    reg [WIDTH/2-1:0] test_bit, temp_square;        
    integer i,j;

    always @(posedge clk) begin
        remainder <= num;               
        root <= 0;                      
        temp_square <= 0;
        
        for (i = WIDTH/2-1; i >= 0; i = i - 1) begin
            test_bit = {WIDTH{1'b1}};      
            temp_square = (root | test_bit);        
            
            for (j = 0; j < WIDTH; j = j + 1) begin
                if (temp_square[j]) 
                begin 
                    square <= square + (temp_square << j); 
                end 
            end 
            
            
            if (square <= remainder) begin
                root <= root | test_bit; 
            end
        end
    end
endmodule

python3 make_test_cases.py --width=16 --test_id=Maximum Input --n=256

// square_root_seq.sv
module square_root_seq(
    parameter WIDTH = 16,
    input logic [WIDTH-1:0] num
);
    //... (code snippet provided above)
    //... (code snippet provided above)
endmodule

module square_root_tb.sv

module square_root_tb.sv

endmodule

module square_root.sv

endmodule

mkdir rtl/square_root
cd rtl/square_root.sv

mkdir rtl/square_root

touch rtl/square_root_tb.sv

module square_root_tb.sv
endmodule