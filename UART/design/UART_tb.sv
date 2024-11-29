module TB ();
logic clk,tx_en;
logic tx;
logic [7:0] tx_data;
logic [7:0] rx;
logic rx_dv;

logic [7:0] check;
parameter CLKS_PER_BIT = 87;

integer errors=0;
integer correct=0;

  // Instantiate the UART Receiver
  UART_receiver #(CLKS_PER_BIT) DUT1 (
    .i_clk(clk),
    .i_rx_serial(tx),  // Connect tx output of sender to rx input of receiver
    .o_rx_byte(rx),
    .o_rx_dv(rx_dv)
  );

  // Instantiate the UART Transmitter
  UART_sender #(CLKS_PER_BIT) DUT2 (
    .i_clk(clk),
    .i_tx_dv(tx_en),
    .i_tx_data(tx_data),
    .o_tx(tx)
  );

initial begin
    clk=0;
    #10;
    forever begin
       #1 clk=~clk;
    end
end
initial begin
    #20;
    repeat(1000)begin
        tx_data=$random;
        check=tx_data;
        @(posedge clk);
        tx_en=1;
        @(posedge rx_dv);
        tx_en=0;
        if(check==rx)begin
        correct++;
        end
        else begin
        errors++;
        end
    end
    $display("correct attempets=%d errors=%d",correct,errors);
    $stop;
end
endmodule