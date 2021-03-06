# Генератор оттисков поверительных и калибровочных клейм

[![Build status master](https://ci.appveyor.com/api/projects/status/github/Metrolog/marks?branch=master&svg=true)](https://ci.appveyor.com/project/sergey-s-betke/marks/branch/master)
[![Build status develop](https://ci.appveyor.com/api/projects/status/github/Metrolog/marks?branch=develop&svg=true)](https://ci.appveyor.com/project/sergey-s-betke/marks/branch/develop)
[![Build status](https://circleci.com/gh/Metrolog/marks/tree/master.svg?&style=shield&circle-token=7e53954cd6f7704d6897c3f8b21502e6d0e920d7)](https://circleci.com/gh/Metrolog/marks)

[![GitHub release](https://img.shields.io/github/release/Metrolog/marks.svg)](https://github.com/Metrolog/marks/releases)

[![Присоединиться к обсуждению на https://gitter.im/Metrolog/marks](https://badges.gitter.im/Metrolog/marks.svg)](https://gitter.im/Metrolog/marks?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

Данный проект - библиотека [PostScript][] функций и примеры сценариев для генерациии
цифрового негатива для производства полимерных клише для поверительных и
калибровочных клейм.

## Подготовка среды

Для внесения изменений в пакет и повторной сборки проекта потребуются следующие продукты:

Под Windows:

- [make][] версии 3.82 или старше (под [CygWin][], [MSYS2][])
- [m4][]
- [iconv][]
- [GhostScript][]
- текстовый редактор, настоятельно рекомендую [VSCode][]

Под Linux:

- [make][] версии 3.82 или старше
- [m4][]
- [iconv][]
- [PowerShellCore][]
- [GhostScript][]
- [VSCode][]

Для [VSCode][] рекомендую установить расширения, указанные в рабочей области.

Существенно удобнее будет работать с репозиторием, имея установленный `git`.

Далее следует скопировать репозиторий проекта либо как zip архив из [последнего
релиза](https://github.com/Metrolog/marks/releases), либо клонировав git репозиторий.
Последнее - предпочтительнее.

Для подготовки среды (установки необходимых приложений)
следует воспользоваться сценарием `install.ps1` (запускать от имени администратора):

    install\install.ps1 -Scope Machine -GUI -Verbose

либо

    install\install.cmd

Указанный сценарий установит все необходимые компоненты.

Для интерактивного контроля процесса установки можно использовать параметр `-Confirm`:

    install\install.ps1 -Scope Machine -GUI -Verbose -Confirm

Указанный параметр вынуждает сценарий перед внесением любых изменений запрашивать
подтверждение у пользователя.

Для дальнейшей работы необходимо включить в переменную `PATH`
каталоги с исполняемыми файлами установленных средств.
Если Вы работаете не под учётной записью администратора, тогда Вам так же
потребуется выполнить `install.ps1` для изменения переменной окружения `PATH` для
Вашей учётной записи:

    install\install.ps1 -Scope User -Verbose

либо

    install\install_for_user.cmd

## Сборка проекта

Сборка проекта осуществляется следующим образом:

    make

либо

    make all

Для доступа к справке по целям `make`:

    make help

## Внесение изменений

Репозиторий проекта размещён по адресу [github.com/Metrolog/marks](https://github.com/Metrolog/marks).
Стратегия ветвления - Git Flow.

При необходимости внесения изменений в сам проект предложите Pull Request в основной
репозиторий в ветку `develop`.

## Подготовка фотошаблона для изготовления полимерных клише для клейм

### Подготовка сценария генерации оттисков

Собственно PostScript файл должен быть сохранён в кодировке Windows-1251.

Для подготовки файла с оттисками клейм для фотовывода
[файл примера](stamps/tests/pdf/4.1.ps) следует скопировать в папку
stamps/sources (папку sources необходимо создать) и назвать по имени заказа
(в имени файлов не допускаются пробелы, только латинские буквы и цифры, знаки пунктуации.)
После чего запускаем редактор ([VSCode][]) и вносим изменения в область, отмеченную комментариями:

    %------------------------------------------------------------------------------
    % для подготовки оттисков править код ниже !!!
    %------------------------------------------------------------------------------
      [
          2017
          [ [ 3 ] quarters ]
          (СП)
          [ 1 256 range ]
          18.0 mm
          false                  % поверка в эксплуатации или после ремонта
          /verification_stamp_upath
        /csm-marks /ProcSet findresource /create_stamps get exec
      ]
      /boxes /ProcSet findresource /GetPageBBox get exec
      2 mm
    /graphics-alignments /ProcSet findresource /align_upaths_in_BBox get exec
    %------------------------------------------------------------------------------
    % конец области для кода генерации оттисков
    %------------------------------------------------------------------------------

Приведённый выше фрагмент - для генерации оттисков поверительных клейм.
Допустимо в одном файле смешивать и поверительные, и калибровочные клейма:

      [
          2017
          [ [ 3 ] quarters ]
          (СП)
          [ 1 256 range ]
          18.0 mm
          false                  % поверка в эксплуатации или после ремонта
          /verification_stamp_upath
        /csm-marks /ProcSet findresource /create_stamps get exec
          2017
          [ [ 1 12  range ] months  [ 1 4 range ] quarters year ]
          (СП)
          [ 1 ]
          18.0 mm
          true                   % при выпуске из производства
          /calibration_stamp_upath
        /csm-marks /ProcSet findresource /create_stamps get exec
      ]
      /boxes /ProcSet findresource /GetPageBBox get exec
      2 mm
    /graphics-alignments /ProcSet findresource /align_upaths_in_BBox get exec

Выше приведён пример, генерирующий поверительные клейма
на 3ий квартал 2017 года, с шифром поверительного клейма "СП",
диаметром 18 мм, для индивидуальных знаков поверителя от 1 до 256.
А так же - квадратные калибровочные клейма
на все месяцы, кварталы и год 2017 года, с шифром клейма "СП",
размером 18 мм, для индивидуального знака поверителя с номером 1.

В целях совместимости с последующими версиями лучше передавать параметры в словаре:

      [
          <<
            /year 2017
            /period % [ [ 1 2  3 6 range  10 ] months  [ 1 4 range ] quarters ]
              [ [ 3 ] quarters ]
            /id (СП)
            /sign [ 1 256 range ]
            /functor /verification_stamp_upath
          >>
        /csm-marks /ProcSet findresource /create_stamps get exec
      ]
      /boxes /ProcSet findresource /GetPageBBox get exec
      2 mm
    /graphics-alignments /ProcSet findresource /align_upaths_in_BBox get exec

Примеры для подготовки оттисков калибровочных клейм, фигурных клейм,
можно найти в [других тестовых файлах](stamps/tests/).

Раскладка на листе выполняется автоматически,
разбиение на страницы - так же.

При раскладке анализируются:

- форма оттиска (на текущий момент определяется только
  круглая форма)
- размеры оттисков

Используется раскладка в строки.
Если возможна оптимизация при шахматной раскладке -
используется шахматная раскладка. Она будет использована
в следующих случаях:

- в двух соседних строках все оттиски одного размера
- и все - одинаковой формы, поддерживающей шахматную раскладку
  (на сегодня - только круглая форма поддерживает).

Если хотя бы одно из условий не выполняется - используется
раскладка в строки.

#### Параметры сценария генерации оттисков

Как видно, при передаче параметров через словарь некоторые параметры указывать не обязательно.
При этом используются значения по умолчанию.

##### Год клейма

`/year` - целое число в пределах от 2000 до 2099, год клейма.

##### Период клейма

`/period` - период клейма (месяц, квартал, год).

Если требуется только годовое клеймо, укажите:

    [ year ]

Для конкретного квартала:

    [ [ 3 ] quarters ]

Для нескольких кварталов:

    [ [ 1 2 3 ] quarters ]

Либо то же самое, но - диапазоном:

    [ [ 1 3 range ] quarters ]

Аналогично для месяцев:

    [ [ 1 ] months ]
    [ [ 1 2 3  7 8 9 10 11 12 ] months ]
    [ [ 1 3 range 7 12 range ] months ]

А теперь - для месяцев, кварталов и года вместе:

    [ [ 1 12  range ] months  [ 1 4 range ] quarters year ]

По умолчанию - годовое клеймо.

##### Шифр клейма

`/id` - шифр клейма.

##### Знак поверителя / калибровщика

`/sign` - номер знака поверителя / калибровщика.

Перечисляем номера:

    [ 1 2 3 4 5 6 7 10 256 ]

Либо то же самое, используя диапазоны:

    [ 1 7 range 10 256]

По умолчанию - `0` (клеймо без знака).

##### Размер клейма

`/size` - размер клейма, по умолчанию - 18 мм.

##### Вид поверки

`/is_for_production` - логический:

- `true` - клеймо для поверки при выпуске из производства
- `false` - для периодической поверки

По умолчанию - `true`.

##### Генератор оттиска клейма

`/functor` - генератор оттиска знака:

- `/verification_stamp_upath` - поверительное клеймо
- `/verification_stamp_rhombus_upath` - ромбовидное ударное поверительное клеймо
- `/calibration_stamp_upath` - калибровочное клеймо

По умолчанию - `/verification_stamp_upath` (поверительное клеймо).

### Дополнительные параметры генератора оттисков

При необходимости дополнительной настройки генератора оттисков следует использовать
следующий фрагмент кода:

    %%BeginSetup
    <<
      /MirrorPrint true
      /NegativePrint true
    >> /csm-marks-params /ProcSet findresource /setmarksparams get exec
    %%EndSetup

Приведённые выше фрагмент включает генерацию файла в негативе и с зеркальным отражением оттисков.

Поддерживаемые параметры:

- `MirrorPrint`: `true`, `false`. Включает (`true`) или отключает (по умолчанию `false`)
  зеркальное отображение оттисков
- `NegativePrint`: `true`, `false`. Включает (`true`) или отключает (по умолчанию `false`)
  вывод оттисков в негативе

### Заключительные рекомендации

Для каждого заказа рекомендую создавать отдельный postscript файл.

Для преобразования .ps файлов в .pdf следует выполнить

    make

из корневого каталога репозитория проекта.
Файлы будут .pdf будут созданы в каталоге stamps/release.

## Пакетная подготовка индивидуальных изображений клейм

Возможность пакетной генерации файлов обеспечена начиная с версии 2.3.

### Подготовка сценария пакетной генерации файлов изображений клейм

Для каждого заказа необходимо готовить отдельный makefile.
Для подготовки сценария пакетной генерации следует скопировать
[файл примера](stamps/tests/mf/test_SP_2018_v.mk)
в папку stamps/sources (папку sources необходимо создать)
и назвать по имени заказа.

Ниже приведён полный текст файла сценария:

    #!/usr/bin/make

    ifndef __itg_stamps_included
    $(error Do not run this file directly. Run 'Makefile' in root project folder.)
    endif

    # разрешение генерируемых файлов, dpi. По умолчанию - 2400.
    STAMPS_DPI     := 1200
    # зеркальный вывод. По умолчанию - $(false).
    STAMPS_MIRROR  := $(true)
    # негативный вывод. По умолчанию - $(false).
    STAMPS_NEGATIVE:= $(true)

    STAMPS_YEAR    := 2018
    STAMPS_ID      := СП
    STAMPS_PERIODS := $(call months,$(call range,1,12)) $(call quarters,$(call range,1,4)) $(call year)
    STAMPS_SIGNS   := $(call range,1,2)
    STAMPS_SIZE    := 18 mm
    STAMPS_VARIANT := 1
    # тип клейма
    # для калибровочного клейма
    # STAMPS_TYPE  := calibration_stamp
    # для поверительного клейма
    STAMPS_TYPE    := verification_stamp
    # для поверительного фигурного клейма
    # STAMPS_TYPE  := verification_stamp_rhombus

Выше приведён пример, генерирующий все месячные, квартальные и годовые поверительные клейма
2018 года, с шифром поверительного клейма "СП",
диаметром 18 мм, для индивидуальных знаков поверителя от 1 до 2.

#### Параметры сценария пакетной генерации оттисков

##### Год клейма (в пакетном режиме)

`STAMPS_YEAR` - целое число в пределах от 2000 до 2099, год клейма.

##### Период клейма (в пакетном режиме)

`STAMPS_PERIODS` - период клейма (месяц, квартал, год).

Если требуется только годовое клеймо, укажите:

    $(call year)

Для конкретного квартала:

    $(call quarters,3)

Для нескольких кварталов:

    $(call quarters,1 2 3)

Либо то же самое, но - диапазоном:

    $(call quarters,$(call range,1,3))
    [ [ 1 3 range ] quarters ]

Аналогично для месяцев:

    $(call months,1)
    $(call months,1 2 3  7 8 9 10 11 12)
    $(call months,$(call range,1,3) $(call range,7,12))

А теперь - для месяцев, кварталов и года вместе:

    $(call months,$(call range,1,12)) $(call quarters,$(call range,1,4)) $(call year)

По умолчанию - годовое клеймо.

##### Шифр клейма (в пакетном режиме)

`STAMPS_ID` - шифр клейма.

##### Знак поверителя / калибровщика (в пакетном режиме)

`STAMPS_SIGNS` - номер знака поверителя / калибровщика.

Перечисляем номера:

    1 2 3 4 5 6 7 10 256

Либо то же самое, используя диапазоны:

    $(call range,1,7) 10 256

По умолчанию - `0` (клеймо без знака).

##### Размер клейма (в пакетном режиме)

`STAMPS_SIZE` - размер клейма, по умолчанию - 18 мм.

##### Вид поверки (в пакетном режиме)

`STAMPS_VARIANT`:

- `1` - клеймо для поверки при выпуске из производства
- `2` - для периодической поверки

По умолчанию - `2`.

##### Тип клейма (в пакетном режиме)

`STAMPS_TYPE` - генератор оттиска знака:

- `verification_stamp` - поверительное клеймо
- `verification_stamp_rhombus` - ромбовидное ударное поверительное клеймо
- `calibration_stamp` - калибровочное клеймо

По умолчанию - `verification_stamp` (поверительное клеймо).

### Дополнительные параметры генератора оттисков (в пакетном режиме)

При необходимости дополнительной настройки генератора оттисков следует использовать
следующий фрагмент кода:

    STAMPS_DPI     := 1200
    STAMPS_MIRROR  := $(true)
    STAMPS_NEGATIVE:= $(true)

Приведённые выше фрагмент включает генерацию файла в негативе и с зеркальным отражением оттисков.

Поддерживаемые параметры:

- `STAMPS_DPI`: разрешение (в точках на дюйм). По умолчанию - 2400 dpi.
- `STAMPS_MIRROR`: `$(true)`, `$(false)`. Включает (`$(true)`) или отключает (по умолчанию `$(false)`)
  зеркальное отображение оттисков
- `STAMPS_NEGATIVE`: `$(true)`, `$(false)`. Включает (`$(true)`) или отключает (по умолчанию `$(false)`)
  вывод оттисков в негативе

### Форматы генерируемых в пакетном режиме графических файлов

Поддерживается генерация:

- .pcx ([PCX](https://ru.wikipedia.org/wiki/PCX "PCExchange"))
- .tif ([TIFF](https://ru.wikipedia.org/wiki/TIFF "Tagged Image File Format"))
- .png ([PNG](https://ru.wikipedia.org/wiki/PNG "Portable Network Graphics"))
- .bmp ([BMP](https://ru.wikipedia.org/wiki/BMP "Bitmap Picture"))

По умолчанию генерируются файлы всех типов. Можно указать необходимые типы файлов:

    make all MFSTAMPSFORMATS='pcx tif'

Например, для генерации только TIFF файлов:

    make all MFSTAMPSFORMATS='tif'

### Заключительные рекомендации (для пакетного режима)

Для каждого заказа рекомендую создавать отдельный файл.
Кроме того, в пакетном режиме нельзя смешивать разные типы оттисков
(поверительные, калибровочные и т.д.),
для каждого типа оттисков необходимого готовить отдельные файлы.

## Благодарности

- [Илья Никуленко](mailto:nikulenko_iliy@rambler.ru): при подготовке знаков
  поверителей в формате Type 3 использованы в качестве основы файлы
  True Type шрифта ГОСТ 2930-62, подготовленные Ильёй Никуленко.

## Лицензионное соглашение

Полный текст лицензионного соглашения приведён в файле [LICENSE](LICENSE).

[PostScript]: https://ru.wikipedia.org/wiki/PostScript
[PostScript Language reference manual]: http://wwwimages.adobe.com/content/dam/Adobe/en/devnet/postscript/pdfs/psrefman.pdf
[CygWin]: http://cygwin.com/install.html
[MinGW]: http://mingw-w64.org
[MSYS2]: http://www.msys2.org
[make]: https://www.gnu.org/software/make
[m4]: https://www.gnu.org/software/m4
[iconv]: https://ru.wikipedia.org/wiki/Iconv
[GhostScript]: https://www.ghostscript.com/
[VSCode]: https://code.visualstudio.com/ "Visual Studio Code"
[PowerShellCore]: https://github.com/PowerShell/PowerShell "PowerShell Core"
