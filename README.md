# IKA9958
A BSD-licensed core for Yamaha's V9958 © 2024 Sehyeon Kim(Raki)

## Current status
**Work in progress**

✅**CI** - CPU bus interface (register RW)<br>
✅**DI** - DRAM interface<br>
▶️**REG** - Register file<br>
✅**VT** V- ideo timing<br>
▶️Tilemap logic(PLA)<br>
⬜Sprite logic<br>
✅ALU<br>
⬜ALU control(PLA)<br>
⬜Palette RAM<br>
⬜Misc

V9958 die-shot based schematic and Verilog core project: This is something that no one has attempted in the 40 years since Yamaha designed it in 1984. Many people have studied it with probing, and while I think the community have achieved a fairly accurate emulation, I think it is worthwhile to rewrite the silicon as-is in HDL.

I have been identifying and schematizing a fairly large amount of gates in my spare time. If you would like to support this project, please be my [patreon]( https://www.patreon.com/ikamusume ). Or, you can support me by donation via paypal mikoto0931 at paypal dot com.