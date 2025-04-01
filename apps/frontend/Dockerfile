FROM alpine

# 安裝ffmpeg
RUN apk add --no-cache ffmpeg

WORKDIR /app
COPY ./app /app
ENTRYPOINT ["/app/app"]
