module State(input [2:0] next_state, input clk,  output reg [2:0] state);
	always @(posedge clk)
	begin
	  state <= next_state;
	end
endmodule


module Decode(input [3:0] index, output reg [15:0] led);
begin
  case (index)
    4'b0000 : led = 16'b00_00_00_00_00_00_00_01; //0
    4'b0001 : led = 16'b00_00_00_00_00_00_00_11; //1
    4'b0010 : led = 16'b00_00_00_00_00_00_01_11; //2 
    4'b0011 : led = 16'b00_00_00_00_00_00_11_11; //3
    4'b0100 : led = 16'b00_00_00_00_00_01_11_11; //4
    4'b0101 : led = 16'b00_00_00_00_00_11_11_11; //5
    4'b0110 : led = 16'b00_00_00_00_01_11_11_11; //6
    4'b0111 : led = 16'b00_00_00_00_11_11_11_11; //7
    4'b1000 : led = 16'b00_00_00_01_11_11_11_11; //8
    4'b1001 : led = 16'b00_00_00_11_11_11_11_11; //9
    4'b1010 : led = 16'b00_00_01_11_11_11_11_11; //10
    4'b1011 : led = 16'b00_00_11_11_11_11_11_11; //11
    4'b1100 : led = 16'b00_01_11_11_11_11_11_11; //12
    4'b1101 : led = 16'b00_11_11_11_11_11_11_11; //13
    4'b1110 : led = 16'b01_11_11_11_11_11_11_11; //14
    4'b1111 : led = 16'b11_11_11_11_11_11_11_11; //15
    default : led = 16'b00_00_00_00_00_00_00_00;
  endcase
end
endmodule


module FSM(input clk, input rst, input flk,
           input [3:0] index, input [2:0] state, 
           output reg [2:0] next_state); 
    localparam S0 = 3'b000,
               S1 = 3'b001,
               S2 = 3'b010,
               S3 = 3'b011,
               S4 = 3'b100,
               S5 = 3'b101,
               S6 = 3'b110;
    
    always @(posedge clk) begin
        case(state)
            S0: if(rst == 1 && flk == 1 && index == 0) begin
                next_state <= S1;
            end
            S1: if(index == 15) begin
                next_state <= S2;
            end
            S2: if(index == 5) begin
                if(flk == 0) begin
                    next_state <= S3;
                end else begin
                    next_state <= S1;
                end
            end
            S3: if(index == 10) begin
                next_state <= S4;
            end
            S4: if(index == 0 || index == 5) begin
                if(flk == 0) begin
                    if(index == 0) begin
                        next_state <= S5;
                    end
                end else begin 
                    next_state <= S3;
                end
            end
            S5: if(index == 5) begin
                next_state <= S6;
            end
            S6: if(index == 0) begin
                next_state <= S0;
            end
			default:
    end
end module


module Index_calculating (input [2:0] state, input clk, inout index)
    localparam S0 = 3'b000,
               S1 = 3'b001,
               S2 = 3'b010,
               S3 = 3'b011,
               S4 = 3'b100,
               S5 = 3'b101,
               S6 = 3'b110;
	always @(posedge clk) begin 
        case(state)
            S0: index <= 0;
            S1: index <= index + 1;
            S2: index <= index - 1;
            S3: index <= index + 1;
            S4: index <= index - 1;
            S5: index <= index + 1;
            S6: index <= index - 1;
    end
endmodule


module main (input rst, input clk, input flk, output reg [15:0] led);
	wire [2:0] next_state;
	wire [2:0] state;
	wire [3:0] index;
	FSM FSM_run(.clk(clk), .rst(rst), .flk(flk), 
				.index(index), .state(state), 
				.next_state(next_state));
	
	
    State State_run(.next_state(next_state), 
					.clk(clk), .state(state));
				
				
	Decode Decode_run(.index(index), .led(led));
	
	
	Index_calculating Index_calculating_run(.state(state), 
											.clk(clk), .index(index));
endmodule