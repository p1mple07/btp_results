// Define a function to generate random test vectors
function automatic void gen_random_test_vector();
	$display("Random Test Vector");
	
	integer i;
	for (i=0; i<5; ++i) begin
		$display("%d", i+1);
	end

endfunction