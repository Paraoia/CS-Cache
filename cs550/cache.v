module cache (
              input enable,
              input clk,
              input rst,
              input createdump,
              input [4:0] tag_in,
              input [7:0] index,
              input [2:0] offset,
              input [15:0] data_in,
              input comp,
              input write,
              input valid_in,

              output [4:0] tag_out,
              output [15:0] data_out,
              output hit,
              output dirty,
              output valid,
              output err
              );

   parameter         cache_id = 0;  // overridden for each cache instance
   wire [4:0]        ram0_id = (cache_id<<3) + 0; // These allow each memory to create a unique dump file
   wire [4:0]        ram1_id = (cache_id<<3) + 1;
   wire [4:0]        ram2_id = (cache_id<<3) + 2;
   wire [4:0]        ram3_id = (cache_id<<3) + 3;
   wire [4:0]        ram4_id = (cache_id<<3) + 4;
   wire [4:0]        ram5_id = (cache_id<<3) + 5;

   wire [15:0]       w0, w1, w2, w3;
   assign            go = enable & ~rst;
   assign            match = (tag_in == tag_out);

   assign            err = offset[0]; //word aligned; odd address is invalid

   assign            wr_word0 = go & write & ~offset[2] & ~offset[1] & (match | ~comp);
   assign            wr_word1 = go & write & ~offset[2] &  offset[1] & (match | ~comp);
   assign            wr_word2 = go & write &  offset[2] & ~offset[1] & (match | ~comp);
   assign            wr_word3 = go & write &  offset[2] &  offset[1] & (match | ~comp);

   assign            wr_dirty = go & write & (match | ~comp);
   assign            wr_tag   = go & write & ~comp;
   assign            wr_valid = go & write & ~comp;
   assign            dirty_in = comp;  // a compare-and-write sets dirty; a cache-fill clears it

   memc #(16) mem_w0 (w0,      index, data_in,  wr_word0, clk, rst, createdump, ram0_id);
   memc #(16) mem_w1 (w1,      index, data_in,  wr_word1, clk, rst, createdump, ram1_id);
   memc #(16) mem_w2 (w2,      index, data_in,  wr_word2, clk, rst, createdump, ram2_id);
   memc #(16) mem_w3 (w3,      index, data_in,  wr_word3, clk, rst, createdump, ram3_id);

   memc #( 5) mem_tg (tag_out, index, tag_in,   wr_tag,   clk, rst, createdump, ram4_id);
   memc #( 1) mem_dr (dirtybit,index, dirty_in, wr_dirty, clk, rst, createdump, ram5_id);
   memv       mem_vl (validbit,index, valid_in, wr_valid, clk, rst, createdump, ram0_id);

   assign            hit = go & match;
   assign            dirty = go & (~write | (comp & ~match)) & dirtybit;
   assign            data_out = (write | ~go)? 16'h0000 :
                     offset[2] ? (offset[1] ? w3 : w2) : (offset[1] ? w1 : w0) ;
   assign            valid = go & validbit & (~write | comp);

endmodule