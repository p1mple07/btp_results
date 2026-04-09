            module mux_synch (

                input [7:0] data_in,   			//asynchronous data input
                input req,                  		//indicating that data is available at the data_in input
                input dst_clk,                 		//destination clock
                input src_clk,                 		//source clock
            	input nrst,                    		//asynchronous reset 
				output reg [7:0] data_out ); 		//synchronized version of data_in to the destination clock domain


            // Insert your implementation here

            endmodule

            