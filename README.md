# FastRTPS Docker implementation

[![Image version information][ver_img_v2.0.1]](https://microbadger.com/images/alex031544/fastrtps)
[![Docker pulls](https://img.shields.io/docker/pulls/alex031544/fastrtps.svg?style=plastic)](https://registry.hub.docker.com/v2/repositories/alex031544/fastrtps/)
[![Docker Stars](https://img.shields.io/docker/stars/alex031544/fastrtps.svg?style=plastic)](https://registry.hub.docker.com/v2/repositories/alex031544/fastrtps/stars/count/)
[![Runtime Image Size information](https://img.shields.io/docker/image-size/alex031544/fastrtps/latest) for Runtime](https://microbadger.com/images/alex031544/fastrtps)
[![Image Size information](https://img.shields.io/docker/image-size/alex031544/fastrtps/latest-dev) for Development](https://microbadger.com/images/alex031544/fastrtps)


Below are the following sections:

1. __Brief Image Overview__ - A brief overview of the images provided
2. __The images in detail__ - The next section describes this images more detailed.
3. __How To__ - This section demonstrates some use cases.
4. __Tag/Version Overview__ - Provides a full overview of the images provided and their related versions.


## Brief Image Overview

Provided are 3 images, which are differently tagged:

1. `<version>`:  
    This is the *runtime* image. This image concludes only the libraries needed to run a FastRTPS application.

2. `<version>-dev`:  
    Use this image for developing and building FastRTPS applications.

3. `<version>-example`:  
    This image contains the eProsimas examples shipped with FastRTPS ready to use.

Where `<version>` can be either `latest` or the version tag of FastRTPS (`v*.*.*`).


## The images in detail

### Runtime image

The runtime image based on Debian slim comprises runtime related libraries:
- libtinyxml2-6
- libssl1.1
- /usr/local/lib/libfastcdr.so
- /usr/local/lib/libfastrtps.so

Thus the image is as small as can be and well suited for final applications and their deployment. Only copy the binaries of an already build FastRTPS application into this image and set either `CMD` or `ENTRYPOINT` optionally.

### Development image

The development image based on Debian slim comprises all header, libraries and tools to build FastRTPS applications or generate code:
- [eProsima FastRTPS](https://www.eprosima.com/index.php/products-all/eprosima-fast-rtps)
- [eProsima FastCDR](https://github.com/eProsima/Fast-CDR)
- [eProsima FastRTPSGen](https://eprosima-fast-rtps.readthedocs.io/en/latest/geninfo.html)
- [Foonathan memory](https://foonathan.net/memory/)
- [GIT](https://git-scm.com)
- [GCC](https://gcc.gnu.org),
- [G++](https://www.cprogramming.com/g++.html)
- [CMake](https://cmake.org)
- [Colcon](https://colcon.readthedocs.io/en/released/)
- [Gradle](https://gradle.org)
- [openJDK, openJRE](https://openjdk.java.net)

Thus the image is large and well suited for the development of applications but not their deployment. Use this image as *builder* in a multistage build, to generate code from IDL files using FastRTPSGen or build an application.

The related paths are:
- FastRTPS
  - */usr/local/include/fastrtps*
  - */usr/local/lib/libfastrtps.so*
  - */usr/local/share/fastrtps*
- FastCDR
  - */usr/local/include/fastcdr*
  - */usr/local/lib/libfastcdr.so*
  - */usr/local/share/fastcdr*
- FastRTPSGen
  - /usr/local/share/fastrtpsgen/
- Foonathan memory
  - */usr/local/bin/nodesize_dbg*
  - */usr/local/include/foonathan_memory*
  - */usr/local/lib/foonathan_memory*
  - */usr/local/lib/libfoonathan_memory-?.a*
  - */usr/local/share/foonathan_memory*
  - */usr/local/share/foonathan_memory_vendor*

As the path to *fastrtpsgen* is set in `PATH`, `fastrtpsgen` can directly be used within the image.

### Examples image

The examples image based on the runtime image and comprises the examples which eProsima ships together with FastRTPS. As the binaries are built in a development container, this is a good demonstration how to do it and that all should work well. The examples are installed to:

```
/usr/local/examples/C++/
├── Benchmark
│   └── bin
│       └── Benchmark
├── ClientServerTest
│   └── bin
│       └── ClientServerTest
├── DeadlineQoSExample
│   └── bin
│       └── DeadlineQoSExample
├── DisablePositiveACKsQoS
│   └── bin
│       └── DisablePositiveACKsQoS
├── DynamicHelloWorldExample
│   └── bin
│       └── DynamicHelloWorldExample
├── FilteringExample
│   └── bin
│       └── FilteringExample
├── FlowControlExample
│   └── bin
│       └── FlowControlExample
├── HelloWorldExample
│   └── bin
│       ├── HelloWorldExample
│       └── StaticHelloWorldExample
├── HelloWorldExampleTCP
│   └── bin
│       └── HelloWorldExampleTCP
├── LifespanQoSExample
│   └── bin
│       └── LifespanQoSExample
├── LivelinessQoS
│   └── bin
│       └── LivelinessQoS
├── OwnershipStrengthQoSExample
│   └── bin
│       └── OwnershipStrengthQoSExample
├── RTPSTest_as_socket
│   └── bin
│       └── RTPSTest_as_socket
├── RTPSTest_persistent
│   └── bin
│       └── RTPSTest_persistent
├── RTPSTest_registered
│   └── bin
│       └── RTPSTest_registered
├── UseCaseDemonstrator
│   └── bin
│       ├── UseCasePublisher
│       ├── UseCaseSubscriber
│       ├── historykind
│       ├── keys
│       ├── latejoiners
│       ├── sampleconfig_controller
│       ├── sampleconfig_events
│       └── sampleconfig_multimedia
├── UserDefinedTransportExample
│   └── bin
│       └── UserDefinedTransportExample
└── XMLProfilesExample
    └── bin
        └── XMLProfiles
```


## How To

### perform a multistage build?

go to [How to perform a multistage build?](https://github.com/Alex031544/docker_fastrtps/tree/master/examples/multiStageBuild/)

### generate code from IDL files?

go to [How to generate code from IDL files?](https://github.com/Alex031544/docker_fastrtps/tree/master/examples/idlCodeGen/)

### to use the development image to build only.

### run the examples shipped with ePraosimas FastRTPS?

To run the *HelloWorldExample* open a terminal, start a *subscriber*:
```
docker run --rm -it alex031544/fastrtps:latest-example /usr/local/examples/C++/HelloWorldExample/bin/HelloWorldExample subscriber
```
and open a second terminal and start a *publisher*:
```
docker run --rm -it alex031544/fastrtps:latest-example /usr/local/examples/C++/HelloWorldExample/bin/HelloWorldExample publisher
```
The complete output shall than look like this on the first terminal:
```
$ docker run --rm -it alex031544/fastrtps:latest-example /usr/local/examples/C++/HelloWorldExample/bin/HelloWorldExample subscriber
Unable to find image 'alex031544/fastrtps:latest-example' locally
latest-example: Pulling from alex031544/fastrtps
68ced04f60ab: Pull complete
b7ab2a749932: Pull complete
66a04b1fec19: Pull complete
7e17a648192c: Pull complete
c0b16ddf6abc: Pull complete
Digest: sha256:0b212faa46b54017f817e82e4a8a09f6d66cb5fb793b0f0897b7c3c60147ba74
Status: Downloaded newer image for alex031544/fastrtps:latest-example
Starting
Subscriber running. Please press enter to stop the Subscriber
Subscriber matched
Message HelloWorld 1 RECEIVED
Message HelloWorld 2 RECEIVED
Message HelloWorld 3 RECEIVED
Message HelloWorld 4 RECEIVED
Message HelloWorld 5 RECEIVED
Message HelloWorld 6 RECEIVED
Message HelloWorld 7 RECEIVED
Message HelloWorld 8 RECEIVED
Message HelloWorld 9 RECEIVED
Message HelloWorld 10 RECEIVED
Subscriber unmatched
```
and the second terminal:
```
$ docker run --rm -it alex031544/fastrtps:latest-example /usr/local/examples/C++/HelloWorldExample/bin/HelloWorldExample publisher
Starting
Publisher running 10 samples.
Publisher matched
Message: HelloWorld with index: 1 SENT
Message: HelloWorld with index: 2 SENT
Message: HelloWorld with index: 3 SENT
Message: HelloWorld with index: 4 SENT
Message: HelloWorld with index: 5 SENT
Message: HelloWorld with index: 6 SENT
Message: HelloWorld with index: 7 SENT
Message: HelloWorld with index: 8 SENT
Message: HelloWorld with index: 9 SENT
Message: HelloWorld with index: 10 SENT
```

## Tag/Version overview

| Runtime Images                                                                 | Development Images                                                                         | Example Images                                                                                         | Base OS                               | [FastRTPS][fastrtps_git_lnk]    | [FastCDR][fastcdr_git_lnk]     | [FastRTPSGen][fastrtpsgen_git_lnk] |
| ------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------ |------------------------------------------------------------------------------------------------------- | ------------------------------------- | ------------------------------- | ------------------------------ | ---------------------------------- |
| [![][ver_img_latest]]() [![][size_img_latest]]() [![][layers_img_latest]]()    | [![][ver_img_latest-dev]]() [![][size_img_latest-dev]]() [![][layers_img_latest-dev]]()    | [![][ver_img_latest-example]]() [![][size_img_latest-example]]() [![][layers_img_latest-example]]()    | [Debian 10-slim][os_hub_deb] | [v2.0.1][fastrtps_git_v2.0.1] | [v1.0.15][fastcdr_git_v1.0.15] | [v1.0.4][fastrtpsgen_git_v1.0.4]   |
| [![][ver_img_v2.0.1]]() [![][size_img_v2.0.1]]() [![][layers_img_v2.0.1]]() | [![][ver_img_v2.0.1-dev]]() [![][size_img_v2.0.1-dev]]() [![][layers_img_v2.0.1-dev]]() | [![][ver_img_v2.0.1-example]]() [![][size_img_v2.0.1-example]]() [![][layers_img_v2.0.1-example]]() | [Debian 10-slim][os_hub_deb] | [v2.0.1][fastrtps_git_v2.0.1] | [v1.0.15][fastcdr_git_v1.0.15] | [v1.0.4][fastrtpsgen_git_v1.0.4]   |
| [![][ver_img_v2.0.0]]() [![][size_img_v2.0.0]]() [![][layers_img_v2.0.0]]() | [![][ver_img_v2.0.0-dev]]() [![][size_img_v2.0.0-dev]]() [![][layers_img_v2.0.0-dev]]() | [![][ver_img_v2.0.0-example]]() [![][size_img_v2.0.0-example]]() [![][layers_img_v2.0.0-example]]() | [Debian 10-slim][os_hub_deb] | [v2.0.0][fastrtps_git_v2.0.0] | [v1.0.14][fastcdr_git_v1.0.14] | [v1.0.4][fastrtpsgen_git_v1.0.4]   |
| [![][ver_img_v1.10.0]]() [![][size_img_v1.10.0]]() [![][layers_img_v1.10.0]]() | [![][ver_img_v1.10.0-dev]]() [![][size_img_v1.10.0-dev]]() [![][layers_img_v1.10.0-dev]]() | [![][ver_img_v1.10.0-example]]() [![][size_img_v1.10.0-example]]() [![][layers_img_v1.10.0-example]]() | [Debian 10-slim][os_hub_deb] | [v1.10.0][fastrtps_git_v1.10.0] | [v1.0.13][fastcdr_git_v1.0.13] | [v1.0.4][fastrtpsgen_git_v1.0.4]   |
| [![][ver_img_v1.9.4]]() [![][size_img_v1.9.4]]() [![][layers_img_v1.9.4]]()    | [![][ver_img_v1.9.4-dev]]() [![][size_img_v1.9.4-dev]]() [![][layers_img_v1.9.4-dev]]()    | [![][ver_img_v1.9.4-example]]() [![][size_img_v1.9.4-example]]() [![][layers_img_v1.9.4-example]]()    | [Debian 10-slim][os_hub_deb] | [v1.9.4][fastrtps_git_v1.9.4]   | [v1.0.13][fastcdr_git_v1.0.13] | [v1.0.3][fastrtpsgen_git_v1.0.3]   |


[ver_img_latest]: https://images.microbadger.com/badges/version/alex031544/fastrtps:latest.svg
[size_img_latest]: https://img.shields.io/docker/image-size/alex031544/fastrtps/latest
[layers_img_latest]: https://img.shields.io/microbadger/layers/alex031544/fastrtps/latest

[ver_img_latest-dev]: https://images.microbadger.com/badges/version/alex031544/fastrtps:latest-dev.svg
[size_img_latest-dev]: https://img.shields.io/docker/image-size/alex031544/fastrtps/latest-dev
[layers_img_latest-dev]: https://img.shields.io/microbadger/layers/alex031544/fastrtps/latest-dev

[ver_img_latest-example]: https://images.microbadger.com/badges/version/alex031544/fastrtps:latest-example.svg
[size_img_latest-example]: https://img.shields.io/docker/image-size/alex031544/fastrtps/latest-example
[layers_img_latest-example]: https://img.shields.io/microbadger/layers/alex031544/fastrtps/latest-example

[ver_img_v2.0.1]: https://images.microbadger.com/badges/version/alex031544/fastrtps:v2.0.1.svg
[size_img_v2.0.1]: https://img.shields.io/docker/image-size/alex031544/fastrtps/v2.0.1
[layers_img_v2.0.1]: https://img.shields.io/microbadger/layers/alex031544/fastrtps/v2.0.1

[ver_img_v2.0.1-dev]: https://images.microbadger.com/badges/version/alex031544/fastrtps:v2.0.1-dev.svg
[size_img_v2.0.1-dev]: https://img.shields.io/docker/image-size/alex031544/fastrtps/v2.0.1-dev
[layers_img_v2.0.1-dev]: https://img.shields.io/microbadger/layers/alex031544/fastrtps/v2.0.1-dev

[ver_img_v2.0.1-example]: https://images.microbadger.com/badges/version/alex031544/fastrtps:v2.0.1-example.svg
[size_img_v2.0.1-example]: https://img.shields.io/docker/image-size/alex031544/fastrtps/v2.0.1-example
[layers_img_v2.0.1-example]: https://img.shields.io/microbadger/layers/alex031544/fastrtps/v2.0.1-example

[ver_img_v2.0.0]: https://images.microbadger.com/badges/version/alex031544/fastrtps:v2.0.0.svg
[size_img_v2.0.0]: https://img.shields.io/docker/image-size/alex031544/fastrtps/v2.0.0
[layers_img_v2.0.0]: https://img.shields.io/microbadger/layers/alex031544/fastrtps/v2.0.0

[ver_img_v2.0.0-dev]: https://images.microbadger.com/badges/version/alex031544/fastrtps:v2.0.0-dev.svg
[size_img_v2.0.0-dev]: https://img.shields.io/docker/image-size/alex031544/fastrtps/v2.0.0-dev
[layers_img_v2.0.0-dev]: https://img.shields.io/microbadger/layers/alex031544/fastrtps/v2.0.0-dev

[ver_img_v2.0.0-example]: https://images.microbadger.com/badges/version/alex031544/fastrtps:v2.0.0-example.svg
[size_img_v2.0.0-example]: https://img.shields.io/docker/image-size/alex031544/fastrtps/v2.0.0-example
[layers_img_v2.0.0-example]: https://img.shields.io/microbadger/layers/alex031544/fastrtps/v2.0.0-example

[ver_img_v1.10.0]: https://images.microbadger.com/badges/version/alex031544/fastrtps:v1.10.0.svg
[size_img_v1.10.0]: https://img.shields.io/docker/image-size/alex031544/fastrtps/v1.10.0
[layers_img_v1.10.0]: https://img.shields.io/microbadger/layers/alex031544/fastrtps/v1.10.0

[ver_img_v1.10.0-dev]: https://images.microbadger.com/badges/version/alex031544/fastrtps:v1.10.0-dev.svg
[size_img_v1.10.0-dev]: https://img.shields.io/docker/image-size/alex031544/fastrtps/v1.10.0-dev
[layers_img_v1.10.0-dev]: https://img.shields.io/microbadger/layers/alex031544/fastrtps/v1.10.0-dev

[ver_img_v1.10.0-example]: https://images.microbadger.com/badges/version/alex031544/fastrtps:v1.10.0-example.svg
[size_img_v1.10.0-example]: https://img.shields.io/docker/image-size/alex031544/fastrtps/v1.10.0-example
[layers_img_v1.10.0-example]: https://img.shields.io/microbadger/layers/alex031544/fastrtps/v1.10.0-example

[ver_img_v1.9.4]: https://images.microbadger.com/badges/version/alex031544/fastrtps:v1.9.4.svg
[size_img_v1.9.4]: https://img.shields.io/docker/image-size/alex031544/fastrtps/v1.9.4
[layers_img_v1.9.4]: https://img.shields.io/microbadger/layers/alex031544/fastrtps/v1.9.4

[ver_img_v1.9.4-dev]: https://images.microbadger.com/badges/version/alex031544/fastrtps:v1.9.4-dev.svg
[size_img_v1.9.4-dev]: https://img.shields.io/docker/image-size/alex031544/fastrtps/v1.9.4-dev
[layers_img_v1.9.4-dev]: https://img.shields.io/microbadger/layers/alex031544/fastrtps/v1.9.4-dev

[ver_img_v1.9.4-example]: https://images.microbadger.com/badges/version/alex031544/fastrtps:v1.9.4-example.svg
[size_img_v1.9.4-example]: https://img.shields.io/docker/image-size/alex031544/fastrtps/v1.9.4-example
[layers_img_v1.9.4-example]: https://img.shields.io/microbadger/layers/alex031544/fastrtps/v1.9.4-example


[os_hub_deb]: https://hub.docker.com/_/debian
[os_ver_deb_10-slim]: https://images.microbadger.com/badges/version/debian:10-slim.svg

[fastrtps_git_lnk]: https://github.com/eProsima/Fast-RTPS
[fastrtps_git_v1.9.4]: https://github.com/eProsima/Fast-RTPS/releases/tag/v1.9.4
[fastrtps_git_v1.10.0]: https://github.com/eProsima/Fast-RTPS/releases/tag/v1.10.0
[fastrtps_git_v2.0.0]: https://github.com/eProsima/Fast-RTPS/releases/tag/v2.0.0

[fastcdr_git_lnk]: https://github.com/eProsima/Fast-CDR
[fastcdr_git_v1.0.13]: https://github.com/eProsima/Fast-CDR/releases/tag/v1.0.13
[fastcdr_git_v1.0.14]: https://github.com/eProsima/Fast-CDR/releases/tag/v1.0.14

[fastrtpsgen_git_lnk]: https://github.com/eProsima/Fast-RTPS-Gen
[fastrtpsgen_git_v1.0.3]: https://github.com/eProsima/Fast-RTPS-Gen/releases/tag/v1.0.3
[fastrtpsgen_git_v1.0.4]: https://github.com/eProsima/Fast-RTPS-Gen/releases/tag/v1.0.4


## References

[see for further information](https://gitlab.com/Alex0315/code-examples/-/tree/master/FastRTPS/01_docker)


## Contributions

I highly appreciate any contributions to this project. As a short summary here is what you could do:

- Improvements on documentation
- File issues against the project
- Open pull requests, for example
  - add new version configurations
  - add more examples


## License

Any directly written content in this repository is licensed under the *Apache-2.0*.
Software parts that are produced during the image build and resulting docker images are of course a composition of components that probably carry their own licenses.
