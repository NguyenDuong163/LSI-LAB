`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/29/2024 01:48:06 PM
// Design Name: 
// Module Name: bound_flasher
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module bound_flasher(reset_n, clock, flick, LED);

input reset_n;
input clock;
input flick;
output [15:0] LED;

reg [15:0] LED;
reg [1:0] operation;

wire clock, reset_n, flick;

parameter UNCHANGE 		  =  2'b00;
parameter ON			  =  2'b01;
parameter OFF 		      =  2'b10;
parameter KICK_BACK	      =  2'b11;


parameter NUM_OF_STATE =7;

//Listing states
parameter INIT              = 7'b0000001;
parameter ZERO_FIFTHTEEN    = 7'b0000010;
parameter FIFTHTEEN_FIVE    = 7'b0000100;
parameter FIVE_TEN          = 7'b0001000;
parameter TEN_ZERO          = 7'b0010000;
parameter ZERO_FIVE         = 7'b0100000;
parameter FIVE_ZERO         = 7'b1000000;


reg [NUM_OF_STATE -1:0] state;
reg [NUM_OF_STATE -1:0] next_state;
reg TEMP = 1'b1;

integer index;
integer i;


always @(posedge clock or negedge reset_n)
begin

	if(!reset_n) begin
	
		state <=  INIT;
			
	end
	
	else begin
	
		state <= next_state;
		
	end

end


//Index Calculating Block
always @(posedge clock or negedge reset_n)
begin

    if (!reset_n) begin
    
        index <= -1;
        
    end
    
    else begin
    
        if (operation == ON)begin
            
            index <= index + 1;
            
        end
        
        if (operation == OFF) begin
        
            index <= index - 1;
           
        end
        
        if (operation == UNCHANGE) begin
        
            index <= index;
            
        end
       
    end
    
end

//Flick check block

always @(state or flick or index)
begin

    operation = 2'b00;
    
    case (state)
    
    INIT: begin
    
            if (index >= 0) operation = OFF; 
            
            else if (flick) begin 
                
                    operation = ON; 
                    
            end
            
            else operation = UNCHANGE;
            
    end
    
    ZERO_FIFTHTEEN: begin
    
            if (index < 15) begin
            
                operation = ON;  
            
            end
            
            else begin
            
                operation = OFF;            
            
            end
    end
            
    FIFTHTEEN_FIVE: begin
    
            if (flick && index == 5) begin 
                
                operation = KICK_BACK;
                
            end
            
            else if (index >= 5) operation = OFF; 
            
            else operation = ON;
      
    end
    
    FIVE_TEN: begin
    
            if (index < 10) operation = ON;
            
            else operation = OFF;      
            
    end
    
    TEN_ZERO: begin
    
            if (flick && (index == 5 || index == 0)) operation = KICK_BACK;
            
            else if (index >= 0) operation = OFF;
            
            else operation = ON;
            
    end
    
    ZERO_FIVE: begin
    
            if (index == 5) operation = OFF;
            
            else operation = ON;
            
    end       
    FIVE_ZERO: begin
     
            if (index >= 0) operation = OFF;
            
           // else operation =  ON;
          
    end
    
    default: operation = UNCHANGE;
    
    endcase
    
end    

// FSM 
always @(state or operation)
begin

        case(state)
        
        INIT: begin
                
                if (operation == ON) begin
                    
                    next_state = ZERO_FIFTHTEEN;
                    
                end
                
                else begin
                
                    next_state = INIT;
                    
                end
          end
          
         ZERO_FIFTHTEEN: begin
         
                if (operation == ON) begin
                
                    next_state = ZERO_FIFTHTEEN;
                    
                end
                
                else begin
                
                    next_state = FIFTHTEEN_FIVE;
                    
                end
                
          end
          
          FIFTHTEEN_FIVE: begin
          
                if (operation == KICK_BACK) begin
                
                    next_state = ZERO_FIFTHTEEN;
                    
                end
                
                else if (operation == OFF) begin
                
                    next_state = FIFTHTEEN_FIVE;
                    
                end
                
                else next_state = FIVE_TEN;
                
           end
           
          FIVE_TEN: begin
                
                if (operation == ON) begin
                
                    next_state =  FIVE_TEN;
                    
                end
                
                else begin
                
                    next_state = TEN_ZERO;      
                
                end   
            
           end
            
           TEN_ZERO: begin
            
                if (operation == KICK_BACK) begin
                
                    next_state = FIVE_TEN;
                    
                end
                
                else if (operation == OFF) begin 
                
                    next_state = TEN_ZERO;
                    
                end
                
                else begin
                
                    next_state = ZERO_FIVE;
                    
                end
                
           end
           
           ZERO_FIVE: begin
           
                if (operation == ON) begin
                    
                    next_state =  ZERO_FIVE;
                    
                end
                
                else begin
                
                    next_state = FIVE_ZERO;
                    
                end
                
            end
            
            FIVE_ZERO: begin
            
                    if (operation == OFF) begin
                    
                        next_state = FIVE_ZERO;
                        
                    end
                    
                    else begin
                    
                        next_state = INIT;
                        
                    end
                    
            end
                    
            default: next_state = INIT;
            
            endcase
            
end

//Decode block

always @(index)
begin

	if(index == -1) 
		for(i = 0; i < 16 ; i = i + 1)
		begin
		
			LED[i] = 0;
		
		end
	
	else
	
		for( i = 0; i < 16 ; i = i + 1)
		begin
			
			if(i <= index) LED[i] = 1'b1;
			
			else LED[i] = 1'b0;
			
		end
	
end

//always @(index) 
//begin
//        case (index)
//        -1: LED = 16'b00_00_00_00_00_00_00_00;
//        0 : LED = 16'b00_00_00_00_00_00_00_01; //0
//        1 : LED = 16'b00_00_00_00_00_00_00_11; //1
//        2 : LED = 16'b00_00_00_00_00_00_01_11; //2 
//        3 : LED = 16'b00_00_00_00_00_00_11_11; //3
//        4 : LED = 16'b00_00_00_00_00_01_11_11; //4
//        5 : LED = 16'b00_00_00_00_00_11_11_11; //5
//        6 : LED = 16'b00_00_00_00_01_11_11_11; //6
//        7 : LED = 16'b00_00_00_00_11_11_11_11; //7
//        8 : LED = 16'b00_00_00_01_11_11_11_11; //8
//        9 : LED = 16'b00_00_00_11_11_11_11_11; //9
//        10 : LED = 16'b00_00_01_11_11_11_11_11; //10
//        11 : LED = 16'b00_00_11_11_11_11_11_11; //11
//        12 : LED = 16'b00_01_11_11_11_11_11_11; //12
//        13 : LED = 16'b00_11_11_11_11_11_11_11; //13
//        14 : LED = 16'b01_11_11_11_11_11_11_11; //14
//        15 : LED = 16'b11_11_11_11_11_11_11_11; //15
//        default : LED = 16'b00_00_00_00_00_00_00_00;
//        endcase
//end

endmodule
