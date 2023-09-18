#!/bin/bash
sudo modprobe v4l2loopback video_nr=42 card_label="virtualcam" exclusive_caps=1 && \
 gst-launch-1.0 libcamerasrc camera-name='\\\_SB_.PCI0.I2C2.CAMF' ! \
    video/x-raw,width=1280,height=720,framerate=30/1,format=NV12 \
    ! videoconvert ! video/x-raw,format=YUY2 !  \
    v4l2sink device=/dev/video42
