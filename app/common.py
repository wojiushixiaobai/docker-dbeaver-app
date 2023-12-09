import abc
import base64
import json
import locale
import os
import sys
import time

_blockInput = None
_messageBox = None



def block_input():
    if _blockInput:
        _blockInput(True)


def unblock_input():
    if _blockInput:
        _blockInput(False)


def decode_content(content: bytes) -> str:
    for encoding_name in ['utf-8', 'gbk', 'gb2312']:
        try:
            return content.decode(encoding_name)
        except Exception as e:
            print(e)
    encoding_name = locale.getpreferredencoding()
    return content.decode(encoding_name)


def notify_err_message(msg):
    if _messageBox:
        _messageBox(msg, 'Error')



class DictObj:
    def __init__(self, in_dict: dict):
        assert isinstance(in_dict, dict)
        for key, val in in_dict.items():
            if isinstance(val, (list, tuple)):
                setattr(self, key, [DictObj(x) if isinstance(x, dict) else x for x in val])
            else:
                setattr(self, key, DictObj(val) if isinstance(val, dict) else val)


class User(DictObj):
    id: str
    name: str
    username: str


class Specific(DictObj):
    # web
    autofill: str
    username_selector: str
    password_selector: str
    submit_selector: str
    script: list

    # database
    db_name: str


class Category(DictObj):
    value: str
    label: str


class Protocol(DictObj):
    id: str
    name: str
    port: int


class Asset(DictObj):
    id: str
    name: str
    address: str
    protocols: list[Protocol]
    category: Category
    spec_info: Specific

    def get_protocol_port(self, protocol):
        for item in self.protocols:
            if item.name == protocol:
                return item.port
        return None


class LabelValue(DictObj):
    label: str
    value: str


class Account(DictObj):
    id: str
    name: str
    username: str
    secret: str
    privileged: bool
    secret_type: LabelValue


class Platform(DictObj):
    charset: str
    name: str
    charset: LabelValue
    type: LabelValue


class Gateway(DictObj):
    id: str
    name: str
    address: str
    port: int
    protocols: list[Protocol]
    account: Account


class TinkerForward(DictObj):
    host: str
    port: int


class Manifest(DictObj):
    name: str
    version: str
    path: str
    exec_type: str
    connect_type: str
    protocols: list[str]


def get_manifest_data() -> dict:
    current_dir = os.path.dirname(__file__)
    manifest_file = os.path.join(current_dir, 'manifest.json')
    try:
        with open(manifest_file, "r", encoding='utf8') as f:
            return json.load(f)
    except Exception as e:
        print(e)
    return {}


def read_app_manifest(app_dir) -> dict:
    main_json_file = os.path.join(app_dir, "manifest.json")
    if not os.path.exists(main_json_file):
        return {}
    with open(main_json_file, 'r', encoding='utf8') as f:
        return json.load(f)


def convert_base64_to_dict(base64_str: str) -> dict:
    try:
        data_json = base64.decodebytes(base64_str.encode('utf-8')).decode('utf-8')
        return json.loads(data_json)
    except Exception as e:
        print(e)
    return {}


class BaseApplication(abc.ABC):

    def __init__(self, *args, **kwargs):
        self.app_name = kwargs.get('app_name', '')
        self.protocol = kwargs.get('protocol', '')
        self.manifest = Manifest(kwargs.get('manifest', {}))
        self.user = User(kwargs.get('user', {}))
        self.asset = Asset(kwargs.get('asset', {}))
        self.account = Account(kwargs.get('account', {}))
        self.platform = Platform(kwargs.get('platform', {}))
        self.gateway = None
        self.tinker_forward = None
        gateway = kwargs.get('gateway')
        tinker_forward = kwargs.get('tinker_forward')
        if gateway:
            self.gateway = Gateway(gateway)
        if tinker_forward:
            self.tinker_forward = TinkerForward(tinker_forward)

    @abc.abstractmethod
    def run(self):
        raise NotImplementedError('run')

    @abc.abstractmethod
    def wait(self):
        raise NotImplementedError('wait')
