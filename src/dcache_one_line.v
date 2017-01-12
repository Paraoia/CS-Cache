module dcache_one_line(
	//Input
	enable, clk, rst, compare, read, address_in, byte_w_en, data_in, data_line_in,
	//Output
	hit, dirty, valid, data_out, data_line_out, address_out
	);
	input 			enable, clk, rst, compare, read;
	input[31:0] 	address_in, data_in;
	input[3:0]		byte_w_en;
	input[255:0]	data_line_in;

	output				hit, dirty, valid;
	output[31:0]		address_out;
	output reg[31:0]	data_out;
	output reg[255:0]	data_line_out;
	/*
	+---+---+---+---+---+---+---+
	| 8 | 8 | 8 | 8 | t | v | d |
	+---+---+---+---+---+---+---+
	8 - 8 bytes, 64 bits, total 256 bit/a block
	t - tag
	v - valid
	d - dirty
	*/
	reg[255:0]	mem[63:0];
	//addr(32) = tag(21) + index_in_block(6) + addr_in_block(5)
	reg[20:0]	tag[63:0];
	reg         valid_bit[63:0], dirty_bit[63:0];

	wire[20:0]	addr_tag;
	wire[5:0]	addr_index;
	wire[2:0]	addr_in_block;
	integer i;

	//mid var
	assign addr_tag 		= address_in[31:11];
	assign addr_index 		= address_in[10:5];
	assign addr_in_block 	= address_in[4:2];

	initial begin
	   for(i = 0; i < 64; i = i + 1) begin
	       valid_bit[i] = 1'b0;
           dirty_bit[i] = 1'b0;
           tag[i] = 21'h0;
	   end
	end

	//output assign
	assign hit 		= compare == 1 ? (addr_tag == tag[addr_index]? 1'b1 : 1'b0) : 1'b0;
	assign dirty 	= dirty_bit[addr_index];
	
	assign valid 	= valid_bit[addr_index];
	assign address_out 	= {tag[addr_index], addr_index, 5'b0};
	always@(negedge clk) begin
		if(enable == 1'b1) begin
			if(rst == 1'b1) begin
			    data_out <= 32'h0;
				for(i = 0; i < 64; i = i + 1) begin
				    valid_bit[i] = 1'b0;
				end
			end
			else if(read == 1'b1) begin
				//Pay attention
				//big endian
				case(addr_in_block)
					0:	data_out	<=	mem[addr_index][31:0];
					1:	data_out	<=	mem[addr_index][63:32];
					2:	data_out	<=	mem[addr_index][95:64];
					3:	data_out	<=	mem[addr_index][127:96];
					4:	data_out	<=	mem[addr_index][159:128];
					5:	data_out	<=	mem[addr_index][191:160];
					6:	data_out	<=	mem[addr_index][223:192];
					7:	data_out	<=	mem[addr_index][255:224];
				endcase
				data_line_out <= mem[addr_index];
			end
			else if(read == 1'b0) begin 
				//write data
				if(compare == 1'b0) begin
				    dirty_bit[addr_index] <= 1'b0;
					mem[addr_index] <= data_line_in;
					tag[addr_index] <= addr_tag;
					valid_bit[addr_index] <= 1'b1;
				end
				else if(compare == 1'b1 && hit == 1'b1) begin
				    dirty_bit[addr_index] <= 1'b1;
				    case(addr_in_block)
                        0:begin
                            if(byte_w_en[0] == 1'b1) begin mem[addr_index][7/*0+7*/:0]                  <=  data_in[7:0]; end
                            if(byte_w_en[1] == 1'b1) begin mem[addr_index][15/*0+8+7*/:8/*0+8*/]        <=	data_in[15:8]; end
                            if(byte_w_en[2] == 1'b1) begin mem[addr_index][23/*0+8*2+7*/:16/*0+8*2*/]	<=	data_in[23:16];  end
                            if(byte_w_en[3] == 1'b1) begin mem[addr_index][31/*0+8*3+7*/:24/*0+8*3*/]	<=	data_in[31:24];   end
                        end
                        1:begin    
                            if(byte_w_en[0] == 1'b1) begin mem[addr_index][39/*32+7*/:32]	            <=	data_in[7:0]; end
                            if(byte_w_en[1] == 1'b1) begin mem[addr_index][47/*32+8+7*/:40/*32+8*/]	    <=	data_in[15:8]; end
                            if(byte_w_en[2] == 1'b1) begin mem[addr_index][55/*32+8*2+7*/:48/*32+8*2*/]	<=	data_in[23:16];  end
                            if(byte_w_en[3] == 1'b1) begin mem[addr_index][63/*32+8*3+7*/:56/*32+8*3*/]	<=	data_in[31:24];   end
                        end
                        2:begin    
                            if(byte_w_en[0] == 1'b1) begin mem[addr_index][71/*64+7*/:64]	            <=	data_in[7:0]; end
                            if(byte_w_en[1] == 1'b1) begin mem[addr_index][79/*64+8+7*/:72/*64+8*/]	    <=	data_in[15:8]; end
                            if(byte_w_en[2] == 1'b1) begin mem[addr_index][87/*64+8*2+7*/:80/*64+8*2*/]	<=	data_in[23:16];  end
                            if(byte_w_en[3] == 1'b1) begin mem[addr_index][95/*64+8*3+7*/:88/*64+8*3*/]	<=	data_in[31:24];   end
                        end
                        3:begin    
                            if(byte_w_en[0] == 1'b1) begin mem[addr_index][103/*96+7*/:96]	                <=	data_in[7:0]; end
                            if(byte_w_en[1] == 1'b1) begin mem[addr_index][111/*96+8+7*/:104/*96+8*/]	    <=	data_in[15:8]; end
                            if(byte_w_en[2] == 1'b1) begin mem[addr_index][119/*96+8*2+7*/:112/*96+8*2*/]	<=	data_in[23:16];  end
                            if(byte_w_en[3] == 1'b1) begin mem[addr_index][127/*96+8*3+7*/:120/*96+8*3*/]	<=	data_in[31:24];   end
                        end
                        4:begin    
                            if(byte_w_en[0] == 1'b1) begin mem[addr_index][135/*128+7*/:128]	             <=	data_in[7:0]; end
                            if(byte_w_en[1] == 1'b1) begin mem[addr_index][143/*128+8+7*/:136/*128+8*/]	     <=	data_in[15:8]; end
                            if(byte_w_en[2] == 1'b1) begin mem[addr_index][151/*128+8*2+7*/:144/*128+8*2*/]  <=	data_in[23:16];  end
                            if(byte_w_en[3] == 1'b1) begin mem[addr_index][159/*128+8*3+7*/:152/*128+8*3*/]  <=	data_in[31:24];   end
                        end                                                
                        5:begin    
                            if(byte_w_en[0] == 1'b1) begin mem[addr_index][167/*160+7*/:160]	             <=	data_in[7:0]; end
                            if(byte_w_en[1] == 1'b1) begin mem[addr_index][175/*160+8+7*/:168/*160+8*/]	     <=	data_in[15:8]; end
                            if(byte_w_en[2] == 1'b1) begin mem[addr_index][183/*160+8*2+7*/:176/*160+8*2*/]  <=	data_in[23:16];  end
                            if(byte_w_en[3] == 1'b1) begin mem[addr_index][191/*160+8*3+7*/:184/*160+8*3*/]  <=	data_in[31:24];   end
                        end                                 
                        6:begin    
                            if(byte_w_en[0] == 1'b1) begin mem[addr_index][199/*192+7*/:192]	             <=	data_in[7:0]; end
                            if(byte_w_en[1] == 1'b1) begin mem[addr_index][207/*192+8+7*/:200/*192+8*/]	     <=	data_in[15:8]; end
                            if(byte_w_en[2] == 1'b1) begin mem[addr_index][215/*192+8*2+7*/:208/*192+8*2*/]  <=	data_in[23:16];  end
                            if(byte_w_en[3] == 1'b1) begin mem[addr_index][223/*192+8*3+7*/:216/*192+8*3*/]  <=	data_in[31:24];   end
                        end                                 
                        7:begin    
                            if(byte_w_en[0] == 1'b1) begin mem[addr_index][231/*224+7*/:224]	             <=	data_in[7:0]; end
                            if(byte_w_en[1] == 1'b1) begin mem[addr_index][239/*224+8+7*/:232/*224+8*/]	     <=	data_in[15:8]; end
                            if(byte_w_en[2] == 1'b1) begin mem[addr_index][247/*224+8*2+7*/:240/*224+8*2*/]  <=	data_in[23:16];  end
                            if(byte_w_en[3] == 1'b1) begin mem[addr_index][255/*224+8*3+7*/:248/*224+8*3*/]  <=	data_in[31:24];   end
                        end                                 
                         
                    endcase				    
					
				end
			end
		end
	end


endmodule