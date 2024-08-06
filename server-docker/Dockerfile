FROM ubuntu
WORKDIR /app

COPY export/ /app/

EXPOSE 8080
ENTRYPOINT [ "/app/tanksweb.sh", "--headless" ]