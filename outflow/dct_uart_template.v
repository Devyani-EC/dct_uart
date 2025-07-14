
// Efinity Top-level template
// Version: 2024.2.294
// Date: 2025-07-15 18:20

// Copyright (C) 2013 - 2024 Efinix Inc. All rights reserved.

// This file may be used as a starting point for Efinity synthesis top-level target.
// The port list here matches what is expected by Efinity constraint files generated
// by the Efinity Interface Designer.

// To use this:
//     #1)  Save this file with a different name to a different directory, where source files are kept.
//              Example: you may wish to save as dct_uart.v
//     #2)  Add the newly saved file into Efinity project as design file
//     #3)  Edit the top level entity in Efinity project to:  dct_uart
//     #4)  Insert design content.


module dct_uart
(
  (* syn_peri_port = 0 *) input clk_in,
  (* syn_peri_port = 0 *) input uart_rx_pin,
  (* syn_peri_port = 0 *) input clk,
  (* syn_peri_port = 0 *) output uart_tx_pin
);


endmodule

