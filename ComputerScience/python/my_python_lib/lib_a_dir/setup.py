from setuptools import setup

with open("README.md", "r") as fh:
    long_description = fh.read()

install_requires = [
    # 必要な依存ライブラリがあれば記述
    "numpy",
    "tweepy"
]

packages = [
    'lib_a',
    'lib_a.submodule',
    'lib_a_cli',
]

console_scripts = [
    'lib_a_cli=lib_a_cli.call:main',
]


setup(
    name='lib_a',
    version='0.0.0',
    packages=packages,
    install_requires=install_requires,
    entry_points={'console_scripts': console_scripts},
)
