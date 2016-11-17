module cache_control(
	input	clk,
	input	rst,
	input	d_cache_read,
	input	d_cache_write,
	input	i_cache_read,
	input	response_ram_to_cache,

	input	d_cache_miss,
	input	d_cache_dirty,
	input	d_cache_hit,
	input	i_cache_miss,
	input 	i_cache_dirty,
	input	i_cache_hit,

	output	i_cache_enable,
	output	i_cache_compare,
	output	i_cache_read,
	output	i_cache_data_line_i_ctr,
	output	d_cache_enable,
	output	d_cache_compare,
	output	d_cache_read,
	output 	d_cache_addr_ctr,

	output	addr_cache_to_ram_ctr,
	output	enable_cache_to_ram,
	output	write_cache_to_ram,
	output	response_inst_cache_to_core,
	output	response_data_cache_to_core
	);
begin
	output	i_cache_enable,
	output	i_cache_compare,
	output	i_cache_read,
	output	i_cache_data_line_i_ctr,
	output	d_cache_enable,
	output	d_cache_compare,
	output	d_cache_read,
	output 	d_cache_addr_ctr,

	output	addr_cache_to_ram_ctr,
	output	enable_cache_to_ram,
	output	write_cache_to_ram,
	output	response_inst_cache_to_core,
	output	response_data_cache_to_core
end