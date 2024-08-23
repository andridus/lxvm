FROM erlang:21.3.8.24
WORKDIR /src
RUN git clone https://github.com/vlang/v
WORKDIR /src/v
RUN make
RUN ./v symlink
WORKDIR /app
CMD [ "bash" ]