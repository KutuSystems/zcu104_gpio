# zcu104_gpio

This project doesn't include the .hdf or bit file, so the Vivado project must be built and exported,
and then petalinux has too import the hardware description using the following command.

petalinux-config --get-hw-description=hardware/ZCU104_GPIO/ZCU104_GPIO.sdk

This keeps the project size very small.
