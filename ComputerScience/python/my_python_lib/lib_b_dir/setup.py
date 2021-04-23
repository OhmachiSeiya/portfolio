import setuptools

with open("README.md", "r") as fh:
    long_description = fh.read()

setuptools.setup(
    name="oreno_command",
    version="0.1.0",
    author="seiyaohmachi",
    description="test",
    long_description=long_description,
    long_description_content_type="text/markdown",
    url="https://github.com/seiyamachiii/lib_b",
    packages=setuptools.find_packages(),
    classifiers=[
        "Programming Language :: Python :: 3",
        "License :: OSI Approved :: MIT License",
        "Operating System :: OS Independent",
    ],
    entry_points = {
        'console_scripts': ['oreno_command = oreno_command.oreno_command:main']
    },
    python_requires='>=3.7',
)
