module icache_two_way_group(
	//Input
	enable, clk, rst, compare, read, address_in, data_line_in, 
	//Output
	 hit, dirty, valid, data_o
	);

	input 			enable, clk, rst, compare, read;
	input[31:0]		address_in;
	input[255:0]	data_line_in;

	output 			hit, dirty, valid;
	output[31:0]	data_o;

	wire			enable0, enable1;
	wire			hit0, hit1, dirty0, dirty1, valid0, valid1;
	wire[31:0]		data_o0, data_o1;
	reg             sel;

	initial begin
		sel = 1'b0;
	end
    
    assign hit 		 = hit0 | hit1;
    assign dirty     = hit0 ? dirty0 : (hit1 ? dirty1 : 0);
    assign valid     = hit0 ? valid0 : (hit1 ? valid1 : 0);
    assign data_o    = hit0 ? data_o0 : (hit1 ? data_o1 : 0);
    assign enable0   = enable & (read |(!read & (!valid0 & valid1 | !sel)));
    assign enable1  = enable & (read |(!read & (valid0 & !valid1 | sel)));
    
	icache_one_line	 icache_one_line0(
							.enable(enable0),
							.clk(clk),
							.rst(rst),
							.compare(compare),
							.read(read),
							.address_in(address_in),
							.data_line_in(data_line_in),
							.hit(hit0),
							.dirty(dirty0),
							.valid(valid0),
							.data_o(data_o0)	
						);
	
	icache_one_line	 icache_one_line1(
							.enable(enable1),
							.clk(clk),
							.rst(rst),
							.compare(compare),
							.read(read),
							.address_in(address_in),
							.data_line_in(data_line_in),
							.hit(hit1),
							.dirty(dirty1),
							.valid(valid1),
							.data_o(data_o1)	
						);

    always@(enable or read) begin
        if(enable == 1'b1) begin
            if(read == 1'b0) begin
                sel <= ~sel;
            end
        end
    end

endmodule