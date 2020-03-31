FROM alex031544/fastrtps:latest-dev AS builder

COPY HelloWorldExample /opt/HelloWorldExample

WORKDIR /opt/build
RUN cmake /opt/HelloWorldExample \
		-DCMAKE_INSTALL_RPATH_USE_LINK_PATH=TRUE && \
	cmake --build . \
		--target install \
		-j 16


FROM alex031544/fastrtps:latest AS runtime

COPY --from=builder \
	/opt/app \
	/opt/app

WORKDIR /opt/app


FROM runtime AS publisher

CMD ["sh", "-c", "./HelloWorldExample publisher"]


FROM runtime AS subscriber

CMD ["sh", "-c", "./HelloWorldExample subscriber"]
