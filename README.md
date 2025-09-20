# fpga-3dmap
FPGA implementation that creates a 3D terrain map by rendering triangles from 16x16 grid elevation data using HDMI port. Compatible with Tang Nano 9K FPGA board.

## Example maps

### flat-map

<img src="https://github.com/berke-ozcan/fpga-3dmap/blob/main/images/flat-map/flat_map.jpg" width="500" height="500">

### test-map

$$ Map \ formula: \ z\ =\ 50\ +\ 100\left(1\ -\ \left(\frac{\left(x-8\right)}{8}\right)^{2}\right)\left(1\ -\ \left(\frac{\left(y-8\right)}{8}\right)^{2}\right) $$

<img src="https://github.com/berke-ozcan/fpga-3dmap/blob/main/images/test-map/test_map_fpga.jpg" width="500" height="500"> <img src="https://github.com/berke-ozcan/fpga-3dmap/blob/main/images/test-map/test_map_real.png" width="500" height="300">




will be updated

