
module fifo_mem(seg1,seg2,fifo_full, fifo_empty, fifo_threshold, fifo_overflow, fifo_underflow,clk, rst_n, wr, rd, data_in,input1,input2);  
  input wr, rd, clk, rst_n;  
  input[7:0] data_in;   
  input[9:0] input1;
  input[9:0] input2;
  output[6:0] seg1;
  output[6:0] seg2;
  wire[7:0] data_out;  
  output fifo_full, fifo_empty, fifo_threshold, fifo_overflow, fifo_underflow;  
  wire[4:0] wptr,rptr;  
  wire fifo_we,fifo_rd;   
  write_pointer top1(wptr,fifo_we,wr,fifo_full,clk,rst_n);  
  read_pointer top2(rptr,fifo_rd,rd,fifo_empty,clk,rst_n);  
  memory_array top3(data_out, data_in, clk,fifo_we, wptr,rptr);  
  status_signal top4(fifo_full, fifo_empty, fifo_threshold, fifo_overflow, fifo_underflow, wr, rd, fifo_we, fifo_rd, wptr,rptr,clk,rst_n);
  segment7 top5(data_out[3:0], seg1);
  segment7 top6(data_out[7:4], seg2);
  decimal_bcd_encoder top7(input1, data_in[3:0]);
  decimal_bcd_encoder top8(input2, data_in[7:4]);
 endmodule  
  
 module decimal_bcd_encoder(
    input [9:0] d,
    output reg [3:0] y
    );
always @ (d)
begin
case(d)
10'b0000000001:y=4'b0000;
10'b0000000010:y=4'b0001;
10'b0000000100:y=4'b0010;
10'b0000001000:y=4'b0011;
10'b0000010000:y=4'b0100;
10'b0000100000:y=4'b0101;
10'b0001000000:y=4'b0110;
10'b0010000000:y=4'b0111;
10'b0100000000:y=4'b1000;
10'b1000000000:y=4'b1001;
default:y=4'b0000;
endcase
end
endmodule

 module memory_array(data_out, data_in, clk,fifo_we, wptr,rptr);  
  input[7:0] data_in;  
  input clk,fifo_we;  
  input[4:0] wptr,rptr;  
  output[7:0] data_out;  
  reg[7:0] data_out2[15:0];  
  wire[7:0] data_out;  
  always @(posedge clk)  
  begin  
   if(fifo_we)   
      data_out2[wptr[3:0]] <=data_in ;  
  end  
  assign data_out = data_out2[rptr[3:0]];  
 endmodule  



 module read_pointer(rptr,fifo_rd,rd,fifo_empty,clk,rst_n);  
  input rd,fifo_empty,clk,rst_n;  
  output[4:0] rptr;  
  output fifo_rd;  
  reg[4:0] rptr;  
  assign fifo_rd = (~fifo_empty)& rd;  
  always @(posedge clk or negedge rst_n)  
  begin  
   if(~rst_n) rptr <= 5'b000000;  
   else if(fifo_rd)  
    rptr <= rptr + 5'b000001;  
   else  
    rptr <= rptr;  
  end  
 endmodule  



 module status_signal(fifo_full, fifo_empty, fifo_threshold, fifo_overflow, fifo_underflow, wr, rd, fifo_we, fifo_rd, wptr,rptr,clk,rst_n);  
  input wr, rd, fifo_we, fifo_rd,clk,rst_n;  
  input[4:0] wptr, rptr;  
  output fifo_full, fifo_empty, fifo_threshold, fifo_overflow, fifo_underflow;  
  wire fbit_comp, overflow_set, underflow_set;  
  wire pointer_equal;  
  wire[4:0] pointer_result;  
  reg fifo_full, fifo_empty, fifo_threshold, fifo_overflow, fifo_underflow;  
  assign fbit_comp = wptr[4] ^ rptr[4];  
  assign pointer_equal = (wptr[3:0] - rptr[3:0]) ? 0:1;  
  assign pointer_result = wptr[4:0] - rptr[4:0];  
  assign overflow_set = fifo_full & wr;  
  assign underflow_set = fifo_empty&rd;  
  always @(*)  
  begin  
   fifo_full =fbit_comp & pointer_equal;  
   fifo_empty = (~fbit_comp) & pointer_equal;  
   fifo_threshold = (pointer_result[4]||pointer_result[3]) ? 1:0;  
  end  
  always @(posedge clk or negedge rst_n)  
  begin  
  if(~rst_n) fifo_overflow <=0;  
  else if((overflow_set==1)&&(fifo_rd==0))  
   fifo_overflow <=1;  
   else if(fifo_rd)  
    fifo_overflow <=0;  
    else  
     fifo_overflow <= fifo_overflow;  
  end  
  always @(posedge clk or negedge rst_n)  
  begin  
  if(~rst_n) fifo_underflow <=0;  
  else if((underflow_set==1)&&(fifo_we==0))  
   fifo_underflow <=1;  
   else if(fifo_we)  
    fifo_underflow <=0;  
    else  
     fifo_underflow <= fifo_underflow;  
  end  
 endmodule  



 module write_pointer(wptr,fifo_we,wr,fifo_full,clk,rst_n);  
  input wr,fifo_full,clk,rst_n;  
  output[4:0] wptr;  
  output fifo_we;  
  reg[4:0] wptr;  
  assign fifo_we = (~fifo_full)&wr;  
  always @(posedge clk or negedge rst_n)  
  begin  
   if(~rst_n) wptr <= 5'b000000;  
   else if(fifo_we)  
    wptr <= wptr + 5'b000001;  
   else  
    wptr <= wptr;  
  end  
 endmodule  

module segment7(
     bcd,
     seg
    );
     
     //Declare inputs,outputs and internal variables.
     input [3:0] bcd;
     output [6:0] seg;
     reg [6:0] seg;

//always block for converting bcd digit into 7 segment format
    always @(bcd)
    begin
        case (bcd) //case statement
            0 : seg = 7'b0000001;
            1 : seg = 7'b1001111;
            2 : seg = 7'b0010010;
            3 : seg = 7'b0000110;
            4 : seg = 7'b1001100;
            5 : seg = 7'b0100100;
            6 : seg = 7'b0100000;
            7 : seg = 7'b0001111;
            8 : seg = 7'b0000000;
            9 : seg = 7'b0000100;
            //switch off 7 segment character when the bcd digit is not a decimal number.
            default : seg = 7'b1111111; 
        endcase
    end
    
endmodule