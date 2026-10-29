# Установка и запуск

## 1. Компоненты

Нужна Windows x64 с .NET Framework 4.8 и Microsoft SQL Server Express LocalDB. На Windows 10/11 .NET Framework обычно уже установлен. LocalDB устанавливается отдельным компонентом SQL Server Express либо вместе с Visual Studio (компонент SQL Server Express LocalDB).

Проверка LocalDB в PowerShell:

```powershell
& 'C:\Program Files\Microsoft SQL Server\160\Tools\Binn\SqlLocalDB.exe' info
```

Путь `160` соответствует SQL Server 2022. Для другой версии используйте путь к установленному `SqlLocalDB.exe`.

## 2. Запуск готового приложения

1. Распакуйте или клонируйте весь проект в отдельную папку.
2. Запустите `Launch.cmd`.
3. Дождитесь создания и импорта базы `FlowerParadise`.
4. Откроется каталог. Для входа нажмите «Войти по логину» и введите, например, `morlov`.

При повторном запуске база не перезаписывается. Инициализатор проверяет версию схемы. Если в выбранной базе уже есть другие таблицы, он отказывается её изменять: выберите новое имя базы.

Не запускайте EXE изнутри ZIP-архива. Папка `Assets` и `FlowerParadise.exe.config` должны находиться рядом с EXE.

## 3. Подготовка базы вручную

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\Initialize-Database.ps1
```

Для SQL Server Express/Developer:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\Initialize-Database.ps1 -Server '.\SQLEXPRESS' -Database FlowerParadise
```

После этого укажите тот же сервер и имя базы в `FlowerParadise.exe.config`:

```xml
<add name="FlowerParadise"
     connectionString="Data Source=.\SQLEXPRESS;Initial Catalog=FlowerParadise;Integrated Security=True;Connect Timeout=15"
     providerName="System.Data.SqlClient"/>
```

Альтернатива — открыть `database/database_with_data.sql` в SQL Server Management Studio и выполнить на пустой базе. Полный скрипт предназначен для однократного запуска; повторный запуск выполняйте через инициализатор. Блоки `GO` должны выполняться отдельно, что SSMS делает автоматически.

При необходимости можно задать `FLOWERPARADISE_CONNECTION_STRING`. Инициализатор и приложение используют её вместо значения по умолчанию. Реальные учётные данные сервера не помещайте в репозиторий.

## 4. Сборка исходников

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\Build.ps1
```

Скрипт использует компилятор .NET Framework из Windows и создаёт `FlowerParadise.exe` в корне проекта. C# не требует внешних пакетов; XAML встроен в сборку.

Для Visual Studio откройте `FlowerParadise.sln`, выберите Debug или Release и соберите решение. EXE будет в `src/FlowerParadise/bin/Debug` или `bin/Release`; ресурсы и конфигурация копируются туда автоматически. Сама сборка решения не создаёт базу: перед первым запуском выполните инициализатор.

## 5. Проверки

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\Run-Tests.ps1
```

Проверки используют отдельную базу `FlowerParadiseVerification`, запускают настоящие операции MSSQL и WPF и сохраняют изображения интерфейса в `docs/screenshots/`. Для WPF нужна интерактивная сессия Windows.

## Возможные ошибки

| Ситуация | Действие |
|---|---|
| Сервер недоступен | Установить/запустить LocalDB или проверить имя экземпляра SQL Server |
| База не найдена | Запустить `Initialize-Database.ps1` с теми же сервером и именем базы, что в конфигурации |
| Нет изображений | Перенести папку `Assets` рядом с EXE |
| Не найден логин | Использовать логин из `source-data/Приложение 2/Users_import.xlsx`, без пароля |
| Другой пользователь изменяет данные | Повторить действие; конфликтующая транзакция откатывается |
| Недостаточно товара | Обновить каталог и уменьшить количество |
| Цена изменилась | Закрыть и повторно открыть корзину, чтобы увидеть текущие цены |
| База содержит посторонние таблицы | Выбрать новую пустую базу; существующие данные не удаляются |
