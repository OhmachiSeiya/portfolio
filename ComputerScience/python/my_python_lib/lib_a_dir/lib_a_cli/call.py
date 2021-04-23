import argparse

from lib_a import (
    Hoge,
    Fuga,
    Cumfreq
)
from lib_a.submodule import Piyo


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--name', choices=['hoge', 'fuga', 'piyo', 'cumfreq'], default='hoge')
    args = parser.parse_args()

    if args.name == 'hoge':
        x = Hoge()
    elif args.name == 'fuga':
        x = Fuga()
    elif args.name == 'piyo':
        x = Piyo()
    elif args.name == 'cumfreq':
        x = Cumfreq()

    print(x())


if __name__ == '__main__':
    main()
