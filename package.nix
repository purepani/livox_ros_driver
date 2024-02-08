{
  lib,
  buildRosPackage,
  cmake,
  boost,
  catkin,
  roscpp,
  rospy,
  std-msgs,
  sensor-msgs,
  rosbag,
  pcl-ros,
  message-generation,
  message-runtime,
  livox_sdk,
}: let
  name = "livox_ros_driver";
  version = "2.6.0";
in
  buildRosPackage {
    pname = name;
    inherit version;

    src = ./livox_ros_driver;

    buildType = "cmake";
    buildInputs = [
      cmake
      livox_sdk
      catkin
      roscpp
      rospy
      sensor-msgs
      std-msgs
      rosbag
      pcl-ros
      message-runtime
      message-generation
    ];
    nativeBuildInputs = [cmake boost];

    meta = {
      description = "Livox ROS Driver";
      license = with lib.licenses; [bsdOriginal];
    };
  }
