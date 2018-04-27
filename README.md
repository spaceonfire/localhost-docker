# Nginx proxy for Docker containers

Вдохновлено [pixelfordinner/pixelcloud-docker-apps](https://github.com/pixelfordinner/pixelcloud-docker-apps)

Простой Nginx прокси для Docker. Можно использовать для локальной разработки. Запускает контейнеры:

1. **[`nginx`](https://hub.docker.com/_/nginx/)** - Связывает порты 80 и 443 с хоста в контейнер, таким образом обрабатывает запросы, приходящие на хост.
1. **[`jwilder/docker-gen`](https://github.com/jwilder/docker-gen)** - Регенерирует конфиг для nginx при запуске/остановке контейнеров.

## Начало работы

1. Создать сеть `proxy` на хосте

    ```bash
    docker network create proxy
    ```

1. Запустить эти контейнеры

    ```bash
    docker-compose up -d
    ```

### Подключить проект к прокси

В конфиге проекта `docker-compose.yml` указать сеть `proxy`:

```yml
networks:
  proxy:
    external: true
```

Для контейнера с веб-сервером (nginx, apache) в переменные окружения указать:

- VIRTUAL_HOST=hostname

Можно указать несколько доменов через запятую.

Больше переменных окружения можно найти в документации к [`docker-gen`](https://github.com/jwilder/docker-gen)

Так же контейнеру с веб-сервером необходимо указать сети:

```yml
networks:
  - default
  - proxy-tier
```

`default` - чтобы для доступа к контейнерам в сети проекта
`proxy-tier` - для участия в прокси

## SSL на Localhost

В папке `volumes/certs` сгенерировать SSL ключ для нужного домена:

```bash
openssl req -x509 -newkey rsa:4096 -keyout demo.local.key -out demo.local.crt -days 365 -nodes -subj '/CN=demo.local'
```

Пересоздайте контейнер с приложением. После регенерации конфига, https будет настроен автоматически.
