`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: apb_master
//////////////////////////////////////////////////////////////////////////////////

module apb_master(
    input clk,
    input reset_n,
    input transfer,
    input [31:0] addr,
    input [31:0] wdata,
    input write,
    output reg pselx,
    output reg penable,
    output reg [31:0] paddr,
    output reg [31:0] pwdata,
    output reg pwrite,
    input pready 
);

   
    parameter idle   = 2'b00;
    parameter setup  = 2'b01;
    parameter access = 2'b10;

    reg [1:0] current_state, next_state;
 
    
    always @(posedge clk or negedge reset_n) begin
        if (~reset_n) begin
            current_state <= idle;
        end
        else begin
            current_state <= next_state;
        end
    end
    
    
    always @(*) begin
        
        next_state = current_state; 
        
        case (current_state)
            idle: begin 
                if (transfer)
                    next_state = setup;
                else    
                    next_state = idle;
            end
            
            setup: begin 
                next_state = access;
            end
            
            access: begin     
                if (pready) begin
                    if (transfer)
                        next_state = setup;
                    else    
                        next_state = idle;
                end
                else begin
                    next_state = access;
                end
            end
            
            default: begin
                next_state = idle;
            end
        endcase
    end

    
    always @(posedge clk or negedge reset_n) begin
        if (~reset_n) begin
            pselx   <= 1'b0;
            penable <= 1'b0;
            paddr   <= 32'b0;
            pwdata  <= 32'b0;
            pwrite  <= 1'b0; 
        end
        else begin
            case (next_state)
                idle: begin
                    pselx   <= 1'b0;
                    penable <= 1'b0;
                end
                
                setup: begin
                    pselx   <= 1'b1;
                    penable <= 1'b0;
                    paddr   <= addr;
                    pwdata  <= wdata;
                    pwrite  <= write;  
                end
                
                access: begin
                    pselx   <= 1'b1;
                    penable <= 1'b1;
                end 
                
                default: begin
                    pselx   <= 1'b0;
                    penable <= 1'b0;
                end
            endcase
        end
    end
    
endmodule