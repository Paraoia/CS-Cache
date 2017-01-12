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
	output reg[31:0]	data_o;
	/*
	+---+---+---+---+---+---+---+
	| 8 | 8 | 8 | 8 | t | v | d |	one line
	+---+---+---+---+---+---+---+
	8 - 8 bytes, 64 bits, total 256 bit/a block
	t - tag
	v - valid
	d - dirty

	64 line
	+---+
	|	| one line
	+---+
	|	| one line	-> 64 line
	+---+
	|	| one line
	+---+
	.....
	1000000

	*/
	reg[255:0]	mem[63:0];
	//addr(32) = tag(21) + index_in_block(6) + addr_in_block(5)
	reg[20:0]	tag[63:0];
	reg		    valid_bit[63:0], dirty_bit[63:0];

	wire[20:0]	addr_tag;
	wire[5:0]	addr_index;
	wire[2:0]	addr_in_block;

	//mid var
	assign addr_tag 		= address_in[31:11];
	assign addr_index 		= address_in[10:5];
	assign addr_in_block 	= address_in[4:2];

	//output assign
	assign hit 		= compare == 1 ? (addr_tag == tag[addr_index]? 1'b1 : 1'b0) : 1'b0;
	assign dirty 	= dirty_bit[addr_index];
	assign valid 	= valid_bit[addr_index];

    integer i;
	initial begin
	  for(i = 0; i < 64; i = i + 1) begin
	       valid_bit[i] = 0;
	       dirty_bit[i] = 0;
	       tag[i] = 0;
	   end
	end

	always@(negedge clk) begin
		if(enable == 1'b1) begin
			if(rst == 1'b1) begin
				data_o 		<= 32'h0;
				for(i = 0; i < 64; i = i + 1) begin
				    valid_bit[i] <= 0;
				end
			end
			else if(read == 1'b1) begin
				//Pay attention
				//big endian
				case(addr_in_block)
					0:	data_o	<=	mem[addr_index][31:0];
					1:	data_o	<=	mem[addr_index][63:32];
					2:	data_o	<=	mem[addr_index][95:64];
					3:	data_o	<=	mem[addr_index][127:96];
					4:	data_o	<=	mem[addr_index][159:128];
					5:	data_o	<=	mem[addr_index][191:160];
					6:	data_o	<=	mem[addr_index][223:192];
					7:	data_o	<=	mem[addr_index][255:224];
				endcase
			end
			else if(read == 1'b0) begin 
				//write data
				mem[addr_index] <= data_line_in;
				tag[addr_index] <= addr_tag;
				valid_bit[addr_index] <= 1'b1;
				dirty_bit[addr_index] <= 1'b0;
			end
		end
	end



endmodule