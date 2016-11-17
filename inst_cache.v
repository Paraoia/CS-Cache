module inst_cache(
	//Input
	enable, clk, rst, compare, read, address_in, data_line_in, 
	//Output
	 hit, dirty, valid, data_o
);

parameter ADDR_WIDTH = 32;
parameter INDEX_WIDTH = 8
parameter BLOCK_WIDTH = 5;
// 32 = tag(16 bit) + index(8 bit) + block(6 bit) + 4bytes(2 bit) 
parameter TAG_WIDTH = ADDR_WIDTH - 3 - INDEX_WIDTH - BLOCK_WIDTH;
parameter CACHE_DEPTH = 1 << INDEX_WIDTH;
parameter DATA_WIDTH = 32;
parameter BLOCK_SIZE = 1 << BLOCK_WIDTH;
parameter BLOCK_WIDTH = BLOCK_SIZE * DATA_WIDTH;

input 			enable;
input 			clk;
input			rst;
input			compare;
input			read;
input[ADDR_WIDTH 	- 1 : 0]	address_in;
input[CACHE_DEPTH 	- 1 : 0]	data_line_in;

output			hit;
output			dirty;
output			valid;
output[DATA_WIDTH 	- 1 : 0]	data_o;				
	
reg		icache[1:0][CACHE_DEPTH - 1 : 0][: 0][7:0]
	always@(posedge clk) begin
		if(enable == 1) begin
			
		end
	end


endmodule