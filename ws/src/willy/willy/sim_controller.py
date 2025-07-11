import rclpy
from rclpy.node import Node
from geometry_msgs.msg import Twist
from std_msgs.msg import Float64

class SimController(Node):
    def __init__(self):
        super().__init__('willy_mecanum_controller')
        self.create_subscription(Twist, '/cmd_vel', self.cmd_callback, 10)

        # One pub per wheel
        self.wheels = {
            'fl': self.create_publisher(Float64, '/fl_joint_velocity_controller/command', 10),
            'ml': self.create_publisher(Float64, '/ml_joint_velocity_controller/command', 10),
            'rl': self.create_publisher(Float64, '/rl_joint_velocity_controller/command', 10),
            'fr': self.create_publisher(Float64, '/fr_joint_velocity_controller/command', 10),
            'mr': self.create_publisher(Float64, '/mr_joint_velocity_controller/command', 10),
            'rr': self.create_publisher(Float64, '/rr_joint_velocity_controller/command', 10),
        }

        # Robot constants
        self.L = 0.3  # length
        self.W = 0.3  # width
        self.R = 0.05 # wheel radius

    def cmd_callback(self, msg):
        vx = msg.linear.x
        vy = msg.linear.y
        wz = msg.angular.z

        # Inverse kinematics for mecanum
        L, W, R = self.L, self.W, self.R
        v = [
            (1/R)*(vx - vy - (L+W)*wz),  # front left
            (1/R)*(vx - vy + (L+W)*wz),  # middle left
            (1/R)*(vx - vy - (L+W)*wz),  # rear left
            (1/R)*(vx + vy + (L+W)*wz),  # front right
            (1/R)*(vx + vy - (L+W)*wz),  # middle right
            (1/R)*(vx + vy + (L+W)*wz),  # rear right
        ]

        for pub, speed in zip(self.wheels.values(), v):
            pub.publish(Float64(data=speed))

def main(args=None):
    rclpy.init(args=args)
    node = SimController()
    rclpy.spin(node)
    node.destroy_node()
    rclpy.shutdown()

if __name__ == '__main__':
    main()
