`timescale 1ns/10ps

module Testbench #(parameter DEPTH = 8, DATA_WIDTH = 12, MEMTYPE=1);
  bit wclk;
  bit rclk;
  bit wreset_n;
  bit rreset_n;
  initial begin
    forever #5 wclk = ~wclk;
  end
  initial begin
    forever #10 rclk = ~rclk;
  end

  initial begin
    wreset_n = 1'b1;
    repeat(3) @(posedge wclk);
    #1
    wreset_n = 1'b0;
    @(posedge wclk);
    #1
    wreset_n = 1'b1;
  end
  initial begin
    rreset_n = 1'b1;
    repeat(3) @(posedge rclk);
    #1
    rreset_n = 1'b0;
    @(posedge rclk);
    #1
    rreset_n = 1'b1;
  end
  FifoIf #(DEPTH,DATA_WIDTH) fIf(wclk,rclk);
  assign fIf.rd_rst_n = rreset_n;
  assign fIf.wr_rst_n = wreset_n;
  assign fIf.wr_mask = 12'b111111111111;
  assign fIf.almost_empty_limit = 2;
  assign fIf.almost_full_limit = 2;
  /*
  async_fifo  #(DEPTH,DATA_WIDTH,MEMTYPE)  gf (  
        .fifo_enable (fIf.fifo_enable),
	.wr_clk (fIf.wr_clk),
	.wr_rst_n (fIf.wr_rst_n),
	.rd_clk (fIf.rd_clk),
	.rd_rst_n (fIf.rd_rst_n),
	.wr_en(fIf.wr_en),
	.wr_line_en(fIf.wr_line_en),
	.rd_en(fIf.rd_en),
	.almost_full_limit (fIf.almost_full_limit),
	.almost_empty_limit (fIf.almost_empty_limit),
        .fifo_full (fIf.fifo_full),
        .fifo_empty (fIf.fifo_empty),
        .wr_data (fIf.wr_data),
        .wr_mask (fIf.wr_mask),
        .rd_data (fIf.rd_data),
	.fifo_almost_empty (fIf.fifo_almost_empty),
	.fifo_almost_full (fIf.fifo_almost_full)
  );
  */
  MonitorIf mon(fIf.wr_clk,fIf.rd_clk);

   wtest test1(fIf,mon);
endmodule
