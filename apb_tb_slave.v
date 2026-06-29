`timescale 1ns / 1ps

module apb_tb_slave;
reg clk, reset_n;
wire pselx;
wire penable;
wire [31:0]paddr;
wire [31:0]pwdata;
wire pwrite;
reg pready;
reg transfer;
reg [31:0]addr;
reg [31:0] wdata;
reg write;

// Instantiate Master DUT
apb_master dut(
    .clk(clk),
    .reset_n(reset_n),
    .transfer(transfer),
    .addr(addr),
    .wdata(wdata),
    .write(write),
    .pselx(pselx),
    .penable(penable),
    .paddr(paddr),
    .pwdata(pwdata),
    .pwrite(pwrite),
    .pready(pready)
);

// Clock Generation
initial begin
    clk = 0;
    transfer = 0;
    addr = 0;
    wdata = 0;
    write = 0;
end

always #5 clk = ~clk; // 100MHz clock
    
initial begin
    // Apply Reset
    reset_n = 0;
    write = 1;
    pready = 1;
    #20;
    
    // Release Reset
    reset_n = 1;
    
    // Drive First Transaction (Properly grouped)
    @(posedge clk);
    begin
        transfer <= 1;
        addr     <= 32'habcd_1234;
        wdata    <= 32'hface_cafe;
        write    <= 1;
    end
        
    @(posedge clk);
    begin
        transfer <= 0;
    end
    
    repeat(3) @(posedge clk);
      
    pready <= 1;
    
    @(posedge clk);
    begin
        pready <= 0;
    end
        
    #50;
    $finish;
end

endmodule