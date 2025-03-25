# Use NVIDIA's PyTorch container as the base image
FROM nvcr.io/nvidia/pytorch:25.03-py3

# Set the locale
RUN apt-get update && apt-get install -y locales && \
    locale-gen en_US en_US.UTF-8 && \
    update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 && \
    export LANG=en_US.UTF-8

# Set the timezone
ENV ROS_VERSION=2
ENV ROS_DISTRO=jazzy
ENV ROS_PYTHON_VERSION=3
ENV TZ=Europe/Berlin
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

#Set the display environment variable 
ENV DISPLAY=:0

# Setup the sources
RUN apt-get update && apt-get install -y software-properties-common curl && \
    add-apt-repository universe && \
    curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | tee /etc/apt/sources.list.d/ros2.list > /dev/null

    # Install ROS 2 packages
    RUN apt-get update && apt-get upgrade -y && \
        apt-get install -y ros-jazzy-desktop-full 

# install bootstrap tools
RUN apt-get update && apt-get install --no-install-recommends -y \
    build-essential \
    git \
    nano \
    iputils-ping \
    wget \
    python3-colcon-common-extensions \
    python3-colcon-mixin \
    python3-rosdep \
    python3-vcstool \
    && rm -rf /var/lib/apt/lists/*

# bootstrap rosdep
RUN rosdep init && \
  rosdep update --rosdistro jazzy

# Environment setup
RUN echo 'source /opt/ros/jazzy/setup.bash' >> ~/.bashrc
RUN echo '#!/usr/bin/env bash' > /ros_entrypoint.sh
RUN echo 'source /opt/ros/jazzy/setup.bash' >> /ros_entrypoint.sh
RUN echo 'exec "$@"' >> /ros_entrypoint.sh
RUN chmod +x /ros_entrypoint.sh

ENTRYPOINT ["/ros_entrypoint.sh"]
# Run bash
CMD ["bash"]
