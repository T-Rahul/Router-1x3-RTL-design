  module router_fifo(clk, rstn, soft_rst, wr_en, rd_en, lfd_state, data_in, full, empty, data_out);
  
  input clk, rstn, soft_rst, wr_en, rd_en, lfd_state;
  input [7:0] data_in;
  output full, empty;
  output reg [7:0] data_out;
  
  reg [8:0] mem [0:15];
  reg [3:0] wp, rp;
  reg [5:0] count;

  integer i;
  
  always@(posedge clk)
  begin
  
  if(!rstn)
  begin
  wp = 4'b0;

  end
  else if(soft_rst)
  begin
  wp = 4'b0;

  end

  else if(lfd_state)
  wp = wp;
  else if(wr_en && (!full))
  wp = wp + 1;
  else
  wp = wp;
  
  end
  
  always@(posedge clk)
  begin
  
  if(!rstn)
  rp = 4'b1111;
  else if(soft_rst)
  rp = 4'b1111;
  else if(rd_en && (!empty))
  rp = rp + 1;
  else
  rp = rp;
  
  end
  
  always@(posedge clk)
  begin
  
  if(!rstn)
  count = 6'b0;
  else if(soft_rst)
  count = 6'b0;
  else if(lfd_state)
  count = data_in[7:2] + 2;
  else if(rd_en && (!empty))
  count = count - 1;
  else if(empty)
  count = 0;
  else
  count = count;
  
  end
  
  always@(posedge clk)
  begin
  
  if(!rstn)
  for(i=0;i<16;i=i+1)
  mem[i] = 0;
  else if(soft_rst)
  for(i=0;i<16;i=i+1)
  mem[i] = 0;
  else if(wr_en && (!full))
  mem[wp] = {lfd_state, data_in};
  else
  mem[wp] = mem[wp];
  
  end
  
  always@(posedge clk)
  begin
  
  if(!rstn)
  begin

  data_out = 8'b0;
  end
  else if(soft_rst)
  begin

  data_out = 8'hzz;
  end
  else if(rd_en && (!empty))
  begin
  data_out = mem[rp];

  end
  else if(empty) //count = 0 and dataout != 0
  begin
  data_out = 8'hzz;

  end
  else
  begin
  data_out = data_out;

  end
  
  end
  
  assign full = ((rstn || !soft_rst) && (wp == 4'd15) && (!rd_en)) ? 1'b1 : 1'b0;
  assign empty = ((!rstn || soft_rst) || ((count == 0) && !lfd_state && rd_en))  ? 1'b1 : 1'b0; 
  
  endmodule