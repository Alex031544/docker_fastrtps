# How To generate code from IDL files?

The Interactive Data Language (IDL) is used to describe data structures language-independently.  IDL can be used to generate standardized code for various languages.

This example shows how C++ code can be generated from a data structure described in IDL using FastRTPSGen.

The directory *idl/* contains the file *MyDataStructure.idl*, which describes the data structure `MyDataStructure`.
```
struct MyDataStructure
{
	string a_string_value;
	double a_double_value;
	long a_long_value;
};
```
Now we can use FastRTPSGen to generate C++ classes and example publisher-subscriber sources. The script file *gen.sh* holds the corresponding call and can be executed with 'bash gen.sh'.
```
#!/bin/bash

# create a directory for the generated code
mkdir -p gen

docker run \
	--rm \
	-it \
	--user $(id -u ${USER}):$(id -g ${USER}) \
	--volume ${PWD}/idl:/opt/idl \
	--volume ${PWD}/gen:/opt/gen \
	alex031544/fastrtps:latest-dev \
	fastrtpsgen \
		-d /opt/gen \
		-example CMake \
		/opt/idl/MyDataStructure.idl
```
The directories *idl* and *gen* are mapped into the container using the volume option. As we want to generate code, we chose `alex031544/fastrtps:latest-dev` as an image. This image provides `fastrtpsgen`. We call `fastrtpsgen` with the entry command, tell `fastrtpsgen` that we want */opt/gen* the output director and that it shall generate an example application for CMake build tool. The last argument is a list of all IDL file to translate - in our case only MyDataStructure.idl.

Calling the script *gen.sh* results in the following output:
```
$ bash gen.sh
openjdk version "11.0.6" 2020-01-14
OpenJDK Runtime Environment (build 11.0.6+10-post-Debian-1deb10u1)
OpenJDK 64-Bit Server VM (build 11.0.6+10-post-Debian-1deb10u1, mixed mode, sharing)
Loading templates...
Processing the file /opt/idl/MyDataStructure.idl...
Generating Type definition files...
Generating TopicDataTypes files...
Generating Publisher files...
Generating Subscriber files...
Generating main file...
Adding project: /opt/idl/MyDataStructure.idl
Generating solution for arch CMake...
Generating CMakeLists solution
```
The directory structure on the host should now look as follows and the generated data should be located in the directory *gen*.
```
.
├── gen
│   ├── CMakeLists.txt
│   ├── MyDataStructure.cxx
│   ├── MyDataStructure.h
│   ├── MyDataStructurePublisher.cxx
│   ├── MyDataStructurePublisher.h
│   ├── MyDataStructurePubSubMain.cxx
│   ├── MyDataStructurePubSubTypes.cxx
│   ├── MyDataStructurePubSubTypes.h
│   ├── MyDataStructureSubscriber.cxx
│   └── MyDataStructureSubscriber.h
├── idl
│   └── MyDataStructure.idl
├── gen.sh
└── README.md
```

## References

For more detailed information and a deeper insight see also:

- [eProsima FASTRTPSGEN: Manual](https://fast-rtps.docs.eprosima.com/en/latest/geninfo.html)
- [eProsima FASTRTPSGEN: Execution and IDL Definition](https://fast-rtps.docs.eprosima.com/en/latest/genuse.html)
- [docker run](https://docs.docker.com/engine/reference/commandline/run/)
