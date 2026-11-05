ROBO RUN — мобильный 3D-платформер (мидтерм)
=============================================

Движок: Godot Engine 4.7 (Steam), рендер Mobile, язык GDScript.
Путь: B — 3D, персонаж от третьего лица.

Структура игры
  Главное меню -> Уровень 1 (обучение) -> Уровень 2 (сложнее) -> Уровень 3 (босс «Каменный король») -> Экран победы -> меню.
  Смерть (0 HP или падение с острова) перезапускает текущий уровень.
  Выход с уровня (портал) открывается, когда собраны все монеты.

Управление
  Клавиатура: WASD / стрелки — бег, Пробел — прыжок, ЛКМ или X — выстрел, ПКМ + мышь — камера, Esc — пауза.
  Телефон: стик слева, кнопки JUMP / FIRE справа, «II» — пауза, перетаскивание пальцем — камера.

Где какая тема курса
  A4 Физика: RigidBody3D героя (scripts/player/player.gd), коллайдеры островов, триггеры монет/портала, урон от шипов при столкновении.
  A5 Анимация: AnimationTree героя Idle/Run/Jump + поворот по движению; клипы монет, сердец, портала, платформы, ловушек, врагов, босса.
  A6 Скрипты: стрельба с кулдауном (shooter.gd), спавн атак босса (boss.gd), корутина неуязвимости (health.gd),
               наследование Enemy -> PatrolBomb/Boss и Projectile -> Bullet/Fireball, Hazard -> Rock, смена сцен (game_manager.gd), звук (audio.gd).
  A7 Ввод: Input Map (move_*/jump/fire/pause), экранный стик и кнопки эмулируют геймпад (scripts/input/).

Ассеты и лицензии
  Робот (герой): «RobotExpressive» — Tomás Laulhé (Quaternius), CC0 1.0.
      Источник: https://github.com/mrdoob/three.js/tree/dev/examples/models/gltf/RobotExpressive
  Камень (босс, камни): «A Rock» — BenDelamore, CC-BY 4.0.
      https://sketchfab.com/3d-models/a-rock-c49139dbab5e4c498c225b56cca30466
  Бомба (враг-патрульный): «Comical Bomb» — XEN0KID, CC-BY 4.0.
      https://sketchfab.com/3d-models/comical-bomb-f979c611634b4cf3bd61a76bf97c1bb7
  Сердце (аптечка): «Heart in Love» — Azamuki, CC-BY 4.0.
      https://sketchfab.com/3d-models/heart-in-love-f39ce19b92e246268f4c501b72ea7d0e
  Шипы: «Spike Trap 01» — Nichgon, Sketchfab Standard License.
      https://sketchfab.com/3d-models/spike-trap-01-4022678cac214fd2963894aa152fc6f2
  Звуковые эффекты (audio/sfx): сгенерированы программно (синтез на Python), без сторонних источников.
  Музыка (audio/music/music.mp3): ДОПИСАТЬ — название, автор, источник, лицензия.
  Острова, монеты, портал, снаряды, интерфейс: встроенные примитивы и шрифт Godot.
