module count59(input clk, input rst, output [5:0] Count, output loop);  reg [5:0] Count;
  always @ (posedge clk or negedge rst)
begin
  if (~rst) 
    Count <= 0;   // reset register
  else if ( Count == 59 ) 
    Count <= 0; 
  else
    Count <= Count + 1;  // increment register
end
assign loop = (Count == 59);
endmodule


module count1224(input clk, input rst, input modo, output [4:0] Count, output am, output pm);  reg [4:0] Count;

always @ (posedge clk or negedge rst)
begin
  if (~rst) 
    Count <= 0;   // reset register
  else if ( Count == 23 && modo == 1'b1 || Count == 11 && modo == 1'b0 ) 
    Count <= 0; 
  else
    Count <= Count + 1;  // increment register
end

wire h;
assign h = (~modo&(Count==11));
statem ampm(clk,rst,h,am,pm);

endmodule


module statem(clk, reset, h, am, pm);
input clk, reset; input  h; output am,pm;
reg  state;
parameter St_am=1'd0, St_pm=1'd1;
assign am = ( state == St_am );
assign pm = ( state == St_pm );
always @(posedge clk or negedge reset)
     begin
          if (reset==0)
               state = St_am;
          else
               case (state)
                    St_am:
                         if ( h == 1'b1 ) state = St_pm;
                    St_pm:
                         if ( h == 1'b1 ) state = St_am;
               endcase
     end
endmodule





module rel(input clk,res,modo,ajuste,pos, 
           output [5:0] minutos,
           output [4:0] hora,
           output am,pm);
	wire outs1;
	wire nc;
  assign nc = (ajuste)? pos:clk;
	count59 min(nc,res,minutos,outs1);
	count1224 hor(~outs1,res,modo,hora,am,pm);
endmodule
