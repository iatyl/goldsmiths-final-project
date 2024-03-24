from triotp import node
from . import app


def main():
    node.run(apps=[
        app.spec(),
    ])


if __name__ == '__main__':
    main()