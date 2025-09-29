# fpga-3dmap
FPGA implementation that creates a 3D terrain map by rendering triangles from 16x16 grid elevation data using HDMI port. Compatible with Tang Nano 9K FPGA board.

## Example maps

### flat-map

<img src="https://github.com/berke-ozcan/fpga-3dmap/blob/main/images/flat-map/flat_map.jpg" height="200">

### test-map

$$ Map \ formula: \ z\ =\ 50\ +\ 100\left(1\ -\ \left(\frac{\left(x-8\right)}{8}\right)^{2}\right)\left(1\ -\ \left(\frac{\left(y-8\right)}{8}\right)^{2}\right) $$

<img src="https://github.com/berke-ozcan/fpga-3dmap/blob/main/images/test-map/test_map_fpga.jpg" height="200"> <img src="https://github.com/berke-ozcan/fpga-3dmap/blob/main/images/test-map/test_map_real.png" height="200">

### amasya-map

<img src="https://github.com/berke-ozcan/fpga-3dmap/blob/main/images/amasya-map/amasya-fpga.jpg" height="200"> <img src="https://github.com/berke-ozcan/fpga-3dmap/blob/main/images/amasya-map/amasya-real.jpg" height="200">

### erciyes-map

<img src="https://github.com/berke-ozcan/fpga-3dmap/blob/main/images/erciyes-map/erciyes-fpga.jpg" height="200"> <img src="https://github.com/berke-ozcan/fpga-3dmap/blob/main/images/erciyes-map/erciyes-real.jpg" height="200">

