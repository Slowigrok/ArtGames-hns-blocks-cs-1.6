# Art Games | HnS Blocks source codes
Исходный код плагинов, которые были использованы на игровых серверах Art Games hns blocks и Favourite Games hns blocks. 

Где-то в период выхода CS:GO плагины активно дорабатывались и подготавливались к запуску нового проекта — Scream Gaming, однако его выход в свет так и не состоялся. 

## Описание содержимого
### Blockmaker (Art Games Course Maker)
Изначально использовался _VCM_, все модификации были добавлены в него.

Доступные команды:<br>
/bm (в чат) — открывает меню блокмейкера<br>
/vote (в чат) — голосование за смену постройки<br>
/stop_vote (в чат) — отменяет голосование<br>

#### Нововведения:
1. Кроме стандартных возможностей в блокмейкере есть поддержка выбора режима игры. 
Постройки сохраняются для каждого режима игры по отдельности.
После смены карты начинается голосование за выбор режима игры, а также за постройки в этом режиме.
Дополнительно присутствует голосование за смену постройки (и режима игры) на той же карте.
2. Дополнительные возможности для блоков, среди которых: 
   - задание цвета, свечения и прозрачности блокам;
   - добавление скорости блокам (чтобы они могли двигаться, дистанция перемещения также регулируется);
   - задание вращения (rotate с интервалом);
   - skip menu — устанавливает блокам таймеры, через которые они пропадают на некоторое время (таким образом позваляет бороться с игроками, которые залезают на постройки и сидят там до победного).
3. Добавлены некоторые новые блоки (типа random).
   
#### Список блоков:
Platform<br>
Bunnyhop<br>
Damage<br>
Healer<br>
No Fall Damage<br>
Ice<br>
Trampoline<br>
Speed Boost<br>
Death<br>
Low Gravity<br>
Slap<br>
Honey<br>
CT Barrier<br>
T Barrier<br>
Vip Barrier<br>
No Slow Down Bunnyhop<br>
Delayed Bunnyhop<br>
Bunnyhop Damage<br>
Invincibility<br>
Stealth<br>
Boots of Speed<br>
Camouflage<br>
Nades<br>
Weapon<br>
Weapon chance<br>
Music<br>
Double Duck<br>
Blind Trap<br>
Earthquake<br>
Magic Carpet<br>
Point Block<br>
Random Block<br>

### Pointmod (Art Games Mode)
Плагин для прокачки игроков на сервере, базировался на поинтмоде by StepZeN & Recon.

Доступные команды:<br>
/pm, /agm, /xp (в чат) — открыть меню прокачки<br>
/top, /top15 (в чат) — отображает список игроков, набравших наибольшее количество поинтов<br>
/reset (в чат) — сбрасывает все прокачки

agm_give_point — дать поинты игроку<br>
agm_remove_point — удалить поинты у игрока<br>
agm_reset_point — сброс всех прокачек и поинтов у игрока
agm_change_upgrade — изменяет прокачки у игроков

#### Новведения
~~Когда-нибудь приложу скриншоты~~
1. Измененное меню прокачек.
2. Меню передачи поинтов.
3. Новые прокачки, связанные с blockmaker.

#### Последние изменения
1. Добавлено Knives меню.
2. Добавлен ранговый VIP (по умолчанию меняется каждый месяц)

#### Список прокачек
Extra Health<br>
Extra Armor<br>
Respawn Chance<br>
Fall Damage Reducer<br>
Auto Health<br>
Extra Damage<br>
Mega Weapon Chance<br>
Chance Large Points<br>
Extra Jokes Time<br>
Extra Jokes Chance<br>
No Footsteps<br>
Anti-Flash<br>
No Pain Shock<br>
Anti-Frost<br>

Описание некоторых из них:
Auto Healt — восстановление части здоровья при падении
Mega Weapon Chance — дополнительный шанс на оружие для weapon chance block
Chance Large Points — шанс получения двойных поинтов на поинт блоке
Extra Jokes Chance — шанс на увеличение времени невидимости/неуязвимости/ускорения и т.п. на блоках
Extra Jokes Time — количество времени, на которое они увеличиваются

#### Список ножей
Swap Knife +<br>
Ninja Knife +<br>
Fast Blade +<br>
Flash Blade +<br>
Poison Sting +<br>
Push Blade _в процессе_<br>
Titan Blade *не готово*<br>
Fire Knife *не готово*<br>
Frost Knife _в процессе_<br>
Thunder Knife +<br>
Vampire Blade *не готово*<br>
Reflect Blade *не готово*<br>
Standart Knife <br>

### Серверные квары:
agm_pnum (AGM, AGCM) — минимальное количество игроков, необходимое для того, чтобы игроки зарабатывали поинты<br>
agm_status (AGM, AGCM) — режим игры (1 — Knives, 2 — Points, 3 — Weapons, 4 — Classic)<br>

agm_kills_points (AGM) — количество поинтов, которое игроки получают за убийство<br>
agm_deaths_points (AGM) — количество поинтов, которое игроки теряют за смерть от руки противника<br>
agm_suicides_points (AGM) — количество поинтов, которое игроки теряют за самоубийство<br>

### Другие плагины:
1. vips — команды /vips, /admins, префиксы для чата
2. vips_models
3. konkurs_menu — использовалось для проведения конкурсов на поинты: сохранения, годмоды, респауны
4. uq_jumpstats — небольшое расширение для добавления поинтов игрокам за прыжки (LJ > 250 и т.п.)
5. autoheal — восстановление хп при падении (с добавлением функций из поинтмода)
6. frostnades — замораживающая граната (с добавлением функций из блокмейкера)
7. hidenseek — hns mod (с функциями из бм)
8. head_splash (с функциями из пм)

### Прочее
В папке _data/AG_ находятся постройки.
