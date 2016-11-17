module icache_one_line(
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
	/*
	+---+---+---+---+---+---+---+
	| 8 | 8 | 8 | 8 | t | v | d |
	+---+---+---+---+---+---+---+
	8 - 8 bytes, 64 bits, total 256 bit/a block
	t - tag
	v - valid
	d - dirty
	*/
	reg		mem[255:0];
	//addr(32) = tag(19) + index_in_block(8) + addr_in_block(5)
	reg		tag[18:0];
	reg		valid_bit, dirty_bit;

	wire[18:0]	addr_tag;
	wire[4:0]	addr_in_block;

	//mid var
	assign addr_tag 		= address_in[31:13];
	assign addr_in_block 	= address_in[4:0];

	//output assign
	assign hit 		= compare == 1 ? addr_tag == tag : 0;
	assign dirty 	= dirty_bit;
	assign valid 	= valid_bit;

	initial begin
		mem = 0; tag = 0; valid_bit = 0; dirty_bit = 0
	end

	always@(posedge clk) begin
		if(enable == 1'b1) begin
			if(rst == 1'b1) begin
				hit 	<= 1'b0;
				dirty 	<= 1'b0;
				valid 	<= 1'b0;
				data_o 	<= 32'h0;
			end
			else if(read == 1'b1) begin
				//Pay attention
				//big endian
				data_o  <= mem[ ((addr_in_block + 4) << 3) - 1 : addr_in_block << 3];
			end
			else if(read == 1'b0) begin 
				//write data
				mem <= data_line_in;
				tag <= addr_tag;
				valid_bit <= 1'b0;
				dirty_bit <= 1'b0;
			end
		end
	end



endmodule