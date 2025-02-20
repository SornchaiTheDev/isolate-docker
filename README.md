# Isolate Dockerfile

This repo is the step to build [ioi/isolate](https://github.com/ioi/isolate/tree/master) into Docker image

## How to

1. Build the image

```sh
docker build -t <tag-name> .
```

2. Run the container

```sh
docker run -v ./config:/usr/local/etc/isolate -it <tag-name>
```
