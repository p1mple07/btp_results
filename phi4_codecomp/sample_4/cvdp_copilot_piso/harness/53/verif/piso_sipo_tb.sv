module piso_sipo_tb();
parameter DATA_WIDTH = 64;
parameter SHIFT_RIGHT = 1;

reg clk;
reg reset_n;
reg reg_load;
reg piso_load;
reg piso_shift_en;
reg sipo_shift_en;
reg [DATA_WIDTH-1:0] data_in;
wire [DATA_WIDTH-1:0] b2g_output;
wire [DATA_WIDTH-1:0] parallel_out;
wire done;

integer i;
reg [DATA_WIDTH-1:0] expected_parallel_out;
reg [DATA_WIDTH-1:0] expecetd_b2g_out;

piso_sipo#(.DATA_WIDTH(DATA_WIDTH),.SHIFT_RIGHT(SHIFT_RIGHT))
uut_piso_sipo (
.clk(clk),
.rst(reset_n),
.reg_load(reg_load),
.piso_load(piso_load),
.piso_shift_en(piso_shift_en),
.sipo_shift_en(sipo_shift_en),
.data_in(data_in),
.b2g_out(b2g_output),
.parallel_out(parallel_out),
.done(done)
);

initial begin
clk = 0;
forever #5 clk = ~clk;
end

initial begin
reset_n = 1'b0;
@(posedge clk);
@(posedge clk);
initialization();
@(negedge clk);
reset_n = 1'b1;
repeat(10) begin
drive();
#10;
end

#100;
$finish();
end

task initialization();
begin
@(posedge clk);
if(!reset_n) begin
    data_in <= {DATA_WIDTH{1'b0}};
    reg_load <= 1'b0; 
    sipo_shift_en <= 1'b0;
    piso_shift_en <= 1'b0;
    piso_load <= 1'b0;
end
end
endtask

task drive();
begin
    register_block();
    piso_check();
    sipo_check();
end
endtask

task register_block();
begin
 @(posedge clk);                            
        reg_load <= 1'b1;                   
        data_in <= $urandom_range(1,(2**DATA_WIDTH)-1);          
        @(posedge clk);
        reg_load <= 1'b0;                   
        @(posedge clk);
        $display("Time = %t, reg_load = %b, data_in = %h", $time, reg_load, data_in); 
end
endtask

task piso_check();
begin
@(posedge clk);                             
        piso_load <= 1'b1;                  
        @(posedge clk);
        piso_load <= 1'b0;                  
        for (i = 0; i < DATA_WIDTH; i = i + 1) 
        begin 
            @(posedge clk);
            piso_shift_en <= 1'b1;           
        end
        @(posedge clk);  
        piso_shift_en <= 1'b0;              
        @(posedge clk);
        //$display("Time = %0t, piso_shift_en = %b, piso_load = %b", $time, piso_shift_en, piso_load); 
end
endtask

task sipo_check();
begin
 for (i = 0; i < DATA_WIDTH; i = i + 1) begin
            @(posedge clk);
            sipo_shift_en <= 1'b1;           
        end
        @(posedge clk);
        sipo_shift_en <= 1'b0;              
        @(posedge clk);
       // $display("Time = %0t, sipo_shift_en = %b,parallel_out = %h, b2g_output = %h", $time, sipo_shift_en, parallel_out,b2g_output); // Display status
end
endtask

always@(*) begin
    if(done == 1) begin
    if(SHIFT_RIGHT == 1) begin
    for(i = 0; i< DATA_WIDTH; i = i+1) begin
    expected_parallel_out[i] = data_in[DATA_WIDTH-1-i]; 
    expecetd_b2g_out = parallel_out ^(parallel_out >> 1);
    end
    end
    else begin
    expected_parallel_out = data_in;
    expecetd_b2g_out = parallel_out ^(parallel_out >> 1);
    end
    end
    end

     
     always @(posedge clk) begin
    if(done) begin
        if ((parallel_out == expected_parallel_out) &&(b2g_output == expecetd_b2g_out)) begin
            $display("Time = %0t MATCHED :: CHECKER PASS, DATA_WIDTH = %h,SHIFT_RIGHT = %b,data_in = %h, expected_parallel_out =%h, parallel_out = %h,expecetd_b2g_out = %h,b2g_output = %h", $time,DATA_WIDTH,SHIFT_RIGHT,data_in,expected_parallel_out, parallel_out,expecetd_b2g_out,b2g_output);
            $display("----------------------------------------------------------------------------------------------------------");
        end else begin
            $display("Time = %0t MIS_MATCHED :: CHECKER FAIL, DATA_WIDTH = %h,SHIFT_RIGHT = %b,data_in = %h,expected_parallel_out = %h, parallel_out = %h,expecetd_b2g_out = %h,b2g_output = %h", $time,DATA_WIDTH,SHIFT_RIGHT,data_in,expected_parallel_out, parallel_out,expecetd_b2g_out,b2g_output);
            $display("----------------------------------------------------------------------------------------------------------");
        end
    end
end


initial begin
$dumpfile("dump.vcd");
$dumpvars(0,piso_sipo_tb);
end


endmodule 