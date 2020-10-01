# Localhost Docker

Localhost Docker позволяет развернуть окружение для разработки веб-приложений.

## Начало работы

1. Создать сеть `localhost` на хосте

    ```bash
    docker network create localhost
    ```

1. Запустить сервисы

    ```bash
    docker-compose \
        -f docker-compose.yml \
        -f proxy.yml \
        -f mysql.yml \
        -f mailcatcher.yml \
        up -d
    ```

## Компоненты

### Nginx Proxy

Простой Nginx прокси для Docker. Можно использовать для локальной разработки. Запускает контейнеры:

1. **[`nginx`](https://hub.docker.com/_/nginx/)** - Связывает порты 80 и 443 с хоста в контейнер, таким образом обрабатывает запросы, приходящие на хост.
1. **[`jwilder/docker-gen`](https://github.com/jwilder/docker-gen)** - Регенерирует конфиг для nginx при запуске/остановке контейнеров.

## Решение проблем

### Не монтируется Docker сокет на Windows

При запуске прокси на Windows может возникнуть ошибка монтирования Docker сокета:

```
Cannot create container for service: b'Mount denied:\nThe source path "\\\\var\\\\run\\\\docker.sock:/var/run/docker.sock"\nis not a valid Windows path'
```

Для этого необходимо определить переменную окружения `COMPOSE_CONVERT_WINDOWS_PATHS` в значение `1`. Это можно сделать командой в консоли:

```cmd
// CMD
set COMPOSE_CONVERT_WINDOWS_PATHS=1

// Powershell
$Env:COMPOSE_CONVERT_WINDOWS_PATHS=1
```

Или глобально через "Панель управления" (Панель управления\Система и безопасность\Система\Дополнительные параметры системы\Переменные среды)

### Подключить проект к прокси

В конфиге проекта `docker-compose.yml` указать сеть `localhost`:

```yml
networks:
  localhost:
    external: true
```

Для контейнера с веб-сервером (nginx, apache) в переменные окружения указать:

- VIRTUAL_HOST=hostname
- VIRTUAL_PORT=8080

Можно указать несколько доменов через запятую.

Больше переменных окружения можно найти в документации к [`docker-gen`](https://github.com/jwilder/docker-gen)

Так же контейнеру с веб-сервером необходимо указать сети:

```yml
networks:
  - default
  - localhost
```

`default` - чтобы для доступа к контейнерам в сети проекта
`localhost` - для участия в прокси

### docker-gen не генерирует конфиг и постоянно перезапускается

Такая ошибка встречалась на Windows при монтировании директории с ntfs диска. Чтобы это исправить можно монтировать вместо
директории docker-том. Для этого в `docker-compose.override.yml` прописать:

```yml
version: '3'

services:
  nginx:
    volumes:
      - nginx:/etc/nginx/conf.d:ro

  docker-gen:
    volumes:
      - nginx:/etc/nginx/conf.d:ro

volumes:
  nginx:
```

Запускать сервисы вместе с указанием файла `-f docker-compose.override.yml` после остальных файлов.

## SSL на Localhost

В папке `volumes/certs` сгенерировать SSL ключ для нужного домена:

```bash
openssl req -x509 -newkey rsa:4096 -keyout demo.local.key -out demo.local.crt -days 365 -nodes -subj '/CN=demo.local'
```

Пересоздайте контейнер с приложением. После регенерации конфига, https будет настроен автоматически.
