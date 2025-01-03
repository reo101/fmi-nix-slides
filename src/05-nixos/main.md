# NixOS

## Преговор

Миналата седмица писахме деривации с mkDerivation

## Ситуацията в момента

- За сега използваме nix само като допълнителна програма към вече съществуваща система
- Nix е пакетен мениджър, та не можем ли да премахнем вградения и да оставим само никс?
- Можем! До това се свежда NixOS
- Обаче ...

## Проблемът който се поражда

Трябва ни някакво глобално състояние!

- Твърде е неудобно да имаме само един прост шел и за всяко нещо да трябва да викаме `nix-shell`.
- Нужно е по-сложно reproducible състояние, което да е стабилно между включвания.
  Не може да направим локални състояния, да рестартираме и да ги загубим.
- За хардуер трябва да конфигурираме драйвъри, което рядко може да стане само на ниво shell
- Daemons (сървиси) няма как да се изпълнят само на ниво shell

## Системата като една деривация

Решението е изненадващо просто:

- Цялата система е една деривация със специализиран builder, съдържаща всички глобални файлове, нужни за системата
- За всяко нещо се правят символични връзки (shortcut) от локации в хард-диска и `/nix/store`
- Изключение праим при bootloader-а, където просто добавяме нова опция

---

Това ни дава някои интересни сили:

- Можем да имаме няколко версии на системата, и да избираме при включване коя искаме
- Лесно можем да разпространяваме конфигурацията
- Лесно можем да направим виртуална машина за дадена система

---

И поражда някои важни проблеми:

- Една система ще има **много** nix код в себе си, твърде много да очакваме потребителя сам да поддържа
- Трудно е да включваме/излключваме/презаписваме стойности, голямото количество код прави промените сложни

## Модули

- Всички тези проблеми са решени чрез модулната система на Nixpkgs
- Това е библиотека, т.е. всичко е имплементирано чрез Nix
- С един модул дефинираме конфигурационни опции и нещата които се случват когато дадем стойност на опция

---

- Модул е функция, приемаща attrset и връщаща attrset
- Върнатия attrset има 3 задължителни атрибута
  - `imports`, списък с пътища към други модули
  - `options`, възможните опции; имена и типове на аргументите
  - `config`, конкретните стойности на чужди опции, спрямо или не избраните опции за тукашния модул
- Входния има следните атрибути:
  - `pkgs`, всички пакети в системата (nixpkgs)
  - `lib`, което е същото като `pkgs.lib`
  - `options`, всички дефинирани опции във всички модули
  - `config`, финалните конфигурационни опции в системата (като няма бездънни рекурсии)

## Опции

- модулната система е **библиотека** в Nixpkgs
- опциите са просто едни attrset-ове (в Nix нямаме статично типизиране)
- конкретните им стойности са просто атрибути със стойности
- функции в библиотеката *експлицитно* правят проверки между опциите които сме декларирали и стойностите, които са дадени

---

- Имаме "вградени" модули, които предоставят опции
- Почти винаги конкретните стойности са върху вградените модули или модули, надграждащи ги
- Фундаментално всичко се свежда до дервации, примерно systemd модулът при създаване на сървис извиква функцията за деривация `runCommand`
  https://github.com/NixOS/nixpkgs/blob/master/nixos/lib/systemd-lib.nix#L66-L91

## Деклариране на опции

- Основната функция за целта е `lib.mkOption`
- Главно приема тип и описание (името се определя от атрибута под `options` в който се записва)
- Някои от по-често използваните типове са: `bool`, `int`, `str`, `package` (деривация), `listOf TYPE`

### mkOption

```
optionName = mkOption {
    type = lib.types.x;
    default = ...;
    example = ...;
    description = "Hello World";
};
```

---

< ДЕМО където се създават една камара модули с по няколко и простички опции >

## Входни опции и конфигурации

- Казахме, че входния attrset приема `options` и `config`, които съответно съдържат всички декларации на опции в системата и финалните стойности на всички конфигурации
- Първото става сравнително лесно: обикаляш из всички модули, събираш опциите на едно място
- Второто как изобщо е възможно?
- Една подсказка, е че то не се справя с бездънни рекурсии, т.е. при това ще получим грешка:

```
{ config, ... }: {
    config.x = config.x + 1;
}
```

---

- Начинът е `fix` функцията, която "намира" фиксирана точка, тоест връща стойност която е същата като входа
- Идва от факта, че Nix е функционален и **lazy evaluated**
- attrset, списъци и функции могат да бъдат lazy evaluated, тоест
  - при индексиране в attrset или списък, можем да достъпим съответния елемент **без** да заредим останалите елементи в паметта
  - функции няма да се изпълнят, ако накрая не използваме техния резултат
- Детайлите на какво се случва ще разгледаме в края на курса
- По-повърхностно, можем да си го представим като обобщение на `rec` attrset-овете

---

< ДЕМОта с по-сложни модули, примери за полезни употреби на config и options >

## Нека да си направим NixOS машина

< ДЕМО как да направим minimal configuration, без flake-ове, и този configuration го пускаме като виртуална машина >

## Променяне на pkgs

- Работейки с цяла Nix система често поражда нуждата за още една функционалност: променяне на nixpkgs
- Може да се нуждаем от лични пакети (деривации) като "wallpaper-collection-1" и "wallpaper-collection-2", които нямат място в публичния nixpkgs
- Може да се нуждаем от специфични промени по пакети, примерно да добавяме patch-ове или да компилираме съществуващи пакети с други флагове
- Това се разрешава от overlay "библиотеката" (вградено в nixpkgs)

## Overlay

- Един overlay е функция, "приемаща" два аргумента - `final` и `prev` и връщаща attrset който ще се използва за обновяване на pkgs
- `final` е pkgs със този overlay сложен (отново `fix` функцията), докато `prev` е pkgs без него
- Логиката се свежда до `pkgs = pkgs // (my_overlay final prev)`

### Пример

```
final: prev: {
   google-chrome = prev.google-chrome.override {
     commandLineArgs =
       "--proxy-server='https=127.0.0.1:3128;http=127.0.0.1:3128'";
   };
};
```

---

< ДЕМО с някои практични примери >
