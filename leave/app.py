import asyncio
import multiprocessing
import os
import signal
import socket
import typing

import leave
#import leave.config
import leave.protocol
import uvloop


class Application:

    def __init__(self, config):
        self.config = config

        self._workers = typing.Set
        self._workers = set()
        
    def callback_listeners(self, loop: object, name: str) -> None:
        if self.config:
            self.config.callback_listeners(self, loop, name)

    def server(self, sock: socket.socket) -> None:
        loop = asyncio.get_event_loop()
        self.callback_listeners(loop, 'before_start_server')
        leave.log.info("Start worker http://{}:{}".format(
            self.host, self.port))
        coro = loop.create_server(
            lambda: leave.protocol.Protocol(self, loop),
            sock=sock, backlog=self.backlog)
        server = loop.run_until_complete(coro)
        loop.add_signal_handler(signal.SIGTERM, loop.stop)
        loop.add_signal_handler(signal.SIGINT, loop.stop)
        try:
            loop.run_forever()
        finally:
            self.callback_listeners(loop, 'before_stop_server')
            server.close()
            loop.run_until_complete(server.wait_closed())
            loop.close()

    def stop_workers(self, sig, frame) -> None:
        if sig == signal.SIGHUP:
            leave.log.info('Reload request received')
        else:
            leave.log.info('Termination request received')
            for worker in self._workers:
                worker.terminate()
        asyncio.get_event_loop().close()
        return

    def run(self, host: str='0.0.0.0', port: int=8000, workers_num: int=1,
            backlog: int=100, debug: bool=False) -> None:
        self.host = host
        self.port = port
        self.backlog = backlog
        leave.logging.basicConfig(level=leave.logging.INFO)
        leave.log.info("Run leave server version {}".format(leave.__version__))

        asyncio.set_event_loop_policy(uvloop.EventLoopPolicy())

        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        s.bind((self.host, self.port))
        s.setblocking(False)
        s.listen(self.backlog)
        os.set_inheritable(s.fileno(), True)

        signal.signal(signal.SIGINT, self.stop_workers)
        signal.signal(signal.SIGTERM, self.stop_workers)
        signal.signal(signal.SIGHUP, self.stop_workers)

        for _ in range(0, workers_num):
            worker = multiprocessing.Process(
                target=self.server,
                kwargs=dict(sock=s))
            worker.daemon = True
            worker.start()
            self._workers.add(worker)

        for worker in self._workers:
            worker.join()
        s.close()

        return
