import os
import xacro

from ament_index_python.packages import get_package_share_directory
from launch import LaunchDescription
from launch.actions import IncludeLaunchDescription, TimerAction, RegisterEventHandler
from launch.launch_description_sources import PythonLaunchDescriptionSource
from launch_ros.actions import Node
from launch.event_handlers import OnProcessExit

def generate_launch_description():
    pkg_name = 'willy'
    pkg_share = get_package_share_directory(pkg_name)

    # File paths
    world_path = os.path.join(pkg_share, 'worlds', 'your_world.world')
    rviz_config_path = os.path.join(pkg_share, 'description', 'rviz', 'rviz_conf.rviz')
    controller_config = os.path.join(pkg_share, 'config', 'willy_controllers.yaml')
    xacro_file = os.path.join(pkg_share, 'description', 'urdf', 'willy.urdf.xacro')

    # Process Xacro file
    robot_description_config = xacro.process_file(
        xacro_file,
        mappings={'controller_yaml_path': controller_config}
    )
    robot_description = {'robot_description': robot_description_config.toxml(), 'use_sim_time': True}

    # Robot State Publisher
    robot_state_publisher = Node(
        package='robot_state_publisher',
        executable='robot_state_publisher',
        output='screen',
        parameters=[robot_description]
    )

    # Gazebo simulator
    gazebo = IncludeLaunchDescription(
        PythonLaunchDescriptionSource(
            os.path.join(
                get_package_share_directory('gazebo_ros'),
                'launch',
                'gazebo.launch.py'
            )
        ),
        launch_arguments={'world': world_path}.items()
    )

    # RViz
    rviz = Node(
        package='rviz2',
        executable='rviz2',
        name='rviz2',
        output='screen',
        arguments=['-d', rviz_config_path]
    )

    # Spawn robot into Gazebo
    spawn_entity = Node(
        package='gazebo_ros',
        executable='spawn_entity.py',
        arguments=[
            '-topic', 'robot_description',
            '-entity', 'willy',
        ],
        output='screen'
    )

    velocity_controller = Node(
        package="controller_manager",
        executable="spawner",
        arguments=["velocity_controller"],
    )

    joint_state_broadcaster = Node(
        package="controller_manager",
        executable="spawner",
        arguments=["joint_state_broadcaster"],
    )

    node_robot_joint_publisher = Node(
        package='joint_state_publisher',
        executable='joint_state_publisher',
        output='screen'
    )

    return LaunchDescription([
        robot_state_publisher,
        gazebo,
        rviz,
        spawn_entity,
        node_robot_joint_publisher
        # velocity_controller,
        # joint_state_broadcaster
    ])