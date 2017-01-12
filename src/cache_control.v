module cache_control(
	//Input
	clk, rst, d_cache_read, d_cache_write, i_cache_read, response_ram_to_cache,
	d_cache_miss, d_cache_dirty, d_cache_hit, i_cache_miss, i_cache_dirty, i_cache_hit,

	//Output
	i_cache_enable, i_cache_compare, i_cache_read_o, i_cache_data_line_i_ctr,
	d_cache_enable, d_cache_compare, d_cache_read_o, d_cache_addr_ctr,
	addr_cache_to_ram_ctr, enable_cache_to_ram, write_cache_to_ram, response_inst_cache_to_core, response_data_cache_to_core
	);
	input	clk;
	input	rst;
	input	d_cache_read;
	input	d_cache_write;
	input	i_cache_read;
	input	response_ram_to_cache;

	input	d_cache_miss;
	input	d_cache_dirty;
	input	d_cache_hit;
	input	i_cache_miss;
	input 	i_cache_dirty;
	input	i_cache_hit;

	output reg 	i_cache_enable;
	output reg 	i_cache_compare;
	output reg 	i_cache_read_o;
	output reg	i_cache_data_line_i_ctr;
	output reg	d_cache_enable;
	output reg	d_cache_compare;
	output reg	d_cache_read_o;
	output reg	d_cache_addr_ctr;

	output reg	addr_cache_to_ram_ctr;
	output reg	enable_cache_to_ram;
	output reg	write_cache_to_ram;
	output reg	response_inst_cache_to_core;
	output reg	response_data_cache_to_core;
		

	reg 	i_cache_enable0, i_cache_compare0, i_cache_read0, i_cache_data_line_i_ctr0, d_cache_enable0;
	reg	    d_cache_compare0, d_cache_read0, d_cache_addr_ctr0, addr_cache_to_ram_ctr0, enable_cache_to_ram0;
	reg	    write_cache_to_ram0, response_inst_cache_to_core0, response_data_cache_to_core0;

	reg 	i_cache_enable1, i_cache_compare1, i_cache_read1, i_cache_data_line_i_ctr1, d_cache_enable1;
	reg	    d_cache_compare1, d_cache_read1, d_cache_addr_ctr1, addr_cache_to_ram_ctr1, enable_cache_to_ram1;
	reg	    write_cache_to_ram1, response_inst_cache_to_core1, response_data_cache_to_core1;

	reg[3:0] state0;
	reg[3:0] state1;

	initial begin
		state0 = 0;
		state1 = 0;
	end
	/*
	assign i_cache_enable				=	i_cache_enable0				| 	i_cache_enable1;
	assign i_cache_compare 				=	i_cache_compare0 			|	i_cache_compare1;
	assign i_cache_read_o				=	i_cache_read0 				|	i_cache_read1;
	assign i_cache_data_line_i_ctr		=	i_cache_data_line_i_ctr0	|	i_cache_data_line_i_ctr1;
	assign d_cache_enable				=	d_cache_enable0				|	d_cache_enable1;
	assign d_cache_compare				=	d_cache_compare0			|	d_cache_compare1;
	assign d_cache_read_o				=	d_cache_read0				|	d_cache_read1;
	assign d_cache_addr_ctr				=	d_cache_addr_ctr0 			|	d_cache_addr_ctr1;
	assign addr_cache_to_ram_ctr		=	addr_cache_to_ram_ctr0		|	addr_cache_to_ram_ctr1;
	assign enable_cache_to_ram			=	enable_cache_to_ram0		|	enable_cache_to_ram1;
	assign write_cache_to_ram			=	write_cache_to_ram0			|	write_cache_to_ram1;
	assign response_inst_cache_to_core	=	response_inst_cache_to_core0|	response_inst_cache_to_core1;
	assign response_data_cache_to_core	=	response_data_cache_to_core0|	response_data_cache_to_core1;
	*/


	always@(posedge clk) begin
		case(state0)
			0: begin
				if(d_cache_read == 1'b1)
					state0	<=	1;
				else if(d_cache_write == 1'b1)
					state0 	<= 	2;
			end
			1: begin
				if(d_cache_hit == 1'b1)
					state0	<=	3;
				else if(d_cache_miss == 1'b1 && d_cache_dirty == 1'b0)
					state0	<=	5;
				else if(d_cache_miss == 1'b1 && d_cache_dirty == 1'b1)
					state0	<=	4;
				else
				    state0	<=	1;
			end
			2: begin
				if(d_cache_hit == 1'b1)
					state0	<=	3;
				else if(d_cache_miss == 1'b1 && d_cache_dirty == 1'b0)
					state0 	<=	5;
				else if(d_cache_miss == 1'b1 && d_cache_dirty == 1'b1)
					state0 	<=	4;
			end
			3: begin
				state0	<=	0;
			end
			4: begin
				if(response_ram_to_cache == 1'b1)
					state0 	<=	5;
			end
			5: begin
				if(response_ram_to_cache == 1'b1)
					state0 	<=	6;
			end
			6: begin
				if(d_cache_read == 1'b1)
					state0	<=	1;
				else if(d_cache_write == 1'b1)
					state0	<=	2;
			end
		endcase
		case(state1)
			0: begin
				if(i_cache_read == 1'b1)
					state1	<=	1;
			end
			1: begin
				if(i_cache_hit == 1'b1)
					state1	<=	2;
				else if(i_cache_miss == 1'b1 &&(d_cache_read == 1'b0 && d_cache_write == 1'b0 || response_data_cache_to_core == 1'b1))
					state1	<=	3;
			end
			2: begin
				state1	<=	0;
			end
			3: begin
				if(d_cache_miss == 1'b1 && response_ram_to_cache == 1'b1)
					state1	<=	4;
				else if(d_cache_hit == 1)
					state1	<=	5;
			end
			4: begin
				state1	<=	1;
			end
			5: begin
				state1	<=	1;
			end
		endcase
	end

	always@(*) begin
		i_cache_enable				<=	i_cache_enable0				| 	i_cache_enable1;
	 	i_cache_compare 			<=	i_cache_compare0 			|	i_cache_compare1;
	 	i_cache_read_o				<=	i_cache_read0 				|	i_cache_read1;
	 	i_cache_data_line_i_ctr		<=	i_cache_data_line_i_ctr0	|	i_cache_data_line_i_ctr1;
		d_cache_enable				<=	d_cache_enable0				|	d_cache_enable1;
		d_cache_compare				<=	d_cache_compare0			|	d_cache_compare1;
		d_cache_read_o				<=	d_cache_read0				|	d_cache_read1;
		d_cache_addr_ctr			<=	d_cache_addr_ctr0 			|	d_cache_addr_ctr1;
		addr_cache_to_ram_ctr		<=	addr_cache_to_ram_ctr0		|	addr_cache_to_ram_ctr1;
		enable_cache_to_ram			<=	enable_cache_to_ram0		|	enable_cache_to_ram1;
		write_cache_to_ram			<=	write_cache_to_ram0			|	write_cache_to_ram1;
		response_inst_cache_to_core	<=	response_inst_cache_to_core0|	response_inst_cache_to_core1;
		response_data_cache_to_core	<=	response_data_cache_to_core0|	response_data_cache_to_core1;
	end

	always@(state0 or state1) begin
		case(state0)
			0: begin
				i_cache_enable0 			<=	0;
				i_cache_compare0 			<=	0;
				i_cache_read0				<=	0;
				i_cache_data_line_i_ctr0 	<=	0;
				d_cache_enable0				<=	0;
				d_cache_compare0			<=	0;
				d_cache_read0				<=	0;
				d_cache_addr_ctr0			<=	0;
				addr_cache_to_ram_ctr0		<=	0;
				enable_cache_to_ram0		<=	0;
				write_cache_to_ram0			<=	0;
				response_inst_cache_to_core0<=	0;
				response_data_cache_to_core0<=	0;
			end
			1: begin
				i_cache_enable0 			<=	0;
				i_cache_compare0 			<=	0;
				i_cache_read0				<=	0;
				i_cache_data_line_i_ctr0 	<=	0;
				d_cache_enable0				<=	1;
				d_cache_compare0			<=	1;
				d_cache_read0				<=	1;
				d_cache_addr_ctr0			<=	1;
				addr_cache_to_ram_ctr0		<=	0;
				enable_cache_to_ram0		<=	0;
				write_cache_to_ram0			<=	0;
				response_inst_cache_to_core0<=	0;
				response_data_cache_to_core0<=	0;
			end
			2: begin
				i_cache_enable0 			<=	0;
				i_cache_compare0 			<=	0;
				i_cache_read0				<=	0;
				i_cache_data_line_i_ctr0 	<=	0;
				d_cache_enable0				<=	1;
				d_cache_compare0			<=	1;
				d_cache_read0				<=	0;
				d_cache_addr_ctr0			<=	1;
				addr_cache_to_ram_ctr0		<=	0;
				enable_cache_to_ram0		<=	0;
				write_cache_to_ram0			<=	0;
				response_inst_cache_to_core0<=	0;
				response_data_cache_to_core0<=	0;
			end
			3: begin
				i_cache_enable0 			<=	0;
				//i_cache_compare0 			<=	0;
				i_cache_read0				<=	0;
				i_cache_data_line_i_ctr0 	<=	0;
				d_cache_enable0				<=	0;
				d_cache_compare0			<=	1;
				d_cache_read0				<=	0;
				//d_cache_addr_ctr0			<=	0;
				addr_cache_to_ram_ctr0		<=	0;
				enable_cache_to_ram0		<=	0;
				write_cache_to_ram0			<=	0;
				response_inst_cache_to_core0<=	0;
				response_data_cache_to_core0<=	1;
			end
			4: begin
				i_cache_enable0 			<=	0;
				i_cache_compare0 			<=	0;
				i_cache_read0				<=	0;
				i_cache_data_line_i_ctr0 	<=	0;
				d_cache_enable0				<=	0;
				d_cache_compare0			<=	0;
				d_cache_read0				<=	0;
				d_cache_addr_ctr0			<=	0;
				addr_cache_to_ram_ctr0		<=	1;
				enable_cache_to_ram0		<=	1;
				write_cache_to_ram0			<=	1;
				response_inst_cache_to_core0<=	0;
				response_data_cache_to_core0<=	0;
			end
			5: begin
				i_cache_enable0 			<=	0;
				i_cache_compare0 			<=	0;
				i_cache_read0				<=	0;
				i_cache_data_line_i_ctr0 	<=	0;
				d_cache_enable0				<=	1;
				d_cache_compare0			<=	0;
				d_cache_read0				<=	0;
				d_cache_addr_ctr0			<=	1;
				addr_cache_to_ram_ctr0		<=	1;
				enable_cache_to_ram0		<=	1;
				write_cache_to_ram0			<=	0;
				response_inst_cache_to_core0<=	0;
				response_data_cache_to_core0<=	0;
			end
			6: begin
				i_cache_enable0 			<=	0;
				i_cache_compare0 			<=	0;
				i_cache_read0				<=	0;
				i_cache_data_line_i_ctr0 	<=	0;
				d_cache_enable0				<=	1;
				d_cache_compare0			<=	0;
				d_cache_read0				<=	0;
				d_cache_addr_ctr0			<=	1;
				addr_cache_to_ram_ctr0		<=	0;
				enable_cache_to_ram0		<=	0;
				write_cache_to_ram0			<=	0;
				response_inst_cache_to_core0<=	0;
				response_data_cache_to_core0<=	0;
			end
	    endcase
		case(state1)
			0: begin
				i_cache_enable1 			<=	0;
				i_cache_compare1 			<=	0;
				i_cache_read1				<=	0;
				i_cache_data_line_i_ctr1 	<=	0;
				d_cache_enable1				<=	0;
				d_cache_compare1			<=	0;
				d_cache_read1				<=	0;
				d_cache_addr_ctr1			<=	0;
				addr_cache_to_ram_ctr1		<=	0;
				enable_cache_to_ram1		<=	0;
				write_cache_to_ram1			<=	0;
				response_inst_cache_to_core1<=	0;
				response_data_cache_to_core1<=	0;
			end
			1: begin
				i_cache_enable1 			<=	1;
				i_cache_compare1 			<=	1;
				i_cache_read1				<=	1;
				i_cache_data_line_i_ctr1 	<=	0;
				d_cache_enable1				<=	0;
				d_cache_compare1			<=	0;
				d_cache_read1				<=	0;
				d_cache_addr_ctr1			<=	0;
				addr_cache_to_ram_ctr1		<=	0;
				enable_cache_to_ram1		<=	0;
				write_cache_to_ram1			<=	0;
				response_inst_cache_to_core1<=	0;
				response_data_cache_to_core1<=	0;
			end
			2: begin
				i_cache_enable1 			<=	1;
				i_cache_compare1 			<=	1;
				i_cache_read1				<=	1;
				i_cache_data_line_i_ctr1 	<=	0;
				d_cache_enable1				<=	0;
				d_cache_compare1			<=	0;
				d_cache_read1				<=	0;
				d_cache_addr_ctr1			<=	0;
				addr_cache_to_ram_ctr1		<=	0;
				enable_cache_to_ram1		<=	0;
				write_cache_to_ram1			<=	0;
				response_inst_cache_to_core1<=	1;
				response_data_cache_to_core1<=	0;
			end
			3: begin
				i_cache_enable1 			<=	0;
				i_cache_compare1 			<=	0;
				i_cache_read1				<=	0;
				i_cache_data_line_i_ctr1 	<=	0;
				d_cache_enable1				<=	1;
				d_cache_compare1			<=	1;
				d_cache_read1				<=	1;
				d_cache_addr_ctr1			<=	0;
				addr_cache_to_ram_ctr1		<=	0;
				enable_cache_to_ram1		<=	1;
				write_cache_to_ram1			<=	0;
				response_inst_cache_to_core1<=	0;
				response_data_cache_to_core1<=	0;
			end
			4: begin
				i_cache_enable1 			<=	1;
				i_cache_compare1 			<=	0;
				i_cache_read1				<=	0;
				i_cache_data_line_i_ctr1 	<=	0;
				d_cache_enable1				<=	0;
				d_cache_compare1			<=	0;
				d_cache_read1				<=	0;
				d_cache_addr_ctr1			<=	0;
				addr_cache_to_ram_ctr1		<=	0;
				enable_cache_to_ram1		<=	0;
				write_cache_to_ram1			<=	0;
				response_inst_cache_to_core1<=	0;
				response_data_cache_to_core1<=	0;
			end
			5: begin
				i_cache_enable1 			<=	1;
				i_cache_compare1 			<=	0;
				i_cache_read1				<=	0;
				i_cache_data_line_i_ctr1 	<=	1;
				d_cache_enable1				<=	0;
				d_cache_compare1			<=	0;
				d_cache_read1				<=	0;
				d_cache_addr_ctr1			<=	0;
				addr_cache_to_ram_ctr1		<=	0;
				enable_cache_to_ram1		<=	0;
				write_cache_to_ram1			<=	0;
				response_inst_cache_to_core1<=	0;
				response_data_cache_to_core1<=	0;
			end
		endcase
	end




endmodule