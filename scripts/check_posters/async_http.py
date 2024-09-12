import logging
import socket
import asyncio
from abc import ABCMeta, abstractmethod
from aiohttp import ClientSession, TCPConnector
from aiohttp.client_exceptions import ClientConnectorError, ClientPayloadError, ServerDisconnectedError
import requests


class AsyncHttp(object):
    """An abstract class to send HTTP requests asynchronously."""

    __metaclass__ = ABCMeta

    def __init__(self, urls):
        """A class initializer.

        :param urls: a list of URLs.

        .. note :: ClientSession() without loop=self.loop works as expected, but produces warnings:
                   ERROR: Creating a client session outside of coroutine
                   As a solution, self.loop is introduced and used in ClientSession(loop=self.loop).
                   See also https://github.com/elastic/elasticsearch-py-async/issues/10
        """
        self.urls = urls
        self.loop = asyncio.get_event_loop()
        self.session = ClientSession(connector=TCPConnector(#family=socket.AF_INET,
                                                            verify_ssl=False, limit=1),
                                     loop=self.loop, trust_env = True)
        self.semaphore = asyncio.Semaphore(1000)

    @abstractmethod
    async def aget(self, url):
        """A method to fetch a URL."""
        pass

    @abstractmethod
    async def tied_aget(self, url):
        """A method to send an HTTP GET request tied with a semaphore."""
        pass

    @abstractmethod
    async def run(self):
        """A method to send HTTP GET requests as co-routines."""
        pass

    @staticmethod
    def _log_response(response):
        """Log response with different log level depending on the response code; return nothing."""
        if response.status == 200:
            logging.debug("%s %s %s" % (response.status, response.reason, response.url))
        else:
            logging.warning("%s %s %s" % (response.status, response.reason, response.url))


class AsyncHttpNoReturn(AsyncHttp):
    """A class to send HTTP GET requests asynchronously without storing the returned responses."""

    async def aget(self, url):
        """Fetch a URL, log the response, return nothing."""
        try:
            async with self.session.get(url) as response:
                await response.read()
                self._log_response(response)
        except (requests.exceptions.RequestException, requests.exceptions.ConnectionError,
                requests.exceptions.Timeout, TimeoutError, socket.error,
                ClientConnectorError, ClientPayloadError, ServerDisconnectedError) as err:
            logging.error("Error when sent GET to %s . Error:\n%s" % (url, err))

    async def tied_aget(self, url):
        """Using a semaphore, redirect to the fetching function; return nothing."""
        async with self.semaphore:
            await self.aget(url)

    def _run_tasks(self):
        """Create and schedule the tasks - one task per a URL."""
        tasks = [asyncio.ensure_future(self.tied_aget(url)) for url in self.urls]
        print("tasks:")
        print(tasks)
        return asyncio.gather(*tasks)

    async def run(self):
        """Create and schedule a task for each URL and wait for all the tasks to be completed."""
        async with self.session:
            await self._run_tasks()


class AsyncHttpReturn(AsyncHttpNoReturn):
    """A class to send HTTP GET requests asynchronously and keep returned responses."""

    def __init__(self, urls, as_json):
        """A class initializer.

        :param urls: a list of URLs.
        :param as_json: a boolean, True if response text is expected to be JSON, otherwise False.
        """
        super(AsyncHttpReturn, self).__init__(urls)
        self.as_json = as_json

    async def aget(self, url):
        """Fetch a URL, log the response,
        return response body as a string if it cannot be converted into JSON,
        otherwise return JSON data decoded from the response body.
        If ClientPayloadError or ServerDisconnectedError occurred, an empty string is returned.
        """
        try:
            async with self.session.get(url) as response:
                if self.as_json:
                    data = await response.json() if response.status == 200 else {}
                else:
                    data = await response.read()
                self._log_response(response)
                return data
        except (ClientConnectorError, ClientPayloadError, ServerDisconnectedError) as err:
            logging.error("Could not fetch the URL %s due to %s" % (url, err))
        return {}

    async def tied_aget(self, url):
        """Using a semaphore, redirect to the fetching function self.aget() and return its value -
        a string or JSON data.
        """
        async with self.semaphore:
            return await self.aget(url)

    async def run(self):
        """Create and run the tasks; return the results of all the tasks."""
        async with self.session:
            return await self._run_tasks()
