# VideoSearch

server/www 

- ErrorCodes.php файл для обработки ошибок а так же формирования текста из айди ошибки 
- JOSN_.php не используется 
- Server.php файл который создает соединение и отправляет запросы в базу 
- UserAPI класс который осуществляет запросы а так же получение токенов пользователей 
- autorize.php файл который получает данные из OAUTh о авторизации 
- ffmpeg.exe это ffmpeg для серверов работающих на windows 
- m.php файл который автоматически добавляет инклайд классов php которые используются в процессе работы 
- process.php файл который должен запускать крон раз в минуту для анализа данных из uploads
- resource.php OUATH запрос на получение авторизации
- token.php получение токенов из OAUTH
- videoSearch.php это класс который реализует АПИ доступа к базе данных 

коментарии раставленны в videoSearch и в process.php остальные классы это просто вспомогательные классы для работы с базой данных 

клиентская часть только отправляет данные с локального устройства на сервер 
коментарии и логика находятся в файле VideoSearch/VideoSearch/ViewController.m 