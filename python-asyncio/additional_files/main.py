import asyncio

from my_package import my_module1


async def main():
    print(await my_module1.get_greeting())

asyncio.run(main())
