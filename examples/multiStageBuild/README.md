# How to perform a multistage build?

This example shows how to perform a multistage build with the given images. We use eProsima's HalloWorldExample from their FastRTPS sources to keep this example as simple as possible.
The goal is to provide two images, one publisher and one subscriber.

The multistage build allows us to separate the compilation and the final application, thus keeping the image with the application small.

The directory *HelloWorldExample/* contains all sources. The sources also conclude a *CMakeLists.txt* which configures the build. We adjust the installation configuration so that the installation of the application appears to the */opt/app/* directory (inside of the container).
```
install(TARGETS HelloWorldExample
    RUNTIME DESTINATION
    	/opt/app/
)
```


## The Dockerfile

Now let's have a look at the Dockerfile. A `FROM <image/stage> AS <new stage>` line marks a stage. The example has four stages.

1. The intermediate __builder__ stage
   ```
   FROM alex031544/fastrtps:latest-dev AS builder

   COPY HelloWorldExample /opt/HelloWorldExample

   WORKDIR /opt/build
   RUN cmake /opt/HelloWorldExample \
   		-DCMAKE_INSTALL_RPATH_USE_LINK_PATH=TRUE && \
   	cmake --build . \
   		--target install \
   		-j 16
   ```
   In this stage is to translate the source code into an application. For this, we use the development image (`alex031544/fastrtps:latest-dev`). With `COPY` we copy the code from the host computer into the image directory */opt/HelloWorldExample/*. With `WORKDIR` we create (because it does not exist jet) and jump into the image directory */opt/build/*, where to store build output. Finally, we call CMake with `RUN`.  Since the application should run inside a container of the same structure, CMake shall not strip the `RPATH` from the application. Otherwise, the application can not find the shared libraries later. We tell CMake this by using the `-DCMAKE_INSTALL_RPATH_USE_LINK_PATH=TRUE` option at the configuration call. The second CMake call is the build and installation execution.

2. The intermediate __runtime__ stage.
   ```
   FROM alex031544/fastrtps:latest AS runtime

   COPY --from=builder \
   	/opt/app \
   	/opt/app

   WORKDIR /opt/app
   ```
   We use this intermediate stage to prepare the runtime by doing common settings. This stage builds upon the fastrtps runtime image (`alex031544/fastrtps:latest`). With `COPY` we copy the directory with our application from the *builder* stage into our new image. Last, we set the working directory to */opt/app/* with `WORKDIR`.

3. The final __publisher__ stage
   ```
   FROM runtime AS publisher

   CMD ["sh", "-c", "./HelloWorldExample publisher"]
   ```
   This stage is our first target. It takes the *runtime* stage and sets `CMD' to call `./HelloWorldExample publisher` automatically when the image starts.

4. The final __subscriber__ stage
   ```
   FROM runtime AS subscriber

   CMD ["sh", "-c", "./HelloWorldExample subscriber"]
   ```
   The same for the second target. Only this time the subscriber is called.


## Perform the build

Since I'm a lazy person and have a poor memory, there is a build script (*build.sh*) for the build call.
```
#!/bin/bash

docker build \
	--rm \
	 --no-cache \
	--target publisher \
	-t fastrtps_helloworld_publisher \
	.

docker build \
	--rm \
	--target subscriber \
	-t fastrtps_helloworld_subscriber \
	.
```
There are two `docker build` calls. By using the `--target` option, we tell `docker build` at which stage the build ends. The `-t` option defines a tag for the image build. The first call also gets the option `--no-cache`. This option forces a clean build of the image without using layers or stages of an earlier build. A clean rebuild becomes necessary as `docker build` rebuilds the layers only in the case that there are changes within the Dockerfile. Changes in the source code do not trigger a rebuild. At the second call, we know that the layers are already rebuilt. So we can reuse them for this build and do not need to force a clean build again. This saves us some lifetime.

Let's call the build script:
```
$ bash build.sh
Sending build context to Docker daemon  60.93kB
Step 1/9 : FROM alex031544/fastrtps:latest-dev AS builder
 ---> 168feef89631
Step 2/9 : COPY HelloWorldExample /opt/HelloWorldExample
 ---> b685e18a7835
Step 3/9 : WORKDIR /opt/build
 ---> Running in 0a2aa092d1e8
Removing intermediate container 0a2aa092d1e8
 ---> 9bcfaa39f4f9
Step 4/9 : RUN cmake /opt/HelloWorldExample 		-DCMAKE_INSTALL_RPATH_USE_LINK_PATH=TRUE && 	cmake --build . 	--target install 		-j 16
 ---> Running in ca767aa60f5f
-- The C compiler identification is GNU 8.3.0
-- The CXX compiler identification is GNU 8.3.0
-- Check for working C compiler: /usr/bin/cc
-- Check for working C compiler: /usr/bin/cc -- works
-- Detecting C compiler ABI info
-- Detecting C compiler ABI info - done
-- Detecting C compile features
-- Detecting C compile features - done
-- Check for working CXX compiler: /usr/bin/c++
-- Check for working CXX compiler: /usr/bin/c++ -- works
-- Detecting CXX compiler ABI info
-- Detecting CXX compiler ABI info - done
-- Detecting CXX compile features
-- Detecting CXX compile features - done
-- Found OpenSSL: /usr/lib/x86_64-linux-gnu/libcrypto.so (found version "1.1.1d")  
-- Performing Test SUPPORTS_CXX11
-- Performing Test SUPPORTS_CXX11 - Success
-- Configuring HelloWorld example...
-- Configuring done
-- Generating done
-- Build files have been written to: /opt/build
Scanning dependencies of target HelloWorldExample
[ 16%] Building CXX object CMakeFiles/HelloWorldExample.dir/HelloWorldSubscriber.cpp.o
[ 33%] Building CXX object CMakeFiles/HelloWorldExample.dir/HelloWorld.cxx.o
[ 50%] Building CXX object CMakeFiles/HelloWorldExample.dir/HelloWorldPubSubTypes.cxx.o
[ 66%] Building CXX object CMakeFiles/HelloWorldExample.dir/HelloWorldPublisher.cpp.o
[ 83%] Building CXX object CMakeFiles/HelloWorldExample.dir/HelloWorld_main.cpp.o
[100%] Linking CXX executable HelloWorldExample
[100%] Built target HelloWorldExample
Install the project...
-- Install configuration: ""
-- Installing: /opt/app/HelloWorldExample
-- Set runtime path of "/opt/app/HelloWorldExample" to "/usr/local/lib"
Removing intermediate container ca767aa60f5f
 ---> 96b00454b18d
Step 5/9 : FROM alex031544/fastrtps:latest AS runtime
 ---> b8af71e1e351
Step 6/9 : COPY --from=builder 	/opt/app 	/opt/app
 ---> 5e65c11ad54f
Step 7/9 : WORKDIR /opt/app
 ---> Running in bd4b9d982f8b
Removing intermediate container bd4b9d982f8b
 ---> efbddd06ba80
Step 8/9 : FROM runtime AS publisher
 ---> efbddd06ba80
Step 9/9 : CMD ["sh", "-c", "./HelloWorldExample publisher"]
 ---> Running in 92f3072878aa
Removing intermediate container 92f3072878aa
 ---> c3da5b77af75
Successfully built c3da5b77af75
Successfully tagged fastrtps_helloworld_publisher:latest
Sending build context to Docker daemon  60.93kB
Step 1/11 : FROM alex031544/fastrtps:latest-dev AS builder
 ---> 168feef89631
Step 2/11 : COPY HelloWorldExample /opt/HelloWorldExample
 ---> Using cache
 ---> b685e18a7835
Step 3/11 : WORKDIR /opt/build
 ---> Using cache
 ---> 9bcfaa39f4f9
Step 4/11 : RUN cmake /opt/HelloWorldExample 		-DCMAKE_INSTALL_RPATH_USE_LINK_PATH=TRUE && 	cmake --build . 	--target install 		-j 16
 ---> Using cache
 ---> 96b00454b18d
Step 5/11 : FROM alex031544/fastrtps:latest AS runtime
 ---> b8af71e1e351
Step 6/11 : COPY --from=builder 	/opt/app 	/opt/app
 ---> Using cache
 ---> 5e65c11ad54f
Step 7/11 : WORKDIR /opt/app
 ---> Using cache
 ---> efbddd06ba80
Step 8/11 : FROM runtime AS publisher
 ---> efbddd06ba80
Step 9/11 : CMD ["sh", "-c", "./HelloWorldExample publisher"]
 ---> Using cache
 ---> c3da5b77af75
Step 10/11 : FROM runtime AS subscriber
 ---> efbddd06ba80
Step 11/11 : CMD ["sh", "-c", "./HelloWorldExample subscriber"]
 ---> Running in 57ed5f51b369
Removing intermediate container 57ed5f51b369
 ---> 5705a3edb1b3
Successfully built 5705a3edb1b3
Successfully tagged fastrtps_helloworld_subscriber:latest
```
The result of each step is called a layer. Each layer gets its unique hash number indicated by an arrow (`--->`) at the end of the step. Comparing the layer hash numbers of the first build with the second, we determine, that all layers are reused instead of the last one where we set a different `CMD`.

Our images are ready now. Let's ask docker about the images available now:
```
$ docker images
REPOSITORY                      TAG         IMAGE ID      CREATED         SIZE
fastrtps_helloworld_subscriber  latest      7d4307287abe  13 minutes ago  113MB
fastrtps_helloworld_publisher   latest      dafb9e865540  13 minutes ago  113MB
alex031544/fastrtps             latest      b8af71e1e351  3 hours ago     113MB
alex031544/fastrtps             latest-dev  168feef89631  20 hours ago    1.1GB
```
Here we can see the two images we pulled from docker hub and our new two images we recently build. It is noteworthy that the size of the application image is small - especially compared to the development image.


## Test the images

To run the images open a terminal and call the *publisher*:
```
docker run --rm -it fastrtps_helloworld_publisher
```
and open a second terminal and start a *subscriber*:
```
docker run --rm -it fastrtps_helloworld_subscriber
```
The complete output shall than look like this on the first terminal:
```
$ docker run --rm -it fastrtps_helloworld_publisher
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
and the second terminal:
```
$ docker run --rm -it fastrtps_helloworld_subscriber
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


## References

- [Dockerfile reference](https://docs.docker.com/engine/reference/builder/)
- [Docker: Use multi-stage builds](https://docs.docker.com/develop/develop-images/multistage-build/)
