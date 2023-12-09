import sys
import json
import os

from common import convert_base64_to_dict
from app import AppletApplication


def main():
    token = os.environ.get('JMS_TOKEN')
    data = convert_base64_to_dict(token)
    print(data)
    applet_app = AppletApplication(**data)
    applet_app.run()
    applet_app.wait()


if __name__ == '__main__':
    try:
        main()
    except Exception as e:
        print(e)
