module cache_top(
	//Input
	rst, clk, 
	byte_w_en, d_cache_read, d_cache_write, data_core_to_dcache_i, address_core_to_dcache,
	i_cache_read, address_core_to_icache,
	response_ram_to_cache, data_ram_to_cache_i,
	//Output
	response_inst_cache_to_core, response_data_cache_to_core, 
	data_cache_to_core_o, inst_cache_to_core_o,
	enable_cache_to_ram, write_cache_to_ram,
	data_cache_to_ram_o, address_cache_to_ram
	);
	input 	rst, clk, d_cache_read, d_cache_write, i_cache_read, response_ram_to_cache;
	input[3:0]	byte_w_en;
	input[31:0]	data_core_to_dcache_i, address_core_to_dcache, address_core_to_icache;
	input[255:0]data_ram_to_cache_i;

	output 	response_inst_cache_to_core, response_data_cache_to_core, enable_cache_to_ram, write_cache_to_ram;
	output[31:0]	data_cache_to_core_o, inst_cache_to_core_o, address_cache_to_ram;
	output[255:0]	data_cache_to_ram_o;

	/*
	clk, rst, d_cache_read, d_cache_write, i_cache_read, response_ram_to_cache,
	d_cache_miss, d_cache_dirty, d_cache_hit, i_cache_miss, i_cache_dirty, i_cache_hit,

	//Output
	i_cache_enable, i_cache_compare, i_cache_read, i_cache_data_line_i_ctr,
	d_cache_enable, d_cache_compare, d_cache_read, d_cache_addr_ctr,
	addr_cache_to_ram_ctr, enable_cache_to_ram, response_inst_cache_to_core, response_data_cache_to_core

	*/
	wire 	d_cache_miss, d_cache_dirty, d_cache_hit, i_cache_miss, i_cache_dirty, i_cache_hit;
	wire 	i_cache_enable, i_cache_compare, i_cache_read_o, i_cache_data_line_i_ctr;
	wire 	d_cache_enable, d_cache_compare, d_cache_read_o, d_cache_addr_ctr;
	wire 	addr_cache_to_ram_ctr, enable_cache_to_ram;
	cache_control	cache_control0(
						.clk(clk),
						.rst(rst),
						.d_cache_read(d_cache_read),
						.d_cache_write(d_cache_write),
						.i_cache_read(i_cache_read),
						.response_ram_to_cache(response_ram_to_cache),
						.d_cache_miss(d_cache_miss),
						.d_cache_dirty(d_cache_dirty),
						.d_cache_hit(d_cache_hit),
						.i_cache_miss(i_cache_miss),
						.i_cache_dirty(i_cache_dirty),
						.i_cache_hit(i_cache_hit),
						
						.i_cache_enable(i_cache_enable),
						.i_cache_compare(i_cache_compare),
						.i_cache_read_o(i_cache_read_o),
						.i_cache_data_line_i_ctr(i_cache_data_line_i_ctr),
						.d_cache_enable(d_cache_enable),
						.d_cache_compare(d_cache_compare),
						.d_cache_read_o(d_cache_read_o), 
						.d_cache_addr_ctr(d_cache_addr_ctr),
						.addr_cache_to_ram_ctr(addr_cache_to_ram_ctr),
						.enable_cache_to_ram(enable_cache_to_ram), 
						.write_cache_to_ram(write_cache_to_ram),
						.response_inst_cache_to_core(response_inst_cache_to_core), 
						.response_data_cache_to_core(response_data_cache_to_core)
					);

	wire[31:0]	d_cache_addr_in;
	assign d_cache_addr_in = d_cache_addr_ctr == 0? address_core_to_icache : address_core_to_dcache;
	assign d_cache_miss = ~d_cache_hit;
	wire d_cache_valid;
	wire[31:0]			d_cache_address_out;
	dcache_two_way_group	dcache_two_way_group0(
								.enable(d_cache_enable),
								.clk(clk),
								.rst(rst),
								.compare(d_cache_compare),
								.read(d_cache_read_o),
								.address_in(d_cache_addr_in),
								.byte_w_en(byte_w_en),
								.data_in(data_core_to_dcache_i),
								.data_line_in(data_ram_to_cache_i),
								.hit(d_cache_hit),
								.dirty(d_cache_dirty),
								.valid(d_cache_valid),
								.data_out(data_cache_to_core_o),
								.data_line_out(data_cache_to_ram_o),
								.address_out(d_cache_address_out)
							);

	wire[255:0]			i_cache_data_line_i;
	assign i_cache_data_line_i = i_cache_data_line_i_ctr == 0 ? data_ram_to_cache_i : data_cache_to_ram_o;
	wire i_cache_valid;
	assign i_cache_miss = ~i_cache_hit;
	
	icache_two_way_group	icache_two_way_group0(
								.enable(i_cache_enable),
								.clk(clk),
								.rst(rst),
								.compare(i_cache_compare),
								.read(i_cache_read_o),
								.address_in(address_core_to_icache),
								.data_line_in(i_cache_data_line_i),
								.hit(i_cache_hit),
								.dirty(i_cache_dirty),
								.valid(i_cache_valid),
								.data_o(inst_cache_to_core_o)
							);

	assign address_cache_to_ram = addr_cache_to_ram_ctr == 0 ? address_core_to_icache : d_cache_address_out; 
	
endmodule