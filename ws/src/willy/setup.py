from setuptools import find_packages, setup
import os
from glob import glob

package_name = 'willy'

setup(
    name=package_name,
    version='0.0.0',
    packages=find_packages(exclude=['test']),
    data_files=[
        ('share/' + package_name, ['package.xml']),
        ('share/' + package_name + '/launch', glob('launch/*.py')),
        ('share/' + package_name + '/description/urdf', glob('description/urdf/*')),
        ('share/' + package_name + '/description/rviz', glob('description/rviz/*')),
        ('share/' + package_name + '/worlds', glob('worlds/*')),
        ('share/' + package_name + '/config', glob('config/*')),
    ],
    install_requires=['setuptools'],
    zip_safe=True,
    maintainer='willy',
    maintainer_email='jacovaut@gmail.com',
    description='TODO: Package description',
    license='Apache-2.0',
    tests_require=['pytest'],
    entry_points={
        'console_scripts': [
            'sim_controller = willy.sim_controller:main',
        ],
    },
)
