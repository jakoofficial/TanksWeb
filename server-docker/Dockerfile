FROM ubuntu
WORKDIR /app

COPY export/ /app/
COPY tanksweb.sh /app/
EXPOSE 8080
ENTRYPOINT [ "/app/tanksweb.sh", "--headless" ]
