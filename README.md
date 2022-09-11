# ℹ️ Examples

This repository contains various examples that show how you use various features of Judge0.

Before you start exploring these examples, you need to know the following:
1. Judge0 uses HTTP protocol.
    * [You can find the detailed API documentation here.](https://ce.judge0.com)
2. For us, the simplest way to showcase the different features of Judge0 is to use [`curl`](https://en.wikipedia.org/wiki/CURL) in the Bash programming language to communicate with Judge0 via HTTP protocol.
    * You need to find an appropriate HTTP client library for your programming language of choice.
3. These examples have been tested on Ubuntu 22.04 but should work anywhere you can run Bash scripts.
4. To have you get started fast, these examples use the [Shared Cloud](https://judge0.com/#pricing) of Judge0 CE and Judge0 Extra CE.
    * There is a FREE plan of Judge0 CE which you can subscribe to [here](https://judge0.com/ce).
    * There is also a FREE plan of Judge0 Extra CE, which you can subscribe to [here](https://judge0.com/extra-ce).

## Prerequisites

To successfully run these examples, you will need to:
1. [Subscribe to the FREE plan of Judge0 CE.](https://judge0.com/ce)
2. [Subscribe to the FREE plan of Judge0 Extra CE.](https://judge0.com/extra-ce)
3. Clone this repository.
4. Edit the file [`.env`](https://github.com/judge0/examples/blob/master/.env) and add the API key that [RapidAPI generated for you](https://docs.rapidapi.com/docs/keys).
5. Make sure you have [`curl`](https://reqbin.com/Article/InstallCurl) and [`jq`](https://stedolan.github.io/jq/download/) installed.

## Get Started

1. Make sure you have fulfilled all [prerequisites](#prerequisites).
2. Every example is self-contained; thus, `cd` into the directory of the example you want to run.
3. Run the `run_example.sh` script from within the example directory.
    ```bash
    $ ./run_example.sh
    ```
