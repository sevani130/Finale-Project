## [REST API](http://localhost:8080/doc)

## Концепция:

- Spring Modulith
    - [Spring Modulith: достигли ли мы зрелости модульности](https://habr.com/ru/post/701984/)
    - [Introducing Spring Modulith](https://spring.io/blog/2022/10/21/introducing-spring-modulith)
    - [Spring Modulith - Reference documentation](https://docs.spring.io/spring-modulith/docs/current-SNAPSHOT/reference/html/)

```
  url: jdbc:postgresql://localhost:5432/jira
  username: jira
  password: JiraRush
```

- Есть 2 общие таблицы, на которых не fk
    - _Reference_ - справочник. Связь делаем по _code_ (по id нельзя, тк id привязано к окружению-конкретной базе)
    - _UserBelong_ - привязка юзеров с типом (owner, lead, ...) к объекту (таска, проект, спринт, ...). FK вручную будем
      проверять

## Аналоги

- https://java-source.net/open-source/issue-trackers

## Тестирование

- https://habr.com/ru/articles/259055/

Список выполненных задач:
1. Разобраться со структурой проекта (onboarding).
2. Удалить социальные сети: vk, yandex.
Удалены: ```VkOAuth2UserDataHandler.java```, ```YandexOAuth2UserDataHandler.java``` (Путь: ```src/main/java/com/javarush/jira/login/internal/sociallogin/handler```)
Удалены кнопки со страницы html: ```/resources/view/login.html``` и ```resources/view/unauth/register.htm```
3. Вынести чувствительную информацию в отдельный проперти файл:
    - логин
    - пароль БД
    - идентификаторы для OAuth регистрации/авторизации
    - настройки почты

    Значения этих проперти должны считываться при старте сервера из переменных окружения машины.
    **Изменен файл: /src/main/resources/application.yaml и добвлен файл /src/main/resources/app-config.yaml**
4. Переделать тесты так, чтоб во время тестов использовалась in memory БД (H2), а не PostgreSQL. Для этого нужно определить 2 бина, и выборка какой из них использовать должно определяться активным профилем Spring. H2 не поддерживает все фичи, которые есть у PostgreSQL, поэтому тебе прийдется немного упростить скрипты с тестовыми данными.

    Создан файл с измененными тестовыми данными ```/src/test/resources/test.sql``` и изменен ```/src/test/resources/application-test.yaml```
5. Написать тесты для всех публичных методов контроллера ProfileRestController. Хоть методов только 2, но тестовых методов должно быть больше, т.к. нужно проверить success and unsuccess path.

    Смотрите файл по пути: ```/src/test/java/com/javarush/jira/profile/internal/web/ProfileRestControllerTest.java```

6. Сделать рефакторинг метода ```com.javarush.jira.bugtracking.attachment.FileUtil#upload``` чтоб он использовал современный подход для работы с файловой системмой.
7. Добавить новый функционал: добавления тегов к задаче (REST API + реализация на сервисе). Фронт делать необязательно. Таблица task_tag уже создана.

    Добавлен функционал в ```/src/main/java/com/javarush/jira/bugtracking/task/TaskService.java```. 
    Также для проверки работы был добавлен функционал в ```/src/main/java/com/javarush/jira/bugtracking/task/TaskController.java``` для проверки через **Swagger API** ```POST /api/tasks/{id}/tags```. 
    Также добавлен тест в ```src/test/java/com/javarush/jira/bugtracking/task/TaskControllerTest.java```

8. Добавить подсчет времени сколько задача находилась в работе и тестировании. Написать 2 метода на уровне сервиса, которые параметром принимают задачу и возвращают затраченное время:
    - Сколько задача находилась в работе (ready_for_review минус in_progress ).
    - Сколько задача находилась на тестировании (done минус ready_for_review).
    Для тестировани этого задания, добален в конец скрипта инициализации базы данных data.sql 3 записи в таблицу ACTIVITY
    insert into ACTIVITY ( ID, AUTHOR_ID, TASK_ID, UPDATED, STATUS_CODE ) values ...
    Со статусами:
        - время начала работы над задачей – in_progress
        - время окончания разработки - ready_for_review
        - время конца тестирования - done

    Основной функционал добавлен в ```src/main/java/com/javarush/jira/bugtracking/task/ActivityService.java```.

    Для тестирования был добавлен функционал в ```src/main/java/com/javarush/jira/bugtracking/task/TaskController.java``` через **Swagger API** ```GET /{id}/activities```. 

9. Написать Dockerfile для основного сервера

10. Написать docker-compose файл для запуска контейнера сервера вместе с БД и nginx. Для nginx используй конфиг-файл config/nginx.conf. При необходимости файл конфига можно редактировать. 

    Попытки создать, но под сомнение сделанные шаги, т.к. БД была пустой при запуске контейнера. Т.е. авторизация не проходила, т.к. таблица users была пустой.

    Для сборки команда ```docker-compose build```, для запуска ```docker-compose up -d``` из папки с файлом ```docker-compose```. Предварительно проект собрать через **maven**, чтобы была папка *targer*.
12. Добавить локализацию минимум на двух языках для шаблонов писем (mails) и стартовой страницы index.html.

    Добавлены русский и английский язык для mails/index/header.
