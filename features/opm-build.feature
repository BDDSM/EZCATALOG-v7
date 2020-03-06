# language: ru

Функционал: Проверка сборки продукта
    Как Пользователь
    Я хочу автоматически проверять сборку моего продукта
    Чтобы гарантировать возможность установку моего продукта у пользователей

Контекст: Отключение отладки в логах
    Допустим Я выключаю отладку лога с именем "oscript.lib.commands"
    И Я очищаю параметры команды "opm" в контексте

Сценарий: Выполнение команды без параметров
    Когда Я добавляю параметр "build ." для команды "opm"
    И Я выполняю команду "opm"
    Тогда Вывод команды "opm" содержит "Сборка пакета завершена"
    И Вывод команды "opm" не содержит "Внешнее исключение"
    И Код возврата команды "opm" равен 0